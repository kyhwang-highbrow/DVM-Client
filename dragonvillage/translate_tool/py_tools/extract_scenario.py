#############################################################################
## 프로젝트에서 시나리오 텍스트 한글을 추출하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json

from tools.extract.extract import extract
from tools.G_sheet.upload_sheet import upload
from tools.util.util_sort import cmp_scenario
from functools import cmp_to_key


search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name = config_json['scenario_sheet_name']
    sheet_extract_list = config_json['scenario_extract']
    scenario_text_ignore_files = config_json['scenario_text_ignore_files']
    scenario_text_ignore_folders = config_json['scenario_text_ignore_folders']
    scenario_text_ignore_krs = config_json['scenario_text_ignore_krs']

all_data_list = [] # 스프레드시트를 만들 리스트 변수


def add_data(datas, date_str):
    for data in datas:
        if scenario_text_ignore_krs.count(data[3]) > 0:
            continue
        temp_data = [data[0], data[1], data[2]] # [file_name, page, speaker_kr]
        temp_data.extend(['' for _ in range(len(locale_list))])
        temp_data.append(data[3]) # text_kr
        temp_data.extend(['' for _ in range(len(locale_list))])
        temp_data.append(date_str)
        all_data_list.append(temp_data)


def start_upload():
    print('Upload start :', spreadsheet_id)
    print('Locale list :', ', '.join(locale_list))

    # 새로 만들 시트의 헤더입니다.
    header = ['fileName', 'page', 'speaker_kr']
    for locale in locale_list:
        header.append('speaker_' + locale)
    header.append('kr')
    for locale in locale_list:
        header.append(locale)
    header.append('date')

    upload(sheet_name, spreadsheet_id, all_data_list, header, locale_list, is_scenario=True)


def extract_scenario():
    date = datetime.datetime.now()
    date_str = date.strftime(r'%Y.%m.%d %H:%M:%S')
    
    # 1. 시나리오 폴더 안 파일들로부터 데이터를 추출하고 모읍니다.
    from_src_list = []
    for sheet_extract in sheet_extract_list:
        data_name = sheet_extract['name']
        source_dir = search_root + sheet_extract['src']
        extract_func = sheet_extract['func']
        from_data = extract(source_dir, extract_func, scenario_text_ignore_files, scenario_text_ignore_folders)
        add_data(from_data, date_str)
        from_src_list.append({'name' : data_name, 'data' : from_data})

    print('Total unique texts from projects :', len(all_data_list))
    print('Found :')
    for from_src in from_src_list:
        print('\t', from_src['name'], '-', len(from_src['data']))

    # 2. 데이터를 파일 명과 페이지를 기준으로 오름차순으로 정렬합니다
    all_data_list.sort(key=cmp_to_key(cmp_scenario)) 

    # 3. 하나로 모은 데이터를 구글 스프레드 시트에 작성합니다
    start_upload()


if __name__ == '__main__':
    print('*** JOB : Extract scenario texts from project at sheet [', sheet_name, ']. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')
        
        extract_scenario()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')
        
    os.system('pause')
