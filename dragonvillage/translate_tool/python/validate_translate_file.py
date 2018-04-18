#-*- coding: utf-8 -*-

## 개요
## 번역 파일 검증

import os
import sys
import re
import shutil

## globals ############################
ROOT_PATH = '../../translate'
TARGET_NAME = ''
INVALID_LIST = []
#######################################

## define checkTranslateFile
## 번역 파일 읽음
def checkTranslateFile(filename):
    fr = None
    try:
        INVALID_LIST.append('\n### File Name : {0}'.format(filename))
        file_path = os.path.join(ROOT_PATH, filename)
        fr = open(file_path, 'r')
        validateNum(fr)
    except:
        pass

## define validateNum
## 숫자 검증
def validateNum(fr):

    lines = fr.readlines()
    INVALID_LIST.append('\n### Total Line : {0}\n\n'.format(len(lines)))

    line_num = 0
    for line in lines:
        line_num = line_num + 1
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
                    INVALID_LIST.append(invalid_str)
                    break
    fr.close()

## define makeTxtFile
## txt 파일 생성
def makeTxtFile():
    cwd = os.getcwd() + "_translate_file.txt"
    fw = open(cwd, "w")
    for item in INVALID_LIST:
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
    