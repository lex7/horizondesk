# Use the official Python image from the Docker Hub
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc

# Set the working directory in the container
WORKDIR /app

# Copy the application code into the container
COPY . .

# Copy the SSL certificate and key into the container
COPY selfsigned.crt /etc/ssl/certs/selfsigned.crt
COPY selfsigned.key /etc/ssl/private/selfsigned.key

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the ports for HTTP (80) and HTTPS (443)
EXPOSE 80
EXPOSE 443

# Command to run the application
CMD ["uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "443", "--ssl-keyfile", "/etc/ssl/private/selfsigned.key", "--ssl-certfile", "/etc/ssl/certs/selfsigned.crt"]
