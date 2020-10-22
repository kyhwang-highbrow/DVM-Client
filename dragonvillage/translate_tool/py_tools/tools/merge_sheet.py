#############################################################################
## 번역이 끝난 시트들을 통합하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import json

from merge.merge import merge


with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    merge_config_list = config_json['merge_config_list']


def merge_backup():
    for merge_config in merge_config_list:
        patch_sheet_name = merge_config['patch_sheet_name']
        backup_sheet_name = merge_config['backup_sheet_name']
        merge_method = merge_config['merge_method']

        merge(merge_method, spreadsheet_id, patch_sheet_name, backup_sheet_name, locale_list)
    
    print('\n*** 작업이 종료되었습니다.')


if __name__ == '__main__':
    import tools.G_sheet.setup

    print('\n*** 작업      : 델타 시트를 백업 시트와 병합합니다.' 
    ,     '\n*** 델타 시트 : [', ', '.join([merge_config['patch_sheet_name'] for merge_config in merge_config_list]), '].' 
    ,     '\n*** 백업 시트 : [', ', '.join([merge_config['backup_sheet_name'] for merge_config in merge_config_list]), '].')
 
    merge_backup()
        
    os.system('pause')
