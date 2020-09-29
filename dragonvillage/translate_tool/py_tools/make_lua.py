#############################################################################
## 구글 스프레드시트로부터 루아 테이블을 생성하는 코드입니다.

#############################################################################
### 하이퍼 파라미터 ##########################################################
make_root = None # 루아 테이블을 생성할 경로, None이면 기본값으로 dragonvillage\res\emulator\translate\newLuaTable 폴더에 생성합니다

locale_list = [
        'en',
        'jp',
        'zhtw',
        'th',
        'es',
        'fa'
    ] # 루아 테이블을 생성할 언어

spreadsheet_key = '1DYREmJ5dnwOsB4vAoynR4zuIPmWlsAD1jKBa80xNyWA' # 스프레드시트 키

sheet_names = [
    'only_ingame',
    'only_scenario'
 ] # 생성할 스프레드시트 이름을 저장하는 리스트 변수입니다. _backup 시트 또한 합산하여 테이블을 만듭니다.

normal_ignore_files = [
        'table_ban_word_chat.csv',
        'table_ban_word_naming.csv'
    ] # 일반 파일 탐색 시 무시할 파일 명

normal_ignore_folders = [
        r'\scenario' # 시나리오 관련 폴더를 무시합니다.
    ] # 일반 파일 탐색 시 무시할 폴더 명

scenario_ignore_files = [
        'table_ban_word_chat.csv',
        'table_ban_word_naming.csv',
        'scenario_resource.csv',
        'scenario_sample.csv'
    ] # 시나리오 파일 탐색 시 무시할 파일 명

scenario_ignore_folders = [
    ] # 시나리오 파일 탐색 시 무시할 폴더 명


#############################################################################
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import tools.G_sheet.spread_sheet as spread_sheet
import tools.util.file_util as file_util
from tools.extract.extract_from_lua import extract_from_lua_only_kr
from tools.extract.extract_from_UI import extract_from_UI_only_kr
from tools.extract.extract_from_csv import extract_from_csv_only_kr
from tools.extract.extract_from_scenario import extract_from_scenario_only_kr


search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
make_root = search_root +  r'\..\translate\newLuaTable' if make_root is None else make_root
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


def merge_kr(using_data_list, kr_data):
    for data in kr_data:
        if using_data_list.count(data) == 0:
            using_data_list.append(data)

    return using_data_list


def search_kr():
    from_lua_only_kr = extract_from_lua_only_kr(search_root + r'\..\src', normal_ignore_files, normal_ignore_folders)
    from_UI_only_kr = extract_from_UI_only_kr(search_root + r'\..\res', normal_ignore_files, normal_ignore_folders)
    from_sv_data_only_kr = extract_from_csv_only_kr(search_root + r'\..\..\sv_tables', normal_ignore_files, normal_ignore_folders)
    from_sv_patch_data_only_kr = extract_from_csv_only_kr(search_root + r'\..\..\sv_tables_patch', normal_ignore_files, normal_ignore_folders)
    from_data_only_kr = extract_from_csv_only_kr(search_root + r'\..\data', normal_ignore_files, normal_ignore_folders)

    
    from_scenario_only_kr = extract_from_scenario_only_kr(search_root + r'\..\data\scenario', scenario_ignore_files, scenario_ignore_folders)

    using_data_list = [] # 현재 사용되고 있는 텍스트 데이터를 저장할 리스트 변수
    merge_kr(using_data_list, from_lua_only_kr)
    merge_kr(using_data_list, from_UI_only_kr)
    merge_kr(using_data_list, from_sv_data_only_kr)
    merge_kr(using_data_list, from_sv_patch_data_only_kr)
    merge_kr(using_data_list, from_data_only_kr)
    merge_kr(using_data_list, from_scenario_only_kr)

    return using_data_list


def merge_all_data(work_sheets, using_data_list):
    global locale_list

    # 현재 프로젝트에서 쓰이는 단어들 구합니다.
    check_list = [False for i in range(len(using_data_list))]
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
            if using_data_list.count(row_dic['kr']) == 0:
                ignore_this = True
            if ignore_this:
                continue

            # 번역어 담기, 만약 없다면 영어, 영어도 없다면 한국어를 담습니다.
            check_list[using_data_list.index(row_dic['kr'])] = True
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
                if using_data_list.count(row_dic['speaker_kr']) == 0:
                    ignore_this = True
                if row_dic['speaker_kr'] == '':
                    ignore_this = True
                if not ignore_this :
                    check_list[using_data_list.index(row_dic['speaker_kr'])] = True
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

    # for log
    for i, data in enumerate(using_data_list):
        if not check_list[i]:
            print('Used in project, but not in sheets : "', data, '"')
            # 만약 한글로라도 루아 테이블에 추가하고 싶은 경우
            # for locale in locale_list:
            #     all_data_list[locale].append([data, data])

    print("Using text count in project :", len(using_data_list))
    print("Lua table text count :", len(all_data_list[locale_list[0]]))

    return all_data_list


def make_lua(locale, all_data_list):
    lua_table = convert(all_data_list[locale])

    return lua_table


def save_file(file_name, data):
    global make_root
    file_path = os.path.join(make_root, file_name)
    file_util.write_file(file_path, data)


def make():
    global locale_list, sheet_names, sheet, work_sheets, make_root

    sheet = spread_sheet.get_spread_sheet(spreadsheet_key)
    for name in sheet_names:
        work_sheets.append(sheet.get_work_sheet(name))
        work_sheets.append(sheet.get_work_sheet(name + '_backup'))

    # 백업 폴더를 만듭니다.
    file_util.make_dir(make_root)
    using_data_list = search_kr()
    all_data_list = merge_all_data(work_sheets, using_data_list)

    for locale in locale_list:
        print('Start make lua :', locale)

        lua_table = make_lua(locale, all_data_list)

        save_file('lang_' + locale + '.lua', lua_table)

    print('Making lua table is done.')

if __name__ == '__main__':
    make()
    os.system('pause')