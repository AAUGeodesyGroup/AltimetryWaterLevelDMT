
# This code was modified from: https://gist.github.com/willrayeo/8aa424384f272d3003a2dea6460cb07b#file-keychain_credentials-py

# excecute in the Terminal or Anaconda command window: pip install requests

# Define token request function
import requests

def get_access_token(username: str, password: str) -> str:
    data = {
        "client_id": "cdse-public",
        "username": username,
        "password": password,
        "grant_type": "password",
    }
    try:
        r = requests.post(
            "https://identity.dataspace.copernicus.eu/auth/realms/CDSE/protocol/openid-connect/token",
            data=data,
        )
        r.raise_for_status()
    except Exception as e:
        raise Exception(
            f"Access token creation failed. Reponse from the server was: {r.json()}"
        )
    return r.json()["access_token"]

# LOAD CREDENTIALS AND REQUEST ACCESS TOKEN
import csv
with open('CLMS_credentials_Hilda.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')
    cred = [row for row in spamreader]
access_token = get_access_token(cred[0][0][3:], cred[1]) # change 3 to 0 in [3:] if the first letters of the username is cut off. If there are unknown symbols before the username, then write a higher number than 3. 

import os
# DEFINE SAVING FOLDER
save_directory = 'downloads'
if not os.path.exists(save_directory):
    os.makedirs(save_directory)

## GET ID LIST FROM FILE
with open('CLMS_Niger_Station_Information.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',', quotechar='|')
    for row in spamreader:
        id = row[0]
        print(id)

        # DOWNLOAD DATA FOR EACH ID
        url = f"https://download.dataspace.copernicus.eu/odata/v1/Products({id})/$value"

        headers = {"Authorization": f"Bearer {access_token}"}

        # Create a session and update headers
        session = requests.Session()
        session.headers.update(headers)

        # Perform the GET request
        response = session.get(url, stream=True)

        # Check if the request was successful
        if response.status_code == 200:
            with open(f"{save_directory}/{id}", "wb") as file:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:  # filter out keep-alive new chunks
                        file.write(chunk)
        else:
            print(f"Failed to download file. Status code: {response.status_code}")
            print(response.text)