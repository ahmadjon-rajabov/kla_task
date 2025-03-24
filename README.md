### DockerHelper and Fibonacci Container
This task result are a PowerShell DockerHelper module for managing Docker images and containers, and an example of using this module to run a container that calculates and outputs Fibonacci numbers. The container supports two modes:
- Without parameter: outputs all Fibonacci numbers one every 0.5 seconds.
- With parameter n: outputs only the nth Fibonacci number.

### File structure
Consists of the following files:
1. DockerHelper.psm1: A PowerShell module containing functions for managing Docker images and containers.
    - Build-DockerImage: Builds a Docker image from the specified Dockerfile. Parameters:
        * $Dockerfile (mandatory): path to the Dockerfile.
        * $Tag (mandatory): the name (tag) for the image.
        * $Context (mandatory): path to the directory with the build files.
        * $ComputerName (optional): the name of the remote host for the build.
    - Copy-Prerequisites: Copies files and directories to the remote host using UNC paths. Parameters:
        * $ComputerName (mandatory): the name of the remote host.
        * $Path (mandatory): local paths to files/directories to copy.
        * $Destination (mandatory): the destination path on the remote host.
    - Run-DockerContainer: Runs a Docker container and returns its name. Parameters:
        * $ImageName (mandatory): the name of the Docker image.
        * $ComputerName (optional): the name of the remote host.
        * $DockerOptions (optional): Docker flags (for example, -d).
        * $ContainerArgs (optional): arguments for the container (for example, ‘10’).
2. Dockerfile: A file to build a Docker image that runs a Python script to calculate Fibonacci numbers.
    - Uses the python:3.8-slim base image to minimise size.
    - Sets up the /app working directory.
    - Copies fibonacci.py into a container.
    - Sets the entry point: python fibonacci.py.
3. fibonacci.py: Python script for calculating Fibonacci numbers.
    - With no arguments: outputs all Fibonacci numbers with a delay of 0.5 seconds.
    - With one argument n: outputs the nth Fibonacci number.
    - Handles input errors (e.g., non-numeric values).
4. README.md: This file containing the documentation of the project.

### Dependecies
- PowerShell: Version 5.1 or higher (including PowerShell 7.x).
- Docker: Installed and running on your machine.
- Python: Not required locally as it is used inside the container.

### Configuring the PowerShell module
Place the DockerHelper.psm1 file in the PowerShell module directory:
- Windows: `C:\Users\<YourUser>\Documents\WindowsPowerShell\Modules\DockerHelper`
- macOS/Linux: `~/Documents/PowerShell/Modules/DockerHelper`
- Import the module into PowerShell: `Import-Module DockerHelper`
- Prepare files for Docker. Create a working directory, such as `C:\DockerFibonacci` (Windows) or `~/DockerFibonacci` (macOS/Linux). Place Dockerfile and fibonacci.py in this directory.

### Usage 
Build a Docker image using the command:
```powershell
Build-DockerImage -Dockerfile "path/to/Dockerfile" -Tag "fibonacci" -Context "path/to/context"
```
- Dockerfile: The path to the Dockerfile.
- Tag: The name (tag) for the image.
- Context: The directory with the build files (for example, containing fibonacci.py).

Start the container using the command:
```powershell
$containerName = Run-DockerContainer -ImageName "<fibonacci>" -DockerOptions @("-d") -ContainerArgs @("10")
```
- ImageName: The name of the Docker image.
- DockerOptions: Docker flags (e.g. -d for background mode).
- ContainerArgs: Arguments for the container (e.g., ‘10’ for the 10th Fibonacci number).

Example without argument:
```powershell
Build-DockerImage -Dockerfile "C:\DockerFibonacci\Dockerfile" -Tag "fibonacci" -Context "C:\DockerFibonacci"
```

Start to build docker image 'fibonacci' from Dockerfile 'C:\DockerFibonacci\Dockerfile' and python application 'C:\DockerFibonacci'
...
The Docker image build is complete

```powershell
$containerName = Run-DockerContainer -ImageName "fibonacci" -DockerOptions @("-d")
Write-Host "Container started: $containerName"
```
Container started: container_abcdef12

```powershell
docker logs -f $containerName
```
0
1
1
2
3
...

Example with argument:
```powershell
$containerName = Run-DockerContainer -ImageName "fibonacci" -ContainerArgs @("10")
Write-Host "Container started: $containerName"
```
Container started: container_12345678

```
docker logs $containerName
```
55