::UTF-8로 실행
chcp 65001

if exist %LUA% (
    cd ../src_tool
    call lua AssetMaker.lua run full
) else (
    ECHO You have to set "LUA" as system environment variable and "PATH"
)

PAUSE