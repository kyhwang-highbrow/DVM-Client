#############################################################################
## 프로젝트에서 번역해야 하는 일반 텍스트 한글을 추출하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
from tools.extract.extract_from_lua import extract_from_lua
from tools.extract.extract_from_UI import extract_from_UI
from tools.extract.extract_from_csv import extract_from_csv
from tools.upload.upload_sheet import upload

search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name = config_json['plain_text_sheet_name']
    plain_text_ignore_files = config_json['plain_text_ignore_files']
    plain_text_ignore_folders = config_json['plain_text_ignore_folders']
    plain_text_ignore_krs = config_json['plain_text_ignore_krs']

all_data_dic = {} # 각 파일로부터 나온 데이터를 저장하는 딕셔너리 변수
all_data_list = [] # 스프레드시트를 만들 리스트 변수


def add_data(datas, date_str):
    for data_key in datas:
        if data_key == 'length':
            continue
        if plain_text_ignore_krs.count(data_key) > 0:
            continue

        if data_key not in all_data_dic.keys():
            all_data_dic[data_key] = {}
            all_data_dic[data_key]['hints'] = datas[data_key]['hints']
            
            temp_data = [data_key]
            for _ in range(len(locale_list)):
                temp_data.append('')
            temp_data.append(','.join(datas[data_key]['hints']))
            temp_data.append(date_str)
            all_data_list.append(temp_data)

        hints = datas[data_key]['hints']
        for hint in hints:
            if all_data_dic[data_key]['hints'].count(hint) == 0: # 겹치는 단어가 다른 파일에서 나온 경우
                all_data_dic[data_key]['hints'].append(hint) # 단어 힌트에 이 파일 이름을 추가합니다.
                for data in all_data_list:
                    if data[0] == data_key:
                        data[1 + len(locale_list)] += ',' + hint
                        break


def start_upload():
    print('Upload start :', spreadsheet_id)
    print('Locale list :', ', '.join(locale_list))

    # 새로 만들 시트의 헤더입니다.
    header = ['kr']
    for locale in locale_list:
        header.append(locale)
    header.append('hints')
    header.append('date')

    upload(sheet_name, spreadsheet_id, all_data_list, header, locale_list)


def extract():
    date = datetime.datetime.now()
    date_str = date.strftime(r'%Y.%m.%d %H:%M:%S')
    
    # 1. 각 파일로부터 데이터를 추출합니다
    from_lua = extract_from_lua(search_root + r'\..\src', plain_text_ignore_files, plain_text_ignore_folders)
    from_UI = extract_from_UI(search_root + r'\..\res', plain_text_ignore_files, plain_text_ignore_folders)
    from_sv_data = extract_from_csv(search_root + r'\..\..\sv_tables', plain_text_ignore_files, plain_text_ignore_folders)
    from_sv_patch_data = extract_from_csv(search_root + r'\..\..\sv_tables_patch', plain_text_ignore_files, plain_text_ignore_folders)
    from_data = extract_from_csv(search_root + r'\..\data', plain_text_ignore_files, plain_text_ignore_folders)

    # 2. 파일로부터 추출한 데이터를 하나로 모으고 kr을 기준으로 오름차순으로 정렬합니다
    add_data(from_lua, date_str)
    add_data(from_UI, date_str)
    add_data(from_sv_data, date_str)
    add_data(from_sv_patch_data, date_str)
    add_data(from_data, date_str)

    all_data_list.sort(key=lambda line: line[0]) 

    print('Total unique texts from projects :', len(all_data_list))
    print('Found :')
    print('\t Lua -', from_lua['length'])
    print('\t UI -', from_UI['length'])
    print('\t SvData -', from_sv_data['length'])
    print('\t SvPatchData -', from_sv_patch_data['length'])
    print('\t CSV -', from_data['length'])
    
    # 3. 하나로 모은 데이터를 구글 스프레드 시트에 작성합니다
    start_upload() 


if __name__ == '__main__':
    print('*** JOB : Extract plain texts from project at sheet [', sheet_name, ']. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')
        
        extract()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')

    os.system('pause')
