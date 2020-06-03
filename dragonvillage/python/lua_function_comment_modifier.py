#-*- coding:utf-8 -*-
'''
lua의 function comment convention을 지키기 위해 만들어졌다.

------------------------------------------
-- function function_name
------------------------------------------

모든 함수의 주석을 위의 형태로 바꾸어준다.
한 폴더(하위 폴더는 보지 않음)만 바꿀 수도 있고, 하위 폴더를 포함하여 전체 lua 파일을 돌며 바꿀 수도 있다.
how_many_files_per_one_commit 을 통해 한 번에 수정하려는 lua 파일 갯수를 설정할 수 있다.
한 번에 많은 파일을 바꾸려면 how_many_files_per_one_commit = 99999로 설정하면 된다.
'''
import time
import os
from io import open

# 하위 폴더에 있는 lua까지 확인하려면 True
is_recursive = True 

# 한 번에 몇 개의 lua 파일을 수정할 것인가
how_many_files_per_one_commit = 30 

# path
path = "D:/dragonvillage/src/frameworks/dragonvillage/src" 

# 이 경로는 제외하고 탐색
exclude_path = ['D:/dragonvillage/src/frameworks/dragonvillage/src/perpleLib'] 

# 몇 줄이 변경되었는가
how_many_lines = 0 

# 변경된 폴더 목록
what_files_changed = [] 

# get folder lists
folder_stack = [] 


###################################
# def find_folders
# @brief 하위 폴더 경로 탐색
###################################
def find_folders(path):
    global folder_stack
    
    # 최상위 path 내의 폴더 탐색
    folder_paths = []
    file_list = os.listdir(path)
    for elm in file_list:
        if(len(elm.split('.')) == 1):
            folder_paths.append(path + '/' + elm)
    
    # 최상위 폴더 스택(folder_paths)에서 pop을 하며 하위 폴더 탐색
    while(len(folder_paths) > 0):
        new_path = folder_paths.pop()
        folder_stack.append(new_path)
        find_folders(new_path)
        
    return folder_stack
    
    
###################################
# def find_lua_extention
# @brief 폴더 내 루아 확장자를 가진 파일 목록 탐색
###################################
def find_lua_extention(folder_path):
    result = []
    file_list = os.listdir(folder_path)
    
    # .lua를 가진 파일 찾기
    for elm in file_list:
        extention = elm[-4:]
        if(extention == '.lua'):
            result.append(folder_path + '/' + elm)
    
    return result


###################################
# def function_comment_verification
# @brief 파일 내 주석의 일치, 불일치 탐색
###################################
def function_comment_verification(src):
    global how_many_lines, what_files_changed
    
    # how_many_files_per_one_commit 만큼의 파일 수정시 리턴 후 종료
    what_files_changed = list(set(what_files_changed))
    if(len(what_files_changed) >= how_many_files_per_one_commit):
        return '', False
    
    # 파일 한 줄 한 줄을 writer 배열로 저장
    writer = []
    
    # 수정할 함수 주석이 몇 번째 line인지 확인
    target_line = -1
    line_index = 0
    
    # 파일 내 모든 함수의 주석이 올바르다면 False
    is_changed = False
    
    # 파일 열기
    f = open(src, 'r', encoding='UTF8')
    
    # 함수 주석 글자 확인
    comment_function_method = ''
    
    # ------------------------------------- first_comment = True
    # -- function function_name
    # ------------------------------------- second_comment = True
    # 함수명 확인을 위한 함수 주석의 위치를 확인
    first_comment = False
    second_comment = False
    
    # 주석에 함수가 아닌 class 등은 무시함
    is_useless = False
    
    for line in f.readlines():
        writer.append(line)
        line_index += 1
        
        # 주석 맨 마지막줄 이후에는 함수명이 있으므로 함수명 체크 및 기존 주석과 일치하는지 확인
        if(second_comment):
            #verification function
            first_comment = False
            second_comment = False
            
            # three types of function description
            #
            # 1. function UI_AdventureSceneNew:init(stage_id)  
            # split by ':' -> init(stage_id) 
            # split by '(' -> init
            #
            # 2. function __G__TRACKBACK__(msg)
            # split by '(' -> function __G__TRACKBACK__
            # split by ' ' -> __G__TRACKBACK__
            #
            # 3. abc.def = function()
            # split by ' = ' -> abc.def
            # split by '.' -> def
            
            function_method = ''
            if(' = function' in line):
                function_method = line.split(' =')[0].split(' ')[-1].split('.')[-1]
            else:
                function_method = line.split(':')[-1].split('(')[0].split(' ')[-1].split('.')[-1]
            
            # 주석이 함수명 convention을 따르지 않을 때
            if(function_method != comment_function_method):
            
                # 함수가 아닌 경우 무시
                if(is_useless):
                    is_useless = False
                    continue
                
                # 잘못된 위치를 찾은 경우 무시
                if ('function' not in line):
                    continue
                
                # 주석 수정
                writer[target_line - 1] = '-- function ' + function_method + '\n'
                how_many_lines += 1
                what_files_changed.append(src.split('src/')[-1])
                is_changed = True
                
        
        # 첫 번째 주석 발견 후 주석의 function name 찾기
        if(first_comment):
            if('--' not in line):
                first_comment = False
            
            if('-- function' in line):
                comment_function_method = line.split(' ')[-1].split('\n')[0]
                target_line = line_index
            
            if('-- class' in line or '-- table' in line):
                is_useless = True
        
        # 주석 ------------------------------------- 발견
        if('-------------------------------------' in line and len(line)==38):
            if(not first_comment):
                first_comment = True
            else:
                second_comment = True
    
    # 파일 닫기
    f.close()
    
    return writer, is_changed


###################################
# def function_comment_verification
# @brief 주석 verification 시작 함수
###################################
def start_function_comment_verification(folder_path):
    lua_files = find_lua_extention(folder_path)
    
    # 모든 파일에 대해 comment와 function_name 일치 확인
    for src in lua_files:
        writer, is_changed = function_comment_verification(src)
        
        # 파일 내 함수의 주석이 수정되었다면 파일 쓰기
        if(is_changed):
            f = open(src, 'w', encoding='UTF8')
            for line in writer:
                f.write(line)
        
        
# main
if __name__ == '__main__':
    
    # 하위 폴더 탐색
    if(is_recursive):
        
        # 하위 폴더 탐색
        folders = find_folders(path)
        folders.append(path)
        
        for folder_path in folders:
        
            # 제외된 파일 경로 탐색하지 않음
            if(folder_path in exclude_path):
                continue
                
            start_function_comment_verification(folder_path)
    
    # path만 탐색
    else:
        start_function_comment_verification(path)
    
    # 결과 출력
    what_files_changed = list(set(what_files_changed))
    print('modified file list')
    for elm in what_files_changed:
        print(elm)
    print('modified file address : ' + path)
    print('modified file number : ' + str(len(what_files_changed)))
    print('modified line number : ' + str(how_many_lines))
    temp = input('all works done. Press Enter.')