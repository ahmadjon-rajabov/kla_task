# DockerHelper module for managing Docker containers

# Build-DockerImage function: Builds a Docker image from the given Docker file
function Build-DockerImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Dockerfile,            # Path to Dockerfile, (mandatory) 

        [Parameter(Mandatory=$true)]
        [string]$Tag,                   # Name for Docker Image (mandatory)

        [Parameter(Mandatory=$true)]
        [string]$Context,               # Path to build files (mandatory) 

        [Parameter(Mandatory=$false)]
        [string]$ComputerName           # Remote host name (optional)
    )

    Write-Host "Start to build docker image '$Tag' from Dockerfile '$Dockerfile' and python application '$Context'"

    # A script block to run the docker build 
    $scriptBlock = {
        param($Dockerfile, $Tag, $Context)
        Write-Host "docker build on local machine"
        docker build -t $Tag -f $Dockerfile $Context
    }

    # Check if the remote computer is specified
    if ($ComputerName) {
        # if yes, run the build on the remote machine
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $Dockerfile, $Tag, $Context
    } else {
        # if no, build locally
        & $scriptBlock $Dockerfile $Tag $Context
    }

    Write-Host "The Docker image build is complete"
}

# Copy-Prerequisites function: Copies files to a remote host
function Copy-Prerequisites {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,          # Remote host name (mandatory)

        [Parameter(Mandatory=$true)]    
        [string[]]$Path,                # Local paths to files/directories to copy (mandatory)

        [Parameter(Mandatory=$true)]
        [string]$Destination            # Local path on remote host (mandatory) 
    )

    Write-Host "Copying files to a remote host '$ComputerName' to destination '$Destination'"

    # Convert the local path to a UNC path to access the remote machine
    $uncDestination = "\\$ComputerName\$($Destination -replace ':', '$')"

    # Copy each element from the path array
    foreach ($item in $Path) {
        Write-Host "Copy '$item' to '$uncDestination'"
        Copy-Item -Path $item -Destination $uncDestination -Recurse -Force
    }

    Write-Host "Copying complete"
}

# Run-DockerContainer function: Runs a Docker container and returns its name
function Run-DockerContainer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ImageName,             # Docker image name, (madatory)

        [Parameter(Mandatory=$false)]
        [string]$ComputerName,          # Remote computer name (optional)

        [Parameter(Mandatory=$false)]
        [string[]]$DockerOptions = @(),  # Docker flags, e.g. ‘-d’ (optional)

        [Parameter(Mandatory=$false)]
        [string[]]$ContainerArgs = @()   # Arguments for container, e.g. ‘10’ (optional)
    )

    Write-Host "Starting a Docker container from an image '$ImageName'"

    # Script block to run the container
    $scriptBlock = {
        param($ImageName, $DockerOptions, $ContainerArgs)
        # Generate a unique container name
        $containerName = "container_$((New-Guid).ToString().Substring(0,8))"
        Write-Host "Container name: '$containerName'"
        
        # Build parameters for the docker run command
        $params = $DockerOptions + @("--name", $containerName, $ImageName) + $ContainerArgs
        Write-Host "Command to launch: docker run $($params -join ' ')"

        # Start the container and clear the standard output
        docker run @params > $null 2>&1

        return $containerName
    }

    # Check if the remote computer is defined
    if ($ComputerName) {
        Write-Host "Running the container on a remote host '$ComputerName'"
        # if yes, run on a remote machine 
        $containerName = Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $ImageName, $DockerOptions, $ContainerArgs
    } else {
        Write-Host "Running the container on the local machine"
        # if no, run locally
        $containerName = & $scriptBlock $ImageName $DockerOptions $ContainerArgs
    }

    Write-Host "Container '$containerName' is running"
    return $containerName
}