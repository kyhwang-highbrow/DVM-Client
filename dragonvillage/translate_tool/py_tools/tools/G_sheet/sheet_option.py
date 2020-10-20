
def get_DVM_plain_text_option(sheet_id, col_size):
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
                        "pixelSize": 700
                    },
                    "fields": "pixelSize"
                }
            }
        ]
    }

    return body


def get_DVM_scenario_text_option(sheet_id, col_size):
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

    return body


sheet_option = {}
sheet_option['DVM_plain_text'] = get_DVM_plain_text_option
sheet_option['DVM_scenario_text'] = get_DVM_scenario_text_option


def get_sheet_option(option_type, sheet_id, col_size):
    return sheet_option[option_type](sheet_id, col_size)