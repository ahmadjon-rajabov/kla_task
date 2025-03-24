# Using Python 3.8 slim base image to minimise size
FROM python:3.8-slim

# Set the working directory inside the container
WORKDIR /app

# Copied the fibonacci.py file to the working directory of the container
COPY fibonacci.py .

# Set the entry point to automatically run the script when the container starts up
ENTRYPOINT ["python", "fibonacci.py"]