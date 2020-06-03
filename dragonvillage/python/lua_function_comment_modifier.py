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

is_recursive = True # 하위 폴더에 있는 lua까지 확인하려면 True
how_many_files_per_one_commit = 30 # 한 번에 몇 개의 lua 파일을 수정할 것인가
#comment_mismatch = open('comment_mismatch.txt', 'w', encoding='UTF8') # if you want log
path = "D:/dragonvillage/src/frameworks/dragonvillage/src" # path
exclude_path = ['D:/dragonvillage/src/frameworks/dragonvillage/src/perpleLib'] # 이 경로는 제외하고 탐색
how_many_lines = 0 # 몇 줄이 변경되었는가
what_files_changed = [] # 변경된 폴더 목록


folder_stack = [] # get folder lists
def find_folders(path):
    global folder_stack
    folder_paths = []
    file_list = os.listdir(path)
    for elm in file_list:
        if(len(elm.split('.')) == 1):
            folder_paths.append(path + '/' + elm)
    while(len(folder_paths) > 0):
        new_path = folder_paths.pop()
        folder_stack.append(new_path)
        find_folders(new_path)
    return folder_stack
    
    
def find_lua_extention(folder_path):
    result = []
    file_list = os.listdir(folder_path)
    for elm in file_list:
        extention = elm[-4:]
        if(extention == '.lua'):
            result.append(folder_path + '/' + elm)
    return result


def function_comment_verification(src):
    global how_many_lines, what_files_changed
    what_files_changed = list(set(what_files_changed))
    if(len(what_files_changed) >= how_many_files_per_one_commit):
        return '', False
    writer = []
    target_line = -1
    is_changed = False
    
    result_str = ''
    for i in range(5):
        result_str += '------------------------------------------\n'
    result_str += src + '\n'
    
    f = open(src, 'r', encoding='UTF8')
    comment_function_method = ''
    first_comment = False
    second_comment = False
    is_useless = False
    line_index = 0
    #print(src)
    for line in f.readlines():
        writer.append(line)
        line_index += 1
        if(second_comment):
            #verification function
            first_comment = False
            second_comment = False
            # two types of function description
            # 1. function method -> function UI_AdventureSceneNew:init(stage_id) -> 
            # split by ':' init(stage_id) -> 
            # split by '(' -> init
            # 2. function name -> function __G__TRACKBACK__(msg)
            # split by '(' -> function __G__TRACKBACK__
            # split by ' ' -> __G__TRACKBACK__
            function_method = ''
            if(' = function' in line):
                function_method = line.split(' =')[0].split(' ')[-1].split('.')[-1]
            else:
                function_method = line.split(':')[-1].split('(')[0].split(' ')[-1].split('.')[-1]
            if(function_method != comment_function_method):
                if(is_useless):
                    is_useless = False
                    continue
                if ('function' not in line):
                    continue
                result_str += 'line : ' + str(line_index) + '\n'
                result_str += 'function method : ' + function_method + '\n'
                result_str += 'comment_function_method : ' + comment_function_method + '\n'
                result_str += '------------------------------------------\n'.replace('-','+')
                
                writer[target_line-1] = '-- function ' + function_method + '\n'
                how_many_lines += 1
                what_files_changed.append(src.split('src/')[-1])
                is_changed = True
                
        
        if(first_comment):
            if('--' not in line):
                first_comment = False
            if('-- function' in line):
                comment_function_method = line.split(' ')[-1].split('\n')[0]
                target_line = line_index
            if('-- class' in line or '-- table' in line):
                is_useless = True
        
        if('-------------------------------------' in line and len(line)==38):
            if(not first_comment):
                first_comment = True
            else:
                second_comment = True
                
    for i in range(5):
        result_str += '------------------------------------------\n'
    modification_not_required_length = len(src) + len('------------------------------------------\n') * 10 + 1
    if(modification_not_required_length != len(result_str)):
        #print(result_str)
        #comment_mismatch.write(result_str + '\n')
        pass
    
    return writer, is_changed


def start_function_comment_verification(folder_path):
    lua_files = find_lua_extention(folder_path)
    for src in lua_files:
        writer, is_changed = function_comment_verification(src)
        if(is_changed):
            f = open(src, 'w', encoding='UTF8')
            for line in writer:
                f.write(line)
        
        
if __name__ == '__main__':
    folders = find_folders(path)
    folders.append(path)
    for folder_path in folders:
        if(folder_path in exclude_path):
            continue
        start_function_comment_verification(folder_path)
    what_files_changed = list(set(what_files_changed))
    print('modified file list')
    for elm in what_files_changed:
        print(elm)
    print('modified file address : ' + path)
    print('modified file number : ' + str(len(what_files_changed)))
    print('modified line number : ' + str(how_many_lines))
    temp = input('all works done. Press Enter.')