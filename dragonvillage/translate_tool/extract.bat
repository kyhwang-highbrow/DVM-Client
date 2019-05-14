@echo off
::js 내부에서 HOD_ROOT값으로 경로 사용하는것이있다. HOD_ROOT를 환경변수에 저장해서 사용할 수도 있지만 pc마다 다르므로 여기서 세팅
set HOD_ROOT=%cd%

::note --"메모리사용제한" "실행항js파일" "추출결과를 넣을 시트이름" "시트ID" "번역필요한 언어들"

::test
::node --max-old-space-size=4096 tools/extract.js test_onlyingame 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw
::node --max-old-space-size=4096 tools/extract_scenario.js test_onlyscenario 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw

::live
node --max-old-space-size=4096 tools/extract.js only_ingame 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw;th;es;fa
node --max-old-space-size=4096 tools/extract_scenario.js only_scenario 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw;th;es;fa

python slack.py extract_translate