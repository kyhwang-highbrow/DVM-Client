#############################################################################
## 번역이 끝난 시트들을 통합하는 코드입니다.

#############################################################################
### 하이퍼 파라미터 ##########################################################
locale_list = [                                                             
        'en',                                                               
        'jp',
        'zhtw',
        'th',
        'es',
        'fa',
    ] # 번역 언어                                               

spreadsheet_key = '1zdD2E4SGh0myHuOd0MXBIlFjAinqha2Zn1yF4n9h6ic' # 스프레드시트 키

sheet_name = 'only_ingame' # 병합할 스프레드시트 이름, sheet_name과 sheet_name_backup 두 시트를 병합합니다.
post_sheet_name = 'only_ingame_backup_test' # 병합된 스프레드시트의 이름을 결정합니다.

is_scenario = False # 통합할 워크 시트가 시나리오 판단하는 변수

is_sorted = False # 통합할 워크 시트를 키 값 기준으로 정렬할 것인지 결정합니다.
sort_crit = 'fileName' # 정렬할 때의 키 값입니다.

#############################################################################
#############################################################################

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import tools.G_sheet.spread_sheet as spread_sheet
from tools.upload.upload_sheet import upload
from tools.util.sort_util import cmp_scenario
from functools import cmp_to_key


sheet = None
work_sheets = []

all_data_list = []
header = []

def make_header():
    global is_scenario, locale_list, header

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
    

def merge_data(data_dic):
    global all_data_list, header, is_scenario
    

    if is_scenario:
        speaker_index = header.index('speaker_kr')
        text_index = header.index('kr')
        for dic in data_dic:
            already_exist = False
            for i, data in enumerate(all_data_list):
                if data[text_index] == dic['kr'] and data[speaker_index] == dic['speaker_kr']:
                    already_exist = True
                    index = i
                    break
            
            if not already_exist:
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
            already_exist = False
            for i, data in enumerate(all_data_list):
                if data[key_index] == dic['kr']:
                    already_exist = True
                    index = i
                    break
            
            if not already_exist:
                index = len(all_data_list)
                temp_list = ['' for _ in range(len(header))]
                temp_list[key_index] = dic['kr']
                all_data_list.append(temp_list)

            for i, header_value in enumerate(header):
                if header_value == 'kr':
                    continue
                if all_data_list[index][i] == '':
                    all_data_list[index][i] = dic[header_value] if header_value in dic else ''




def merge_backup():
    global sheet, work_sheets, spreadsheet_key, sheet_name, all_data_list, header, is_scenario, post_sheet_name

    sheet = spread_sheet.get_spread_sheet(spreadsheet_key)
    work_sheets.append(sheet.get_work_sheet(sheet_name + '_backup'))
    work_sheets.append(sheet.get_work_sheet(sheet_name))

    # 시나리오 시트인지 아닌지에 따라 헤더를 만듭니다.
    make_header()

    # 워크시트에 들어있는 데이터를 통합합니다.
    for work_sheet in work_sheets:
        print('Merge data :', work_sheet.title)
        merge_data(spread_sheet.make_rows_to_dic(work_sheet.get_all_values()))

    # 정렬이 필요하다면 정렬합니다.
    if is_sorted:
        if is_scenario and sort_crit == 'fileName':
            all_data_list.sort(key=cmp_to_key(cmp_scenario))
        else:
            key_index = header.index(sort_crit)
            all_data_list.sort(key=lambda data : data[key_index])

    # 모은 데이터를 워크시트에 작성합니다.
    print('Total strings (no dup) :', len(all_data_list))
    upload(sheet_name + '_backup', spreadsheet_key, all_data_list, header, locale_list, post_sheet_name=post_sheet_name, is_scenario=is_scenario)
    print('Merging sheets is done.')


if __name__ == '__main__':
    merge_backup()