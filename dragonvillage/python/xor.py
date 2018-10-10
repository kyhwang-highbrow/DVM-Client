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
    xor_core.setChangeExtension('.ps')

    # 대상 확장자 지정
    xor_core.setTargetExtensionList(['.lua'])

    #상위 폴더를 root_dir경로로 지정
    root_dir = os.path.dirname(os.path.realpath(__file__))
    root_dir = os.path.join(root_dir, '../')
    src_dir = os.path.join(root_dir, 'src')
    ps_dir = os.path.join(root_dir, 'ps')
    
    #복사를 제외할 경로 리스트 지정
    exclude_dir_list = []
    exclude_dir_list.append(os.path.join(src_dir, 'monitor'))

    # 1. ps폴더 삭제
    print('1. rmtree "ps"')
    if os.path.isdir(ps_dir):
        shutil.rmtree(ps_dir)

    # 2. ps폴더 생성    
    print('2. mkdir "ps"')
    os.mkdir(ps_dir)

    # 3. 폴더 복사
    print('3. copy_files')
    xor_core.copy_files2(src_dir, ps_dir, exclude_dir_list)
        
    # 4. xor 암호화
    sub_dir = 'ps'
    xor_core.convert(root_dir, sub_dir, '../' + sub_dir)

    print('------------------------------------------------------------')
    print('Total ' + str(xor_core.count_files) + ' files changed')

if __name__ == '__main__':
    main()