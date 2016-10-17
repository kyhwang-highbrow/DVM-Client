# -*- coding: utf-8 -*-
import os, sys
import zipfile

root_dir = ''

#마지막 폴더명만 얻어오는 함수
def getDirName(path):
    # file의 경우 dirname을 먼저 얻어옴
    if os.path.isdir(path) == False:
        path = os.path.dirname(path)    

    normpath = os.path.normpath(path)
    basename = os.path.basename(normpath)
    return basename


def zipdirectory(path):
    os.chdir(path)
    
    dirname = getDirName(path)
    
    zipname = os.path.join(path, '../', dirname + '.zip')
    
    zipf = zipfile.ZipFile(zipname, 'w', zipfile.ZIP_DEFLATED)
    for root, dirs, files in os.walk('./'):
        for file in files:
            print(os.path.join(root, file))
            zipf.write(os.path.join(root, file))
    zipf.close()
    
def main():
    global root_dir
    root_dir = os.path.dirname(os.path.realpath(__file__))
    root_dir = os.path.join(root_dir, '..')
    root_dir = os.path.abspath(root_dir)
    os.chdir(root_dir)
   
    zipdirectory(os.path.join(root_dir, 'src'))
    
if __name__ == '__main__':
    main()