import requests
import json
import sys

payload = {
    "text":"test"
    }

if sys.argv[1] == "extract_translate" :
    payload["text"] = "번역이 추출되었습니다.\nsheet : https://docs.google.com/spreadsheets/d/1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw"
elif sys.argv[1] == "make_lua" :
    payload["text"] = "번역 lua 파일이 커밋되었습니다."

requests.post("https://hooks.slack.com/services/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", data={"payload":json.dumps(payload)} )
