#############################################################################
## 시나리오 csv를 제외한 일반 csv 파일로부터 텍스트를 추출하는 코드입니다.
#############################################################################


import os
import tools.util.util_file as util_file
import re
import csv
import copy


def parse(result_data, file_path, header_datas, body_datas, ignore_krs):
    reg_check = re.compile(r'[가-힣]+')
    
    for i, header in enumerate(header_datas):
        if header.find('t_') == 0: # 번역해야 되는 칼럼 판단합니다.
            
            for body in body_datas:
                find_data = body[i]
                
                if ignore_krs.count(find_data) > 0:
                    continue

                if reg_check.search(find_data): # 한글이 포함되어 있는 데이터라면
                    reform_data = find_data.replace('\r\n', r'\n') # csv 파일 내에서 개행문자로 저장되어 있었다면 \n으로 변경
                    reform_data = reform_data.replace('\n', r'\n') 
                    
                    # 지금까지 모은 data 딕셔너리에 현재 찾은 텍스트 키값이 존재하는지 검사하고 없다면 추가
                    if reform_data not in result_data.keys():
                        result_data[reform_data] = {'hints' : []}

                    # 힌트에 현재 파일 이름이 존재하는지 검사하고 추가
                    hint_exist = False
                    file_name = os.path.basename(file_path)
                    for hints in result_data[reform_data]['hints']:
                        if file_name in hints:
                            hint_exist = True
                            break
                    if not hint_exist:
                        result_data[reform_data]['hints'].append(file_name)
            

def get_str(result_data, file_path, ignore_krs):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            csv_file = csv.reader(f)
            csv_data = []
            for line in csv_file:
                csv_data.append(line)
            header_data, body_data = csv_data[0], csv_data[1:]
            parse(result_data, file_path, header_data, body_data, ignore_krs)
    except:
        print('해당 파일을 읽는 도중 문제가 발생했습니다. :', file_path)
        os.system('pause')


def extract_from_DVM_csv(path, ignoreFiles, ignoreFolders, ignore_krs): # 딕셔너리 반환
    result_data = {}
    
    option = {}
    option['ignoreFiles'] = ignoreFiles
    option['ignoreFolders'] = ignoreFolders
    option['searchExtensions'] = ['.csv', '.CSV']

    files = util_file.get_all_files(path, option)

    for file in files:
        get_str(result_data, file, ignore_krs)

    # print(result_data)

    return result_data
