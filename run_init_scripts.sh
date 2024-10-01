#!/bin/bash

# Wait for the PostgreSQL database to be ready
echo "Waiting for PostgreSQL..."
while ! nc -z db 5432; do
  sleep 1
done
echo "PostgreSQL started."

# Execute the Python scripts in the correct order
echo "Running Python initialization scripts..."
python create_users.py
python create_requests.py
python update_requests.py
python deny_requests.py

echo "Initialization complete."
