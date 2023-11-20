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

from extract.extract import extract
from sum_data.sum_data import sum_data
from upload.upload import upload
import util.util_file as util_file
from util.util_quote import quote_row_dics
from functools import cmp_to_key
from tools.util.util_sort import cmp_scenario
from lang_codes.lang_codes import get_language_code_list


plain_text_list = []
# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    spreadsheet_id = config_json['spreadsheet_id']
    extract_config_list = config_json['extract_config_list']
    integration_spreadsheet_id = config_json['integration_spreadsheet_id']
    locale_list = get_language_code_list()

def start_upload(upload_method, patch_sheet_name, backup_sheet_name, all_data_list):
    ss_list_sheet = spread_sheet.get_spread_sheet(spreadsheet_id).get_work_sheet('ss_list')
    ss_info_list = quote_row_dics(spread_sheet.make_rows_to_dic(ss_list_sheet.get_all_values()))    

    idx = 1
    for row in ss_info_list:
        ss_id = row['ss_id']
        lang_code = row['lang_code']
        lang_code_list = lang_code.split(',')        
        
        progress_str = 'Upload start({0}/{1}) : {2}'.format(idx, len(ss_info_list), lang_code)
        print(progress_str)

        upload(upload_method, patch_sheet_name, backup_sheet_name, ss_id, all_data_list, lang_code_list)        
        idx = idx + 1

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
        
        # 설정으로부터 추출된 데이터, 리스트 형태일수도 딕셔너리 형태일수도 있음
        from_data = extract(extract_func, source_dir, ignore_files, ignore_folders, ignore_krs)

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
    # start_upload(upload_method, patch_sheet_name, backup_sheet_name, all_data_list) 
    #make_plain_text_list(upload_method, all_data_list)
    
    return all_data_list
    
def make_plain_text_list(upload_method, all_data_list):
    if upload_method == "upload_DVM_plain_text":
        temp_text_list = []
        for data in all_data_list:
            temp_data = []
            temp_data.append(data[0])
            temp_data.extend(['' for _ in range(len(locale_list))])
            temp_data.append('plain_text')
            temp_text_list.append(temp_data)
        temp_text_list.sort(key=lambda line: line[0])
        plain_text_list.extend(temp_text_list)

    else:
        # 데이터를 파일 이름과 페이지 값을 이용하여 정렬합니다.
        all_data_list.sort(key=cmp_to_key(cmp_scenario)) 
        for data in all_data_list:
            temp_data1 = []
            temp_data1.append(data[2])
            temp_data1.extend(['' for _ in range(len(locale_list))])
            temp_data1.append('scenario_speaker')
            plain_text_list.append(temp_data1)

        len_locale_list = len(locale_list)
        for data in all_data_list:
            temp_data2 = []            
            temp_data2.append(data[2 + len_locale_list + 1])
            temp_data2.extend(['' for _ in range(len(locale_list))])
            temp_data1.append('scenario_text')
            plain_text_list.append(temp_data2)

def upload_integration_sheet():
    if len(plain_text_list) == 0:
        return
    
    # 헤더를 생성합니다.
    header = ['kr']
    for locale in locale_list:
        header.append(locale)

    # 시트를 만들 때 사용될 칼럼 사이즈입니다.
    col_size = len(header)

    # 스프레드시트의 아이디값을 이용하여 연결합니다.
    sheet = spread_sheet.get_spread_sheet(integration_spreadsheet_id)

    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    delta_sheet = sheet.get_work_sheet('DIFF')
    # if delta_sheet is not None:
    #     sheet.del_work_sheet(delta_sheet)
    #     delta_sheet = None

    # 헤더 생성
    if delta_sheet is None:
        backup_option = {}
        backup_option['rows'] = 1
        backup_option['cols'] = col_size
        delta_sheet = sheet.add_work_sheet('DIFF', backup_option)
        delta_sheet.insert_row(header, 1, value_input_option='RAW')
        #sheet_id = delta_sheet._properties['sheetId']
        #sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
        #sheet.batch_update(sheet_option)

    # 행들 추가
    exist_datas = delta_sheet.get_all_values()
    row_size = len(exist_datas) + 1
    delta_sheet.resize(rows=row_size)

    if len(plain_text_list) > 0:
        delta_sheet.insert_rows(plain_text_list, row_size, value_input_option='RAW')

    # 시트의 크기를 보기 좋게 조정합니다.
    # sheet_id = delta_sheet._properties['sheetId']
    # sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
    # sheet.batch_update(sheet_option)

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
    for extract_config in extract_config_list:
        extract_text(extract_config)
    # 통합 시트에 올리기
    # upload_integration_sheet()
    # 색상 코드 추출
    # find_all_color_codes()
    print('\n*** 작업이 종료되었습니다.')

if __name__ == '__main__':
    print('\n*** 작업      : 프로젝트에서 텍스트를 추출합니다.')
    extract_text_from_config_lists()
    os.system('pause')