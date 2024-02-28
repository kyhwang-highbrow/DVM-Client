#############################################################################
## 프로젝트에서 한글을 추출하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
import re
import G_sheet.spread_sheet as spread_sheet
from tools.G_sheet.sheet_option import get_sheet_option
import time


from extract.extract import extract
from sum_data.sum_data import sum_data
from upload.upload import upload
import util.util_file as util_file
from util.util_quote import quote_row_dics
from functools import cmp_to_key
from tools.util.util_sort import cmp_scenario
from lang_codes.lang_codes import get_language_code_list
from apps_script.apps_script import execute_apps_script
from check_sync.check_sync import check_sync

plain_text_list = []
# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    spreadsheet_id = config_json['spreadsheet_id']
    extract_config_list = config_json['extract_config_list']    
    locale_list = get_language_code_list()

def start_upload(upload_method, patch_sheet_name, backup_sheet_name, all_data_list):
    ss_list_sheet = spread_sheet.get_spread_sheet(spreadsheet_id).get_work_sheet('ss_list')
    ss_info_list = quote_row_dics(spread_sheet.make_rows_to_dic(ss_list_sheet.get_all_values()))    
    
    idx = 1
    # 1번째에 추출된 텍스트 업로드
    result_data_list = []
    for row in ss_info_list:
        ss_id = row['ss_id']
        lang_code = row['lang_code']
        lang_code_list = lang_code.split(',')        
        result_data_list = upload(upload_method, patch_sheet_name, backup_sheet_name, ss_id, all_data_list, lang_code_list)
        progress_str = 'upload complete({0}/{1}) : {2}'.format(idx, len(ss_info_list), lang_code)
        print(progress_str)
        idx = idx + 1
        break

    # # 2번째부터는 1번째에 추출된 텍스트 리스트를 토대로 동기화(매번 비교하면 퍼포먼스가 느림)
    # for row in ss_info_list[1:]:
    #     ss_id = row['ss_id']
    #     lang_code = row['lang_code']
    #     lang_code_list = lang_code.split(',')
    #     sync(upload_method, patch_sheet_name, backup_sheet_name, ss_id, result_data_list, lang_code_list)
    #     progress_str = 'sync complete({0}/{1}) : {2}'.format(idx, len(ss_info_list), lang_code)
    #     idx = idx + 1
    #     print(progress_str)
    #     time.sleep(10)

        

def extract_text(extract_config):
    date = datetime.datetime.now()
    date_str = date.strftime(r'%Y.%m.%d %H:%M:%S')

    all_data_dic = {} # 각 파일로부터 나온 데이터를 저장하는 딕셔너리 변수
    all_data_list = [] # 스프레드시트를 만들 리스트 변수

    patch_sheet_name = extract_config['patch_sheet_name']
    backup_sheet_name = extract_config['backup_sheet_name']
    extract_method_list = extract_config['extract_method_list']
    sum_data_method = extract_config['sum_data_method']
    upload_method = extract_config['upload_method']

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
        only_include_file_count = len(only_include_files)
        if only_include_file_count == 0:
            from_data = extract(extract_func, source_dir, ignore_files, ignore_folders, ignore_krs)
        else:
            from_data = extract(extract_func, source_dir, ignore_files, ignore_folders, ignore_krs, only_include_files)

        print('current working info')
        print('source_dir : ', source_dir)

        # 데이터 합치기
        sum_data(sum_data_method, all_data_list, all_data_dic, from_data, locale_list, date_str)
        
        # 로그 띄우기 위한 정보
        from_src_list.append({'name' : data_name, 'data_length' : len(from_data)})

    print('Total unique texts from projects :', len(all_data_list))
    print('Found :')
    for from_src in from_src_list:
        print('\t', from_src['name'], '-', from_src['data_length'])
 
    # 하나로 모은 데이터를 구글 스프레드 시트에 작성합니다
    start_upload(upload_method, patch_sheet_name, backup_sheet_name, all_data_list)    
    return all_data_list

def find_all_color_codes():
    set_colors = set()
    text_color_list = []
    for rows in plain_text_list:
        list_result = re.findall(r'({@\w+[\w\.]*})', rows[0])        
        for color_code in list_result:
            if color_code not in set_colors:
                set_colors.add(color_code)
                text_color_list.append(color_code)
                print(color_code)
    #print(text_color_list)

def extract_text_from_config_lists():
    # 모든 시트 번역 진행도 싱크 여부를 체크
    # print('\n*** 작업      : 모든 시트 번역 진행도 싱크 여부를 체크합니다.')
    # for extract_config in extract_config_list:
    #     list = [extract_config['patch_sheet_name'], extract_config['backup_sheet_name']]
    #     if check_sync(list) == False:
    #         return

    # 추출
    print('\n*** 작업      : 프로젝트에서 텍스트를 추출합니다.')
    extracted_count = 0
    for extract_config in extract_config_list:
        extracted_text_list = extract_text(extract_config)
        extracted_count = extracted_count + len(extracted_text_list)

    print('\n*** 작업이 종료되었습니다.')

if __name__ == '__main__':
    
    extract_text_from_config_lists()
    os.system('pause')