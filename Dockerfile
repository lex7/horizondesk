# Use the official Python image from the Docker Hub
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc

# Set the working directory in the container
WORKDIR /app

# Copy project files (this includes the Python scripts and shell script)
COPY . .

# Ensure the init script has execution permissions
RUN chmod +x /app/run_init_scripts.sh

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run the application
CMD ["uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "8000"]
