import time
import os
import module.directory_helper as directory_helper
import sys
import shutil


# 복사해야 되는 폴더들
PATH_LIST = ['src', 'data', 'res', 'translate', 'sound', 'json']

# 복사해서 넣어야하는 폴더
# dragonvillage/python 기준 상대 경로
ASSETS_PATH = '../../assets/full'


def main():
    # 시작
    start = time.time()
    print('\n\n')
    print('## CopySrcToAsset:run')
    print('\n')
    print('-------------------------------------------')
    print('## Target Path : ', ASSETS_PATH)
    print('-------------------------------------------')
    
    
    # 목표 위치로 폴더 동기화
    directory_helper.syncDirectory('../ps', ASSETS_PATH + '/ps')
   
    # 현재 폴더 위치 확인
    os.chdir(ASSETS_PATH)
    print('current dir : ', os.getcwd())
    print('-------------------------------------------')
    
    # 걸린 시간
    print("time : ", time.time() - start)
    
    os.system('Pause')

#AssetMaker.py
if __name__ == '__main__':
    main()