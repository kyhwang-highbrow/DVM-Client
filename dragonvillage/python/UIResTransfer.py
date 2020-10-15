#-*- coding: utf-8 -*-

## 개요
## ui파일을 순회하며 old_path 파일을 사용하는 ui파일을 찾아내어
## 대상 파일을 trans_path 로 옮기고 ui파일도 변경한다.

import os
import sys
import re
import shutil

## globals ############################
T_TARGET_UI = None
T_TARGET_RES = None
REG_EXP = None
REG_SUB_PATTERN = None

ROOT_PATH = '../res'
UI_PATH = '../res/ui/'
#######################################

## define loopAllFile
## 파일들을 순회시킨다.
def initGlobalVars(old_path, trans_path):
    global T_TARGET_UI
    global T_TARGET_RES
    global REG_EXP, REG_SUB_PATTERN

    T_TARGET_UI = {}
    T_TARGET_RES = {}
    REG_EXP = re.compile(old_path + r'(?P<name>\w*.png)')
    REG_SUB_PATTERN = trans_path + r'\g<name>'

## define loopAllFile
## 파일들을 순회시킨다.
def loopAllFile():
    for root, _, files in os.walk(ROOT_PATH):
        for filename in files:
            if filename.endswith('.ui'):
                file_path = os.path.join(root, filename)
                findTarget(file_path)


## define findTarget
## 해당 경로의 파일을 조사하여 바꿀 UI와 res 리스트 작성
def findTarget(file_path):
    is_deserve = False
    with open(file_path, 'r') as f:
        while True:
            line = f.readline()
            if not line:
                break
            # 정규식으로 걸러지는 파일을 찾는다.
            reg_s = REG_EXP.search(line)
            if (reg_s):
                res_name = reg_s.group()
                T_TARGET_RES[res_name] = True
                is_deserve = True

    # 바뀔 png가 있다면 UI 등록
    if is_deserve:
        T_TARGET_UI[file_path] = True


## define changeDotUI
## ui파일을 변경한다.
def changeDotUI(file_path):
    ui_str = None
    with open(file_path, 'r') as f:
        ui_str = f.read()

    new_ui_str = REG_EXP.sub(REG_SUB_PATTERN, ui_str)
    # .ui 새로 쓰기
    with open(file_path, 'w') as f:
        f.write(new_ui_str)


## define moveResFile
## 대상 파일들을 새로운 경로로 이동시킨다.
def moveResFile(file_path):
    src_path = UI_PATH + file_path
    org_path = REG_EXP.sub(REG_SUB_PATTERN, src_path)
    shutil.move(src_path, org_path)
    print('## move to :' + org_path)


## define doTransfer
## 실행부
def doTransfer(old_path, transfer_path):
    initGlobalVars(old_path, transfer_path)
    loopAllFile()

    # UI 변경
    for file_path in T_TARGET_UI.keys():
        print('##' + file_path)
        changeDotUI(file_path)
    
    # 리소스 이동할 곳의 폴더 생성
    # 예외처리 필요
    os.mkdir(UI_PATH + transfer_path)

    # 리소스 이동
    for file_name in T_TARGET_RES.keys():
        print('##' + file_name)
        moveResFile(file_name)

###################################
# MAIN
###################################
if __name__ == '__main__':
    doTransfer('frame/', 'frames/temp/')

else:
    print('## I am being imported from another module')
    