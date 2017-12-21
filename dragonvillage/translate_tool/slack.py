import requests
import json

payload = {
    "text": "번역이 추출되었습니다.\nsheet : https://docs.google.com/spreadsheets/d/1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw"
    }

requests.post("https://hooks.slack.com/services/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", data={"payload":json.dumps(payload)} )
