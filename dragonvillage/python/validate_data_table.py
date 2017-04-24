#-*- coding: utf-8 -*-

import os
import sys
import re
import csv
import json

DATA_ROOT = '../data/'
DRAGON_TABLE_PATH = '../data/table_dragon.csv'
INVALID_DATA_TABLE = []

DRAGON_TABLE = {}
MONSTER_TABLE = {}

###################################
# def install_and_import
# @brief 특정 폴더의 전체 파일 절대경로 리스트 반환
###################################
def install_and_import(package):
    import importlib
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        pip.main(['install', package])
    finally:
        globals()[package] = importlib.import_module(package)

#import
install_and_import('slacker')

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
# def validateData
# @brief data 검증 시작
###################################
def validateData():
    file_path_list = getAllFilePath(DATA_ROOT)

    # 전체 파일 리스트 자료 정리 (딕셔너리화)
    table_data = makeDictAllData(file_path_list)

    # 파일 검증
    validateData_Dragon(table_data)




###################################
# def validateData_Dragon
# @brief 드래곤 테이블 관련 테이블 did 검증
###################################
def validateData_Dragon(table_data):
    t_dragon = makeDictCSV(os.path.abspath(DRAGON_TABLE_PATH), 'did')

    for file_path, l_data in table_data.iteritems():
        if file_path.find('table_dragon') > 0:
            for t_row in l_data:
                checkCSVRow(t_row, 'did', t_dragon, file_path)
                checkCSVRow(t_row, 'base_did', t_dragon, file_path)

###################################
# def checkCSVRow
###################################
def checkCSVRow(t_row, key, table, file_path):
    did_str = t_row.get(key)
    if did_str:
        if did_str.find(',') > 0:
            l_did = did_str.split(',')
            for did in l_did:
                checkDictHasKey(table, did, file_path)
        else:
            checkDictHasKey(table, did_str, file_path)

###################################
# def checkDictHasKey
###################################
def checkDictHasKey(table, key, file_path):
    key = key.strip()
    if not table.get(key):
        temp_dict = {}
        path_extractor = re.findall(r"table_\w+[.]\w+", file_path)
        temp_dict['path'] = path_extractor[0]
        temp_dict['info'] = key
        INVALID_DATA_TABLE.append(temp_dict)



###################################
# def makeDictAllData
# @brief 파일 경로 리스트를 받아서 각 파일을 딕셔너리화 한 딕셔너리 반환
###################################
def makeDictAllData(file_path_list):
    table_data = {}
    for file_path in file_path_list:
        l_data = None

        if file_path.endswith('.csv'):
            l_data = makeListCSV(file_path)
        elif file_path.endswith('.txt'):
            l_data = makeDataTxt(file_path)

        table_data[file_path] = l_data

    return table_data

###################################
# def makeListCSV
# @brief csv를 리스트로 변환
###################################
def makeListCSV(file_path):
    reader = csv.reader(open(file_path, "rt"))
    l_csv = []
    l_header = []
    is_first = True

    for row in reader:
        if is_first:
            l_header = row
            is_first = False
        else:
            t_row = {}
            idx = 0
            for item in row:
                t_row[l_header[idx]] = item
                idx += 1
            l_csv.append(t_row)

    return l_csv

###################################
# def makeDictCSV
# @brief csv를 특정 값을 찾아서 키로 하는 딕셔너리로 변환
###################################
def makeDictCSV(file_path, key):
    reader = csv.reader(open(file_path, "rt"))
    t_csv = {}
    l_header = []
    is_first = True

    for row in reader:
        if is_first:
            l_header = row
            is_first = False
        else:
            t_row = {}
            idx = 0
            for item in row:
                t_row[l_header[idx]] = item
                idx += 1
            real_key = t_row[key]
            t_csv[real_key] = t_row

    return t_csv

###################################
# def makeDataTxt
# @brief json을 파씽
###################################
def makeDataTxt(file_path):
    txt_dict = None
    with open(file_path) as json_data:
        try:
            txt_dict = json.load(json_data)
        except ValueError:
            print file_path

    return txt_dict







###################################
# def makeInvalidStr
# @brief 오류가 있는 테이블 목록을 예쁘게 출력될 텍스트로 만든다.
###################################
def makeInvalidStr():
    table_str = "@jykim\n"
    table_str += "##잘못된 데이터 목록##\n"
    for temp_dict in INVALID_DATA_TABLE:
        text = temp_dict.get('path') + '\t' + temp_dict.get('info')
        table_str += text + "\n"

    return table_str

###################################
# def sendInvalidTableListBySlack
# @brief 슬랙으로 쏜다
###################################
def sendInvalidTableListBySlack():
    if len(INVALID_DATA_TABLE) == 0:
        return

    attachments_dict = dict()
    attachments_dict['title'] = "[DV_BOT] TABLE VALIDATION"
    attachments_dict['title_link'] = 'https://drive.google.com/open?id=0Bzybp2XzPNq0flpmdEstcDJYOTdPbXFWcFpkWktZY0NxdnpyUHF1VENFX29jbnJLSGRvcFE'
    attachments_dict['fallback'] = "[DV_BOT] 테이블 오류 발견 !!"
    attachments_dict['text'] = makeInvalidStr()

    #attachments_dict['pretext'] = "pretext - python slack api TEST"
    #attachments_dict['mrkdwn_in'] = ["text", "pretext"]  # 마크다운을 적용시킬 인자들을 선택합니다.

    # jykim : U1QEY8938
    # wjung : U386T6HD5
    # hkkang : U1QPKAS2F

    attachments = [attachments_dict]

    token = 'xoxp-4049551466-60623372247-67908400245-53f29cbca3'
    slack = slacker.Slacker(token)
    slack.chat.post_message(
        channel="C1RUT070B", username="드빌봇",
        text=None, attachments=attachments, as_user=False)


###################################
# def main
###################################
def main():
    sys_error_code = 0
    validateData()
    print makeInvalidStr()
    try:
        print "## table validation done"
    except:
        print "## there is some error"
        sys_error_code = 105
    finally:
        print "## end"
        #sendInvalidTableListBySlack()
        sys.exit(sys_error_code)

###################################
print "## start"
###################################
if __name__ == '__main__':
    main()
else:
    print '## I am being imported from another module'
    