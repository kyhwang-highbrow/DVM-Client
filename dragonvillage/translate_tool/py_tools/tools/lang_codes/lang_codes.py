#############################################################################
## table_language_config_file에서 언어 코드리스트를 가져옴
#############################################################################

import sys
import os
import csv
import json
import csv

with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    table_language_config_file = config_json['table_language_config_file']
    spreadsheet_id = config_json['spreadsheet_id']
    merge_config_list = config_json['merge_config_list']

# 우선순위대로 언어 코드리스트를 가져옴
def get_language_code_list():
    lang_tuple_list = list()
    lang_code_list = list()
    csv_file = open(table_language_config_file, "r", encoding="utf_8", errors="", newline="" )
    f = csv.DictReader(csv_file, delimiter=",", doublequote=True, lineterminator="\r\n", quotechar='"', skipinitialspace=True)    
    for row in f:
        if row["active"] == "TRUE" and row["lang_code"] != "ko" :
            tuple_lang = (row["lang_code"], int(row["sheet_priority"]))
            lang_tuple_list.append(tuple_lang)
            
    #1순위는 기존에 서비스했던 언어 여부, 2순위는 언어 코드의 알파벳순
    lang_tuple_list.sort(key=lambda x:(-x[1], x[0]))
    for row in lang_tuple_list:
        lang_code_list.append(row[0])

    return lang_code_list

# 언어 코드별로 저장할 번역파일명을 담은 리스트(코드명과 번역파일명이 규칙적으로 일치하지 않는 경우가 생기기 때문)
def get_translation_file_list(add_keyword):
    file_list = list()
    dict_file = dict()

    csv_file = open(table_language_config_file, "r", encoding="utf_8", errors="", newline="" )
    f = csv.DictReader(csv_file, delimiter=",", doublequote=True, lineterminator="\r\n", quotechar='"', skipinitialspace=True)    

    for row in f:
        trans_file = row["translate_file"]
        dict_file[row["lang_code"]] = trans_file.replace('translate/', '') + add_keyword + ".lua"

    lang_list = get_language_code_list()
    for lang_code in lang_list:
        file_list.append(dict_file[lang_code])

    return file_list

# 언어 코드별로 저장할 번역파일명을 담은 딕셔너리(코드명과 번역파일명이 규칙적으로 일치하지 않는 경우가 생기기 때문)
def get_translation_file_dict(add_keyword):
    dict_file = dict()

    csv_file = open(table_language_config_file, "r", encoding="utf_8", errors="", newline="" )
    f = csv.DictReader(csv_file, delimiter=",", doublequote=True, lineterminator="\r\n", quotechar='"', skipinitialspace=True)    

    for row in f:
        trans_file = row["translate_file"]
        dict_file[row["lang_code"]] = trans_file.replace('translate/', '') + add_keyword + ".lua"

    return dict_file



if __name__ == '__main__':
    get_language_code_list()
    os.system('pause')