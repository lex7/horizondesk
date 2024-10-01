import json
import random
import requests
from datetime import datetime, timedelta

# Authorization endpoint
login_url = 'http://localhost:8000/login'

# API endpoint
url = 'http://localhost:8000/create-request'

# Credentials for authentication
username = 'admin'
password = '1234'

# Get auth token from /login
response = requests.post(login_url, json={'username': username, 'password': password})
if response.status_code == 200:
    auth_token = response.json()['access_token']
else:
    print(f"Failed to get auth token with status code: {response.status_code} and response: {response.text}")
    exit(1)

# Get list of users from /users endpoint, exclude user_id = 1
users_url = 'http://localhost:8000/users'
response = requests.get(users_url, headers={'Authorization': f'Bearer {auth_token}'})
if response.status_code == 200:
    users = [user['user_id'] for user in response.json() if user['user_id'] != 1]
else:
    print(f"Failed to get users with status code: {response.status_code} and response: {response.text}")
    exit(1)

def random_datetime():
    start_date = datetime.now() - timedelta(days=90)
    end_date = datetime.now()
    delta = end_date - start_date
    random_days = random.randrange(delta.days + 1)
    random_time = timedelta(seconds=random.randrange(86400))  # random time within a day
    return (start_date + timedelta(days=random_days) + random_time).isoformat() + 'Z'

# Function to send a POST request using requests
def send_request(issue):
    created_at = random_datetime()
    random_user_id = random.choice(users)  # Select a random user from the users list
    payload = {
        "request_type": issue['request_type'],
        "user_id": random_user_id,  # Use the random user ID
        "area_id": issue['area_id'],
        "description": issue['description'],
        "created_at": created_at
    }

    headers = {
        'accept': 'application/json',
        'Authorization': f'Bearer {auth_token}',
        'Content-Type': 'application/json'
    }

    response = requests.post(url, headers=headers, json=payload)

    if response.status_code == 200:
        print(f"Request sent for user_id: {random_user_id} with response: {response.json()}")
    else:
        print(f"Failed to send request for user_id: {random_user_id} with status code: {response.status_code} and response: {response.text}")

# Read JSON file
with open('data/issues.json', 'r', encoding='utf-8') as file:
    issues = json.load(file)

# Loop through each issue and send request
for issue in issues:
    send_request(issue)
