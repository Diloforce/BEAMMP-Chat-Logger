import time
import requests
import os

# Configuration
log_file_path = r"D:\server\chat_logs.txt"
webhook_url = "https://discord.com/api/webhooks/1199391173102542888/DrAYxf1gq7DGj87vU6mtc50SEcAPzPCL3QXB1U85enIqQdiDKYTgRd8nUwV66pg1UDnR"

def send_to_webhook(message):
    payload = {
        "content": message
    }
    try:
        response = requests.post(webhook_url, json=payload)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Error sending to webhook: {e}")

def monitor_log_file():
    with open(log_file_path, "r") as log_file:
        # Move the file pointer to the end of the file
        log_file.seek(0, os.SEEK_END)
        
        while True:
            line = log_file.readline()
            if line:
                send_to_webhook(line.strip())
            else:
                time.sleep(1)  # Sleep briefly to avoid busy-waiting

if __name__ == "__main__":
    print("Starting log monitor...")
    monitor_log_file()
