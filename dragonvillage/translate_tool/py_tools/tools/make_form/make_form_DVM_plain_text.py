#############################################################################
## 구글 스프레드시트에 업로드하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import tools.G_sheet.spread_sheet as spread_sheet
from tools.G_sheet.sheet_option import get_sheet_option
from tools.util.util_quote import quote


def make_DVM_plain_text(delta_sheet_name, backup_sheet_name, spreadsheet_id, locale_list):
    # 데이터를 KR 값을 이용하여 정렬합니다.
    #data_list.sort(key=lambda line: line[0]) 

    # 헤더를 생성합니다.
    header = ['kr']
    for locale in locale_list:
        header.append(locale)
    header.append('hints')
    header.append('date')

    # 시트를 만들 때 사용될 칼럼 사이즈입니다.
    col_size = len(header)

    # 스프레드시트의 아이디값을 이용하여 연결합니다.
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)

    print('스프레드 시트 아이디 : ' + spreadsheet_id)

    backup_sheet = sheet.get_work_sheet(backup_sheet_name)

    if backup_sheet is not None:
        sheet.del_work_sheet(backup_sheet)
        backup_sheet = None

    if backup_sheet is None:
        backup_option = {}
        backup_option['rows'] = 1
        backup_option['cols'] = col_size
        backup_sheet = sheet.add_work_sheet(backup_sheet_name, backup_option)
        backup_sheet.insert_row(header, 1, value_input_option='RAW')
        sheet_id = backup_sheet._properties['sheetId']
        sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
        sheet.batch_update(sheet_option)


    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    delta_sheet = sheet.get_work_sheet(delta_sheet_name)

    if delta_sheet is not None:
        sheet.del_work_sheet(delta_sheet)
        delta_sheet = None

    if delta_sheet is None:
        backup_option = {}
        backup_option['rows'] = 1
        backup_option['cols'] = col_size
        delta_sheet = sheet.add_work_sheet(delta_sheet_name, backup_option)
        delta_sheet.insert_row(header, 1, value_input_option='RAW')
        sheet_id = delta_sheet._properties['sheetId']
        sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
        sheet.batch_update(sheet_option)
        
    
    # # 시트에 데이터를 삽입합니다 
    # # 시트의 빈 칸이 시작되는 행을 파악해서 넣습니다.
    # exist_datas = delta_sheet.get_all_values()
    # row_size = len(exist_datas) + 1
    # delta_sheet.resize(rows=row_size)
    # if len(data_list) > 0:
    #     delta_sheet.insert_rows(data_list, row_size, value_input_option='RAW')

    # # 시트의 크기를 보기 좋게 조정합니다.
    # sheet_id = delta_sheet._properties['sheetId']
    # sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
    # sheet.batch_update(sheet_option)

    # print('Add text in [', delta_sheet_name, '] :', len(data_list))
