#-*- coding:utf-8 -*-

'''
현재 시점의 패치 로그 파일을 생성하는 python 파일
root_dir의 patch_0.plg파일명으로 패치로그파일이 생성됨
'''

import os
import sys
import hashlib
import base64

#모듈을 사용하기 위해 시스템 경로 추가
file_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(file_path, 'module'))
import utility

root_dir = ''           # 실행되는 기본 경로

# 파일을 읽어 MD5를 생성
def file2md5(filename):
    md5 = hashlib.md5()
    with open(filename, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), ''):
            md5.update(chunk)
    return md5.hexdigest()
    
# 파일을 읽어 MD5를 생성
def file2md5(filename):
    BLOCKSIZE = 65536
    hasher = hashlib.md5()
    with open(filename, 'rb') as afile:
        buf = afile.read(BLOCKSIZE)
        while len(buf) > 0:
            hasher.update(buf)
            buf = afile.read(BLOCKSIZE)
    return hasher.hexdigest()
    
# 파일을 읽어 SHA1를 생성
def file2sha1(filename):
    BLOCKSIZE = 65536
    hasher = hashlib.sha1()
    with open(filename, 'rb') as afile:
        buf = afile.read(BLOCKSIZE)
        while len(buf) > 0:
            hasher.update(buf)
            buf = afile.read(BLOCKSIZE)
    return hasher.hexdigest()
    
# base64
def base64encode(input):
    # byte-stream으로 변환
    if utility.isPython3():
        output = base64.b64encode(input.encode())
    else:
        output = base64.b64encode(input)
    return output

# 파일의 md5를 추출, base64로 인코딩
def getPatchHash(filename):
    md5 = file2md5(filename)
    base64 = base64encode(md5)
    return base64

def iterstart(rootdir, subdir, hash_dic):
    print('search ' + subdir)
    iterfunc(rootdir, subdir, hash_dic)
    
def iterfunc(rootdir, subdir, hash_dic):
    global root_dir
    path = os.path.join(rootdir, subdir)
    
    if os.path.isdir(path) == False:
        print('"' + subdir + '" directory not found!')
        return
        
    if (utility.is_hidden(path)):
        print('hidden folder!')
        return
    
    for item in os.listdir(path):
        fullpath = os.path.join(path, item)
        
        if os.path.isdir(fullpath):
            iterfunc(path, item, hash_dic)
        else:
            relpath = os.path.relpath(fullpath, root_dir)
            hash = getPatchHash(fullpath)

            # 리스트에 key:경로, value:해쉬로 저장
            hash_dic[relpath] = hash
        
# plg 파일 세이브
def savePatchLog(root_dir, hash_dic):
    path = os.path.join(root_dir, 'patch_0.plg')
    f = open(path, 'w')
    for key in sorted(hash_dic):
        if utility.isPython3():
            f.writelines(key + '\t' + hash_dic[key].decode() + '\n')
        else:
            f.writelines(key + '\t' + hash_dic[key] + '\n')
    f.close()
    
        
# 메인함수
def main():
    global root_dir   
    # @mskim, 2020.11.20
    # python 위치 및 로그 생성 대상 파일을 고려하여 상대 경로 수정할 것
    relative_asset_path = '../../assets/full'

    root_dir = os.path.dirname(os.path.realpath(__file__))
    root_dir = os.path.join(root_dir, relative_asset_path)
    root_dir = os.path.abspath(root_dir)
    
    hash_dic = {}
    
    # hash_dic에 파일들의 hash정보를 저장
    iterstart(root_dir, 'data_dat', hash_dic)
    iterstart(root_dir, 'ps', hash_dic)
    iterstart(root_dir, 'res', hash_dic)
    iterstart(root_dir, 'sound', hash_dic)
    iterstart(root_dir, 'translate', hash_dic)
    
    # plg 파일 세이브
    savePatchLog(root_dir, hash_dic)
    
    print('done...')
    

if __name__ == '__main__':
    main()