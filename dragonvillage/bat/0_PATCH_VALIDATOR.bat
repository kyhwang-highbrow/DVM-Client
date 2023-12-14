cd ../bat
call Validate_Data_Table.bat

echo %ERRORLEVEL%
IF NOT %ERRORLEVEL% == 0 EXIT

cd ../bat
call TranslationChecker.bat

echo %ERRORLEVEL%
IF NOT %ERRORLEVEL% == 0 EXIT

cd ../bat
call CsvToLuaTableStr.bat

echo %ERRORLEVEL%
IF NOT %ERRORLEVEL% == 0 EXIT

cd ../bat
call MakePreloadTable.bat

echo %ERRORLEVEL%
IF NOT %ERRORLEVEL% == 0 EXIT

cd ../bat
call RemoveUnreleaseRes.bat

echo %ERRORLEVEL%
IF NOT %ERRORLEVEL% == 0 EXIT

PAUSE