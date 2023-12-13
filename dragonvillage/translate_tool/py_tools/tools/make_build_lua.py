#############################################################################
## 구글 스프레드시트로부터 lua 테이블을 생성하는 코드입니다.
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
import extract_text
from sum_data.sum_data import sum_data
from extract.extract import extract
from lang_codes.lang_codes import get_language_code_list
from lang_codes.lang_codes import get_translation_file_dict

def getTranslatePath(sub_dir):
    # OSX
    if (sys.platform == 'darwin'):
        sub_dir = sub_dir.replace("\\", "/")
    return os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), sub_dir)


# config.json으로부터 데이터 읽기
with open('config.json', 'r', encoding='utf-8') as f: 
    config_json = json.load(f)
    spreadsheet_id = config_json['spreadsheet_id']
    lua_table_config = config_json['build_lua_table_config']
    make_root = getTranslatePath(lua_table_config['make_dir'])
    locale_list = get_language_code_list()
    translate_build_file_map = get_translation_file_dict('_build')
    translate_base_file_map = get_translation_file_dict('')
    
    #sheet_name_list = lua_table_config['sheet_name_list']
    #lang_key = lua_table_config['lang_key'] # key 
    #lang_replace_key_list = lua_table_config['lang_replace_list'] # 해당 언어의 번역이 없을 경우 대체할 언어 코드 리스트


# 루아 테이블 코드를 생성합니다.
def convert(data_list):
    arr = []
    for data in data_list:
        arr.append("['" + data[0] + "']='" + data[1] + "'")

    text = 'return {$}'.replace('$', ',\n'.join(arr))
    return text

# 루아 테이블 코드를 생성합니다.
def convert_from_lua(line):
    return line.replace('\'', "'")


# 시트들의 정보를 병합하여 총 정리
def merge_all_data(work_sheets):
    all_translate_dic = {} # all_translate_dic[key_text][lang_code] = xxx
    key_text_list = [] # 키 언어의 텍스트 순서 저장 (항상 일관적인 순서로 데이터가 출력되도록)
    lang_key_map = {} # 지금껏 나왔던 언어 코드 저장

    # 전달받은 시트를 순서대로 순회
    for work_sheet in work_sheets:
        # 시트의 row를 딕셔너리 리스트로 변환
        row_dic_list = quote_row_dics(spread_sheet.make_rows_to_dic(work_sheet.get_all_values()))

        # 시트 row 딕셔너리 순회
        for row_dic in row_dic_list:
            # 해당 row 검증
            if lang_key not in row_dic:
                continue
            if row_dic[lang_key] == '':
                continue

            # 해당 row의 key 텍스트
            key_text = row_dic[lang_key]
            if key_text == '':
                break

            # key 텍스트가 아직 전체 정보 딕셔너리에 저장되지 않았다면 추가
            if key_text not in all_translate_dic:
                all_translate_dic[key_text] = {}
                key_text_list.append(key_text)

            # 해당 key 텍스트의 번역 정보를 추가
            for row_key, row_value in row_dic.items():
                if row_key == lang_key:
                    continue
                if row_key == 'hints':
                    continue
                # 한번이라도 나왔던 언어 코드에 대해서는 저장 (파일 생성에 참고)
                if row_key not in lang_key_map:
                    lang_key_map[row_key] = True
                if row_value == '':
                    continue

                # 값 덮어씌운다
                all_translate_dic[key_text][row_key] = row_value
    
    print("Total lua table text count :", len(key_text_list))

    # 정리한 데이터를 바탕으로 언어 파일 생성을 위한 데이터 전달
    return all_translate_dic, key_text_list, lang_key_map

def make_lua(index, all_data_list):
    lua_table = convert(all_data_list[index])
    return lua_table

# 파일 저장
def save_file(file_name, data):
    file_path = os.path.join(make_root, file_name)
    util_file.write_file(file_path, data)

def extract_text(extract_config):
    date = datetime.datetime.now()
    date_str = date.strftime(r'%Y.%m.%d %H:%M:%S')

    all_data_dic = {} # 각 파일로부터 나온 데이터를 저장하는 딕셔너리 변수
    all_data_list = [] # 스프레드시트를 만들 리스트 변수


    extract_method_list = extract_config['extract_method_list']
    sum_data_method = extract_config['sum_data_method']

    from_data_map = {}
    # 각 파일로부터 데이터를 추출하고 모읍니다.
    from_src_list = []
    for extract_method in extract_method_list:
        data_name = extract_method['name']
        source_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), extract_method['src'])
        extract_func = extract_method['func']
        ignore_files = extract_method['ignore_files']
        ignore_folders = extract_method['ignore_folders']
        ignore_krs = extract_method['ignore_krs']
        only_include_files = extract_method['only_include_files']
        
        # 설정으로부터 추출된 데이터, 리스트 형태일수도 딕셔너리 형태일수도 있음
        from_data = extract(extract_func, source_dir, ignore_files, ignore_folders, ignore_krs, only_include_files)

        print('current working info')
        print('source_dir : ', source_dir)

        # 데이터 합치기
        sum_data(sum_data_method, all_data_list, all_data_dic, from_data, locale_list, date_str)
        
        # 로그 띄우기 위한 정보
        # from_src_list.append({'name' : data_name, 'data_length' : len(from_data)})
        from_data_map.update(from_data)
    return from_data_map


# 원본 번역 파일 생성
def make_build_lua_table():
    # translate/lang_언어.lua 를 모두 읽어서 모든 언어에 대한 딕셔너리를 만듦
    # (주의) 그래서 make_base_lua로 기본 언어 파일이 먼저 만들자.

    # 번역이 필요한 문구들 추출
    extract_config_list = lua_table_config['extract_list']
    build_key_text_list = []
    key_map = {}
    for extract_config in extract_config_list:
        #build_key_text_list.extend(extract_text.extract_text(extract_config))
        key_map.update(extract_text(extract_config))
        print(build_key_text_list)
        print("Total build text count :", len(build_key_text_list))

    for key_text in key_map.keys():
        build_key_text_list.append(key_text.replace("'", "\'"))

    #build_key_text_list.extend(list(key_map.keys()))
    # 지금껏 나온 언어 코드들을 정리하여 언어 빌드 번역 파일 생성
    for lang_key in locale_list:
        lua_table_name = make_root +  '\\' + translate_build_file_map[lang_key]        
        lua_file_name = make_root + '\\' + translate_base_file_map[lang_key]
        all_translate_dic = {}

        try:
            with open(lua_file_name, 'r', encoding='utf-8') as f:
                all_data = f.read()
                reg_find_case_1 = re.compile(r"\['(.+)'\]=\'(.+)\'")
                find_datas = reg_find_case_1.findall(all_data)                
                #all_translate_dic = dict((x, y) )
                for x, y in find_datas:
                    all_translate_dic[x] = y
                #print(all_translate_dic)                
            
        except:
            print('해당 파일을 읽는 도중 문제가 발생했습니다. :', lua_file_name)
            os.system('pause')

        print('Start make build lua table :', lua_table_name)

        data_list = []
        for _, build_key_text_data in enumerate(build_key_text_list):
            key_text = build_key_text_data.replace("\'", "\\'")           
            # key text
            translated_text = key_text
            # 해당 번역이 존재한다면 
            if key_text in all_translate_dic:
                translated_text = all_translate_dic[key_text]
            # # 번역 존재 안하면 다른 거로 대입
            # else:
            #     for replace_lang_key in lang_replace_key_list:
            #         if replace_lang_key in all_translate_dic[key_text]:
            #             translated_text = all_translate_dic[key_text][replace_lang_key]
            #             break

            data_list.append([key_text, translated_text])
        # 해당 언어에 정리된 루아 테이블 생성 및 저장
        lua_table = convert(data_list)
        save_file(lua_table_name, lua_table)        
    print('\n*** 작업이 종료되었습니다.')


# 외부 실행을 위한 함수
def execute():
    import tools.G_sheet.setup
    print('\n*** 작업      : 빌드 번역 파일을 생성합니다.')
    make_build_lua_table()

if __name__ == '__main__':
    execute()    
    os.system('pause')