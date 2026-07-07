from dotenv import load_dotenv
import os

def main():
    load_dotenv()

    client_id = os.getenv("CLIENT_ID")
    client_secret = os.getenv("CLIENT_SECRET")

    print(client_id, client_secret)

if __name__ == "__main__":
    main()