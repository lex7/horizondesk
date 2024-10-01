import json
import requests

# URL of your FastAPI register endpoint
api_url = 'http://localhost:8000/register'  # Replace with your API URL if different

# Path to the user.json file
user_file = 'user.json'

# Read users from the user.json file
with open(user_file, 'r') as file:
    users = json.load(file)

# Iterate through each user and send a POST request to register
for user in users:
    try:
        response = requests.post(api_url, json=user)
        
        # Check if the request was successful
        if response.status_code == 200:
            print(f"User {user['username']} registered successfully.")
        else:
            print(f"Failed to register {user['username']}. Status code: {response.status_code}")
            print("Error detail:", response.json().get("detail"))
    
    except Exception as e:
        print(f"An error occurred while registering {user['username']}: {str(e)}")
