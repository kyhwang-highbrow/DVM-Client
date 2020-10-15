#-*- coding: utf-8 -*-

import os
import sys
import csv
import json
import json_formatter
import module.utility as utils

# 전역 변수
DATA_ROOT = '../data/'
INVALID_DATA_TABLE = []
DRAGON_TABLE = None
MONSTER_TABLE = None

#import
utils.install_and_import('slacker', globals())

###################################
# def initGlobalVar
###################################
def initGlobalVar():
    global DRAGON_TABLE
    global MONSTER_TABLE
    DRAGON_TABLE = makeDictCSV('../data/table_dragon.csv', 'did')
    MONSTER_TABLE = makeDictCSV('../data/table_monster.csv', 'mid')


###################################
# def validateData
# @brief data 검증 시작
###################################
def validateData():
    # 전체 파일 경로 찾기
    file_path_list = getAllFilePath(DATA_ROOT)

    # 전체 파일 리스트 자료 정리 (딕셔너리화)
    table_data = makeDictAllData(file_path_list)

    # 파일 검증
    validateData_Dragon(table_data)
    validateData_Stage(table_data)
    validateData_Skill()



######################################################################
# 1. 전체 파일 경로 찾기

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



######################################################################
# 2. 전체 파일 구조화

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
    reader = csv.reader(open(file_path, "rt", encoding='utf-8'))
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
            valid_json_str = json_formatter.makeValidJson(file_path)
            txt_dict = json.loads(valid_json_str)

    return txt_dict





######################################################################
# 3. 데이터 테이블 검증

###################################
# def validateData_Dragon
# @brief 드래곤 테이블 관련 테이블 did 검증
###################################
def validateData_Dragon(table_data):
    for file_path, l_data in table_data.iteritems():
        if file_path.find('table_dragon') > 0:
            for t_row in l_data:
                checkCSVRow(t_row, 'did', DRAGON_TABLE, file_path)
                checkCSVRow(t_row, 'base_did', DRAGON_TABLE, file_path)

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
# def validateData_Stage
# @brief 드래곤 테이블 관련 테이블 did 검증
###################################
def validateData_Stage(table_data):
    for file_path, t_data in table_data.iteritems():
        if file_path.find('stage_') > 0 and file_path.endswith('.txt'):
            checkStageScript(t_data, file_path)

###################################
# def checkStageScript
###################################
def checkStageScript(t_data, file_path):
    for t_wave in t_data.get("wave"):
        for summon_info in t_wave.get("wave").values():
            for script in summon_info:
                monster_id = script.split(';')[0]
                if monster_id.find('RandomDragon') == -1:
                    checkDictHasKey(MONSTER_TABLE, monster_id, file_path)

###################################
# def validateData_Stage
# @brief 드래곤 테이블 관련 테이블 did 검증
###################################
def validateData_Skill():
    t_dragon_skill = makeDictCSV('../data/table_dragon_skill.csv', 'sid')
    t_monster_skill = makeDictCSV('../data/table_monster_skill.csv', 'sid')

    l_skill_column = ['skill_basic', 'skill_active']
    for i in range(10):
        l_skill_column.append("skill_" + str(i))

    # 1. dragon
    checkSkillTable(t_dragon_skill, DRAGON_TABLE, l_skill_column)

    # 2. monster
    checkSkillTable(t_monster_skill, MONSTER_TABLE, l_skill_column)

###################################
# def checkSkillTable
###################################
def checkSkillTable(skill_table, char_table, l_skill_column):
    for t_char in char_table.values():
        char_name = t_char.get('t_name').decode('utf-8')
        for skill_column in l_skill_column:
            skill_id = t_char.get(skill_column)
            if skill_id:
                checkDictHasKey(skill_table, skill_id, char_name)

###################################
# def checkDictHasKey
# @brief 특정 사전에 특정 키값이 존재하는지 검사하여 없으면 에러 테이블 목록에 등록한다.
###################################
def checkDictHasKey(table, key, file_path):
    key = key.strip()
    if not table.get(key):
        temp_dict = {}
        temp_dict['path'] = file_path.replace(DATA_ROOT, "")
        temp_dict['info'] = key
        INVALID_DATA_TABLE.append(temp_dict)




######################################################################
# 3. 검증 결과 리포트 (출력 + 슬랙)

###################################
# def makeInvalidStr
# @brief 오류가 있는 테이블 목록을 예쁘게 출력될 텍스트로 만든다.
###################################
def makeInvalidStr():
    table_str = "@hkkang @wjung @jykim\n"
    table_str += "##잘못된 데이터 목록##\n"
    for temp_dict in INVALID_DATA_TABLE:
        text = temp_dict.get('path') + '\t' + temp_dict.get('info')
        table_str += text.encode('utf-8') + "\n"

    return table_str

###################################
# def sendInvalidTableListBySlack
# @brief 슬랙으로 쏜다
###################################
def sendInvalidTableListBySlack():
    attachments_dict = dict()
    attachments_dict['title'] = "[DV_BOT] TABLE VALIDATION"
    attachments_dict['title_link'] = 'https://drive.google.com/open?id=0Bzybp2XzPNq0flpmdEstcDJYOTdPbXFWcFpkWktZY0NxdnpyUHF1VENFX29jbnJLSGRvcFE'
    attachments_dict['fallback'] = "[DV_BOT] 테이블 오류 발견 !!"
    attachments_dict['text'] = makeInvalidStr()
    print(makeInvalidStr())
    
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
    print("## TABLE VALIDATION START")

    sys_error_code = 0

    # 전역 변수 초기화
    initGlobalVar()

    # 데이터 검증
    validateData()

    # 검증 결과 리포트
    if len(INVALID_DATA_TABLE) > 0:
        sendInvalidTableListBySlack()
        sys_error_code = 105

    print("## TABLE VALIDATION END")

    sys.exit(sys_error_code)

###################################
###################################
if __name__ == '__main__':
    main()
else:
    print('## I am being imported from another module')
    