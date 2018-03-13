#-*- coding: utf-8 -*-

## 개요
## ui파일을 순회하며 png, vrp 리소스 추출

import os
import sys
import re
import shutil

## globals ############################
ROOT_PATH = '../res'
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
        print '\n### '+filename
        file_path = os.path.join(ROOT_PATH, filename)
        fr = open(file_path, 'r')
        extractionRes(fr)
    except:
        print '\n### '+filename+'\n'+'read fail!!!'
        pass

## define extractionRes
## UI파일에서 사용된 리소스 print
def extractionRes(fr):
    data = ""
    res_list = []
    for line in fr:
        data = data + line.strip()
    data = data.replace(" ", "")
    vars_target = re.findall(r"file_name='[\w\d\s+-/*]*'", data)

    for i in range(len(vars_target)):
        if vars_target[i] == "file_name=''":
            try:
                vars_target.remove(i)
            except:
                pass

    for i in range(len(vars_target)):
        _res = vars_target[i]
        _res = re.sub("'", "", _res)
        _res = re.sub("file_name=", "", _res)
        if len(_res) > 0:
            res_list.append(_res)

    for var in res_list:
        try:
            print var
        except:
            pass

###################################
# MAIN
###################################
if __name__ == '__main__':
    print '## find resource in ui file'
    loopAllFile()

else:
    print '## I am being imported from another module'
    