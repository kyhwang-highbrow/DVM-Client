::UTF-8로 실행
chcp 65001

if exist %LUA% (
    cd ../src_tool
    call lua DataTableValidator.lua run
) else (
    ECHO You have to set "LUA" as system environment variable and "PATH"
)

PAUSE