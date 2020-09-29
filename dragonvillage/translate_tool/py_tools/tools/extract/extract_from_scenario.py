import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import util.file_util as file_util

import re
import os
import csv
import copy

def parse(result_data, file_path, header_datas, important_header_index, body_datas):
    reg_check = re.compile(r'[가-힣]')

    for body in body_datas:
        page = body[important_header_index['page']]
        file_name = os.path.basename(file_path)
        
        # 1. 캐릭터이름 / 대사 부분 한글 데이터 추출하기 
        char = body[important_header_index['char']]
        t_char_name = body[important_header_index['t_char_name']]
        if len(t_char_name) <= 0 and len(char) > 0:
            t_char_name = char
        
        t_text = body[important_header_index['t_text']]
        if len(t_text) > 0 and reg_check.match(t_text):
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
        

def get_str(result_data, file_path):
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
        parse(result_data, file_path, header_data, important_header_index, body_data)


def extract_from_scenario(path, ignoreFiles, ignoreFolders):
    result_data = []
    
    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.csv', '.CSV']

    files = file_util.get_all_files(path, option)

    for file in files:
        # print(file)
        get_str(result_data, file)

    # print(result_data)

    return result_data


def parse_only_kr(result_data, file_path, header_datas, important_header_index, body_datas):
    reg_check = re.compile(r'[가-힣]')

    for body in body_datas:
        # 1. 캐릭터이름 / 대사 부분 한글 데이터 추출하기 
        char = body[important_header_index['char']]
        t_char_name = body[important_header_index['t_char_name']]
        if len(t_char_name) <= 0 and len(char) > 0:
            t_char_name = char
        
        t_text = body[important_header_index['t_text']]
        if len(t_text) > 0 and reg_check.match(t_text):
            invert_text = t_text.replace('\r\n', r'\n').replace('\n', r'\n')
            if len(t_char_name) > 0 and result_data.count(t_char_name) == 0:
                result_data.append(t_char_name) 
            if result_data.count(invert_text) == 0:
                result_data.append(invert_text) 


def get_only_kr(result_data, file_path):
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
        parse_only_kr(result_data, file_path, header_data, important_header_index, body_data)


def extract_from_scenario_only_kr(path, ignoreFiles, ignoreFolders):
    result_data = []
    
    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.csv', '.CSV']

    files = file_util.get_all_files(path, option)

    for file in files:
        # print(file)
        get_only_kr(result_data, file)

    # print(result_data)

    return result_data