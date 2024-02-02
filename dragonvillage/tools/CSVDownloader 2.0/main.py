from genericpath import exists
import sys
import os
import pickle
import shutil
import re
import io
import json
from time import thread_time_ns

def install_if_no_exist(package):
    try:
        return __import__(package)
    except ImportError:
        print('# INSTALL DEPENDENCY MODULE :', package)
        try:
            from pip import main as pipmain
        except:
            from pip._internal.main import main as pipmain
        pipmain(['install', package])

# 만약 라이브러리 없다면 설치함
install_if_no_exist('PyQt5')
install_if_no_exist('google-api-python-client')
install_if_no_exist('google-auth-httplib2')
install_if_no_exist('google-auth-oauthlib')
install_if_no_exist('googleapiclient')

from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5 import uic 
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.http import MediaIoBaseDownload


import warnings
warnings.filterwarnings('ignore')

import logging
logging.getLogger().setLevel(logging.ERROR)

FOLDER_CLIENT = 'table_client'
FOLDER_SERVER = 'table_server'


# 다운로드용
class DownloadThread(QThread):
    def __init__(self, owner):
        super().__init__()

        self.owner = owner
        self.download_queue = []


    def run(self):
        while True:
            if len(self.download_queue) > 0:
                download_data = self.download_queue.pop(0)
                file_id = download_data[0]
                file_name = download_data[1]
                file_user = download_data[2]
                file_date = download_data[3]
                
                p = re.compile(r'(^table_\S*) ')            
                m = p.search(file_name)

                # 양식에 맞는 데이터 테이블이 아닌 경우
                if m is None:
                    self.owner.print_log('<b>SKIP!</b> invalid table name : ' + table_name)
                    continue

                table_name = m.group(1)
                is_client = (file_name.find('[client]') != -1)
                is_server = (file_name.find('[server]') != -1)

                # csv 파일 다운로드
                if is_client or is_server:
                    request = self.owner.service.files().export_media(fileId=file_id, mimeType='text/csv') # csv로 다운로드
                    fh = io.BytesIO()
                    downloader = MediaIoBaseDownload(fh, request)
                    done = False
                    while done is False:
                        status, done = downloader.next_chunk()
                    self.owner.print_log(f"{table_name}\t{file_date} by [{file_user}]")

                    if is_client:
                        file_path = os.path.join(FOLDER_CLIENT, table_name + '.csv')
                        with open(file_path, 'wb') as f:
                            f.write(fh.getvalue())
                
                    if is_server:
                        file_path = os.path.join(FOLDER_SERVER, table_name + '.csv')
                        with open(file_path, 'wb') as f:
                            f.write(fh.getvalue())
                    fh.close()

            if len(self.download_queue) == 0:
                self.owner.print_log('<b>Finish CSV Download!</b>')
                self.finished.emit()
                break

            self.msleep(10)


    def push_download_list(self, file_data_list):
        self.download_queue.extend(file_data_list)
        self.start()


# 메인 CSV Downloader  윈도우
UI = uic.loadUiType("csv_downloader.ui")[0]
class CSVDownloader(QMainWindow, UI):
    # UI widget object names
    # clientCheckBtn
    # serverCheckBtn
    # serverPatchCheckBtn
    # downloadBtn

    def __init__(self):
        super().__init__()

        self.init_service()
        self.init_ui()
        self.init_button()

        self.download_thread = DownloadThread(self)

        self.print_log('<b># CSV Downloader Start!</b>')
        
        # 마지막 행동 데이터 세팅
        self.load_history()


    def init_service(self):
         # 구글 드라이브 접속
        # SCOPES = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
        SCOPES = ['https://www.googleapis.com/auth/drive']
        creds = None

        # 이전에 인증한 정보가 남아있는지 확인
        if os.path.exists('token.pickle'):
            with open('token.pickle', 'rb') as token:
                creds = pickle.load(token)

        # 인증 정보가 없는 경우 새로 인증
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    'credentials.json', SCOPES)
                creds = flow.run_local_server(port=0)

            with open('token.pickle', 'wb') as token:
                pickle.dump(creds, token)

        self.service = build('drive', 'v3', credentials=creds)


    def init_ui(self):
        self.setWindowTitle("CSV Downloader")
        self.setupUi(self)

        self.textBrowser.setAcceptRichText(True)


    def init_button(self):
        self.downloadBtn.clicked.connect(self.click_downloadBtn)


    def print_log(self, text):
        self.textBrowser.append(text)
        self.textBrowser.verticalScrollBar().setValue(self.textBrowser.verticalScrollBar().maximum()) #append text로 focus


    def load_history(self):
        json_data = {}
        if os.path.exists('history.json'):
            json_data = json.load(open('history.json', 'r'))
        self.history = json_data

        if 'datetime' in json_data:
            date_time = QDateTime().fromString(json_data['datetime'], 'yyyy-MM-ddTHH:mm:ss')
            date_time_str = date_time.toString('yyyy-MM-dd HH:mm:ss')
            self.print_log(f'<b># 최근 실행 기록 시간 {date_time_str}으로 세팅합니다.</b>')
            self.dateTimeEdit.setDateTime(date_time)


    def save_history(self):
        with open('history.json', 'w') as f:
            json.dump(self.history, f, indent='\t')


    def click_downloadBtn(self):
        # client, server 파일 만들기
        if os.path.exists(FOLDER_CLIENT):
            shutil.rmtree(FOLDER_CLIENT)

        if os.path.exists(FOLDER_SERVER):
                    shutil.rmtree(FOLDER_SERVER)
            
        os.mkdir(FOLDER_CLIENT)
        os.mkdir(FOLDER_SERVER)

        # 구글 스프레드시트 테이블 데이터 검색할 폴더 ID
        parent_folder = '1ouHiC3BZMP66kmVJvJXVoEYH9zlcZIPE'

        # 특정 날짜 이후로 수정된 파일만 받기
        datetime_edit = self.dateTimeEdit
        date_time = datetime_edit.dateTime()
        modified_time = date_time.toString('yyyy-MM-ddTHH:mm:ss') # 2012-06-04T12:00:00꼴
        self.history['datetime'] = modified_time
        self.save_history()
        self.print_log(f'<b># {modified_time} 이후로 변경된 테이블을 다운로드합니다.</b>')


        # 테이블 폴더 안에서 필요한 테이블 하나하나 다운받아 폴더에 다운로드
        response = self.service.files().list(q=f"'{parent_folder}' in parents and name contains 'table_' and modifiedTime > '{modified_time}'",
                                        supportsAllDrives=True, # 공유 드라이브 검색 옵션 1
                                        includeItemsFromAllDrives=True, # 공유 드라이브 검색 옵션 2
                                        fields='nextPageToken, files(id, name, modifiedTime, lastModifyingUser)').execute()


        import datetime
        # 검색으로 나온 파일들 다운로드
        file_data_list = []        
        for file in response.get('files', []):
            file_id = file.get('id')
            file_name = file.get('name')
            file_modified_str = file.get('modifiedTime')
            file_modified_user = file.get('lastModifyingUser')
            file_modified_date = datetime.datetime.strptime(file_modified_str, "%Y-%m-%dT%H:%M:%S.%fZ")
            
            display_name = 'Unknown'
            file_modified_user_type = str(type(file_modified_user))
            if 'dict' in file_modified_user_type:
                display_name = file_modified_user.get('displayName')

            file_data_list.append([file_id, file_name, display_name, file_modified_date.strftime("%m/%d/%Y %H시 수정")])
     

        self.downloadBtn.setDisabled(True)
        self.download_thread.finished.connect(self.unlock_downloadBtn)
        self.download_thread.push_download_list(file_data_list)


    # 다운로드 시작 시 버튼을 잠금
    def unlock_downloadBtn(self):
        self.downloadBtn.setEnabled(True)


# 메인 함수
def main():
    app = QApplication(sys.argv)

    window = CSVDownloader()
    window.show()

    app.exec_()


if __name__ == '__main__':
    main()