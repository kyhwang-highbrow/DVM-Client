#-*- coding: utf-8 -*-

## 개요
## 번역 파일 검증

import os
import sys
import re
import shutil
import time

import importlib

def install_and_import(package):
    try:
        importlib.import_module(package)
    except ImportError:
        print('INSTALL DEPENDENCY MODULE :', package)
        try:
            from pip import main as pipmain
        except:
            from pip._internal.main import main as pipmain
        pipmain(['install', package])
    finally:
        globals()[package] = importlib.import_module(package)


install_and_import('progressbar')


## globals ############################
ROOT_PATH = '../../../translate'
MAKE_PATH = '../../'
INVALID_NUM_LIST = []
INVALID_NEWLINE_LIST = []
INVALID_COLOR_LIST = []

IGNORE_NUM_DIC = {}
IGNORE_NEWLINE_DIC = {}
#######################################

## define makeIgnoreList
## 등록된 ignore list 딕셔너리로 만들어줌
def makeIgnoreList():
    file_path = os.path.join(os.getcwd(), 'ignore_list_num.txt')
    fr = open(file_path, 'r', encoding='utf-8')
    lines = fr.readlines()
    for line in lines:
        IGNORE_NUM_DIC[line] = True
    fr.close()

    file_path = os.path.join(os.getcwd(), 'ignore_list_newline.txt')
    fr = open(file_path, 'r', encoding='utf-8')
    lines = fr.readlines()
    for line in lines:
        IGNORE_NEWLINE_DIC[line] = True
    fr.close()

## define checkTranslateFile
## 번역 파일 읽음
def checkTranslateFile(filename):
    file_path = os.path.join(ROOT_PATH, filename)
    fr = open(file_path, 'r', encoding='utf-8')
    lines = fr.readlines()
    line_num = 0
    INVALID_NUM_LIST.append('\n## {0}\n'.format(filename))
    INVALID_NEWLINE_LIST.append('\n## {0}\n'.format(filename))
    INVALID_COLOR_LIST.append('\n## {0}\n'.format(filename))

    print('## {0}'.format(filename))
    line_max = len(lines)
    progress = progressbar.ProgressBar()

    for i in progress(range(line_max)):
        line = lines[i]
        line_num = line_num + 1

        validateNum(line, line_num)
        validateLine(line, line_num)
        vaildateColorTag(line, line_num)

    fr.close()

## define validateNum
## 숫자 검증
def validateNum(line, line_num):
    is_ignore = False
    ignore_list = list(IGNORE_NUM_DIC.keys())
    for ignore_str in ignore_list:
        if line.find(ignore_str.strip()) != -1:
            is_ignore = True
            break

    if is_ignore == True:
        return

    target = re.findall(r'\d+(?:[\.|\,]\d+)?', line.strip())
    target_len = len(target)
    # if (target_len % 2 == 1):
        # res_list.append(idx)
    if (target_len > 0 and target_len % 2 == 0):
        new_list_1 = target[0:target_len//2]
        new_list_2 = target[target_len//2:target_len]
        new_list_1.sort()
        new_list_2.sort()
        for i in range(len(new_list_1)):
            if (new_list_1[i] != new_list_2[i]):
                # print target
                # print new_list_1
                # print new_list_2
                # print line_num
                invalid_str = '{0} line : '.format(line_num) + line
                INVALID_NUM_LIST.append(invalid_str)
                break

## define validateLine
## 개행문자 검증
def validateLine(line, line_num):
    is_ignore = False
    ignore_list = list(IGNORE_NEWLINE_DIC.keys())
    for ignore_str in ignore_list:
        if line.find(ignore_str.strip()) != -1:
            is_ignore = True
            break

    if is_ignore == True:
        return

    target = line.count('\\n')
    if (target > 0 and target % 2 == 1):
            invalid_str = '{0} line : '.format(line_num) + line
            INVALID_NEWLINE_LIST.append(invalid_str)

## define vaildateColorTag
## 리치라벨 칼라태그 검증
def vaildateColorTag(line, line_num):
    target = re.findall(r'{[@][\w\d\s+-/*]*}', line.strip())
    target_len = len(target)
    if (target_len > 0 and target_len % 2 == 1):
        invalid_str = '{0} line : '.format(line_num) + line
        INVALID_COLOR_LIST.append(invalid_str)

## define makeTxtFile
## txt 파일 생성
def makeTxtFile():
    file_path = os.path.join(MAKE_PATH, "validate_translate_file.txt")
    fw = open(file_path, "w", encoding='utf-8')

    fw.write('\n\n1.CHECK NUMBER \n')
    for item in INVALID_NUM_LIST:
        fw.write(item)

    fw.write('\n\n2.CHECK NEWLINE \n')
    for item in INVALID_NEWLINE_LIST:
        fw.write(item)

    fw.write('\n\n3.CHECK COLOR TAG \n')
    for item in INVALID_COLOR_LIST:
        fw.write(item)

    fw.close()

###################################
# MAIN
###################################
if __name__ == '__main__':
    print('## validate_translate_file')
    makeIgnoreList()
    checkTranslateFile('lang_en.lua')
    checkTranslateFile('lang_es.lua')
    checkTranslateFile('lang_fa.lua')
    checkTranslateFile('lang_jp.lua')
    checkTranslateFile('lang_th.lua')
    checkTranslateFile('lang_zhtw.lua')
    makeTxtFile()
    print('## success')
else:
    print('## I am being imported from another module')
    