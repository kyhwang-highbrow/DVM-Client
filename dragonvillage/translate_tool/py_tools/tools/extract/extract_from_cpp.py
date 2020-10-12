#############################################################################
## 나중에 cpp 파일로부터 텍스트를 추출할 수 있도록 만든 예시 코드입니다.
#############################################################################


import os
import tools.util.util_file as util_file
import re


# TODO : CPP 상황에 맞게 구현 필요
def get_str(result_data, file_path, ignore_krs): # 사용된 한글, 힌트 파일 등 상세하게 뽑아내는 함수
    pass


def extract_from_cpp(path, ignoreFiles, ignoreFolders, ignore_krs):
    result_data = {}

    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.cpp', '.CPP', '.h', '.H']

    files = util_file.get_all_files(path, option)

    for file in files:
        get_str(result_data, file, ignore_krs)

    # print(result_data)

    return result_data
