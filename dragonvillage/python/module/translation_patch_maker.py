#-*- coding:utf-8 -*-

####################################
# IMPORT
####################################
import os
import sys
import shutil
import zipfile
import datetime
import re
import module.md5_log_maker as md5
import module.utility as utils
import module.checksum as checksum

# import requests
utils.install_and_import('requests', globals())
####################################
# VARIABLES
####################################

# set current path
__CURR_PATH = os.path.dirname(os.path.realpath(__file__))
sys.path.append(__CURR_PATH)

__PATCH_INFO_DIC = {}
__REG_LANG = re.compile("^lang_(?P<lang>[a-zA-Z\-]+)(_patch)?_[0-9]*.zip$")

# 서버로부터 패치 정보 얻어옴
def __get_language_patch_info(target_server_url, app_ver, lang_code):
    params = {
        'app_ver': app_ver,
        'patch_ver': 0,        
        'lang' : lang_code
    }
    
    r = requests.get(target_server_url + '/get_patch_info', params=params)
    r.raise_for_status() #200 OK 코드가 아닌 경우 에러 발동
    ret_data = r.json()
    # print(ret_data)

    if ret_data.get('lang_list') != None:
        lang_patch_info_list = ret_data['lang_list']
        for patch_info in lang_patch_info_list:
            if (patch_info['name'].find('_patch_') == -1):
                __PATCH_INFO_DIC[lang_code] = patch_info
            else:
                __PATCH_INFO_DIC[lang_code + '_patch'] = patch_info

# 언어 패치 서버 정보와 checksum 비교
def __check_lang_patch_same(app_ver, target_server_url, zip_path):
    # language code 구분
    lang_code = __REG_LANG.search(zip_path).group("lang")
    
    # getPatchInfo 중복 호출 하지 않도록 캐싱하기 위한 키
    # langcode or langcode_patch
    patch_info_key = None
    if (zip_path.find('_patch') == -1):
        patch_info_key = lang_code
    else:
        patch_info_key = lang_code + '_patch'

    # language patch 정보 획득 - 동일한 패치 생성하지 않도록 하기 위함
    if (__PATCH_INFO_DIC.get(patch_info_key) == None):
        __get_language_patch_info(target_server_url, app_ver, lang_code)

    patch_info = __PATCH_INFO_DIC.get(patch_info_key)
    if patch_info == None:
        return False

    server_checksum = patch_info['md5']
    local_checksum = md5.file2md5(zip_path)

    return server_checksum == local_checksum


# 언어 패치 생성
def make_language_patch(app_ver, target_server_url, curr_dir):
    app_ver_dash = app_ver.replace('.', '_')
    src_dir = os.path.abspath(os.path.join(curr_dir, '../translate'))
    dst_dir = os.path.abspath(os.path.join(curr_dir, f'../../patch/patch_{app_ver_dash}/translate'))
    
    # destination directory 삭제 및 재생성
    if (os.path.isdir(dst_dir) == True):
        shutil.rmtree(dst_dir)
    os.makedirs(dst_dir)

    # change directory
    os.chdir(dst_dir)

    # 파일 목록
    file_list = []
    for (dir_path, dir_names, file_names) in os.walk(src_dir):
        for f in file_names:
            # build 번역 파일은 번역 패치 대상으로 관리하지 않음
            if ((f.startswith('lang_') == True) and (f.endswith('build.lua') == False)):
                file_list.append(f)
        break
    
    # Log
    print(f'lang count : {len(file_list) / 2}')

    # 패치 폴더로 에셋 카피 후 압축
    idx = 1
    zip_path_list = []
    now = datetime.datetime.now().strftime('%y%m%d%H%M%S')
    for translate_file in file_list:
        src = os.path.join(src_dir, translate_file)
        dst = os.path.join(dst_dir, translate_file)
         
        # 에셋 카피(메타 데이터 포함)
        shutil.copy2(src, dst)

        # 압축 - 업로드 파일 관리를 위해 시간 정보를 붙여 파일 이름 변경
        zip_path = translate_file.replace('.lua', f'_{now}.zip')
        zipf = zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED)
        zipf.write(translate_file)
        zipf.close()
        
        # 불필요한 파일 삭제
        os.remove(dst)

        # 서버에 있는 패치 파일과 같다면 삭제
        is_same = __check_lang_patch_same(app_ver, target_server_url, zip_path)

        local_checksum = md5.file2md5(zip_path)
        print(checksum)

        if (is_same):
            os.remove(zip_path)
        else:
            zip_path_list.append(zip_path)
            

        print(f'{idx}. processing {translate_file} / {is_same}', local_checksum)
        idx = idx + 1

    return zip_path_list