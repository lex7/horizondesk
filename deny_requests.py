import json
import random
import requests
from datetime import datetime, timedelta

# Authorization endpoint
login_url = 'http://localhost:8000/login'

# API endpoint
url = 'http://localhost:8000'

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
users_url = f'{url}/users'
response = requests.get(users_url, headers={'Authorization': f'Bearer {auth_token}'})
if response.status_code == 200:
    users = [user['user_id'] for user in response.json() if user['user_id'] != 1]
    masters = [user['user_id'] for user in response.json() if user['user_id'] != 1 and user['role_id'] == 2]
else:
    print(f"Failed to get users with status code: {response.status_code} and response: {response.text}")
    exit(1)

# API endpoints
requests_url = f'{url}/requests'
deny_url = f'{url}/master-deny'

# Get all requests with status_id=1
def get_requests():
    headers = {
        'accept': 'application/json',
        'Authorization': f'Bearer {auth_token}'
    }
    response = requests.get(requests_url, headers=headers, verify=False)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to get requests. Status code: {response.status_code}")
        return []

# Deny the request
def deny_request(request_id, user_id, reason):
    headers = {
        'accept': 'application/json',
        'Authorization': f'Bearer {auth_token}',
        'Content-Type': 'application/json'
    }
    payload = {
        "request_id": request_id,
        "user_id": user_id,
        "reason": reason
    }
    response = requests.post(deny_url, headers=headers, json=payload, verify=False)
    if response.status_code == 200:
        print(f"Request {request_id} denied by user {user_id}")
    else:
        print(f"Failed to deny request {request_id}. Status code: {response.status_code}")

# Main logic
all_requests = get_requests()

# Filter requests with status_id=1
pending_requests = [req for req in all_requests if req.get('status_id') == 1]

# Sort requests by created_at in descending order (latest first)
pending_requests.sort(key=lambda req: datetime.strptime(req['created_at'], '%Y-%m-%dT%H:%M:%S'))

# Select 30% of the latest requests
num_requests = int(len(pending_requests) * 0.3)
selected_requests = pending_requests[:num_requests]

# Process each selected request
for request in selected_requests:
    request_id = request['request_id']
    
    # Step: Deny the request with a random master and reason 'не актуально'
    denier_user_id = random.choice(masters)
    deny_reason = 'не актуально'
    deny_request(request_id, denier_user_id, deny_reason)