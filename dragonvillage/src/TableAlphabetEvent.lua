local PARENT = TableClass

-------------------------------------
-- class TableAlphabetEvent 
-------------------------------------
TableAlphabetEvent = class(PARENT, {
    })

local THIS = TableAlphabetEvent

-------------------------------------
-- function init
-------------------------------------
function TableAlphabetEvent:init()
    self.m_tableName = 'table_alphabet_event'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getWordList
-------------------------------------
function TableAlphabetEvent:getWordList()
    if (self == THIS) then
        self = THIS()
    end

    local word_list = table.MapToList(clone(self.m_orgTable))

    local function sort_func(a, b)
        return a['id'] < b['id']
    end

    table.sort(word_list, sort_func)

    for i,v in ipairs(word_list) do
        local l_item = self:parseAlphabetListStr(v['alphabet'])
        v['alphabet_list'] = l_item
    end

    return word_list
end

-------------------------------------
-- function getAlphabetList
-------------------------------------
function TableAlphabetEvent:getAlphabetList(word_id)
    if (self == THIS) then
        self = THIS()
    end

    local str = self:getValue(word_id, 'alphabet')
    local l_item = self:parseAlphabetListStr(str)
    return l_item
end

-------------------------------------
-- function parseAlphabetListStr
-------------------------------------
function TableAlphabetEvent:parseAlphabetListStr(str)
    if (self == THIS) then
        self = THIS()
    end

    -- str 예시
    -- 700214;1,700228;1,700211;1,700217;1,700225;1,700224;1,700232;1,700219;1,700222;1,700222;1,700211;1,700217;1,700215;1,700223;1
    local l_item = ServerData_Item:parsePackageItemStr(str)
    local l_ret = {}
    for i,v in ipairs(l_item) do
        l_ret[i] = v['item_id']
    end

    -- l_ret 예시
    --{
    --    700214;
    --    700228;
    --    700211;
    --    700217;
    --    700225;
    --    700224;
    --    700232;
    --    700219;
    --    700222;
    --    700222;
    --    700211;
    --    700217;
    --    700215;
    --    700223;
    --}
    return l_ret
end