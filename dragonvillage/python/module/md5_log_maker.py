#-*- coding:utf-8 -*-
import os
import hashlib
import base64
import module.utility as utils

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
    
# base64
# input: String
# output : Binary
def base64encode(input):
    # byte-stream으로 변환
    if utils.isPython3():
        output = base64.b64encode(input.encode()) # string to binary
    else:
        output = base64.b64encode(input)
    return output

# 파일의 md5를 추출, base64로 인코딩
def getPatchHash(filename):
    md5 = file2md5(filename)
    base64 = base64encode(md5)
    if utils.isPython3():
        return base64.decode() # binary to string
    return base64

def iterstart(workd_path, rootdir, subdir, hash_dic):
    print('\t search ' + subdir)
    iterfunc(workd_path, rootdir, subdir, hash_dic)
    
def iterfunc(workd_path, rootdir, subdir, hash_dic):
    path = os.path.join(rootdir, subdir)

    if os.path.isdir(path) == False:
        print('\t"' + subdir + '" directory not found!')
        return
    
    if (utils.is_hidden(path)):
        print('\t hidden folder : ' + path)
        return

    for item in os.listdir(path):
        fullpath = os.path.join(path, item)
        
        if os.path.isdir(fullpath):
            iterfunc(workd_path, path, item, hash_dic)
        else:
            relpath = os.path.relpath(fullpath, workd_path)
            hash = getPatchHash(fullpath)

            # 리스트에 key:경로, value:해쉬로 저장
            hash_dic[relpath] = hash
    

def makePatchLog(source_path, plg_path):
    # Dictionary<String, ByteStream>
    # String to ByteStream -> param.encode()
    # ByteStream to String -> param.decode()
    hash_dic = {}
    
    # 1. 타겟 경로들의 모든 파일들의 md5를 생성
    # hash_dic에 파일들의 hash정보를 저장
    workd_path = source_path
    iterstart(workd_path, source_path, 'data_dat', hash_dic)
    iterstart(workd_path, source_path, 'ps', hash_dic)
    iterstart(workd_path, source_path, 'res', hash_dic)
    iterstart(workd_path, source_path, 'sound', hash_dic)
    iterstart(workd_path, source_path, 'translate', hash_dic)

    # # 파일에 세이브
    f = open(plg_path, 'w')
    for key in sorted(hash_dic):
        f.writelines(key + '\t' + hash_dic[key] + '\n')
    f.close()
    
    print('\t' + plg_path)
    return hash_dic
    
def loadPatchLog(plg_path):
    hash_dic = {}
    
    lines = [line.rstrip('\n') for line in open(plg_path)]
    
    
    for line in lines:
        split = line.split('\t')
        key = split[0]
        value = split[1]
        hash_dic[key] = value
    
    return hash_dic