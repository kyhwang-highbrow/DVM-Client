import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import json
import G_sheet.spread_sheet as spread_sheet

from merge.merge import merge
from util.util_quote import quote_row_dics
from check_sync.check_sync import check_sync

with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)    
    spreadsheet_id = config_json['spreadsheet_id']
    merge_config_list = config_json['merge_config_list']

if __name__ == '__main__':
    # 모든 시트 번역 진행도 싱크 여부를 체크
    print('\n*** 작업      : 모든 시트 번역 진행도 싱크 여부를 체크합니다.')
    for extract_config in merge_config_list:
        list = [extract_config['patch_sheet_name'], extract_config['backup_sheet_name']]
        if check_sync(list) == False:
            os.system('pause')

    print('\n*** 모든 시트 번역 진행도 일치')
    os.system('pause')
