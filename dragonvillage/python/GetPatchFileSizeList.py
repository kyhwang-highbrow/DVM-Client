# 특정 ROOT의 특정 확장자 파일의 이름과 사이즈 반환

import os
import re
import csv
import sys
import imghdr
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../patch/', 'patch_')

MAKE_CSV_NAME = 'result/FILE_SIZE_LIST.csv'

root_simple = os.path.basename(ROOT)
# brief : 특정 파일 이름 및 사이즈 리스트 반환


def get_file_size_data(root):
    data_list = []
    file_name_list = os.listdir(root)
    for file_name in file_name_list:
        full_file_name = os.path.join(root, file_name)
        if os.path.isdir(full_file_name):
            sub_data_list = get_file_size_data(full_file_name)
            data_list.extend(sub_data_list)
        else:
            ext = os.path.splitext(full_file_name)[-1]
            if ext == '.zip' :
                file_size = os.path.getsize(full_file_name)
                name = root_simple + full_file_name[len(ROOT):]
                patch_num = re.sub(r'[^0-9]', '', name)
                data = [name, file_size, file_size / 1024, file_size / 1024 / 1024, int(patch_num)]
                data_list.append(data)

    return data_list


# brief : csv 생성에 쓰일 헤더 생성
def make_header():
    return ['name', 'byte', 'KB', 'MB']


def make_csv(data_list):
    data_list.sort(key=lambda x:x[4])
    sum_size = 0
    for data in data_list:
        sum_size = data[3] + sum_size    
        print('>>>>', os.path.basename(data[0]), ':' , round(data[3],2), 'MB')
    print('Total Size :', round(sum_size, 2), 'MB')
        

def main():
    root = ROOT + sys.argv[1].replace('.', '_')
    print("# Make Patch File Zip List And Size")
    print("# Root :", root)

    # 파일 이름 및 사이즈 데이터 리스트 얻음
    data_list = get_file_size_data(root)

    make_csv(data_list)

    print("# FINISH :", MAKE_CSV_NAME)

    os.system('pause')    


if __name__ == '__main__':
    main()
         
