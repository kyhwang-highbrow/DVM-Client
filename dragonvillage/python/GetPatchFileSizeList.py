# 패치 파일 사이즈 출력 기능
# 라이브 서버만 확인하도록 개발해놓음
import os
import re
import sys
import shutil
import module.utility as utils

# brief : 특정 파일 이름 및 사이즈 리스트 반환
# 서버로부터 패치 정보 얻어옴
def info_patch_size(app_ver):
    print(app_ver, 'version get patch size info ...')
    # import requests
    utils.install_and_import('requests', globals())
    params = {'app_ver': app_ver}

    # QA서버에서 사이즈를 가져오도록 수정
    # http://dvm-api.perplelab.com/get_patch_info
    r = requests.get('http://dv-qa.perplelab.com:9003/get_patch_info', params=params)
    ret_data = r.json()

    if ret_data['status'] < 0:
        print(ret_data)
        return

    list = ret_data['list']
    sum_size = 0
    for v in list:
        mb_size = v['size']/1024/1024
        sum_size = sum_size + mb_size
        print('>>', os.path.basename(v['name']) , ':' , round(mb_size ,2), 'MB')

    print('Total Size :', round(sum_size, 2), 'MB')

    # 현재 패치 ver를 리턴
    cur_patch_ver = max([0, ret_data['cur_patch_ver']])
    return cur_patch_ver

def main():
    # 파일 이름 및 사이즈 데이터 리스트 얻음
    info_patch_size(sys.argv[1])

if __name__ == '__main__':
    main()
         
