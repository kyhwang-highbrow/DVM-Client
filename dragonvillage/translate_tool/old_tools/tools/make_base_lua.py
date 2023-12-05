#############################################################################
## 구글 스프레드시트로부터 lua 테이블을 생성하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
import shutil

import G_sheet.spread_sheet as spread_sheet
import util.util_file as util_file
from util.util_quote import quote_row_dics


with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    lua_table_config = config_json['base_lua_table_config']
    make_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['make_dir'])
    make_file_name_list = lua_table_config['make_file_name_list']
    backup_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['backup_dir'])
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name_list = lua_table_config['sheet_name_list']

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


def merge_all_data(work_sheets):
    # 워크시트들의 정보를 병합하여 하나의 리스트에 담습니다.
    all_data_list = [[] for _ in range(len(make_file_name_list))]
    
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
                value_list = key_value_config['value_list']
                for index, value in enumerate(value_list):
                    tr_str = ''
                    if value in row_dic:
                        tr_str = row_dic[value]
                    
                    for replace_value in key_value_config['replace_list']:
                        if tr_str != '':
                            break
                        if replace_value in row_dic:
                            tr_str = row_dic[replace_value]

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


def backup_origin():
    if backup_root is None:
        return
        
    if not os.path.isdir(backup_root):
        os.mkdir(backup_root)

    for lua_table_name in make_file_name_list:
        table_path = os.path.join(make_root, lua_table_name)
        if os.path.isfile(table_path):
            dest_path = os.path.join(backup_root, lua_table_name)
            shutil.move(table_path, dest_path)


def make_origin_lua_table():
    backup_origin()
    
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)
    for sheet_name in sheet_name_list:
        work_sheets.append(sheet.get_work_sheet(sheet_name))

    if not os.path.isdir(make_root):
        os.mkdir(make_root)
    
    all_data_list = merge_all_data(work_sheets)

    for index, lua_table_name in enumerate(make_file_name_list):
        print('Start make origin lua table :', lua_table_name)

        lua_table = make_lua(index, all_data_list)

        save_file(lua_table_name, lua_table)

    print('\n*** 작업이 종료되었습니다.')


if __name__ == '__main__':
    import tools.G_sheet.setup
    
    print('\n*** 작업      : 원본 번역 파일을 생성합니다.' 
    +     '\n*** 작업 시트 : [', ', '.join(sheet_name_list), '].')
    
    make_origin_lua_table()

    os.system('pause')