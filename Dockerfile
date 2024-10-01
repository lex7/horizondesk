# Use the official Python image from the Docker Hub
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc

# Set the working directory in the container
WORKDIR /app

# Copy project files
COPY . .

# Copy the initialization scripts
COPY create_users.py /app/
COPY create_requests.py /app/
COPY update_requests.py /app/
COPY deny_requests.py /app/
COPY run_init_scripts.sh /app/

RUN chmod +x /app/run_init_scripts.sh

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run the application with HTTPS enabled
CMD ["uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "8000"]
