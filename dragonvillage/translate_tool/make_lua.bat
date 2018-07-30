@echo off
chcp 65001
set HOD_ROOT=%cd%
::test
::node --max-old-space-size=4096 tools/make_lua.js test_onlyingame;test_onlyscenario 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw
::live
node --max-old-space-size=4096 tools/make_lua.js only_ingame;only_scenario 1M_in-ZIMHsXvkSu_EBktrtDxBVpKXSbl0l4wpljU1gw en;jp;zhtw;th

::루아 검증
cd "../translate"
call "../../../res/tools/lua/bin/lua.exe" "checkLua.lua" en
call "../../../res/tools/lua/bin/lua.exe" "checkLua.lua" jp
call "../../../res/tools/lua/bin/lua.exe" "checkLua.lua" zhtw
call "../../../res/tools/lua/bin/lua.exe" "checkLua.lua" th

::커밋
TortoiseProc /command:commit /path:%cd% /closeonend:1