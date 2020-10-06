#############################################################################
## 프로젝트에서 번역해야 하는 시나리오 한글을 추출하는 코드입니다.
#############################################################################

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
from tools.extract.extract_from_scenario import extract_from_scenario
from tools.upload.upload_sheet import upload
from tools.util.sort_util import cmp_scenario
from functools import cmp_to_key

search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name_list = config_json['sheet_name_list']
    scenario_text_ignore_files = config_json['scenario_text_ignore_files']
    scenario_text_ignore_folders = config_json['scenario_text_ignore_folders']

all_data_list = [] # 스프레드시트를 만들 리스트 변수
date_str = ''


def add_data(datas):
    global locale_list, all_data_list, count, date_str

    for data in datas:
        temp_data = [data[0], data[1], data[2]] # [file_name, page, speaker_kr]
        temp_data.extend(['' for _ in range(len(locale_list))])
        temp_data.append(data[3]) # text_kr
        temp_data.extend(['' for _ in range(len(locale_list))])
        temp_data.append(date_str)
        all_data_list.append(temp_data)


def start_upload():
    global sheet_name_list, spreadsheet_id, all_data_list, locale_list

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

    for sheet_name in sheet_name_list:
        upload(sheet_name, spreadsheet_id, all_data_list, header, locale_list, is_scenario=True)


def extract():
    global search_root, scenario_text_ignore_files, scenario_text_ignore_folders, all_data_list, date_str, count, sheet_name, spreadsheet_id
    
    date = datetime.datetime.now()
    date_str = date.strftime(r'%Y.%m.%d %H:%M:%S')
    
    # 1. 시나리오 폴더 안 파일들로부터 데이터를 추출합니다
    from_scenario = extract_from_scenario(search_root + r'\..\data\scenario', scenario_text_ignore_files, scenario_text_ignore_folders)

    # 2. 파일로부터 추출한 데이터를 하나로 모으고 오름차순으로 정렬합니다
    add_data(from_scenario)

    # 데이터를 정렬합니다.
    all_data_list.sort(key=cmp_to_key(cmp_scenario)) 

    # print(from_scenario)

    print('Total strings (no dup) :', len(all_data_list))
    print('Found :')
    print('\t Scenario -', len(from_scenario))

    # 3. 하나로 모은 데이터를 구글 스프레드 시트에 작성합니다
    start_upload()


if __name__ == '__main__':
    print('*** JOB : Extract scenario texts from project. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')
        
        extract()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')
        
    os.system('pause')
