@echo off
set HOD_ROOT=%cd%
::test
::node --max-old-space-size=4096 tools/extract.js test_onlyingame 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw
::node --max-old-space-size=4096 tools/extract_scenario.js test_onlyscenario 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw

::live
node --max-old-space-size=4096 tools/extract.js only_ingame 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw
node --max-old-space-size=4096 tools/extract_scenario.js only_scenario 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw

::python slack.py