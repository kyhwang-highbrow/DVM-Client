#############################################################################
## 구글 스프레드시트로부터 루아 테이블을 생성하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import json
import tools.G_sheet.spread_sheet as spread_sheet
import tools.util.file_util as file_util
from tools.extract.extract_from_lua import extract_from_lua_only_kr
from tools.extract.extract_from_UI import extract_from_UI_only_kr
from tools.extract.extract_from_csv import extract_from_csv_only_kr
from tools.extract.extract_from_scenario import extract_from_scenario_only_kr


with open('config.json', 'r') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name_list = config_json['sheet_name_list']
    plain_text_ignore_files = config_json['plain_text_ignore_files']
    plain_text_ignore_folders = config_json['plain_text_ignore_folders']
    scenario_text_ignore_files = config_json['scenario_text_ignore_files']
    scenario_text_ignore_folders = config_json['scenario_text_ignore_folders']

search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
make_root = search_root +  r'\..\translate\newLuaTable'
print ("make directory :", make_root)
sheet = None
work_sheets = []


# 각종 특수문자들을 올바르게 처리합니다.
def quote(text):
    value = text.replace("\'", "\\'").replace('\"', '\\"').replace('\\\\n', '\\n')
    return value


# 루아 테이블 코드를 생성합니다.
def convert(data_list):
    text = 'return {$}'
    arr = []

    for data in data_list:
        arr.append("['" + quote(data[0]) + "']='" + quote(data[1]) + "'")

    text = text.replace('$', ',\n'.join(arr))

    return text

# 텍스트 데이터를 중복 없이 합치는 작업
def merge_kr(sum_data, add_data):
    for data in add_data:
        if sum_data.count(data) == 0:
            sum_data.append(data)

    return sum_data

# 현재 프로젝트에서 사용되는 텍스트 데이터를 추출하는 작업
def search_kr():
    from_lua_only_kr = extract_from_lua_only_kr(search_root + r'\..\src', plain_text_ignore_files, plain_text_ignore_folders)
    from_UI_only_kr = extract_from_UI_only_kr(search_root + r'\..\res', plain_text_ignore_files, plain_text_ignore_folders)
    from_sv_data_only_kr = extract_from_csv_only_kr(search_root + r'\..\..\sv_tables', plain_text_ignore_files, plain_text_ignore_folders)
    from_sv_patch_data_only_kr = extract_from_csv_only_kr(search_root + r'\..\..\sv_tables_patch', plain_text_ignore_files, plain_text_ignore_folders)
    from_data_only_kr = extract_from_csv_only_kr(search_root + r'\..\data', plain_text_ignore_files, plain_text_ignore_folders)

    
    from_scenario_only_kr = extract_from_scenario_only_kr(search_root + r'\..\data\scenario', scenario_text_ignore_files, scenario_text_ignore_folders)

    using_data_list = [] # 현재 사용되고 있는 텍스트 데이터를 저장할 리스트 변수
    merge_kr(using_data_list, from_lua_only_kr)
    merge_kr(using_data_list, from_UI_only_kr)
    merge_kr(using_data_list, from_sv_data_only_kr)
    merge_kr(using_data_list, from_sv_patch_data_only_kr)
    merge_kr(using_data_list, from_data_only_kr)
    merge_kr(using_data_list, from_scenario_only_kr)

    return using_data_list


def merge_all_data(work_sheets):
    global locale_list

    # 워크시트들의 정보를 병합하여 하나의 리스트에 담습니다.
    all_data_list = {}
    for locale in locale_list:
        all_data_list[locale] = []
    
    for work_sheet in work_sheets:
        row_dics = spread_sheet.make_rows_to_dic(work_sheet.get_all_values())
        for row_dic in row_dics:
            # 이미 담은 단어인지 판단합니다.
            ignore_this = False
            for data in all_data_list[locale_list[0]]:
                if data[0] == row_dic['kr']:
                    ignore_this = True
                    break
            if ignore_this:
                continue

            # 번역어 담기, 만약 없다면 영어, 영어도 없다면 한국어를 담습니다.
            for locale in all_data_list:
                tr_str = ''
                if locale in row_dic:
                    tr_str = row_dic[locale]
                if tr_str == '':
                    tr_str = row_dic['en']
                if tr_str == '':
                    tr_str = row_dic['kr']
                all_data_list[locale].append([row_dic['kr'], tr_str])

            if 'speaker_kr' in row_dic.keys(): # 만약 화자가 있다면 추가로 담습니다.
                for data in all_data_list[locale_list[0]]:
                    if data[0] == row_dic['speaker_kr']:
                        ignore_this = True
                        break
                if row_dic['speaker_kr'] == '':
                    ignore_this = True
                if not ignore_this :
                    for locale in locale_list:
                        speaker_locale = 'speaker_' + locale
                        tr_speaker = ''
                        if speaker_locale in row_dic:
                            tr_speaker = row_dic[speaker_locale]
                        if tr_speaker == '':
                            tr_speaker = row_dic['speaker_en']
                        if tr_speaker == '':
                            tr_speaker = row_dic['speaker_kr']
                        all_data_list[locale].append([row_dic['speaker_kr'], tr_speaker])

    print("Lua table text count :", len(all_data_list[locale_list[0]]))

    return all_data_list


def make_lua(locale, all_data_list):
    lua_table = convert(all_data_list[locale])

    return lua_table


def save_file(file_name, data):
    global make_root
    file_path = os.path.join(make_root, file_name)
    file_util.write_file(file_path, data)


def make_all():
    global locale_list, sheet_name_list, spreadsheet_id, sheet, work_sheets, make_root

    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)
    for sheet_name in sheet_name_list:
        work_sheets.append(sheet.get_work_sheet(sheet_name))
        work_sheets.append(sheet.get_work_sheet(sheet_name + '_backup'))

    file_util.make_dir(make_root)
    
    all_data_list = merge_all_data(work_sheets)

    for locale in locale_list:
        print('Start make lua :', locale)

        lua_table = make_lua(locale, all_data_list)

        save_file('lang_' + locale + '.lua', lua_table)

    print('Making lua table is done.')

if __name__ == '__main__':
    print('*** JOB : Make lua tables from spreadsheets. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')

        make_all()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')
        
    os.system('pause')