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


#지정된 대상과 목표를 동기화 시킨다.
def syncAllDirectory():    
    for path in PATH_LIST:
        directory_helper.syncDirectory('../' + path, ASSETS_PATH + '/' + path)


def main():
    # 시작
    start = time.time()
    print('\n\n')
    print('## CopyAssetFull:run')
    print('\n')
    print('-------------------------------------------')
    print('## Target Path : ', ASSETS_PATH)
    print('-------------------------------------------')
    
    # 목표 폴더 제거
    directory_helper.removeDirectory(ASSETS_PATH)

    # 목표 폴더 사전 생성
    directory_helper.createDirectory(ASSETS_PATH)
    
    # 목표 위치로 폴더 동기화
    syncAllDirectory()

    # entrypoint lua파일 복사
    shutil.copy('../entry_main.lua', ASSETS_PATH + '/entry_main.lua')
    shutil.copy('../entry_patch.lua', ASSETS_PATH + '/entry_patch.lua')
    
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