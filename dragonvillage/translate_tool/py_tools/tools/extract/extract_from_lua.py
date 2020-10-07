#############################################################################
## lua 파일로부터 텍스트를 추출하는 코드입니다.
#############################################################################

import os
import tools.util.util_file as util_file
import re


def get_str(result_data, file_path): # 사용된 한글, 힌트 파일 등 상세하게 뽑아내는 함수
    with open(file_path, 'r', encoding='utf-8') as f:
        all_data = f.read()
        reg_find_case_1 = re.compile(r'Str\s*\(\s*\'(.*?)\'')
        reg_find_case_2 = re.compile(r'Str\s*\(\s*\"(.*?)\"')
        reg_check = re.compile(r'[가-힣]')
        find_datas = reg_find_case_1.findall(all_data)
        find_datas.extend(reg_find_case_2.findall(all_data))
        
        for find_data in find_datas:
            # 한글이 존재하는지 검사
            if not reg_check.match(find_data):
                continue
            
            # 지금까지 모은 data 딕셔너리에 현재 찾은 텍스트 키값이 존재하는지 검사하고 없다면 추가
            if find_data not in result_data.keys():
                result_data[find_data] = {'hints' : []}

            # 힌트에 현재 파일 이름이 존재하는지 검사하고 추가
            hint_exist = False
            file_name = os.path.basename(file_path)
            for hints in result_data[find_data]['hints']:
                if file_name in hints:
                    hint_exist = True
                    break
            if not hint_exist:
                result_data[find_data]['hints'].append(file_name)
                result_data['length'] += 1


def extract_from_lua(path, ignoreFiles, ignoreFolders):
    result_data = {}
    result_data['length'] = 0

    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.lua', '.LUA']

    files = util_file.get_all_files(path, option)

    for file in files:
        get_str(result_data, file)

    # print(result_data)

    return result_data
