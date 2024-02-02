import os
import re
import json
import csv

# path 경로가 주어질 때 하위 파일까지 전부 찾아서 cb 함수를 실행시키는 함수
def find_file(path, except_path_abs_list, data_dic, dup_list, extension_list, cb=None):
    if except_path_abs_list.count(path) > 0: # 제외 경로 제외하기
        return

    if os.path.isdir(path): # 폴더인 경우
        for file in os.listdir(path): # 하위 폴더 및 파일에 재귀로 돌리기
            sub_path = os.path.join(path, file) # 하위 폴더 및 파일 절대 경로 
            find_file(sub_path, except_path_abs_list, data_dic, dup_list, extension_list, cb)
    else:                   # 파일인 경우
        _, file_extension = os.path.splitext(path) # 확장자 추출
        if extension_list.count(file_extension) == 0: # 확장자가 찾던 게 아닌 경우
            return
        
        file_name = os.path.basename(path) 
        if dup_list.count(file_name) > 0: # 중복 파일의 경우 제외(다른 경로에 같은 파일이 존재하는 경우)
            return

        dup_list.append(file_name)
        if cb is not None: # 콜백 함수 존재하면 콜백함수 실행
            cb(path, data_dic)


# ui 파일에서 lua_name 추출하는 함수
def find_ui_cb(path, data_dic):
    with open(path, 'r', encoding='utf-8') as f:
        file_name = os.path.basename(path)
        text = f.read()
        reg_find_lua_name = re.compile(r"lua_name = '(.+?)'") # |lua_name = 'XXX'| 꼴의 패턴에서 XXX를 찾아줌
        find_lua_names = reg_find_lua_name.findall(text) # 파일 내 텍스트에서 해당하는 정규식 패턴 전부 찾아서 리스트로 반환
        for lua_name in find_lua_names:
            if lua_name not in data_dic: # 만약 처음 찾은 lua_name이라면 딕셔너리에 추가
                data_dic[lua_name] = [0, []] # [count, file_list]
            data_dic[lua_name][0] += 1 # count 증가
            if data_dic[lua_name][1].count(file_name) == 0: # 힌트 파일에 추가
                data_dic[lua_name][1].append(file_name)


# csv 파일에서 칼럼명 추출하는 함수
def find_csv_cb(path, data_dic):
    with open(path, 'r', encoding='utf-8') as f:
        file_name = os.path.basename(path)
        rdr = csv.reader(f)
        column_name_list = rdr.__next__() # 첫 줄 읽기(헤더)
        
        for column_name in column_name_list:
            if len(column_name) == 0:
                continue
            if column_name not in data_dic: # 만약 처음 찾은 칼럼 이름이라면 딕셔너리에 추가
                data_dic[column_name] = [0, []] # [count, file_list]
            data_dic[column_name][0] += 1 # count 증가
            if data_dic[column_name][1].count(file_name) == 0: # 힌트 파일에 추가
                data_dic[column_name][1].append(file_name)


# lua 파일에서 변수명 추출하는 함수
def find_lua_cb(path, data_dic):
    with open(path, 'r', encoding='utf-8') as f:
        file_name = os.path.basename(path)
        text = f.read()
        # global 변수의 경우 초기화를 함께 진행함 
        # local 변수의 경우 그냥 선언만 할 수도 있고, 초기화를 함께 진행할 수도 있음, 하지만 선언부에 local을 붙임
        reg_find_global_variable = re.compile(r"([a-zA-Z0-9_]+) ?= ?[a-zA-Z0-9_]+") # |XXX = YYY| 꼴에서 문자+숫자+언더바로 이루어진 XXX를 찾아줌.
        reg_find_local_variable = re.compile(r"local ([a-zA-Z0-9_]+)") # |local XXX| 꼴에서 문자+숫자+언더바로 이루어진 XXX를 찾아줌.

        find_variable_names = reg_find_global_variable.findall(text) # 파일 내 텍스트에서 해당하는 정규식 패턴 전부 찾아서 리스트로 반환
        find_variable_names.extend(reg_find_local_variable.findall(text))
        
        reserve_list = ['and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'goto', 'if',
                        'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while'] #예약어 리스트
        variable_list = [] # 변수가 코드 내에서 여러 번 쓰였어도 하나의 파일 당 한번만 카운트를 할 것
        for variable_name in find_variable_names: 
            # 찾은 변수 검증 및 중복 제거
            if reserve_list.count(variable_name) > 0:
                continue
            elif variable_list.count(variable_name) > 0:
                continue
            else:
                variable_list.append(variable_name)

        for variable_name in variable_list:
            if variable_name not in data_dic: # 만약 처음 찾은 변수 이름이라면 딕셔너리에 추가
                data_dic[variable_name] = [0, []] # [count, file_list]
            data_dic[variable_name][0] += 1 # count 증가
            if data_dic[variable_name][1].count(file_name) == 0: # 힌트 파일에 추가
                data_dic[variable_name][1].append(file_name)


# 정렬 기준에 맞춰 csv 파일을 생성해주는 함수
def make_csv_file(data_dic, sort_key, file_name):
    result_data = []
    for key_name in data_dic: # 딕셔너리를 정렬 및 csv에 입력하기 편하게 하기 위해 리스트로 바꿈
        # 리스트에 들어가는 데이터의 모양 [lua_name, count, file_list]
        result_data.append( [ key_name, str(data_dic[key_name][0]), ', '.join(data_dic[key_name][1]) ] )
            
    if sort_key == 'variable_name': # 추출값 기준으로 오름차순
        result_data.sort(key=lambda data: data[0])
    elif sort_key == 'count_desc': # 횟수 기준으로 내림차순
        result_data.sort(reverse=True, key=lambda data: int(data[1]))
    elif sort_key == 'count_asc': # 횟수 기준으로 오름차순
        result_data.sort(key=lambda data: int(data[1]))
    else: # 올바르지 않은 정렬 방식의 경우
        print('SORT_KEY ERROR :', sort_key)
        return

    if not os.path.exists('result'): # 만약 result 폴더가 없다면 생성
        os.mkdir('result')
    with open('result/' + file_name, 'w', encoding='utf-8', newline='') as f:
        wr = csv.writer(f)
        wr.writerow(['variable_name', 'count', 'hint_file']) # csv 헤더 먼저 입력 
        wr.writerows(result_data) # 데이터 입력
    

def main():
    extract_cb_dic = {} # 키 값에 따른 콜백 함수 저장
    extract_cb_dic['extract_ui_lua_name'] = find_ui_cb
    extract_cb_dic['extract_csv_column'] = find_csv_cb
    extract_cb_dic['extract_lua_variable'] = find_lua_cb

    extension_list_dic = {} # 키 값에 따른 확장자 저장
    extension_list_dic['extract_ui_lua_name'] = ['.ui', '.UI']
    extension_list_dic['extract_csv_column'] = ['.csv', '.CSV']
    extension_list_dic['extract_lua_variable'] = ['.lua', '.LUA']

    print('## LOAD CONFIG...')
    with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기 
        config_json = json.load(f)
        extract_variable_list = config_json['extract_variable_list']

    print('## START...')
    
    for extract_variable_config in extract_variable_list: # 각 파일 종류마다 알맞게 추출하기
        name = extract_variable_config['name'] # 로그를 띄울 때 이름
        rel_path_list = extract_variable_config['path_list'] # 파일을 찾을 최상위 경로들에 대한 리스트
        except_path_rel_list = extract_variable_config['except_path_list'] # 파일을 찾을 때 제외할 경로들 
        extract_func = extract_variable_config['extract_func'] # 파일을 찾을 방법 키값 (ex: extract_ui, ...)
        sort_key = extract_variable_config['sort_key'] # csv 파일을 생성할 때 정렬할 기준 (ex: count_desc, count_asc, ...)
        file_name = extract_variable_config['file_name'] # 생성할 csv 파일의 이름

        print('##', name, 'START')

        except_path_abs_list = [] # 제외 폴더 경로들을 상대 경로에서 절대 경로로 바꾸기
        for except_rel_path in except_path_rel_list:
            except_abs_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), except_rel_path)
            except_path_abs_list.append(except_abs_path)

        data_dic = {} # 추출한 데이터를 저장할 딕셔너리
        dup_list = [] # 중복 파일 방지용 리스트
        for rel_path in rel_path_list: # 다중 경로에서 추출 가능하도록 
            abs_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), rel_path)
            find_file(abs_path, except_path_abs_list, data_dic, dup_list, extension_list_dic[extract_func], extract_cb_dic[extract_func])
        
        make_csv_file(data_dic, sort_key, file_name) # 추출된 데이터를 저장한 딕셔너리를 이용하여 csv 파일 생성

        print('##', name, 'FINISH')

    
    print('## ALL JOB FINISH...')


if __name__ == "__main__":
    main()
    os.system('pause')
