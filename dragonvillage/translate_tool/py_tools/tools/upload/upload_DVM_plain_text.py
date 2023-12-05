#############################################################################
## 구글 스프레드시트에 업로드하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import tools.G_sheet.spread_sheet as spread_sheet
from tools.G_sheet.sheet_option import get_sheet_option
from tools.util.util_quote import quote
from util.util_quote import quote_row_dics
from lang_codes.lang_codes import get_language_code_list


def removeStr(sheet, data_list, header, locale_list): # sheet과 datalist의 값 비교를 통해 중복을 제거한 data_list 반환합니다.
    remove_index = []
    data_text_locale_index = {}

    for locale in locale_list:
        if locale in header:
            data_text_locale_index[locale] = header.index(locale)
            
    for row in sheet.get_all_values():
        if row[0] == 'kr':
            row_text_locale_index = {}
            for locale in locale_list:
                if locale in row:
                    row_text_locale_index[locale] = row.index(locale)
            continue
        for index, data in enumerate(data_list):
            if data[0] == row[0]: # 텍스트가 같은 경우
                # 중복이므로 제거합니다
                remove_index.append(index)

    data_list = [data for index, data in enumerate(data_list) if index not in remove_index] 
    return data_list


def upload_DVM_plain_text(delta_sheet_name, backup_sheet_name, spreadsheet_id, data_list, locale_list):
    # 힌트랑 날짜가 찍히지 않아서 찍히도록 수정
    total_lang_list = get_language_code_list()
    temp_data_list = []
    for data in data_list:            
        temp_data = []
        temp_data.append(data[0])
        start_idx = 1 + total_lang_list.index(locale_list[0])
        for i in range(start_idx, start_idx + len(locale_list)):
            temp_data.append(data[i])
        temp_data.append(data[len(data) - 2])
        temp_data.append(data[len(data) - 1])
        temp_data_list.append(temp_data)

    # 데이터를 KR 값을 이용하여 정렬합니다.
    temp_data_list.sort(key=lambda line: line[0]) 

    # 새로 만들 시트의 헤더입니다.
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

    backup_sheet = sheet.get_work_sheet(backup_sheet_name)
    if backup_sheet is None:
        backup_option = {}
        backup_option['rows'] = 1
        backup_option['cols'] = col_size
        backup_sheet = sheet.add_work_sheet(backup_sheet_name, backup_option)
        backup_sheet.insert_row(header, 1, value_input_option='RAW')
        sheet_id = backup_sheet._properties['sheetId']
        sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
        sheet.batch_update(sheet_option)
    else: # 백업 시트가 존재한다면 백업 시트와의 중복 검사 실시
        temp_data_list = removeStr(backup_sheet, temp_data_list, header, locale_list)

    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    delta_sheet = sheet.get_work_sheet(delta_sheet_name)
    if delta_sheet is None:
        delta_option = {}
        delta_option['rows'] = 1
        delta_option['cols'] = col_size
        delta_sheet = sheet.add_work_sheet(delta_sheet_name, delta_option)
        delta_sheet.insert_row(header, 1, value_input_option='RAW')
    else: # 기존의 뉴시트와 중복 검사
        temp_data_list = removeStr(delta_sheet, temp_data_list, header, locale_list)
   
    # 시트에 데이터를 삽입합니다 
    # 시트의 빈 칸이 시작되는 행을 파악해서 넣습니다.
    exist_datas = delta_sheet.get_all_values()
    row_size = len(exist_datas) + 1
    delta_sheet.resize(rows=row_size)
    if len(temp_data_list) > 0:
        delta_sheet.insert_rows(temp_data_list, row_size, value_input_option='RAW')

    # 시트의 크기를 보기 좋게 조정합니다.
    sheet_id = delta_sheet._properties['sheetId']
    sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
    sheet.batch_update(sheet_option)

    print('Add text in [', delta_sheet_name, '] :', len(temp_data_list))
    delta_sheet_rows = delta_sheet.get_all_values()
    return delta_sheet_rows[1:]

def direct_upload_DVM_plain_text(delta_sheet_name, backup_sheet_name, spreadsheet_id, data_list, locale_list):
    # 힌트랑 날짜가 찍히지 않아서 찍히도록 수정    
    temp_data_list = []    
    for data in data_list:            
        temp_data = []
        temp_data.append(data[0])
        for v in range(0, len(locale_list)):
            temp_data.append('')
        
        temp_data.append(data[len(data) - 2])
        temp_data.append(data[len(data) - 1])
        temp_data_list.append(temp_data)

    # 새로 만들 시트의 헤더입니다.
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
    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    delta_sheet = sheet.get_work_sheet(delta_sheet_name)

    if delta_sheet is not None:
        sheet.del_work_sheet(delta_sheet)

    delta_option = {}
    delta_option['rows'] = 1
    delta_option['cols'] = col_size
    delta_sheet = sheet.add_work_sheet(delta_sheet_name, delta_option)
    delta_sheet.insert_row(header, 1, value_input_option='RAW')
   
    # 시트에 데이터를 삽입합니다 
    # 시트의 빈 칸이 시작되는 행을 파악해서 넣습니다.
    exist_datas = delta_sheet.get_all_values()
    row_size = len(exist_datas) + 1
    delta_sheet.resize(rows=row_size)
    
    if len(temp_data_list) > 0:
        delta_sheet.insert_rows(temp_data_list, row_size, value_input_option='RAW')

    # 시트의 크기를 보기 좋게 조정합니다.
    sheet_id = delta_sheet._properties['sheetId']
    sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
    sheet.batch_update(sheet_option)

    print('Add text in [', delta_sheet_name, '] :', len(temp_data_list))    

