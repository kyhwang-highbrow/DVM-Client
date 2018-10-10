#-*- coding:utf-8 -*-

import os
import sys
import shutil
import utility

count_files = 0
EXT_TO_CHANGE = ''
L_TARGET_EXT = {}

def setChangeExtension(ext):
    global EXT_TO_CHANGE
    EXT_TO_CHANGE = ext

def setTargetExtensionList(l_ext):
    global L_TARGET_EXT
    L_TARGET_EXT = l_ext

def changeExt(org):
    dest = os.path.splitext(org)[0] + EXT_TO_CHANGE
    return dest
                
def check_excluded_dir(excluded_dir_list, dir):
    abs_path = os.path.abspath(dir)
    for excluded_dir in excluded_dir_list:
        if abs_path == os.path.abspath(excluded_dir):
            return True
        
    return False
        
# 특정 경로를 제외하고 복사
def copy_files2(src, dst, excluded_dir_list):
    if check_excluded_dir(excluded_dir_list, src):
        return
    elif not os.path.isdir(src):
        return
    else:
        for item in os.listdir(src):
            path = os.path.join(src, item)
            # hidden file have not to copy
            if utility.is_hidden(path):
                continue
            
            if check_excluded_dir(excluded_dir_list, path):
                continue
                    
            # Android can not package the file that ends with ".gz"
            if os.path.isfile(path) and not item.endswith('.gz'):
                shutil.copy(path, dst)

            if os.path.isdir(path):
                new_dst = os.path.join(dst, item)
                os.mkdir(new_dst)
                copy_files2(path, new_dst, excluded_dir_list)
                
def copy_files(src, dst):
    excluded_dir_list = []
    return copy_files2(src, dst, excluded_dir_list)

def convert(rootdir, subdir, subdir2):
    path = os.path.join(rootdir, subdir)

    for item in os.listdir(path):
        fullpath = os.path.join(path, item)

        subdir3 = subdir2 + '/' + item

        for ext in L_TARGET_EXT:
            if (item.endswith(ext)):
                xor_encrypter(fullpath, subdir3)
                break

        if os.path.isdir(fullpath):
            convert(path, item, subdir3)

def xor_encrypter(file_path, file):
    # 파일 오픈
    #print(file_path)
    f = open(file_path, 'rb')
    file_arr = f.read()
    f.close()
    
    # xor 암호화
    data = bytearray(file_arr)
    key = bytearray([0x01, 0x90, 0x32, 0xcf, 0x96, 0x7b, 0x5a, 0xe5, 0xd2, 0xbf, 0x2d, 0xdc, 0xb6, 0x83, 0x4e, 0x04])
    xor_data = xor(data, key)
    
    global count_files

    # 파일에 쓰기
    write_f = open(changeExt(file_path), 'wb')
    write_f.write(xor_data)
    write_f.close()
    count_files = (count_files + 1)
    
    # 파일 삭제
    os.remove(file_path)

    # 진행하는 것이 보이게 path 출력
    # sys.stdout.write(file_path + '\r')
    # sys.stdout.flush()

def xor(data, key):
    l = len(key)
    return bytearray((
        (data[i] ^ key[i % l]) for i in range(0,len(data))
    ))