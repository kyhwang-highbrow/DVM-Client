import requests
import json
import module.utility as utils

# 메인 함수
def send_slack_message(msg, color):    
        # import requests
    utils.install_and_import('requests', globals())
    # print('테스트 슬랙 메시지 전송')

    try:
        url = "https://hooks.slack.com/services/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"
        header = {'Content-type': 'application/json'}
        icon_emoji = ":slack:"
        username = "DVM-client"
        attachments = [{
            "color": color,
            "text": msg
        }]

        params = {
            #"uid" : "MFqooDQK9maoJkK3UzMKQ5zFhLB2",
            #"timestamp" : "0",
            "username": username,            
            "attachments": attachments,
            "icon_emoji": icon_emoji
        }
        #print(data)
        # 메세지 전송
        r = requests.post(url, headers=header, json=params)
        print(r.text)
        return r

        
    except Exception as e:
        print("Slack Message 전송에 실패했습니다.")
        print("에러 내용 : " + e)
        exit(0)
