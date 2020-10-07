import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import G_sheet.spread_sheet as spread_sheet


def removeStr(sheet, data_list, header, locale_list, is_scenario=False): # sheet과 datalist의 값 비교를 통해 중복을 제거한 data_list 반환합니다.
    remove_index = []
    
    if is_scenario: # 시나리오 텍스트의 경우
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
        
    else: # 일반 텍스트 경우
        data_text_locale_index = {}
        for locale in locale_list:
            if locale in header:
                data_text_locale_index[locale] = header.index(locale)
        for row in sheet.get_all_values():
            if row[0] == 'kr':
                row_text_locale_index = {}
                for locale in locale_list:
                    if locale in row:
                        row_text_locale_index[locale] = row.index(locale)
                continue
            for index, data in enumerate(data_list):
                if data[0] == row[0]: # 텍스트가 같은 경우
                    # 중복이므로 제거합니다
                    remove_index.append(index)

    data_list = [data for index, data in enumerate(data_list) if index not in remove_index] 
    return data_list


def getSheetOption(sheet_id, is_scenario, col_size):
    if is_scenario:
        locale_size = (col_size - 3) / 2
        body = {
            "requests": [
                {
                    "updateDimensionProperties": {
                        "range": {
                            "sheetId": sheet_id, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": 0, # fileName
                            "endIndex": 1 
                        },
                        "properties": { # 해당 속성을 부여합니다.
                            "pixelSize": 200
                        },
                        "fields": "pixelSize"
                    }
                },
                {
                    "updateDimensionProperties": {
                        "range": {
                            "sheetId": sheet_id, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": 1, # speaker_X
                            "endIndex": 2 + locale_size 
                        },
                        "properties": { # 해당 속성을 부여합니다.
                            "pixelSize": 100
                        },
                        "fields": "pixelSize"
                    }
                },
                {
                    "updateDimensionProperties": {
                        "range": {
                            "sheetId": sheet_id, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": 2 + locale_size, # text 
                            "endIndex": col_size - 1
                        },
                        "properties": { # 해당 속성을 부여합니다.
                            "pixelSize": 400
                        },
                        "fields": "pixelSize"
                    }
                },
                {
                    "updateDimensionProperties": {
                        "range": {
                            "sheetId": sheet_id, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": col_size - 1, # date
                            "endIndex": col_size
                        },
                        "properties": { # 해당 속성을 부여합니다.
                            "pixelSize": 150
                        },
                        "fields": "pixelSize"
                    }
                }
            ]
        }
    else:
        body = {
            "requests": [
                {
                    "updateDimensionProperties": {
                        "range": {
                            "sheetId": sheet_id, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": 0, # 0번 인덱스부터
                            "endIndex": col_size # col_count - 1까지 
                        },
                        "properties": { # 해당 속성을 부여합니다.
                            "pixelSize": 500
                        },
                        "fields": "pixelSize"
                    }
                }
            ]
        }

    return body


def upload(sheet_name, spreadsheet_key, data_list, header, locale_list, is_scenario=False):
    # 스프레드시트의 아이디값을 이용하여 연결합니다.
    sheet = spread_sheet.get_spread_sheet(spreadsheet_key)

    # 병합과정이 아니라 추출 과정이라면 backup 시트를 가져와서 데이터가 겹치는 것을 제거합니다.
    if '_backup' not in sheet_name: 
        backup_sheet = sheet.get_work_sheet(sheet_name + '_backup')
        if backup_sheet is not None: # 백업 시트가 존재한다면 백업 시트와의 중복 검사 실시
            data_list = removeStr(backup_sheet, data_list, header, locale_list, is_scenario)


    # 시트를 만들 때 사용될 칼럼 사이즈입니다.
    col_size = len(header)

    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    work_sheet = sheet.get_work_sheet(sheet_name)
    if work_sheet is None:
        option = {}
        option['rows'] = 1
        option['cols'] = col_size
        work_sheet = sheet.add_work_sheet(sheet_name, option)
        work_sheet.insert_row(header, 1, value_input_option='RAW')
    elif '_backup' not in sheet_name: # 기존의 뉴시트와 중복 검사
        data_list = removeStr(work_sheet, data_list, header, locale_list, is_scenario)
    
    # 시트에 데이터를 삽입합니다 
    # 시트의 빈 칸이 시작되는 행을 파악해서 넣습니다.
    exist_datas = work_sheet.get_all_values()
    row_size = len(exist_datas) + 1
    work_sheet.resize(rows=row_size)
    if len(data_list) > 0:
        work_sheet.insert_rows(data_list, row_size, value_input_option='RAW')

    # 시트의 크기를 보기 좋게 조정합니다.
    sheet_id = work_sheet._properties['sheetId']
    sheet_option = getSheetOption(sheet_id, is_scenario, col_size)
    sheet.batch_update(sheet_option)

    