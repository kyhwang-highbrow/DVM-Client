import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
import re
import G_sheet.spread_sheet as spread_sheet
from tools.G_sheet.sheet_option import get_sheet_option
from lang_codes.lang_codes import get_language_code_list
from util.util_quote import quote_row_dics

total_text_rows = []

with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    spreadsheet_id = config_json['spreadsheet_id']
    extract_config_list = config_json['extract_config_list']
    integration_spreadsheet_id = config_json['integration_spreadsheet_id']
    locale_list = get_language_code_list()
    integration_config_list = config_json['make_integration_sheets'] 

def make_integration_sheet(plain_text_list):    
    if len(plain_text_list) == 0:
        return
    
    # 헤더를 생성합니다.
    header = ['kr']
    for locale in locale_list:
        header.append(locale)

    # 시트를 만들 때 사용될 칼럼 사이즈입니다.
    col_size = len(header)

    # 스프레드시트의 아이디값을 이용하여 연결합니다.
    sheet = spread_sheet.get_spread_sheet(integration_spreadsheet_id)

    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    delta_sheet = sheet.get_work_sheet('DIFF')
    if delta_sheet is not None:
        sheet.del_work_sheet(delta_sheet)
        delta_sheet = None

    # 헤더 생성
    if delta_sheet is None:
        backup_option = {}
        backup_option['rows'] = 1
        backup_option['cols'] = col_size
        delta_sheet = sheet.add_work_sheet('DIFF', backup_option)
        delta_sheet.insert_row(header, 1, value_input_option='RAW')
        #sheet_id = delta_sheet._properties['sheetId']
        #sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
        #sheet.batch_update(sheet_option)

    # 행들 추가
    exist_datas = delta_sheet.get_all_values()
    row_size = len(exist_datas) + 1
    delta_sheet.resize(rows=row_size)

    if len(plain_text_list) > 0:
        delta_sheet.insert_rows(plain_text_list, row_size, value_input_option='RAW')

    
def extract_kr_list(sheet, sheet_name):    
    work_sheet = sheet.get_work_sheet(sheet_name)
    total_text_rows = work_sheet.get_all_values()
    locale_len = len(locale_list)

    result_text_rows = []
    if sheet_name == 'only_ingame':
        for row in total_text_rows[1:]:
            temp_data = []
            temp_data.append(row[0])
            temp_data.extend('' for v in range(0, locale_len))
            temp_data.append('plain_text')
            result_text_rows.append(temp_data)
        
    elif sheet_name == 'only_scenario':        
        for row in total_text_rows[1:]:
            temp_data = []
            temp_data.append(row[2])
            temp_data.extend('' for v in range(0, locale_len))
            temp_data.append('scenario_speaker')
            result_text_rows.append(temp_data)

        for row in total_text_rows[1:]:
            temp_data = []
            temp_data.append(row[13])
            temp_data.extend('' for v in range(0, locale_len))
            temp_data.append('scenario_text')
            result_text_rows.append(temp_data)

    return result_text_rows

def make_integration_sheets():
    ss_list_sheet = spread_sheet.get_spread_sheet(spreadsheet_id).get_work_sheet('ss_list')
    ss_info_list = quote_row_dics(spread_sheet.make_rows_to_dic(ss_list_sheet.get_all_values()))
    
    row = ss_info_list[0]
    ss_id = row['ss_id']
    sheet = spread_sheet.get_spread_sheet(ss_id)

    total_text_rows = []
    for v in integration_config_list:
        sheet_name = v['sheet_name']
        temp_list = extract_kr_list(sheet, sheet_name)
        total_text_rows.extend(temp_list)

    make_integration_sheet(total_text_rows)
    print('\n*** 작업 완료 {0}개 행 추출'.format(len(total_text_rows)))

if __name__ == '__main__':
    print('\n*** 작업      : 번역본을 통합 시트로 옮깁니다.')
    make_integration_sheets()     
    os.system('pause')