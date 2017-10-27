require 'LuaStandAlone'

-------------------------------------
-- class Development
-------------------------------------
Development = class({   
    })

-------------------------------------
-- function init
-------------------------------------
function Development:init()
end

-------------------------------------
-- function run
-------------------------------------
function Development:run(target_path)
    cclog('## Development:run')
    cclog('## Development - target path : ' .. tostring(target_path))
    
    self:dateTest()
    if true then
        return
    end

    self.targetPath = target_path
    
    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    util.changeDir('..')

    -- assets dirtory 만듬
    util.makeDirectory(self.targetPath)

    -- 암호화
    self:encryptSrcAndData()
    
    -- mirroring
    self:mirroring()

    -- 암호화 파일을 지운다.
    self:deleteEncrypt()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function dateTest
-------------------------------------
function Development:dateTest()
    cclog('## Development:dateTest()')
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    Development():run()
end