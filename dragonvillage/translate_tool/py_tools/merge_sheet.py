#############################################################################
## 번역이 끝난 시트들을 통합하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import json
import tools.G_sheet.spread_sheet as spread_sheet
from tools.upload.upload_sheet import upload
from tools.util.sort_util import cmp_scenario
from functools import cmp_to_key


with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    locale_list = config_json['locale_list']
    spreadsheet_id = config_json['spreadsheet_id']
    sheet_name_list = [config_json['plain_text_sheet_name'], config_json['scenario_sheet_name']]
    plain_text_ignore_files = config_json['plain_text_ignore_files']
    plain_text_ignore_folders = config_json['plain_text_ignore_folders']


def make_header(is_scenario):
    global locale_list

    header = []
    if is_scenario:
        header.extend(['fileName', 'page', 'speaker_kr'])
        for locale in locale_list:
            header.append('speaker_' + locale)
    header.append('kr')
    for locale in locale_list:
        header.append(locale)
    if not is_scenario:
        header.append('hints')
    header.append('date')

    return header
    

def merge_data(all_data_list, data_dic, header, is_scenario):
    if is_scenario:
        speaker_index = header.index('speaker_kr')
        text_index = header.index('kr')
        for dic in data_dic:
            index = len(all_data_list)
            temp_list = ['' for _ in range(len(header))]
            temp_list[speaker_index] = dic['speaker_kr']
            temp_list[text_index] = dic['kr']
            all_data_list.append(temp_list)

            for i, header_value in enumerate(header):
                if header_value == 'kr' or header_value == 'speaker_kr':
                    continue
                if all_data_list[index][i] == '':
                    all_data_list[index][i] = dic[header_value] if header_value in dic else ''
    else:
        key_index = header.index('kr')
        for dic in data_dic:
            index = len(all_data_list)
            temp_list = ['' for _ in range(len(header))]
            temp_list[key_index] = dic['kr']
            all_data_list.append(temp_list)

            for i, header_value in enumerate(header):
                if header_value == 'kr':
                    continue
                if all_data_list[index][i] == '':
                    all_data_list[index][i] = dic[header_value] if header_value in dic else ''

    return all_data_list


def merge_backup():
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)

    for sheet_name in sheet_name_list:
        all_data_list = []
        work_sheet = sheet.get_work_sheet(sheet_name)
        is_scenario = True if 'scenario' in sheet_name else False

        # 시나리오 시트인지 아닌지에 따라 헤더를 만듭니다.
        header = make_header(is_scenario)

        # 워크시트에 들어있는 데이터를 통합합니다.
        print('Merge data :', work_sheet.title)
        all_data_list = merge_data(all_data_list, spread_sheet.make_rows_to_dic(work_sheet.get_all_values()), header, is_scenario)
        print('length of data list :', len(all_data_list))

        # 모은 데이터를 워크시트에 작성합니다.
        upload(sheet_name + '_backup', spreadsheet_id, all_data_list, header, locale_list, is_scenario=is_scenario)
        print('Merging sheets at',sheet_name,'is done.')


if __name__ == '__main__':
    print('*** JOB : Merge backup sheet and new sheet [', ', '.join(sheet_name_list), ']. DO THIS NOW? (y/n)')
    key = input()

    if key == 'y' or key == 'Y':
        print('*** START JOB')

        merge_backup()
        
        print('*** FINISH JOB')
    else:
        print('*** CANCEL JOB')
        
    os.system('pause')
