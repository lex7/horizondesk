import json
import random
import requests
from datetime import datetime, timedelta
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Authorization token
auth_token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJUTUstSGVhbHRoQ2hlY2siLCJleHAiOjE3Mjc2MDcyMzh9.0IEJicCuligKuLfhtvCp0r0LTUuwADmEVskZ790MbYg'

# API endpoints
base_url = 'https://timofmax1.fvds.ru'
requests_url = f'{base_url}/requests'
deny_url = f'{base_url}/master-deny'

masters = [43, 42, 32, 52]

# Get all requests with status_id=1
def get_requests():
    headers = {
        'accept': 'application/json',
        'Authorization': auth_token
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
        'Authorization': auth_token,
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
