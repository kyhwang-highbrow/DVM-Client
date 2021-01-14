#-*- coding:utf-8 -*-

import os
import sys
import shutil
import zipfile
import module.md5_log_maker as md5
import module.utility as utils
from ui_resource_validator import check_ui_resource_validate

# 전역변수
tar_server = ''
source_path = ''
patch_work_path = ''
dest_path = ''
app_ver = ''
latest_patch_ver = ''
is_force_patch = 1
TARGET_SERVER = ''
LOCAL_MACHINE_ID = ''
LOCAL_MACHINE_PASSWD = ''
LOCAL_MACHINE_DOMAIN = ''

# 게임 서버
SERVER_PATH = ''
# 운영툴 서버
TOOL_SERVER_PATH = ''
# 플랫폼 서버
PLATFORM_SERVER_PATH = ''

#마지막 폴더명만 얻어오는 함수
def getDirName(path):
    # file의 경우 dirname을 먼저 얻어옴
    if os.path.isdir(path) == False:
        path = os.path.dirname(path)    

    normpath = os.path.normpath(path)
    basename = os.path.basename(normpath)
    return basename

# 압축
def zipdirectory(path):
    os.chdir(path)
    
    dirname = getDirName(path)
    
    zipname = os.path.join(path, '..', dirname + '.zip')
    dst_zipname = os.path.join(path, dirname + '.zip')
    
    zipf = zipfile.ZipFile(zipname, 'w', zipfile.ZIP_DEFLATED)
    walk = os.walk('./')
    for root, dirs, files in walk:
        for file in files:
            zipf.write(os.path.join(root, file))
    zipf.close()
    
    shutil.move(zipname, dst_zipname)
    return dst_zipname
    
# 전역변수 초기화
def init_global_var():
    print('# init_global_var ...')
    global TARGET_SERVER
    global source_path
    global patch_work_path
    global dest_path
    global app_ver
    global is_force_patch
    global SERVER_PATH
    global TOOL_SERVER_PATH
    global PLATFORM_SERVER_PATH

    global LOCAL_MACHINE_PASSWD
    global LOCAL_MACHINE_ID
    global LOCAL_MACHINE_DOMAIN

    # TODO 경로들은 추후에 파라미터로 받을 것!
    # 소스 경로 (개발 폴더 혹은 에뮬레이터 경로)
    source_path = os.path.dirname(os.path.realpath(__file__))
    source_path = os.path.join(source_path, '..')
    
    # 패치 작업 경로 (패치 로그파일, .zip파일이 저장되는 경로)
    patch_work_path = os.path.join(source_path, '..', 'patch')
    patch_work_path = os.path.abspath(patch_work_path)
    
    # 패치 .zip파일을 생성하여 카피하는 경로
    dest_path = os.path.join(r'\\', '192.168.0.219', 'dvm', 'patch', 'dv_test')
    
    # 패치 타겟 서버
    TARGET_SERVER = sys.argv[1]
    if TARGET_SERVER == 'DEV':
        SERVER_PATH = 'http://dv-test.perplelab.com:9003'
        PLATFORM_SERVER_PATH = 'http://dev.platform.perplelab.com/1003'    

    elif TARGET_SERVER == 'QA':
        SERVER_PATH = 'http://dv-qa.perplelab.com:9003'
        PLATFORM_SERVER_PATH = 'http://dev.platform.perplelab.com/1003'

    elif TARGET_SERVER == 'LIVE':
        SERVER_PATH = 'http://dvm-api.perplelab.com'
        PLATFORM_SERVER_PATH = 'http://dn3bwi5jsw20r.cloudfront.net/1003'
        
    TOOL_SERVER_PATH = 'http://192.168.0.211:7777/maintenance'

    LOCAL_MACHINE_DOMAIN = 'dragonvillagem'
    LOCAL_MACHINE_ID = 'dvm'
    LOCAL_MACHINE_PASSWD = 'perple!1'

    # 패치를 진행할 앱 버전
    app_ver = sys.argv[2]
    # 유저 강제 재접속 여부 결정, 1이면 강제 재접속시킴
    is_force_patch = 0 if ((len(sys.argv) >= 4) and (sys.argv[3] == '0')) else 1
    print('\t' + 'is_force_patch : ' + str(is_force_patch))

    print('\t' + source_path)
    print('\t' + patch_work_path)
    print('\t' + dest_path)
    print('\t' + TARGET_SERVER + ' - ' + SERVER_PATH)
    print('\t' + app_ver)
    
# 서버로부터 패치 정보 얻어옴
def get_patch_info(app_ver):
    print('# get_patch_info ...')
    # import requests
    utils.install_and_import('requests', globals())
    
    params = {'app_ver': app_ver}
    r = requests.get(SERVER_PATH + '/get_patch_info', params=params)
    ret_data = r.json()

    # 현재 패치 ver를 리턴
    cur_patch_ver = max([0, ret_data['cur_patch_ver']])
    return cur_patch_ver

# 서버로부터 패치 정보 얻어옴
def find_patch_log(patch_work_path, app_ver, latest_patch_ver):
    ver_path = 'patch_' + app_ver.replace('.', '_')
    log_path = os.path.join(patch_work_path, ver_path, 'log')

    next_plg_path = os.path.join(log_path, 'patch_' + str(latest_patch_ver + 1) + '.plg')
    
    idx = max([latest_patch_ver, 0])
    
    for i in range(idx, -1, -1):
        plg_name = 'patch_' + str(i) + '.plg'
        latest_plg_path = os.path.join(log_path, plg_name)
        
        exist = os.path.exists(latest_plg_path)
        print('\t' + latest_plg_path + ' ' + str(exist))
        if exist == True :
            return True, latest_plg_path, next_plg_path
    
    return False, os.path.join(log_path, 'patch_0.plg'), next_plg_path
    
# 다음 버전의 plg 파일 생성
def make_next_plg(source_path, plg_path):
    print('# make_next_plg ...')
    return md5.makePatchLog(source_path, plg_path)
    
# 패치파일 리스트 추출
def get_patch_list(latest_plg_hash, next_plg_hash):
    print('# get_patch_list ...')
    new_plg_hash = {}    
    
    count = 0
    
    # 이전 데이터가 없거나 파일이 변경되었을 경우만 추가
    for key in sorted(next_plg_hash):
        if (key in latest_plg_hash) and (latest_plg_hash[key] == next_plg_hash[key]):
            continue
        else:
            new_plg_hash[key] = next_plg_hash[key]
            count = count + 1
            
    print('\t count : ' + str(count))
    return new_plg_hash
    
# 패치파일 카피
def patch_files_copy_and_zip(source_path, patch_work_path, app_ver, latest_patch_ver, new_plg_hash):
    print('# patch_files_copy_and_zip ...')
    
    dst_base_dir = os.path.join(patch_work_path, 'patch_' + app_ver.replace('.', '_'), 'patch_' + str(latest_patch_ver))
    
    if (os.path.isdir(dst_base_dir) == True):
        shutil.rmtree(dst_base_dir)
    
    print('\t copy plg ...')
    for key in sorted(new_plg_hash):
        src = os.path.join(source_path, key)
        dst = os.path.join(dst_base_dir, key)
        
        dst_dir = os.path.dirname(dst)
        if (not os.path.exists(dst_dir)):
            os.makedirs(dst_dir)
        shutil.copy(src, dst)
    
    print('\t zip ...')    
    return zipdirectory(dst_base_dir)

def copy(src_file, dst_dir):
    file_name = os.path.basename(src_file)
    dst_file = os.path.join(dst_dir, file_name)
    print('# copy patch zip ...')
    os.system(r"NET USE P: %s %s /USER:%s\%s" % (dst_dir, LOCAL_MACHINE_PASSWD, LOCAL_MACHINE_DOMAIN, LOCAL_MACHINE_ID))
    print(os.path.isdir(dst_dir))
    shutil.copy(src_file, dst_file)
    os.system(r"NET USE P: /DELETE")
    
# 메인 함수
def main():
    global latest_patch_ver
    
    # 전역변수 초기화
    init_global_var()

    # UI Resource 체크
    check_ui_resource_validate()
    
    # 1. 패치정보 받아오기
    latest_patch_ver = get_patch_info(app_ver)
    
    # 2. 패치 로그 파일 찾기
    exist_plg_file, latest_plg_path, next_plg_path = find_patch_log(patch_work_path, app_ver, latest_patch_ver)
    
    # 2-1. 기본 패치파일 생성
    latest_plg_hash = {}
    next_plg_hash = {}
    if exist_plg_file == False:
        md5.makePatchLog(source_path, latest_plg_path)
        print('ERROR: The latest "plg file" does not exist. : ' + latest_plg_path)
        exit(-1)
    else:
        latest_plg_hash = md5.loadPatchLog(latest_plg_path)
        next_plg_hash = make_next_plg(source_path, next_plg_path)

    # 3. 패치파일 리스트 추출(변경된 파일만 추출)
    new_plg_hash = get_patch_list(latest_plg_hash, next_plg_hash)
    
    if len(new_plg_hash) == 0:
        os.remove(next_plg_path)
        print('# No changes file!! (patch_idx ' + str(latest_patch_ver) + ')')
        exit(0)
    
    # 4. 패치파일 복사, 압축
    new_patch_ver = latest_patch_ver + 1
    zip_file = patch_files_copy_and_zip(source_path, patch_work_path, app_ver, new_patch_ver, new_plg_hash)
    
    # 5. NAS에 복사
    dst_forder = 'patch_' + app_ver.replace('.', '_')
    dst_dir = os.path.join(dest_path, dst_forder)
    copy(zip_file, dst_dir)
    
    # 운영툴 패치 정보 업데이트
    print('# [tool] update_patch_dv')
    data = {
        'is_force_patch' : is_force_patch
    }
    r = requests.post(TOOL_SERVER_PATH + '/update_patch_dv', data = data)

    print('# [tool] upload_patch_dv')
    r = requests.get(TOOL_SERVER_PATH + '/upload_patch_dv')
    
    # 플랫폼 서버에 패치 정보 전달
    print('# [platform] add patch info')
    zip_path = '%s/patch_%d.zip' % (dst_forder, new_patch_ver)
    zip_md5 = md5.file2md5(zip_file)
    zip_size = os.path.getsize(zip_file)
    data = {
        'app_ver': app_ver,
        'version' : new_patch_ver,
        'name' : zip_path,
        'md5' : zip_md5,
        'size' : zip_size
    }
    print(data)
    r = requests.post(PLATFORM_SERVER_PATH + '/versions/addPatchInfo', data = data)
    print(r.text)

    print('----------------------------------------')
    print('DONE')
    print('----------------------------------------')

if __name__ == '__main__':
    print('----------------------------------------')
    main()
    print('----------------------------------------')