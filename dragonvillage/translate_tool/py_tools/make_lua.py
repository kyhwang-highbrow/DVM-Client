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

spreadsheet_key = '1zdD2E4SGh0myHuOd0MXBIlFjAinqha2Zn1yF4n9h6ic' # 스프레드시트 키

sheet_names = [
    'only_ingame',
    'only_scenario'
 ] # 생성할 스프레드시트 이름을 저장하는 리스트 변수입니다. _backup 시트 또한 합산하여 테이블을 만듭니다.

#############################################################################
#############################################################################


import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

import datetime
import tools.G_sheet.spread_sheet as spread_sheet
import tools.util.file_util as file_util

make_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__))) +  r'\..\translate\newLuaTable' if make_root is None else make_root
print (make_root)
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
    

def make_lua(locale):
    global work_sheets
    
    # 워크시트들의 정보를 병합하여 하나의 리스트에 담습니다.
    data_list = []
    for work_sheet in work_sheets:
        row_dics = spread_sheet.make_rows_to_dic(work_sheet.get_all_values())
        for row_dic in row_dics:
            # 이미 담은 단어인지 판단합니다.
            ignore_this = False
            for data in data_list:
                if data[0] == row_dic['kr']:
                    ignore_this = True
                    break
            if ignore_this:
                # print('dup word :', data[0])
                continue
            
            # 번역어 담기, 만약 없다면 영어, 영어도 없다면 한국어를 담습니다.
            tr_str = ''
            if locale in row_dic:
                tr_str = row_dic[locale]
            if tr_str == '':
                tr_str = row_dic['en']
            if tr_str == '':
                tr_str = row_dic['kr']
            data_list.append([row_dic['kr'], tr_str])

            if 'speaker_kr' in row_dic.keys(): # 만약 화자가 있다면 추가로 담습니다.
                for data in data_list:
                    if data[0] == row_dic['speaker_kr']:
                        ignore_this = True
                        break
                if not ignore_this :
                    speaker_locale = 'speaker_' + locale
                    tr_speaker = ''
                    if speaker_locale in row_dic:
                        tr_speaker = row_dic[speaker_locale]
                    if tr_speaker == '':
                        tr_speaker = row_dic['speaker_en']
                    if tr_speaker == '':
                        tr_speaker = row_dic['speaker_kr']
                    data_list.append([row_dic['speaker_kr'], tr_speaker])
    
    lua_table = convert(data_list)

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

    for locale in locale_list:
        print('Start make lua :', locale)
        
        lua_table = make_lua(locale)

        save_file('lang_' + locale + '.lua', lua_table)

    print('Making lua table is done.')

if __name__ == '__main__':
    make()