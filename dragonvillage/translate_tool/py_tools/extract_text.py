#############################################################################
## 프로젝트에서 한글을 추출하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json

from tools.extract.extract import extract
from tools.sum_data.sum_data import sum_data
from tools.upload.upload import upload


# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    extract_config = config_json['extract_config']
    
    delta_sheet_name = extract_config['delta_sheet_name']
    backup_sheet_name = extract_config['backup_sheet_name']
    extract_method_list = extract_config['extract_method_list']
    sum_data_method = extract_config['sum_data_method']
    upload_method = extract_config['upload_method']

all_data_dic = {} # 각 파일로부터 나온 데이터를 저장하는 딕셔너리 변수
all_data_list = [] # 스프레드시트를 만들 리스트 변수


def start_upload():
    print('Upload start :', spreadsheet_id)
    print('Locale list :', ', '.join(locale_list))
    print('Upload method :', upload_method)

    # 새로 만들 시트의 헤더입니다.
    
    upload(upload_method, delta_sheet_name, backup_sheet_name, spreadsheet_id, all_data_list, locale_list)


def extract_plain():
    date = datetime.datetime.now()
    date_str = date.strftime(r'%Y.%m.%d %H:%M:%S')
    
    # 각 파일로부터 데이터를 추출하고 모읍니다.
    from_src_list = []
    for extract_method in extract_method_list:
        data_name = extract_method['name']
        source_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), extract_method['src'])
        extract_func = extract_method['func']
        ignore_files = extract_method['ignore_files']
        ignore_folders = extract_method['ignore_folders']
        ignore_krs = extract_method['ignore_krs']
        
        # 설정으로부터 추출된 데이터, 리스트 형태일수도 딕셔너리 형태일수도 있음
        from_data = extract(extract_func, source_dir, ignore_files, ignore_folders, ignore_krs)

        # 데이터 합치기
        sum_data(sum_data_method, all_data_list, all_data_dic, from_data, locale_list, date_str)
        
        # 로그 띄우기 위한 정보
        from_src_list.append({'name' : data_name, 'data_length' : len(from_data)})

    print('Total unique texts from projects :', len(all_data_list))
    print('Found :')
    for from_src in from_src_list:
        print('\t', from_src['name'], '-', from_src['data_length'])
 
    # 하나로 모은 데이터를 구글 스프레드 시트에 작성합니다
    start_upload() 


if __name__ == '__main__':
    print('\n*** JOB : Extract plain texts from project at sheet [', delta_sheet_name, ']. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')
        
        extract_plain()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')

    os.system('pause')
