#############################################################################
## 시나리오 csv 파일로부터 텍스트를 추출하는 코드입니다.
#############################################################################

import os
import tools.util.util_file as util_file
import re
import csv
import copy


def parse(result_data, file_path, header_datas, important_header_index, body_datas, ignore_krs):
    reg_check = re.compile(r'[가-힣]+')

    for body in body_datas:
        page = body[important_header_index['page']]
        file_name = os.path.basename(file_path)
        
        # 1. 캐릭터이름 / 대사 부분 한글 데이터 추출하기 
        char = body[important_header_index['char']]
        t_char_name = body[important_header_index['t_char_name']]
        if len(t_char_name) <= 0 and len(char) > 0:
            t_char_name = char
        
        t_text = body[important_header_index['t_text']]
        if ignore_krs.count(t_text) > 0:
            continue
        if len(t_text) > 0 and reg_check.search(t_text):
            invert_text = t_text.replace('\r\n', r'\n').replace('\n', r'\n')
            result_data.append([file_name, page, t_char_name, invert_text] ) # [파일이름, 페이지, 캐릭터이름, 대사]

        # 2. 이펙트 이름 부분 한글 데이터 추출하기 (현재 필요없는 더미 코드라고 생각하여 주석 처리함)
        # effect_index = 1
        # effect_header = 'effect_' + str(effect_index)
        # while effect_header in important_header_index.keys():
        #     effect_value = body[important_header_index[effect_header]]

        #     if len(effect_value) > 0 and reg_check.match(effect_value):
        #         effect_list = effect_value.split(';')
        #         for effect_text in effect_list:
        #             if reg_check.match(effect_text):
        #                 invert_text = effect_text.replace('\r\n', r'\n').replace('\n', r'\n')
        #                 result_data.append([file_name, page, '', invert_text])

        #     effect_index += 1
        #     effect_header = 'effect_' + str(effect_index)
        

def get_str(result_data, file_path, ignore_krs):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            csv_file = csv.reader(f)
            csv_data = []
            for line in csv_file:
                csv_data.append(line)
            header_data, body_data = csv_data[0], csv_data[1:]
            important_header_index = {}
            for i, header in enumerate(header_data):
                if header != 't_char_name' and header != 'page' and header != 'char' and header != 't_text' and header.find('effect_') < 0:
                    continue
                important_header_index[header] = i
            # print(important_header_index)
            parse(result_data, file_path, header_data, important_header_index, body_data, ignore_krs)
    except:
        print('해당 파일을 읽는 도중 문제가 발생했습니다. :', file_path)
        os.system('pause')


def extract_from_DVM_scenario_csv(path, ignoreFiles, ignoreFolders, ignore_krs): # 리스트 반환
    result_data = []
    
    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.csv', '.CSV']

    files = util_file.get_all_files(path, option)

    for file in files:
        # print(file)
        get_str(result_data, file, ignore_krs)

    # print(result_data)

    return result_data
    