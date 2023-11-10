#############################################################################
## 구글 스프레드시트와 관련된 유틸 및 클래스 코드입니다.
#############################################################################

from tools.util.util_import import install_and_import, install_if_no_exist

install_if_no_exist('gspread')

import os
import gspread


class spreadSheet:
    def __init__(self, doc):
        self.doc = doc


    def get_work_sheet(self, title):
        worksheets = self.doc.worksheets()
        for worksheet in worksheets:
            if worksheet.title == title:
                return worksheet
        return None


    def add_work_sheet(self, title, option):
        self.doc.add_worksheet(title, option['rows'], option['cols'], 0)
        return self.doc.worksheet(title)
    
    def del_work_sheet(self, sheet):
        self.doc.del_worksheet(sheet)
        sheet = None


    def batch_update(self, body):
        self.doc.batch_update(body)


def get_spread_sheet(sheet_key):
    # 인증 받아 시트 열기
    # scope = ['https://spreadsheets.google.com/feeds',
    #         'https://www.googleapis.com/auth/drive']
    # cred = ServiceAccountCredentials.from_json_keyfile_name(
    #     os.path.join(os.path.dirname(os.path.abspath(__file__)), 'cred.json'), scope)
    # gc = gspread.authorize(cred)
    
    gc = gspread.oauth()

    doc = gc.open_by_key(sheet_key)

    sheet = spreadSheet(doc)

    return sheet
    
# 워크시트로부터 받은 데이터 정보를 딕셔너리 형태로 변환힙니다.
def make_rows_to_dic(rows):
    result = []
    for i in range(1, len(rows)):
        temp = {}
        for j, key in enumerate(rows[0]):
            temp[key] = rows[i][j]
        result.append(temp)
    return result