::UTF-8로 실행
chcp 65001

cd "../src_tool"
call "../tools/lua/bin/lua.exe" "AssetMaker.lua" run
call "../tools/lua/bin/lua.exe" "AssetMaker_ApkExpansion.lua" run
PAUSE