#-*- coding: utf-8 -*-

## 개요
## ui파일을 순회하며 file_name, lua_name, ui_name등 원하는 값 추출

import os
import sys
import re
import shutil

## globals ############################
ROOT_PATH = '../res'
TARGET_NAME = ''
READ_FAIL_LIST = []
#######################################

## define loopAllFile
## 파일들을 순회시킨다.
def loopAllFile():
    for root, _, files in os.walk(ROOT_PATH):
        for filename in files:
            if filename.endswith('.ui'):
                readUIFile(filename)

## define readUIFile
## UI파일을 순차적으로 읽음
def readUIFile(filename):
    fr = None
    try:
        print('\n### '+filename)
        file_path = os.path.join(ROOT_PATH, filename)
        fr = open(file_path, 'r')
        extractionRes(fr)
    except:
        READ_FAIL_LIST.append(filename)
        print('\n### '+filename+'\n'+'read fail!!!')
        pass

## define extractionRes
## UI파일에서 사용된 리소스 print
def extractionRes(fr):
    data = ""
    res_list = []
    for line in fr:
        data = data + line.strip()
    data = data.replace(" ", "")
    vars_target = re.findall(r"{0}='[\w\d\s+-/*]*'".format(TARGET_NAME), data)

    for i in range(len(vars_target)):
        if vars_target[i] == "{0}=''".format(TARGET_NAME):
            try: vars_target.remove(i)
            except: pass

    for i in range(len(vars_target)):
        _res = vars_target[i]
        _res = re.sub("'", "", _res)
        _res = re.sub("{0}=".format(TARGET_NAME), "", _res)
        if len(_res) > 0:
            res_list.append(_res)

    for var in res_list:
        try: print(var)
        except: pass

## define retryReadFile
## read fail한 파일들 있으면 다시한번 시도
def retryReadFile():
    if len(READ_FAIL_LIST) > 0:
        for i in range(len(READ_FAIL_LIST)):
            try:
                var = READ_FAIL_LIST[i]
                READ_FAIL_LIST.remove(i)
                readUIFile(var)
            except:
                pass

## define finishReadFile
## read fail한 파일들 있으면 출력
def finishReadFile():
    if len(READ_FAIL_LIST) > 0:
        print('\n\n##READ_FAIL_LIST')
        for var in READ_FAIL_LIST:
            try: print(var)
            except: pass
    else:
        print('\n\n##SUCCESS')

###################################
# MAIN
###################################
if __name__ == '__main__':
    print('UIResExtraction')
    print('Type the name you want to extract in ui file!\n(ex:file_name, lua_name, ui_name)')
    TARGET_NAME = raw_input()
    loopAllFile()
    retryReadFile()
    finishReadFile()
else:
    print('## I am being imported from another module')
    