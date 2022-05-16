import os
import shutil

import module.utility as utils

utils.install_and_import('dirsync', globals())

SYNC_EXCLUDE_PATTERN = r'.svn',

# 폴더 생성 함수
def createDirectory(path):
# 폴더 경로를 순차적으로 생성하기

    if not os.path.isdir(path):
        os.makedirs(path)
        print('create directory : ', path)

# 하위 폴더와 파일까지 같이 삭제
def removeDirectory(path):
    if os.path.isdir(path):
        shutil.rmtree(path) 
        print('remove directory : ', path)
    else:
        print('remove directory no folders : ', path)
    
def moveDirectory(path, target):
    if os.path.isdir(path):
        createDirectory(target)
        for filename in os.listdir(path):
            shutil.move(path + '/' + filename, target)
        print('move directory : ', path, ' -> ', target)
    else:
        print('move directory no folders : ', path)

# path의 내용과 target_pathf를 동기화한다.
# path에 있고 target에 없으면 복사
# path에 없고 target에 있으면 삭제
def syncDirectory(path, target_path):
    # exclude는 특정 형식 제외
    # purge는 동기화 소스 위치에 없는 파일들이 타겟 위치에 있다면 그 모든 파일들을 지우는 옵션값
    createDirectory(path)
    createDirectory(target_path)
    print('syncDirectory :', path, target_path)
    dirsync.sync(path, target_path, 'sync', purge=True, exclude=SYNC_EXCLUDE_PATTERN)
    
# 폴더 사이즈를 반환하는 함수
# 대상이 파일이면 사이즈 반환, 폴더면 재귀로 호출해서 하위 파일을 검사한다.
def getDirectorySize(path):
    total = 0
    with os.scandir(path) as it:
        for entry in it:
            if entry.is_file():
                total += entry.stat().st_size
            elif entry.is_dir():
                total += getDirectorySize(entry.path)
    return total

#대상에 따라서 폴더 사이즈 검사 또는 파일 사이즈를 검사한다.
def getSize(path):
    if os.path.isfile(path):
        return os.path.getsize(path)
    elif os.path.isdir(path):
        return getDirectorySize(path)
    else:
        return 0
    
# 경로의 파일이 지정된 key를 모두 가지고 있으면 삭제
def removeFileInPathByKeys(path, key_list):
    removeCount = 0
    removeFileList = []
    
    print('removeFileInPathByKey')
    
    for filename in os.listdir(path):        
        target_file = True

        for key in key_list:
            if not (key in filename):
                target_file = False
                break
        
        if target_file:
            os.remove(path + '/' + filename)
            removeCount += 1
            removeFileList.append(filename)
            
    print('remove Count : ', removeCount)
    print(removeFileList)

# 폴더 없으면 생성하고 true 반환, 있으면 false
def makeDirectoryIfNotExist(path):
    if (not os.path.exists(path)): 
        os.makedirs(path)
        return True
    return False