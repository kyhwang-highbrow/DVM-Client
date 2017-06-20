require 'SrcToolUtils'
TranslateExtractor = class({
    
    



    })

function TranslateExtractor:init() 

end

function TranslateExtractor:extractUIFiles()
    local root_dir = '\\..\\res\\'
    -- UIÆÄÀÏµé¿¡¼­ µ¥ÀÌÅÍ¸¦ ÀĞ¾î¿Â´Ù.
    -- ÀÌ °úÁ¤À» °ÅÄ¡¸é t_translateÀº key = ÆÄÀÏ ÀÌ¸§, value = ÇÑ±Û string
    local t_translate = getChildrenPathByKey( {lfs.currentdir() .. root_dir} , '*.ui')
    for k, _ in pairs(t_translate) do
        local components = {}
        local ui_contents = pl.file.read(k)
        t_translate[k] = loadstring('return ' .. ui_contents)()
        self:findTranslateTargetInUI(t_translate[k], components)
        if(not table.empty(components)) then 
            t_translate[k] = components
        else 
            t_translate[k] = nil
        end
    end
    return t_translate
end

function TranslateExtractor:extractLuaFiles()
    local root_dir = '\\..\\src\\'
    -- LuaÆÄÀÏµé¿¡¼­ µ¥ÀÌÅÍ¸¦ ÀĞ¾î¿Â´Ù.
    -- ÀÌ °úÁ¤À» °ÅÄ¡¸é, t_translateÀº key = ÆÄÀÏ ÀÌ¸§, value = ÇÑ±Û string
    local t_translate = getChildrenPathByKey( {lfs.currentdir() .. root_dir} , '*.lua')
    for k, _ in pairs(t_translate) do
        local components = {}
        local lua_contents = pl.file.read(k)
        t_translate[k] = pl.stringx.splitlines(lua_contents)
        self:findTranslateTargetInLua(t_translate[k], components)
        if(not table.empty(components)) then
            t_translate[k] = components
        else
            t_translate[k] = nil
        end
    end
    --ccdump(t_translate)
    return t_translate
end

function TranslateExtractor:extractCSVFiles()
    local root_dir = '\\..\\data\\'
    -- CSVÆÄÀÏµé¿¡¼­ µ¥ÀÌÅÍ¸¦ ÀĞ¾î¿Â´Ù.
    -- ÀÌ °úÁ¤À» °ÅÄ¡¸é, t_translateÀº key = ÆÄÀÏ ÀÌ¸§, value = ÇÑ±Û string
    local t_translate = getChildrenPathByKey ( {lfs.currentdir() .. root_dir} , '*.csv')
    for k, _ in pairs(t_translate) do
        if(not k:match('table_[a-z+]')) then
            t_translate[k] = nil
        end
    end
    ccdump(t_translate)
    for k, _ in pairs(t_translate) do
        local components = {}
        local csv_contents = TABLE:loadCSVTable(k:sub(1, -5))
        ccdump(csv_contents)
    end
end

function TranslateExtractor:findTranslateTargetInUI(t, ret)
    if (t['type'] == 'LabelTTF') then
        if (self:isKorean(t['text'])) then
            if (not ret['LabelTTF']) then
                ret['LabelTTF'] = {}
            end
            table.insert(ret['LabelTTF'], t['text']) 
        end
    elseif (t['type'] == 'EditBox') then
        if (self:isKorean(t['placeholder'])) then
            if (not ret['EditBox']) then
                ret['EditBox'] = {}
            end
            table.insert(ret['EditBox'], t['placeholder'])
        end
    end

    for i, v in ipairs(t) do
        self:findTranslateTargetInUI(v, ret)
    end
end

function TranslateExtractor:findTranslateTargetInLua(t, ret)
    for i, v in ipairs(t) do
        str = self:isTargetInLua(v)
        if (str) then
            ret[i] = str
        end
    end
end

function TranslateExtractor:findTranslateTargetInCSV(t, ret)
 
end

function TranslateExtractor:isKorean(str)
    return str:find('[°¡-ÆR]+')
end

function TranslateExtractor:isTargetInLua(str)
    local temp = str:match('Str%(\'.*\'%)')

    if(temp and self:isKorean(temp)) then
        temp = temp:sub(6, -3)
        return temp
    end
    return false
end

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end