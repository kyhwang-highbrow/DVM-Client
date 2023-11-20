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

def get_slice_text_list(keyword, start, end):    
    result_list = []
    for rows in total_text_rows:
        last_idx = len(rows) - 1
        if rows[last_idx] == keyword:
            temp_data = rows[start:end]
            result_list.append(temp_data)
    return result_list

def read_input_sheets():
    sheet = spread_sheet.get_spread_sheet(integration_spreadsheet_id)
    work_sheet = sheet.get_work_sheet('DIFF')
    all_rows = work_sheet.get_all_values()   

    for v in all_rows[1:]:        
        data_list = v[1:]
        total_text_rows.append(data_list)

def copy_cells_to_sheets():
    ss_list_sheet = spread_sheet.get_spread_sheet(spreadsheet_id).get_work_sheet('ss_list')
    ss_info_list = quote_row_dics(spread_sheet.make_rows_to_dic(ss_list_sheet.get_all_values()))

    slice_idx = 0
    key_word_list = ['plain_text', 'scenario_speaker', 'scenario_text']
    for row in ss_info_list:
        ss_id = row['ss_id']
        lang_code = row['lang_code']
        lang_code_list = lang_code.split(',')
        lang_count = len(lang_code_list)

        start_idx = slice_idx
        last_idx = slice_idx + lang_count

        for key_word in key_word_list:
            sliced_text_list = get_slice_text_list(key_word, start_idx, last_idx)
            update_sheets(ss_id, key_word, sliced_text_list, lang_count)
        
        break
        slice_idx = last_idx

def update_sheets(ss_id, key_word, sliced_text_list, lang_count):
    sheet = spread_sheet.get_spread_sheet(ss_id)  
    count = len(sliced_text_list)

    if key_word == 'plain_text':
        work_sheet = sheet.get_work_sheet('only_ingame')

        ascii_code = chr(ord('B') + lang_count - 1)
        cell_range = 'B2:{0}{1}'.format(ascii_code, len(sliced_text_list) + 1)

        print('cell_range', cell_range)
        print('sliced_text_list count', len(sliced_text_list) + 1)
        print('sliced_text_list col count', len(sliced_text_list[0]))
        
        work_sheet.update(cell_range, sliced_text_list)        

    else:
        work_sheet = sheet.get_work_sheet('only_scenario')
        if key_word == 'scenario_speaker':
            cell_range = 'C2:C{0}'.format(2 + count)
            work_sheet.update(cell_range, sliced_text_list)

        elif key_word == 'scenario_text':            
            ascii_code = chr(ord('D') + lang_count)
            cell_range = '{0}2:{1}{2}'.format(ascii_code, ascii_code, 2 + count)
            work_sheet.update(cell_range, sliced_text_list)

if __name__ == '__main__':
    print('\n*** 작업      : 프로젝트에서 텍스트를 추출합니다.')    

    read_input_sheets()
    copy_cells_to_sheets()

    os.system('pause')