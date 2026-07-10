import os
import base64
import json
from dotenv import load_dotenv
from requests import post


client_id = os.getenv("CLIENT_ID")
client_secret = os.getenv("CLIENT_SECRET")

def get_token():
    auth_string = client_id + ":" + client_secret
    auth_bytes = auth_string.encode("utf-8")
    auth_base64 = str(base64.b64decode(auth_bytes), "utf-8")

    url = "https://accounts.spotify.com/api/token"
    headers = {
        "Authorization": "Basic" + auth_base64,
        "Content-Type": "application/x-www-form-urleconded"
    }
    data = {
        "grant_type": "client_credentials"
    }

    result = post(url, headers=headers, data=data)
    json_result = json.loads(result.content)
    token = json_result["access_token"]
    
    return token

def get_auth_header(token):
    return {
        "Authorization" : "Bearer" + token
    }

def main():
    load_dotenv()

    token = get_token()

    print(f"{client_id}\n{client_secret}")

if __name__ == "__main__":
    main()