import json
import random
import requests
from datetime import datetime, timedelta
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Authorization token
auth_token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJUTUstSGVhbHRoQ2hlY2siLCJleHAiOjE3Mjc2MDcyMzh9.0IEJicCuligKuLfhtvCp0r0LTUuwADmEVskZ790MbYg'

# API endpoints
base_url = 'https://corp3.cybertrain4security.ru:65534'
requests_url = f'{base_url}/requests'
approve_url = f'{base_url}/master-approve'
take_on_work_url = f'{base_url}/take-on-work'
executor_complete_url = f'{base_url}/executor-complete'
requestor_confirm_url = f'{base_url}/requestor-confirm'

creators = [30, 31, 33, 44, 49, 48, 50]
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

# Approve the request
def approve_request(request_id, user_id):
    headers = {
        'accept': 'application/json',
        'Authorization': auth_token,
        'Content-Type': 'application/json'
    }
    payload = {
        "request_id": request_id,
        "user_id": user_id,
        "reason": "Approved by script"
    }
    response = requests.post(approve_url, headers=headers, json=payload, verify=False)
    if response.status_code == 200:
        print(f"Request {request_id} approved by user {user_id}")
    else:
        print(f"Failed to approve request {request_id}. Status code: {response.status_code}")

# Take on work
def take_on_work(request_id, user_id):
    headers = {
        'accept': 'application/json',
        'Authorization': auth_token,
        'Content-Type': 'application/json'
    }
    payload = {
        "request_id": request_id,
        "user_id": user_id
    }
    response = requests.post(take_on_work_url, headers=headers, json=payload, verify=False)
    if response.status_code == 200:
        print(f"Request {request_id} taken on by user {user_id}")
    else:
        print(f"Failed to take on work for request {request_id}. Status code: {response.status_code}")

# Complete the work
def executor_complete(request_id, user_id):
    headers = {
        'accept': 'application/json',
        'Authorization': auth_token,
        'Content-Type': 'application/json'
    }
    payload = {
        "request_id": request_id,
        "user_id": user_id
    }
    response = requests.post(executor_complete_url, headers=headers, json=payload, verify=False)
    if response.status_code == 200:
        print(f"Request {request_id} completed by user {user_id}")
    else:
        print(f"Failed to complete request {request_id}. Status code: {response.status_code}")

# Confirm the request
def requestor_confirm(request_id, user_id):
    headers = {
        'accept': 'application/json',
        'Authorization': auth_token,
        'Content-Type': 'application/json'
    }
    payload = {
        "request_id": request_id,
        "user_id": user_id
    }
    response = requests.post(requestor_confirm_url, headers=headers, json=payload, verify=False)
    if response.status_code == 200:
        print(f"Request {request_id} confirmed by user {user_id}")
    else:
        print(f"Failed to confirm request {request_id}. Status code: {response.status_code}")

# Main logic
all_requests = get_requests()

# Filter requests with status_id=1
pending_requests = [req for req in all_requests if req.get('status_id') == 1]

# Sort requests by created_at in ascending order
pending_requests.sort(key=lambda req: datetime.strptime(req['created_at'], '%Y-%m-%dT%H:%M:%S'))  # Adjust the format as needed

# Select 80% of the earliest requests
num_requests = int(len(pending_requests) * 0.8)
selected_requests = pending_requests[:num_requests]

# Process each selected request
for request in selected_requests:
    request_id = request['request_id']
    creator_id = request['created_by']
    
    # Step 1: Approve the request
    approver_user_id = random.choice(masters)
    approve_request(request_id, approver_user_id)
    
    # Step 2: Take on work with random user_id
    worker_user_id = random.choice(creators)
    take_on_work(request_id, worker_user_id)
    
    # Step 3: Executor completes the work
    executor_complete(request_id, worker_user_id)
    
    # Step 4: Requestor confirms the request
    requestor_confirm(request_id, creator_id)
