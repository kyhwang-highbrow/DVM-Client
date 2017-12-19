@echo off
chcp 65001
set HOD_ROOT=%cd%
::test
::node --max-old-space-size=4096 tools/make_lua.js test_onlyingame 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw
::live
node --max-old-space-size=4096 tools/make_lua.js only_ingame 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw
cd "../translate"
TortoiseProc /command:commit /path:%cd% /closeonend:1