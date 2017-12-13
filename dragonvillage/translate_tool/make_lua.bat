@echo off
chcp 65001
set HOD_ROOT=%cd%
node --max-old-space-size=4096 tools/make_lua.js
cd "../translate"
TortoiseProc /command:commit /path:%cd% /closeonend:1