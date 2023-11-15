#############################################################################
## 구글 스프레드시트에 업로드하는 코드입니다.
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import tools.G_sheet.spread_sheet as spread_sheet
from tools.G_sheet.sheet_option import get_sheet_option
from tools.util.util_sort import cmp_scenario
from functools import cmp_to_key
from lang_codes.lang_codes import get_language_code_list


def removeStr(sheet, data_list, header, locale_list): # sheet과 datalist의 값 비교를 통해 중복을 제거한 data_list 반환합니다.
    remove_index = []
    
    data_speaker_kr_index = header.index('speaker_kr')
    data_text_kr_index = header.index('kr')
    data_speaker_locale_index = {}
    data_text_locale_index = {}
    for locale in locale_list:
        speaker_locale = 'speaker_' + locale
        if speaker_locale in header:
            data_speaker_locale_index[locale] = header.index(speaker_locale)
        if locale in header:
            data_text_locale_index[locale] = header.index(locale)
    for row in sheet.get_all_values():
        if row[0] == 'fileName':
            row_speaker_kr_index = row.index('speaker_kr')
            row_text_kr_index = row.index('kr')
            row_speaker_locale_index = {}
            row_text_locale_index = {}
            for locale in locale_list:
                speaker_locale = 'speaker_' + locale
                if speaker_locale in row:
                    row_speaker_locale_index[locale] = row.index(speaker_locale)
                if locale in row:
                    row_text_locale_index[locale] = row.index(locale)
            continue
        for index, data in enumerate(data_list):
            if data[data_text_kr_index] == row[row_text_kr_index]: # 이미 겹치는 대사가 있는 경우 
                remove_index.append(index)
                continue
            if data[data_speaker_kr_index] == row[row_speaker_kr_index] and row[row_speaker_kr_index] != '': # 이미 겹치는 화자 이름이 있는 경우
                for locale in locale_list: # 내용을 채워줍니다.
                    if locale in row_speaker_locale_index:
                        data[data_speaker_locale_index[locale]] = row[row_speaker_locale_index[locale]]
    
    # 중복을 제거하는 과정에서 번역이 전부 채워지게 된 경우(빈 칸이 없는 경우) 번역 요청 리스트에서 제거합니다.
    # 화자는 처음부터 빈칸일 수 있으므로 예외로 처리해서 검사합니다.
    for index, data in enumerate(data_list):
        if data[data_speaker_kr_index] == '' and '' not in [data[data_text_locale_index[locale]] for locale in locale_list]:
            remove_index.append(index)
        elif '' not in data:
            remove_index.append(index)
        
    data_list = [data for index, data in enumerate(data_list) if index not in remove_index] 
    return data_list


def upload_DVM_scenario_text(delta_sheet_name, backup_sheet_name, spreadsheet_id, data_list, locale_list):
    # 힌트랑 날짜가 찍히지 않아서 찍히도록 수정
    total_lang_list = get_language_code_list()
    temp_data_list = []
    for data in data_list:            
        temp_data = [data[0], data[1], data[2]]  # [file_name, page, speaker_kr]
        start_idx = 3 + total_lang_list.index(locale_list[0])
        last_idx = start_idx + len(locale_list)
        for i in range(start_idx, last_idx):
            temp_data.append(data[i])

        start_idx = 3 + len(total_lang_list)
        temp_data.append(data[start_idx]) # kr

        start_idx = start_idx + total_lang_list.index(locale_list[0]) + 1
        last_idx = start_idx + len(locale_list)
        for i in range(start_idx, last_idx):
            temp_data.append(data[i])
        temp_data.append(data[len(data) - 1]) #date
        temp_data_list.append(temp_data)

    # 데이터를 파일 이름과 페이지 값을 이용하여 정렬합니다.
    temp_data_list.sort(key=cmp_to_key(cmp_scenario)) 

    # 새로 만들 시트의 헤더입니다.
    header = ['fileName', 'page', 'speaker_kr']
    for locale in locale_list:
        header.append('speaker_' + locale)
    header.append('kr')
    for locale in locale_list:
        header.append(locale)
    header.append('date')
    
    # 시트를 만들 때 사용될 칼럼 사이즈입니다.
    col_size = len(header)

    # 스프레드시트의 아이디값을 이용하여 연결합니다.
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)

    backup_sheet = sheet.get_work_sheet(backup_sheet_name)
    if backup_sheet is None:
        backup_option = {}
        backup_option['rows'] = 1
        backup_option['cols'] = col_size
        backup_sheet = sheet.add_work_sheet(backup_sheet_name, backup_option)
        backup_sheet.insert_row(header, 1, value_input_option='RAW')
        sheet_id = backup_sheet._properties['sheetId']
        sheet_option = get_sheet_option('DVM_scenario_text', sheet_id, col_size)
        sheet.batch_update(sheet_option)
    else: # 백업 시트가 존재한다면 백업 시트와의 중복 검사 실시
        temp_data_list = removeStr(backup_sheet, temp_data_list, header, locale_list)

    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    delta_sheet = sheet.get_work_sheet(delta_sheet_name)
    if delta_sheet is None:
        option = {}
        option['rows'] = 1
        option['cols'] = col_size
        delta_sheet = sheet.add_work_sheet(delta_sheet_name, option)
        delta_sheet.insert_row(header, 1, value_input_option='RAW')
    else: # 기존의 뉴시트와 중복 검사
        temp_data_list = removeStr(delta_sheet, temp_data_list, header, locale_list)
    
    # 시트에 데이터를 삽입합니다 
    # 시트의 빈 칸이 시작되는 행을 파악해서 넣습니다.
    exist_datas = delta_sheet.get_all_values()
    row_size = len(exist_datas) + 1
    delta_sheet.resize(rows=row_size)
    if len(temp_data_list) > 0:
        delta_sheet.insert_rows(temp_data_list, row_size, value_input_option='RAW')

    # 시트의 크기를 보기 좋게 조정합니다.
    sheet_id = delta_sheet._properties['sheetId']
    sheet_option = get_sheet_option('DVM_scenario_text', sheet_id, col_size)
    sheet.batch_update(sheet_option)

    print('Add text in [', delta_sheet_name, '] :', len(temp_data_list))

    