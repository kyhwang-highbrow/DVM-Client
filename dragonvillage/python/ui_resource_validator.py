# UI 파일들을 돌면서 해당 UI에 연결된 리소스가 경로에 존재하는지, 파일 이름 대소문자 맞는지 판단

import os
import re

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'res')
IS_WRONG_RESOURCE = False

def validate_ui_resource(file_path):
    global IS_WRONG_RESOURCE
    # 정규식으로 resource 경로들을 찾음
    with open(file_path, 'r', encoding='utf-8') as f:
        all_data = f.read()
        reg_find_case = re.compile(r"file_name = '(.+?)'")
        find_datas = reg_find_case.findall(all_data)

        for find_data in find_datas:
            # 경로에 파일이 존재하는지 체크
            full_file_name = os.path.join(ROOT, find_data)
            is_exist = False

            if os.path.isfile(full_file_name):
                directory, _ = os.path.split(full_file_name)
                file_name = os.path.basename(find_data)
                if (file_name in os.listdir(directory)):
                    is_exist = True

            if not is_exist:
                IS_WRONG_RESOURCE = True
                print('# Resource no exist :', find_data, '-', os.path.basename(file_path))


def search_ui_file(root):
    file_name_list = os.listdir(root)

    for file_name in file_name_list:
        full_file_name = os.path.join(root, file_name)

        if os.path.isdir(full_file_name):
            search_ui_file(full_file_name)
        else:
            ext = os.path.splitext(full_file_name)[-1]
            if ext == '.ui':
                validate_ui_resource(full_file_name)


def check_ui_resource_validate():
    print("# Validate UI resources path")

    search_ui_file(ROOT)

    if IS_WRONG_RESOURCE == True:
        print('# Check above resources')
        os.system('pause')


if __name__ == '__main__':
    check_ui_resource_validate()
         
