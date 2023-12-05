
#############################################################################
## 언어 리스트를 가지고 스프레드 시트 폼 만들기
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
import time
import shutil
import re
import copy

import G_sheet.spread_sheet as spread_sheet
import util.util_file as util_file
from util.util_quote import quote_row_dics
from upload.upload import upload
from make_form.make_form import make_form
from lang_codes.lang_codes import get_language_code_list
from lang_codes.lang_codes import get_translation_file_list

with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    lua_table_config = config_json['base_lua_table_config']
    make_sheet_form_config = config_json['make_sheet_form_config']
    make_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['make_dir'])
    locale_list = get_language_code_list()
    make_file_name_list = get_translation_file_list('')

    backup_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['backup_dir'])
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name_list = lua_table_config['sheet_name_list']

def make_sheet_form():
    sheet_id_list = make_sheet_form_config['sheet_id_list']
    sheet_form_method_list = make_sheet_form_config['sheet_form_method_list']
    copy_locale_list = get_language_code_list()
    result_list = []

    while len(copy_locale_list) > 0:
        lang_list = []
        str = ""
        for i in range(0, 10):            
            if len(copy_locale_list) > 0:
                lang = copy_locale_list[0]
                lang_list.append(lang)                
                str = str + lang + ", "
                copy_locale_list.remove(lang)
                #print('언어 ' + lang)
        #print("생성 언어 리스트", len(lang_list))
        #print(lang_list)
        result_list.append(lang_list)

    num = 0
    for spreadsheet_id in sheet_id_list:
        #sheet = spread_sheet.get_spread_sheet(spreadsheet_id)
        locales = result_list[num]
        num = num + 1
        for sheet_form_method in sheet_form_method_list:
            make_method = sheet_form_method['make_method']
            patch_sheet_name = sheet_form_method['patch_sheet_name']
            backup_sheet_name = sheet_form_method['backup_sheet_name']
            make_form(make_method, patch_sheet_name, backup_sheet_name, spreadsheet_id, locales)
        time.sleep(10)

    print('폼 생성 완료!!')


if __name__ == '__main__':
    import tools.G_sheet.setup
    print('\n*** 작업      : 스프레드 시트 폼을 만듭니다.' 
    +     '\n*** 작업 시트 : [', ', '.join(sheet_name_list), '].')
    make_sheet_form()
    os.system('pause')