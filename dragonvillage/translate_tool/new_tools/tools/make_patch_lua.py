#############################################################################
## 구글 스프레드시트와 원본 lua 테이블을 비교하여 델타 lua 테이블을 생성하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
import shutil
import re

import G_sheet.spread_sheet as spread_sheet
import util.util_file as util_file
from util.util_quote import quote_row_dics
from lang_codes.lang_codes import get_language_code_list
from lang_codes.lang_codes import get_translation_file_list


with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    lua_table_config = config_json['patch_lua_table_config']
    make_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['make_dir'])
    locale_list = get_language_code_list()
    make_file_name_list = get_translation_file_list('_patch')

    compare_root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), lua_table_config['compare_dir'])
    compare_file_name_list = get_translation_file_list('')
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
    all_data_list = [[] for _ in range(len(lua_table_config['make_file_name_list']))]
    
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
                        if tr_str != '':
                            break
                        if replace_value in row_dic:
                            tr_str = row_dic[replace_value]

                    if tr_str == '':
                        tr_str = row_dic[key]

                    all_data_list[index].append([row_dic[key], tr_str])

    return all_data_list


# data_list와 data_dic 비교하여 새로운 KEY 값이거나 VALUE가 다르다면 추가합니다.
def compare_data(data_list, data_dic):
    result = []
    
    for data in data_list:
        k, v = data[0], data[1]
        if k in data_dic.keys():
            if v == data_dic[k]:
                continue
        result.append([k, v])
        print('== Find delta ==')
        print('Sheet key :', k)
        print('Sheet val :', v)
        print('Lua   val :', data_dic[k] if k in data_dic.keys() else 'NO VALUE IN LUA')
        print('================')

    return result


# 루아 테이블 파일에서 KEY/VALUE 추출하여 딕셔너리 형태로 반환합니다.
def get_lua_to_dic(path):
    result = {}
    try:
        with open(path, 'r', encoding='utf-8') as origin_lua_file:
            data = origin_lua_file.read()
            kv_pattern_1 = re.compile(r"\['(.*?)'\]='(.*?)',\n") # [1, N - 1] lines
            kv_pattern_2 = re.compile(r"\['(.*?)'\]='(.*?)'}") # N line
            find_kv_list = kv_pattern_1.findall(data)
            find_kv_list.extend(kv_pattern_2.findall(data))
            for k, v in find_kv_list:
                result[k] = v
    except FileNotFoundError:
        print('BACKUP FILE NOT FOUND :', path)
        os.system('pause')

    return result


def make_delta_lua(index, all_data_list):
    compare_data_dic = get_lua_to_dic(os.path.join(compare_root, compare_file_name_list[index]))

    change_data_list = compare_data(all_data_list[index], compare_data_dic)
    
    print("Delta lua table text count :", len(change_data_list))

    lua_table = convert(change_data_list)

    return lua_table


def save_file(file_name, data):
    file_path = os.path.join(make_root, file_name)
    util_file.write_file(file_path, data)


def make_delta_lua_table():
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)
    for sheet_name in sheet_name_list:
        work_sheets.append(sheet.get_work_sheet(sheet_name))

    if not os.path.isdir(make_root):
        os.mkdir(make_root)
    
    all_data_list = merge_all_data(work_sheets)

    for index, lua_table_name in enumerate(lua_table_config['make_file_name_list']):
        print('Start make delta lua table :', lua_table_name)

        lua_table = make_delta_lua(index, all_data_list)

        save_file(lua_table_name, lua_table)

    print('\n*** 작업이 종료되었습니다.')



if __name__ == '__main__':
    import tools.G_sheet.setup

    print('\n*** 작업      : 패치 번역 파일을 생성합니다.' 
    +     '\n*** 작업 시트 : [', ', '.join(sheet_name_list), '].')

    make_delta_lua_table()
    
    os.system('pause')