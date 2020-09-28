import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import G_sheet.spread_sheet as spread_sheet

def upload(sheet_name, spreadsheet_key, data_list, header, locale_list, post_sheet_name=None, is_scenario=False):
    # 스프레드시트의 아이디값을 이용하여 연결합니다.
    sheet = spread_sheet.get_spread_sheet(spreadsheet_key)

    
    # 병합과정이 아니라 추출 과정이라면 backup 시트를 가져와서 데이터가 겹치는 것을 제거합니다.
    remove_index = []
    if '_backup' not in sheet_name: 
        backup_sheet = sheet.get_work_sheet(sheet_name + '_backup')
        if backup_sheet is not None:
    
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
                for row in backup_sheet.get_all_values():
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
                        if data[data_text_kr_index] == row[row_text_kr_index]: # 이미 겹치는 대사가 있는 경우 backup에 있는 내용으로 채웁니다.
                            for locale in locale_list:
                                if locale in row_text_locale_index:
                                    data[data_text_locale_index[locale]] = row[row_text_locale_index[locale]]
                        if data[data_speaker_kr_index] == row[row_speaker_kr_index] and row[row_speaker_kr_index] != '': # 이미 겹치는 화자 이름이 있는 경우 backup에 있는 내용으로 채웁니다.
                            for locale in locale_list:
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
                for row in backup_sheet.get_all_values():
                    if row[0] == 'kr':
                        row_text_locale_index = {}
                        for locale in locale_list:
                            if locale in row:
                                row_text_locale_index[locale] = row.index(locale)
                        continue
                    for index, data in enumerate(data_list):
                        if data[0] == row[0]: # 텍스트가 같은 경우
                            # 이미 backup에 번역이 되어 있는 언어의 경우 가져옵니다.
                            for locale in locale_list:
                                if locale in row_text_locale_index:
                                    data[data_text_locale_index[locale]] = row[row_text_locale_index[locale]]
                
                # 중복을 제거하는 과정에서 번역이 전부 채워지게 된 경우(빈 칸이 없는 경우) 번역 요청 리스트에서 제거합니다.
                for index, data in enumerate(data_list):
                    if '' not in data:
                        remove_index.append(index)

    data_list = [data for index, data in enumerate(data_list) if index not in remove_index]
    
    # 시트를 만들 때 사용될 칼럼 사이즈입니다.
    col_count = len(header)

    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    work_sheet = sheet.get_work_sheet(sheet_name if post_sheet_name is None else post_sheet_name)
    if work_sheet is None:
        option = {}
        option['rows'] = 1
        option['cols'] = col_count
        work_sheet = sheet.add_work_sheet(sheet_name if post_sheet_name is None else post_sheet_name, option)
    else:
        work_sheet.clear()
        work_sheet.delete_row(1)
        work_sheet.resize(1, col_count)
    
    # 시트에 데이터를 삽입합니다 
    work_sheet.insert_row(header, 1, value_input_option='RAW')
    work_sheet.insert_rows(data_list, 2, value_input_option='RAW')

    # 시트의 크기를 보기 좋게 조정합니다.
    sheetId = work_sheet._properties['sheetId']
    if is_scenario:
        locale_size = (col_count - 3) / 2
        body = {
            "requests": [
                {
                    "updateDimensionProperties": {
                        "range": {
                            "sheetId": sheetId, # 해당 시트에 대하여
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
                            "sheetId": sheetId, # 해당 시트에 대하여
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
                            "sheetId": sheetId, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": 2 + locale_size, # text 
                            "endIndex": col_count - 1
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
                            "sheetId": sheetId, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": col_count - 1, # date
                            "endIndex": col_count
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
                            "sheetId": sheetId, # 해당 시트에 대하여
                            "dimension": "COLUMNS", # 칼럼을 기준으로 할 때 
                            "startIndex": 0, # 0번 인덱스부터
                            "endIndex": col_count # col_count - 1까지 
                        },
                        "properties": { # 해당 속성을 부여합니다.
                            "pixelSize": 500
                        },
                        "fields": "pixelSize"
                    }
                }
            ]
        }
    sheet.batch_update(body)
    work_sheet.freeze(rows=1)

    