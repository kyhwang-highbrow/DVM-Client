#############################################################################
## 구글 스프레드시트로부터 lua 테이블을 생성하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
import shutil
import copy

import G_sheet.spread_sheet as spread_sheet
import util.util_file as util_file
from util.util_quote import quote_row_dics
from lang_codes.lang_codes import get_translation_file_dict

with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    lua_table_config = config_json['base_lua_table_config']
    make_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['make_dir'])
    make_file_name_dict = get_translation_file_dict("")

    backup_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['backup_dir'])
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name_list = lua_table_config['sheet_name_list']   

    row_replace_dic = {}


print ("make directory :", make_root)
sheet = None
work_sheets = []

# 루아 테이블 코드를 생성합니다.
def convert(data_list):
    text = 'return {$}'
    arr = []

    for data in data_list:
        arr.append("['" + data[0] + "']='" + data[1] + "'")

    text = text.replace('$', ',\n'.join(arr))

    return text


def merge_all_data(work_sheets, locale_list, file_name_list):
    # 워크시트들의 정보를 병합하여 하나의 리스트에 담습니다.
    all_data_list = [[] for _ in range(len(file_name_list))]
    
    for work_sheet in work_sheets:
        row_dics = quote_row_dics(spread_sheet.make_rows_to_dic(work_sheet.get_all_values()))

        for row_dic in row_dics:
            # 이미 담은 단어인지 판단합니다.
            for key_value_config in lua_table_config['key_value_list']:                
                key = key_value_config['key']
                if key not in row_dic:
                    continue
                
                ignore_this = False
                for data in all_data_list[0]:
                    if data[0] == row_dic[key]:
                        ignore_this = True
                        break
                if row_dic[key] == '':
                    ignore_this = True
                
                if ignore_this:
                    continue                    
                
                # 번역어 담기, 만약 없다면 영어, 영어도 없다면 한국어를 담습니다.
                value_list = locale_list
                for index, value in enumerate(value_list):
                    col_name = key_value_config['keyword'] + value
                    tr_str = ''
                    if col_name in row_dic:
                        tr_str = row_dic[col_name]
                    
                    for replace_value in key_value_config['replace_list']:
                        if replace_value in row_dic:
                            if replace_value not in row_replace_dic :
                                row_replace_dic[replace_value] = {}

                            row_replace_dic[replace_value][row_dic[key]] = row_dic[replace_value]                            

                        if tr_str != '':
                            break

                        if replace_value in row_replace_dic:
                            tr_str = row_replace_dic[replace_value][row_dic[key]] #row_dic[replace_value]

                    if tr_str == '':
                        tr_str = row_dic[key]

                    all_data_list[index].append([row_dic[key], tr_str])

    print("Origin lua table text count :", len(all_data_list[0]))
    return all_data_list


def make_lua(index, all_data_list):
    lua_table = convert(all_data_list[index])
    return lua_table

def save_file(file_name, data):
    file_path = os.path.join(make_root, file_name)
    util_file.write_file(file_path, data)

def backup_origin(make_file_name_list):
    for lua_table_name in make_file_name_list:
        table_path = os.path.join(make_root, lua_table_name)
        if os.path.isfile(table_path):
            dest_path = os.path.join(backup_root, lua_table_name)
            shutil.move(table_path, dest_path)

def make_origin_lua_table():
    if not os.path.isdir(make_root):
        os.mkdir(make_root)

    idx = 1
    ss_list_sheet = spread_sheet.get_spread_sheet(spreadsheet_id).get_work_sheet('ss_list')    
    ss_info_list = quote_row_dics(spread_sheet.make_rows_to_dic(ss_list_sheet.get_all_values()))
    for row in ss_info_list:
        ss_id = row['ss_id']
        lang_code = row['lang_code']
        lang_code_list = lang_code.split(',')
        make_file_name_list = [] 

        for lang in lang_code_list:
            make_file_name_list.append(make_file_name_dict[lang])

        # 정리한 번역 스프레드시트 ID 리스트를 순회하며 필요한 시트 데이터 정리 및 병합
        work_sheets = [] 
        progress_str = 'Make Base Lua Start({0}/{1}) : {2}'.format(idx, len(ss_info_list), lang_code)
        print(progress_str)
        
        # 백업하기
        backup_origin(make_file_name_list)

        idx = idx + 1
        sheet = spread_sheet.get_spread_sheet(ss_id)
        for sheet_name in sheet_name_list:
            work_sheets.append(sheet.get_work_sheet(sheet_name))

        all_data_list = merge_all_data(work_sheets, lang_code_list, make_file_name_list)
        for index, lua_table_name in enumerate(make_file_name_list):            
            lua_table = make_lua(index, all_data_list)
            save_file(lua_table_name, lua_table)

    print('\n*** 작업이 종료되었습니다.')


if __name__ == '__main__':
    import tools.G_sheet.setup
    print('\n*** 작업      : 백업 파일을 생성상합니다.' )
    
    if backup_root is not None:        
        if not os.path.isdir(backup_root):
            os.mkdir(backup_root)

    print('\n*** 작업      : 원본 번역 파일을 생성합니다.' 
    +     '\n*** 작업 시트 : [', ', '.join(sheet_name_list), '].')

    make_origin_lua_table()

    os.system('pause')