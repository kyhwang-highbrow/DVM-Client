#############################################################################
## 각종 추출 함수와 func 비교후 매핑해주는 코드입니다.
#############################################################################


from tools.extract.extract_from_cpp import extract_from_cpp
from tools.extract.extract_from_lua import extract_from_lua
from tools.extract.extract_from_ui import extract_from_ui
from tools.extract.extract_from_csv import extract_from_csv
from tools.extract.extract_from_scenario import extract_from_scenario


def extract(src, func_name, ignore_files, ignore_folders):
    if func_name == 'extract_cpp':
        return extract_from_cpp(src, ignore_files, ignore_folders)
    elif func_name == 'extract_lua':
        return extract_from_lua(src, ignore_files, ignore_folders)
    elif func_name == 'extract_ui':
        return extract_from_ui(src, ignore_files, ignore_folders)
    elif func_name == 'extract_csv':
        return extract_from_csv(src, ignore_files, ignore_folders)
    elif func_name == 'extract_scenario':
        return extract_from_scenario(src, ignore_files, ignore_folders)
