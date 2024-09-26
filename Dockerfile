# Use the official Python image from the Docker Hub
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc

# Set the working directory in the container
WORKDIR /app

# Copy project files
COPY . .

# Copy SSL certificates to the container
COPY selfsigned.crt /app/selfsigned.crt
COPY selfsigned.key /app/selfsigned.key

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run the application with HTTPS enabled
CMD ["uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "443", "--ssl-keyfile", "/app/selfsigned.key", "--ssl-certfile", "/app/selfsigned.crt"]
