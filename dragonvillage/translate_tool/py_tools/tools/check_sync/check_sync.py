#############################################################################
## 14개 번역 시트 간 데이터 일치여부 체크
#############################################################################
import sys
import os
import json
import time
import util.util_file as util_file
from util.util_quote import quote_row_dics
import G_sheet.spread_sheet as spread_sheet

# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    spreadsheet_id = config_json['spreadsheet_id']
    extract_config_list = config_json['extract_config_list']

def get_sheet_col_vals(compare_sheet, target_column_name):
    # 시트에서 첫 번째 행의 컬럼명 가져오기
    header_row = compare_sheet.row_values(1)
    column_index = header_row.index(target_column_name)
    values = compare_sheet.col_values(column_index + 1)
    return values

def check_sync(sheet_name_list):
    ss_list_sheet = spread_sheet.get_spread_sheet(spreadsheet_id).get_work_sheet('ss_list')
    ss_info_list = quote_row_dics(spread_sheet.make_rows_to_dic(ss_list_sheet.get_all_values()))
    prev_compare_sheet_vals = None

    # 함수 호출
    try:
        for sheet_name in sheet_name_list:
            print('check sync', sheet_name)
            prev_compare_sheet_vals = None
            for row in ss_info_list:
                ss_id = row['ss_id']
                lang_code = row['lang_code']
                # 스프레드시트의 아이디값을 이용하여 연결합니다.
                sheet = spread_sheet.get_spread_sheet(ss_id)                
                # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
                compare_sheet = sheet.get_work_sheet(sheet_name)
                if compare_sheet is not None:                  
                    compare_values = get_sheet_col_vals(compare_sheet, 'kr')
                    if prev_compare_sheet_vals is not None:
                        if prev_compare_sheet_vals != compare_values:
                            raise ValueError('분할 시트 간에 싱크가 맞지 않습니다. [{0}] : {1}'.format(sheet_name, lang_code))                    
                    prev_compare_sheet_vals = compare_values

            print('check sync complete', sheet_name)
            print('wait for 30 secs...')
            time.sleep(30)

    except ValueError as e:
        print(f"예외 발생: {e}")
        return False

    return True