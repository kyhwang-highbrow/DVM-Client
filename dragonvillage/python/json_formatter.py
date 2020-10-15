#-*- coding: utf-8 -*-

import os
import re
import json

DATA_ROOT = '../data/'
INVALID_DATA_TABLE = []

# 큰따옴표나 작은 따옴표
RE_Q_1 = re.compile(r'"\s+"')
RE_Q_2 = re.compile(r"'(?P<org>\w+)'")

# 개행 전후로 문자나 숫자 사용
RE_W_1 = re.compile(r'"\s+(?P<org>\w)')
RE_W_2 = re.compile(r'(?P<org>\w)\s+"')

# JsonObject의 키를 숫자로 사용
RE_D = re.compile(r'(?P<org>\d+[.]*\d*)[:]')

# 각괄호 [] 와 중괄호 {} 전후로 잘못된 개행
RE_M_1 = re.compile(r'[}]\s+[{]')
RE_M_2 = re.compile(r'[]]\s+[[]')

RE_M_3 = re.compile(r'"\s+[[]')
RE_M_4 = re.compile(r'[]]\s+"')

RE_M_5 = re.compile(r'"\s+[{]')
RE_M_6 = re.compile(r'[}]\s+"')

###################################
# def getAllFilePath
# @brief 특정 폴더의 전체 파일 절대경로 리스트 반환
###################################
def getAllFilePath(path):
    res = []
    for root, _, files in os.walk(path):
        for filename in files:
            res.append(os.path.join(root, filename))

    return res

###################################
# def checkData
###################################
def checkData(file_path_list):
    for file_path in file_path_list:
        if file_path.endswith('.txt'):
            if not validateJson(file_path):
                print("#### Check this!! " + file_path)
                break

###################################
# def validateJson
###################################
def validateJson(file_path):
    with open(file_path, 'r') as json_data:
        try:
            json.load(json_data)
            return True

        except UnicodeDecodeError:
            print("### UnicodeDecodeError " + file_path)
            # UTF converter 실행
            return True

        except ValueError:
            print("### ValueError " + file_path)
            makeValidJson(file_path)
            return True

###################################
# def makeValidJson
###################################
def makeValidJson(file_path):
    whole_data = None
    with open(file_path, 'r') as json_data:
        whole_data = json_data.read()

        whole_data = RE_Q_1.sub(r'",\n"', whole_data)
        whole_data = RE_Q_2.sub(r'"\g<org>"', whole_data)

        whole_data = RE_W_1.sub(r'",\n\g<org>', whole_data)
        whole_data = RE_W_2.sub(r'\g<org>,\n"', whole_data)

        whole_data = RE_D.sub(r'"\g<org>":', whole_data)

        whole_data = RE_M_1.sub(r'},{', whole_data)
        whole_data = RE_M_2.sub(r'],[', whole_data)

        whole_data = RE_M_3.sub(r'",[', whole_data)
        whole_data = RE_M_4.sub(r'],"', whole_data)

        whole_data = RE_M_5.sub(r'",\n{', whole_data)
        whole_data = RE_M_6.sub(r'},\n"', whole_data)

    if whole_data:
        return whole_data

###################################
# def main
###################################
def main():
    print("## JSON FORMATTER START")
    checkData(getAllFilePath(DATA_ROOT))
    print("## JSON FORMATTER END")

###################################
# MAIN
###################################
# if __name__ == '__main__':
#     main()
# else:
#     print('## I am being imported from another module')
    