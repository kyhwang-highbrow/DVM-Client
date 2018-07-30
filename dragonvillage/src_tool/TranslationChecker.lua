require 'LuaStandAlone'

-------------------------------------
-- class TranslationChecker
-------------------------------------
TranslationChecker = class({   
    })

-------------------------------------
-- function init
-------------------------------------
function TranslationChecker:init()
end

-------------------------------------
-- function run
-------------------------------------
function TranslationChecker:run(target_path)
    print ('## try to load japanese lua ...')
    require '../translate/lang_jp'

    print ('## try to load english lua ...')
    require '../translate/lang_en'

    print ('## try to load chinese(taiwan) lua ...')
    require '../translate/lang_zhtw'

    print ('## try to load thai lua ...')
    require '../translate/lang_th'

    print ('## perfect !')
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    TranslationChecker():run()
end