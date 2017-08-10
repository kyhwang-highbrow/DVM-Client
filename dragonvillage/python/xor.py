#-*- coding:utf-8 -*-

import os
import sys
import shutil

count_files = 0

# 확장자 변경 *.lua -> *.ps
def changeExt(org):
    dest = os.path.splitext(org)[0] + ".ps"
    return dest

def copy_files(src, dst):
	if not os.path.isdir(src):
		return
	else:
		for item in os.listdir(src):
			path = os.path.join(src, item)
			# Android can not package the file that ends with ".gz"
			if os.path.isfile(path) and not item.startswith('.') and not item.endswith('.gz'):
				shutil.copy(path, dst)
			if os.path.isdir(path) and not item.startswith('.'):
				new_dst = os.path.join(dst, item)
				os.mkdir(new_dst)
				copy_files(path, new_dst)
                
def convert(rootdir, subdir, subdir2):
    path = os.path.join(rootdir, subdir)

    for item in os.listdir(path):
        fullpath = os.path.join(path, item)

        subdir3 = subdir2 + '/' + item

        if item.endswith('.lua'):
            xor_encrypter(fullpath, subdir3)

        if os.path.isdir(fullpath):
            convert(path, item, subdir3)

def xor_encrypter(file_path, file):
    # lua파일 오픈
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
    
    # lua파일 삭제
    os.remove(file_path)
    

def xor(data, key):
    l = len(key)
    return bytearray((
        (data[i] ^ key[i % l]) for i in range(0,len(data))
    ))

print('------------------------------------------------------------')

#상위 폴더를 root_dir경로로 지정
root_dir = os.path.dirname(os.path.realpath(__file__))
root_dir = os.path.join(root_dir, '../')
src_dir = os.path.join(root_dir, 'src')
ps_dir = os.path.join(root_dir, 'ps')

# 1. ps폴더 삭제
print('1. rmtree "ps"')
if os.path.isdir(ps_dir):
    shutil.rmtree(ps_dir)

# 2. ps폴더 생성    
print('2. mkdir "ps"')
os.mkdir(ps_dir)

# 3. 폴더 복사
print('3. copy_files')
copy_files(src_dir, ps_dir)
    
# 4. xor 암호화
sub_dir = 'ps'
convert(root_dir, sub_dir, '../' + sub_dir)

print('------------------------------------------------------------')
print('Total ' + str(count_files) + ' files changed')

#os.system('pause')