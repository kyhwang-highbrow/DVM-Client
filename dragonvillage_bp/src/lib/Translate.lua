--MARK: 지원언어 목록 셋업 부분, 주석처리
--if PatiFriends.line then
--    t_language = {'en', 'jp', 'tw'}
--else
    t_language = {'kr', 'cn'}
--end

local CustomFontNameTable = {
--    kr = 'NanumBarunGothic';
}

Translate = {}

-- 1. os에 설정된 언어 설정을 가져오고
-- 2. 해당 언어가 지원언어목록에 있다면 해당 언어를 사용하고
-- 3. 목록에 없다면 지원언어목록 제일 앞에 있는 언어를 사용한다.
function Translate:init()
    self.phoneLang = 'kr'
    self.gameLang = nil
    --if CCApplication.getPatiLanguageCode then
    --    self.phoneLang = CCApplication:getPatiLanguageCode()
    --end
    if table.find(t_language, self.phoneLang) then
        self.gameLang = self.phoneLang
    else
        self.gameLang = t_language[1]
    end
    --TODO: ios는 ttf가 붙지 않는다..
    self.customFontName = CustomFontNameTable[self.gameLang] or ''
    --if (not AppDelegate.getMarketName() == 'APPL') and #self.customFontName > 0 then
    --    self.customFontName = self.customFontName .. '.ttf'
    --end
end

Translate:init()

local keyLang = 'kr'
local function loadTranslate(disposable)
    --[[
    local gameLang = Translate.gameLang
    if gameLang == keyLang then
        return nil
    end

    local gzio = require 'gzio'

    local t1 = os.clock()
    local keyFileName = 'translate/' .. keyLang .. 'langs' .. (disposable and '_disposable' or '')
    local curFileName = 'translate/' .. gameLang .. 'langs' .. (disposable and '_disposable' or '')

    local fKey = FileUtil.load(keyFileName)
    local fCur = FileUtil.load(curFileName)
    
    if fKey == nil or fCur == nil then
        return nil
    end

    local t2 = os.clock()
    
    local strTable_key = seperate(fKey, '\n')
    local strTable_cur = seperate(fCur, '\n')
    local map = {}
    for i, key in ipairs(strTable_key) do
        key = string.gsub(key, '\\n', '\n')
        key = string.gsub(key, '\\"', '\"')
        map[key] = string.gsub(strTable_cur[i], '\\n', '\n')
        map[key] = string.gsub(map[key], '\\"', '\"')
    end
    
    local t3 = os.clock()
    Log(string.format('%s parsing:%f convert:%f', 'translate', t2-t1, t3-t2))
    return map
    --]]
end

--[[
-- strict 때문에 글로벌 함수의 존재 여부를 체크만 해도 lua error가 난다.
if rawget(_G, 'UnzipFilesFromResource') then
    local unzippedCount = UnzipFilesFromResource('translate/', true)
    Log('unzippedCount ' .. tostring(unzippedCount))
end

Translate.map = loadTranslate(false)
Translate.disposable = loadTranslate(true)
--]]

function Translate:get(id)
    local id = string.gsub(id, '\\n', '\n')
    if self.map and self.map[id] then
        return self.map[id]
    end
    if self.disposable and self.disposable[id] then
        return self.disposable[id]
    end
    return id
end

function Translate:dispose()
    self.disposable = nil
end
