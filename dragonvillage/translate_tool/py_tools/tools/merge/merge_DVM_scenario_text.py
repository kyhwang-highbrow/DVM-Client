import tools.G_sheet.spread_sheet as spread_sheet
from tools.G_sheet.sheet_option import get_sheet_option
from tools.util.util_quote import quote
import gspread

def merge_upload(backup_sheet_name, spreadsheet_id, data_list, header, locale_list):
    # 스프레드시트의 아이디값을 이용하여 연결합니다.
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)

    # 시트를 만들 때 사용될 칼럼 사이즈입니다.
    col_size = len(header)

    # 데이터 리스트 사이즈를 바탕으로 시트를 작성합니다.
    work_sheet = sheet.get_work_sheet(backup_sheet_name)
    if work_sheet is None:
        option = {}
        option['rows'] = 1
        option['cols'] = col_size
        work_sheet = sheet.add_work_sheet(backup_sheet_name, option)
        work_sheet.insert_row(header, 1, value_input_option='RAW')
    
     # 백업 시트의 내용을 가져옵니다.
    backup_datas = work_sheet.get_all_values()[1:]

    # 백업 시트에 델타 시트의 내용을 덮어씌웁니다.
    is_dup_list = [False for _ in range(len(data_list))]
    speaker_index = header.index('speaker_kr')
    text_index = header.index('kr')
    for backup_index, backup_data in enumerate(backup_datas):
        for delta_index, delta_data in enumerate(data_list):
            if backup_data[speaker_index] == delta_data[speaker_index] and quote(backup_data[text_index]) == quote(delta_data[text_index]):
                for i in range(len(header)):
                    if i == text_index:
                        continue
                    if delta_data[i] != '':
                        backup_datas[backup_index][i] = delta_data[i]
                is_dup_list[delta_index] = True

    # 백업 시트의 내용을 적습니다.
    work_sheet.resize(rows=2)
    work_sheet.insert_rows(backup_datas, 2, value_input_option='RAW')

    # 중복되지 않은 델타 시트의 내용을 아래에 추가합니다.
    no_dup_data_list = [delta_data for delta_index, delta_data in enumerate(data_list) if not is_dup_list[delta_index]]
    
    # 시트에 데이터를 삽입합니다 
    row_size = len(backup_datas) + 2
    work_sheet.resize(rows=row_size)
    if len(no_dup_data_list) > 0:
        work_sheet.insert_rows(no_dup_data_list, row_size, value_input_option='RAW')
    work_sheet.resize(rows=len(work_sheet.get_all_values()) - 1)
    
    # 시트의 크기를 보기 좋게 조정합니다.
    sheet_id = work_sheet._properties['sheetId']
    sheet_option = get_sheet_option('DVM_scenario_text', sheet_id, col_size)
    sheet.batch_update(sheet_option)

    print('Add text in [', backup_sheet_name, ']')


def merge_data(all_data_list, data_dic, header):
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

## 병합하기 전의 델타 시트를 백업
def backup_delta_sheet(sheet, delta_sheet, delta_sheet_name):
    # 델타 백업 시트 네이밍
    delta_backup_sheet_name = delta_sheet_name + '_merge_backup'    

    # 대상 스프레드시트에 대상 시트 추가 (이미 존재하면 열기)
    delta_backup_sheet = sheet.get_work_sheet(delta_backup_sheet_name)

    if delta_backup_sheet is None:
        option = {}
        option['rows'] = 1
        option['cols'] = 100
        delta_backup_sheet = sheet.add_work_sheet(delta_backup_sheet_name, option)

    src_values = delta_sheet.get_all_values()
    delta_backup_sheet.clear()
    delta_backup_sheet.update('A1', src_values)


## 델타 시트의 첫 번째 행을 제외한 모든 행 제거
def clear_delta_sheet(delta_sheet):
    # 첫 번째 행을 제외한 나머지 행 제거
    all_rows = delta_sheet.get_all_values()    
    
    #행 1개를 추가
    num_rows = delta_sheet.row_count
    delta_sheet.insert_row([''], 2, value_input_option='RAW')

    if len(all_rows) > 1:        
        delta_sheet.delete_rows(3, num_rows + 1)


def merge_DVM_scenario_text(spreadsheet_id, delta_sheet_name, backup_sheet_name, locale_list):
    all_data_list = []
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)
    delta_sheet = sheet.get_work_sheet(delta_sheet_name)

    if delta_sheet is None:
        print("NO EXIST DELTA SHEET :", delta_sheet_name)
        return
    
    # 헤더 생성
    header = ['fileName', 'page', 'speaker_kr']
    for locale in locale_list:
        header.append('speaker_' + locale)
    header.append('kr')
    for locale in locale_list:
        header.append(locale)
    header.append('date')

    # 워크시트에 들어있는 데이터를 통합합니다.
    print('Merge data :', delta_sheet.title)
    merge_data(all_data_list, spread_sheet.make_rows_to_dic(delta_sheet.get_all_values()), header)
    print('length of data list :', len(all_data_list))

    # 모은 데이터를 워크시트에 작성합니다.
    merge_upload(backup_sheet_name, spreadsheet_id, all_data_list, header, locale_list)

    # 델타 시트 내용 삭제
    clear_delta_sheet(delta_sheet)    
    print('Merging sheets at', backup_sheet_name, 'is done.')