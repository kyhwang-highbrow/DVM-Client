# 개요
프로젝트 내에서 사용되는 각종 변수 값을 추출하고 사용 횟수를 합산하는 툴입니다.
좀 더 자세한 내용은 아래 컨플루언스에서 확인하실 수 있습니다.
https://highbrow.atlassian.net/wiki/spaces/dvm/pages/734167158


# 실행을 위해 필요한 것
코드는 파이썬 버전 3.8.5를 기준으로 작성했습니다.  
파이썬이 아직 설치되어있지 않다면 res/emulator/translate_tool/py_tools/python-3.8.5.exe 파일로 설치하셔도 됩니다.


# 사용 방법
1. config.json 파일을 알맞게 수정합니다. 모든 기능은 config.json 파일로부터 읽은 설정 값을 기반으로 동작합니다.
2. extract_name.bat 실행하고, result 폴더에 결과물을 확인합니다.
   

# config.json 구성요소
1. name - 해당 설정 값의 이름입니다. 콘솔 창에 로그를 띄울 때 사용되는 값입니다.

2. path_list - 탐색을 실시할 폴더들의 상대 경로입니다.

3. except_path_list - 탐색을 실시할 때 제외할 폴더들의 상대경로입니다.

4. extract_func - 해당 값에 따라 탐색할 파일의 확장자명과 추출 로직이 달라집니다. 다음과 같은 값이 들어갈 수 있습니다.
    1) extract_ui_lua_name : UI 파일에서 lua_name 에 사용된 값들을 추출합니다. 확장자는 ui, UI 파일을 찾습니다.
    2) extract_csv_column : CSV 파일에서 칼럼에 사용된 값들을 추출합니다. 확장자는 csv, CSV 파일을 찾습니다.
    3) extract_lua_variable : LUA 파일에서 변수명으로 사용된 값들을 추출합니다. 확장자는 lua, LUA 파일을 찾습니다.

5. sort_key - 해당 값에 따라 csv 파일을 생성할 때 정렬하는 방식이 달라집니다. 다음과 같은 값이 들어갈 수 있습니다.
    1) variable_name : 추출한 값을 기준으로 오름차순으로 정렬합니다.
    2) count_desc : 사용 횟수를 기준으로 내림차순으로 정렬합니다.
    3) count_asc : 사용 횟수를 기준으로 오름차순으로 정렬합니다.

6. file_name - 결과로 생성될 csv 파일의 이름입니다.
