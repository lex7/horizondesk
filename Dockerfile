# Use the official Python image from the Docker Hub
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc

# Set the working directory in the container
WORKDIR /app

# Copy the application code into the container
COPY . .


# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the ports for HTTP (80) and HTTPS (443)
EXPOSE 80
EXPOSE 443

# Command to run the application
CMD ["uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "443"]
