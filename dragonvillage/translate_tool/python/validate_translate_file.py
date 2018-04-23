#-*- coding: utf-8 -*-

## 개요
## 번역 파일 검증

import os
import sys
import re
import shutil

## globals ############################
ROOT_PATH = '../../translate'
INVALID_NUM_LIST = []
INVALID_NEWLINE_LIST = []
INVALID_COLOR_LIST = []
#######################################

## define checkTranslateFile
## 번역 파일 읽음
def checkTranslateFile(filename):
    file_path = os.path.join(ROOT_PATH, filename)
    fr = open(file_path, 'r')

    lines = fr.readlines()
    line_num = 0
    INVALID_NUM_LIST.append('\n###{0}\n'.format(filename))
    INVALID_NEWLINE_LIST.append('\n###{0}\n'.format(filename))
    INVALID_COLOR_LIST.append('\n###{0}\n'.format(filename))

    for line in lines:
        line_num = line_num + 1
        validateNum(line, line_num)
        validateLine(line, line_num)
        vaildateColorTag(line, line_num)

    fr.close()

## define validateNum
## 숫자 검증
def validateNum(line, line_num):
    target = re.findall(r'\d+(?:[\.|\,]\d+)?', line.strip())
    target_len = len(target)
    # if (target_len % 2 == 1):
        # res_list.append(idx)
    if (target_len > 0 and target_len % 2 == 0):
        new_list_1 = target[0:target_len/2]
        new_list_2 = target[target_len/2:target_len]
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
    cwd = os.getcwd() + "_translate_file.txt"
    fw = open(cwd, "w")
    fw.write('\n\n\n1.CHECK NUMBER \n')
    for item in INVALID_NUM_LIST:
        fw.write(item)

    fw.write('\n\n\n2.CHECK NEWLINE \n')
    for item in INVALID_NEWLINE_LIST:
        fw.write(item)

    fw.write('\n\n\n3.CHECK COLOR TAG \n')
    for item in INVALID_COLOR_LIST:
        fw.write(item)

    fw.close()

###################################
# MAIN
###################################
if __name__ == '__main__':
    print '## validate_translate_file'
    checkTranslateFile('lang_en.lua')
    checkTranslateFile('lang_jp.lua')
    checkTranslateFile('lang_zhtw.lua')
    makeTxtFile()
    print '## success'
else:
    print '## I am being imported from another module'
    