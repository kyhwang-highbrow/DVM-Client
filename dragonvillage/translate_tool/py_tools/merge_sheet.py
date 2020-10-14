#############################################################################
## 번역이 끝난 시트들을 통합하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import json

from tools.merge.merge import merge


with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    merge_config_list = config_json['merge_config_list']


def merge_backup():
    for merge_config in merge_config_list:
        delta_sheet_name = merge_config['delta_sheet_name']
        backup_sheet_name = merge_config['backup_sheet_name']
        merge_method = merge_config['merge_method']

        merge(merge_method, spreadsheet_id, delta_sheet_name, backup_sheet_name, locale_list)


if __name__ == '__main__':
    print('\n*** JOB : Merge delta sheets [', ', '.join([merge_config['delta_sheet_name'] for merge_config in merge_config_list]), 
    '] and backup sheets [', ', '.join([merge_config['backup_sheet_name'] for merge_config in merge_config_list]), ']. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')

        merge_backup()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')
        
    os.system('pause')
