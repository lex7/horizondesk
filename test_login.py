import requests
import json

# API endpoint for login
login_url = 'https://corp3.cybertrain4security.ru:4443/login'

# Login credentials
username = 'TMK-HealthCheck'
password = 'GoLiveMonitorCheck1#'

# Function to perform login
def login(username, password):
    payload = {
        'username': username,
        'password': password,
        'fcm_token': 'asus:testingprodfrompy'
    }
    
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.post(login_url, headers=headers, json=payload, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Login failed: {e}")
        return None

# Perform login and print the response
login_response = login(username, password)
if login_response:
    print("Login successful. Response:")
    print(json.dumps(login_response, indent=2))
else:
    print("Login failed.")


