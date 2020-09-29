import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import util.file_util as file_util

import re
import os


def get_str(result_data, file_path): # 사용된 한글, 힌트 파일 등 상세하게 뽑아내는 함수
    with open(file_path, 'r', encoding='utf-8') as f:
        all_data = f.read()
        reg_find_case1 = re.compile(r"text = '(.+?)'")
        reg_find_case2 = re.compile(r"placeholder = '(.+?)'")
        reg_check = re.compile(r'[가-힣]')
        find_datas = reg_find_case1.findall(all_data)
        find_datas.extend(reg_find_case2.findall(all_data))
        
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


def extract_from_UI(path, ignoreFiles, ignoreFolders):
    result_data = {}
    result_data['length'] = 0

    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.ui', '.UI']

    files = file_util.get_all_files(path, option)

    for file in files:
        get_str(result_data, file)

    # print(result_data)

    return result_data


def get_only_kr(result_data, file_path): # 단순히 한글이 어떤 게 사용되는지만 알려주는 함수
    with open(file_path, 'r', encoding='utf-8') as f:
        all_data = f.read()
        reg_find_case1 = re.compile(r"text = '(.+?)'")
        reg_find_case2 = re.compile(r"placeholder = '(.+?)'")
        reg_check = re.compile(r'[가-힣]')
        find_datas = reg_find_case1.findall(all_data)
        find_datas.extend(reg_find_case2.findall(all_data))
        
        for find_data in find_datas:
            # 한글이 존재하는지 검사
            if not reg_check.match(find_data):
                continue
            
            # 지금까지 모은 data 딕셔너리에 현재 찾은 텍스트 키값이 존재하는지 검사하고 없다면 추가
            if result_data.count(find_data) == 0:
                result_data.append(find_data)


def extract_from_UI_only_kr(path, ignoreFiles, ignoreFolders):
    result_data = []

    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.ui', '.UI']

    files = file_util.get_all_files(path, option)

    for file in files:
        get_only_kr(result_data, file)

    # print(result_data)

    return result_data