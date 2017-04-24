#-*- coding: utf-8 -*-

import os
import re
import json

DATA_ROOT = '../data/'
INVALID_DATA_TABLE = []

re_1 = re.compile(r'\"\s+\"')
re_3 = re.compile(r'\"\s+(?P<num>\d)')
re_4 = re.compile(r'(?P<num>\d)\s+\"')
re_5 = re.compile(r'[}]\s+[{]"')
re_6 = re.compile(r'[]]\s+[[]"')

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
                print file_path
                break

###################################
# def validateJson
###################################
def validateJson(file_path):
    with open(file_path, 'r') as json_data:
        try:
            json.load(json_data)
            return True
        except ValueError:
            makeValidJson(file_path)
            return False

###################################
# def makeValidJson
###################################
def makeValidJson(file_path):
    with open(file_path, 'r') as json_data:
        whole_data = json_data.read()

        whole_data = re_1.sub(r'","', whole_data)

        whole_data = re_3.sub(r'",\g<num>', whole_data)
        whole_data = re_4.sub(r'\g<num>,"', whole_data)

        whole_data = re_5.sub(r'},{', whole_data)
        whole_data = re_6.sub(r'],["', whole_data)

        print whole_data

###################################
# def main
###################################
def main():
    checkData(getAllFilePath(DATA_ROOT))

###################################
print "## start"
###################################
if __name__ == '__main__':
    main()
    print "## end"
else:
    print '## I am being imported from another module'
    