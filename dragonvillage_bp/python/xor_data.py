#-*- coding:utf-8 -*-

import os
import sys
import shutil

#모듈을 사용하기 위해 시스템 경로 추가
file_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(file_path, 'module'))
import xor_core

def main():
    # 변경될 확장자 지정
    xor_core.setChangeExtension('.dat')

    # 대상 확장자 지정
    xor_core.setTargetExtensionList(['.txt', '.json', '.csv'])

    #상위 폴더를 root_dir경로로 지정
    root_dir = os.path.dirname(os.path.realpath(__file__))
    root_dir = os.path.join(root_dir, '../')
    src_dir = os.path.join(root_dir, 'data')
    dat_dir = os.path.join(root_dir, 'data_dat')

    # 1. dat폴더 삭제
    print('1. rmtree "data_dat"')
    if os.path.isdir(dat_dir):
        shutil.rmtree(dat_dir)

    # 2. dat폴더 생성    
    print('2. mkdir "data_dat"')
    os.mkdir(dat_dir)

    # 3. 폴더 복사
    print('3. copy_files')
    xor_core.copy_files(src_dir, dat_dir)
        
    # 4. xor 암호화
    sub_dir = 'data_dat'
    xor_core.convert(root_dir, sub_dir, '../' + sub_dir)

    print('------------------------------------------------------------')
    print('Total ' + str(xor_core.count_files) + ' files changed')

if __name__ == '__main__':
    main()