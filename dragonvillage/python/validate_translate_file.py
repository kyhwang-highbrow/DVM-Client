#-*- coding: utf-8 -*-

## 개요
## 번역 파일 검증

import os
import sys
import re
import shutil

## globals ############################
ROOT_PATH = '../translate'
TARGET_NAME = ''
READ_FAIL_LIST = []
#######################################

## define checkTranslateFile
## 번역 파일 읽음
def checkTranslateFile(filename, string_option):
    fr = None
    try:
        print '\n### '+filename
        file_path = os.path.join(ROOT_PATH, filename)
        fr = open(file_path, 'r')
        validateNum(fr, string_option)
    except:
        READ_FAIL_LIST.append(filename)
        print '\n### '+filename+'\n'+'read fail!!!'
        pass

## define validateNum
## 숫자 검증
def validateNum(fr, string_option):
    res_list = []
    lines = fr.readlines()

    print '### Total Line : {0}'.format(len(lines))
    print

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

                    if (string_option) :
                        invalid_str = '{0} line : '.format(line_num) + line.decode('utf-8')
                    else :
                        invalid_str = "{0} line : ".format(line_num) + ' '.join(
                            str(e) for e in new_list_1) + ' -> ' + ' '.join(str(e) for e in new_list_2)

                    res_list.append(invalid_str)
                    break

    for var in res_list:
        try:
            print var
        except:
            pass

    fr.close()

###################################
# MAIN
###################################
if __name__ == '__main__':
    print 'validate_translate_file'
    checkTranslateFile('lang_en.lua', True)
    checkTranslateFile('lang_jp.lua', False)
    checkTranslateFile('lang_zhtw.lua', False)

else:
    print '## I am being imported from another module'
    