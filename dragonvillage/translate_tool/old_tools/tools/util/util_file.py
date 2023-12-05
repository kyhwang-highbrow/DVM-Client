#############################################################################
## 파일과 관련된 유틸을 담은 코드입니다.
#############################################################################


import os


def get_file(file_list, path, option):
    for file in os.listdir(path):
        file_path = os.path.join(path, file) # 파일 절대 경로를 얻습니다.
        ignore_this = False # 이 파일을 무시할 것인지 판단하는 BOOL 변수
        
        if os.path.isdir(file_path): # 현재 파일이 폴더인 경우
            for ignoreFolder in option['ignoreFolders']: # 탐색 옵션의 ignoreFolders와 비교합니다.
                if file_path.find(ignoreFolder) != -1:
                    ignore_this = True
                    break
            
            if ignore_this: # 만약 무시해야 된다면 넘어갑니다.
                continue        
            
            get_file(file_list, file_path, option)
        else:
            for ignore_file in option['ignoreFiles']: # 탐색 옵션의 ignoreFiles와 비교
                if file == ignore_file: # 파일명 직접 비교합니다.
                    ignore_this = True
                    break

            if ignore_this: # 만약 무시해야 된다면 넘어갑니다.
                continue
            
            _, file_extension = os.path.splitext(file_path)
            for search_ext in option['searchExtensions']:  # 탐색 옵션의 searchExtensions와 비교
                if file_extension == search_ext:  # 확장자명 직접 비교합니다.  
                    file_list.append(file_path)  # 찾아야 되는 확장자라면 리스트에 삽입합니다.
                    break
        

# path 매개변수로 들어온 경로 하위의 파일들을 전부 찾습니다.
def get_all_files(path, option):
    file_list = []
    get_file(file_list, path, option)

    return file_list


def make_dir(path):
    if not os.path.exists(path):
        os.mkdir(path)


def remove_dir(path):
    os.remove(path)


def write_file(path, data):
    with open(path, 'w', encoding='utf-8', newline='\n') as f: # crlf가 아닌 lf로 파일을 작성하기 위해서
        f.write(data)
