#############################################################################
## 각종 추출 함수와 func 비교후 매핑해주는 코드입니다.
#############################################################################


from tools.extract.extract_from_cpp import extract_from_cpp
from tools.extract.extract_from_DVM_lua import extract_from_DVM_lua
from tools.extract.extract_from_DVM_ui import extract_from_DVM_ui
from tools.extract.extract_from_DVM_csv import extract_from_DVM_csv
from tools.extract.extract_from_DVM_scenario_csv import extract_from_DVM_scenario_csv

extract_func = {}
extract_func['extract_DVM_lua'] = extract_from_DVM_lua
extract_func['extract_DVM_ui'] = extract_from_DVM_ui
extract_func['extract_DVM_csv'] = extract_from_DVM_csv
extract_func['extract_DVM_scenario_csv'] = extract_from_DVM_scenario_csv


def extract(func_name, src, ignore_files, ignore_folders, ignore_krs, only_include_files = None):
    try:
        result = extract_func[func_name](src, ignore_files, ignore_folders, ignore_krs, only_include_files)
    except FileNotFoundError:
        import os
        print('EXTRACT PATH NOT FOUND :', src)
        os.system('pause')
    return result
