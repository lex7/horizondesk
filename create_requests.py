import json
import random
import requests
from datetime import datetime, timedelta
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# File path to the JSON file
json_file = 'data/issues.json'

# Authorization token
auth_token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhbGV4IiwiZXhwIjoxNzI3MzU2ODgxfQ.N_6HcEr5hzeELuCS6KoUpBgPxTckNClBu8v2pPNxeC8'

# API endpoint
url = 'https://timofmax1.fvds.ru/create-request'

def random_datetime():
    start_date = datetime(2024, 7, 30)
    end_date = datetime(2024, 9, 24)
    delta = end_date - start_date
    random_days = random.randrange(delta.days + 1)
    random_time = timedelta(seconds=random.randrange(86400))  # random time within a day
    return (start_date + timedelta(days=random_days) + random_time).isoformat() + 'Z'

# Function to send a POST request using requests
def send_request(issue):
    created_at = random_datetime()
    payload = {
        "request_type": issue['request_type'],
        "user_id": issue['user_id'],
        "area_id": issue['area_id'],
        "description": issue['description'],
        "created_at": created_at
    }

    headers = {
        'accept': 'application/json',
        'Authorization': auth_token,
        'Content-Type': 'application/json'
    }

    response = requests.post(url, headers=headers, json=payload, verify=False)

    if response.status_code == 200:
        print(f"Request sent for user_id: {issue['user_id']} with response: {response.json()}")
    else:
        print(f"Failed to send request for user_id: {issue['user_id']} with status code: {response.status_code} and response: {response.text}")

# Read JSON file
with open(json_file, 'r', encoding='utf-8') as file:
    issues = json.load(file)

# Loop through each issue and send request
for issue in issues:
    send_request(issue)
