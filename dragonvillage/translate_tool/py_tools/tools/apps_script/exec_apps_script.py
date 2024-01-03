import requests

def execute_apps_script(url, function_name):
    # 배포한 웹 앱의 URL    
    # 실행하려는 함수와 관련된 쿼리 매개변수 추가
    params = {'function': function_name}
    # HTTP GET 요청 보내기
    response = requests.get(url, params=params)
    print(response.text)