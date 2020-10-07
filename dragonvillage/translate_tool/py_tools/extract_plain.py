#############################################################################
## 프로젝트에서 일반 텍스트 한글을 추출하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json

from tools.extract.extract import extract
from tools.G_sheet.upload_sheet import upload


search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name = config_json['plain_text_sheet_name']
    sheet_extract_list = config_json['plain_text_extract']
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


def extract_plain():
    date = datetime.datetime.now()
    date_str = date.strftime(r'%Y.%m.%d %H:%M:%S')
    
    # 1. 각 파일로부터 데이터를 추출하고 모읍니다.
    from_src_list = []
    for sheet_extract in sheet_extract_list:
        data_name = sheet_extract['name']
        source_dir = search_root + sheet_extract['src']
        extract_func = sheet_extract['func']
        from_data = extract(source_dir, extract_func, plain_text_ignore_files, plain_text_ignore_folders)
        add_data(from_data, date_str)
        from_src_list.append({'name' : data_name, 'data' : from_data})

    print('Total unique texts from projects :', len(all_data_list))
    print('Found :')
    for from_src in from_src_list:
        print('\t', from_src['name'], '-', len(from_src['data']))

    # 2. 데이터를 kr을 기준으로 오름차순으로 정렬합니다
    all_data_list.sort(key=lambda line: line[0]) 
 
    # 3. 하나로 모은 데이터를 구글 스프레드 시트에 작성합니다
    start_upload() 


if __name__ == '__main__':
    print('*** JOB : Extract plain texts from project at sheet [', sheet_name, ']. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')
        
        extract_plain()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')

    os.system('pause')
