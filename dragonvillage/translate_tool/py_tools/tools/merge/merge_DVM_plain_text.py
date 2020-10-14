import tools.G_sheet.spread_sheet as spread_sheet
from tools.G_sheet.sheet_option import get_sheet_option


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
    
    # 시트에 데이터를 삽입합니다 
    # 시트의 빈 칸이 시작되는 행을 파악해서 넣습니다.
    exist_datas = work_sheet.get_all_values()
    row_size = len(exist_datas) + 1
    work_sheet.resize(rows=row_size)
    if len(data_list) > 0:
        work_sheet.insert_rows(data_list, row_size, value_input_option='RAW')

    # 시트의 크기를 보기 좋게 조정합니다.
    sheet_id = work_sheet._properties['sheetId']
    sheet_option = get_sheet_option('DVM_plain_text', sheet_id, col_size)
    sheet.batch_update(sheet_option)

    print('Add text in [', backup_sheet_name, '] :', len(data_list))


def merge_data(all_data_list, data_dic, header):
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


def merge_DVM_plain_text(spreadsheet_id, delta_sheet_name, backup_sheet_name, locale_list):
    all_data_list = []
    sheet = spread_sheet.get_spread_sheet(spreadsheet_id)
    delta_sheet = sheet.get_work_sheet(delta_sheet_name)

    if delta_sheet is None:
        print("NO EXIST DELTA SHEET :", delta_sheet_name)
        return

    # 헤더 생성
    header = ['kr']
    for locale in locale_list:
        header.append(locale)
    header.append('hints')
    header.append('date')
    
    # 워크시트에 들어있는 데이터를 통합합니다.
    print('Merge data :', delta_sheet.title)
    merge_data(all_data_list, spread_sheet.make_rows_to_dic(delta_sheet.get_all_values()), header)
    print('length of data list :', len(all_data_list))

    # 모은 데이터를 워크시트에 작성합니다.
    merge_upload(backup_sheet_name, spreadsheet_id, all_data_list, header, locale_list)
    print('Merging sheets at', backup_sheet_name, 'is done.')