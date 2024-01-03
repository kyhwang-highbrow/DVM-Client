from __future__ import print_function
import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient import errors
from googleapiclient.discovery import build

def auth_apps_script(script_id, function_name):    
    # script, spreadsheet를 수정하는 권한이 필요한 것을 명시합니다.
    SCOPES = [
        'https://www.googleapis.com/auth/script.projects', 
        'https://www.googleapis.com/auth/script.scriptapp', 
        'https://www.googleapis.com/auth/spreadsheets',
        'https://www.googleapis.com/auth/script.external_request',
    ]

    # 권한 획득 Start ###########################
    creds = None
    if os.path.exists('service-account-key.json'):
        creds = Credentials.from_authorized_user_file('service-account-key.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('service-account-key.json', 'w') as token:
            token.write(creds.to_json())
    # 권한 획득 End ###########################

    try:
        #https://script.googleapis.com/v1/scripts/AKfycby_OfwWR2lN2OzILmyCt6YWDMnapi4NS81zfFY3Lo2nGD6iYJaC1qWpnU7M9igy67qN:run
        scriptID = script_id
        service = build("script", "v1", credentials=creds)
         # Create an execution request object.
        request = { "function":function_name}
        service.scripts().run(scriptId=scriptID, body=request).execute()

    except errors.HttpError as error:
        # The API encountered a problem.
        print(error.content)


def execute_apps_script(script_id, function_name):
    auth_apps_script(script_id, function_name)