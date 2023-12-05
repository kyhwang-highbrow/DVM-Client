@echo off
::test
::node --max-old-space-size=4096 tools/make_total.js test_onlyingame 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw 0
::node --max-old-space-size=4096 tools/make_total.js test_onlyscenario 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw 1
::live
node --max-old-space-size=4096 tools/make_total.js only_ingame 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw;th;es;fa 0
node --max-old-space-size=4096 tools/make_total.js only_scenario 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw;th;es;fa 1
@pause