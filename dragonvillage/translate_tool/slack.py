import requests
import json

payload = {
    "text": "번역이 추출되었습니다.\nen : https://docs.google.com/spreadsheets/d/1TzxlNwZHMZxG4W0LsPokaQfnCsCoCM3qvozAt7tvICg\njp : https://docs.google.com/spreadsheets/d/1hYRS7hE6OTRNQ-2RJL14O0VmxXxbYoT0wtQ7-rFnAi4\nzhtw : https://docs.google.com/spreadsheets/d/1Cv2vBmWpnVwK74KN6SnL0QKdTpMoAx8VPYDzOi9yks0"
    }

requests.post("https://hooks.slack.com/services/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", data={"payload":json.dumps(payload)} )
