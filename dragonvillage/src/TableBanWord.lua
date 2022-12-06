local PARENT = TableClass

-------------------------------------
-- class TableBanWord
-------------------------------------
TableBanWord = class(PARENT, {
    m_lLowerBanWord = 'list',
    m_lLowerStrictBanWord = 'list',
})

local instance = nil

-------------------------------------
-- function init
-------------------------------------
function TableBanWord:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_ban_word_chat'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
-------------------------------------
function TableBanWord:getInstance()
    if instance == nil then
        instance = TableBanWord()
    end
    return instance
end

-------------------------------------
-- function getBanWordList_Lower
-- @brief 소문자로 변환한 밴 단어 리스트 반환, 긴 문자열부터 반환한다.
-------------------------------------
function TableBanWord:getBanWordList_Lower()
    if (self.m_lLowerBanWord == nil) then
        local l_ban_word_lower = {}

        for _, t_data in pairs(self.m_orgTable) do
            table.insert(l_ban_word_lower, tostring(t_data['word']))
        end

        table.sort(l_ban_word_lower, function(a, b)
            local a_len = string.len(a)
            local b_len = string.len(b)

            if (a_len ~= b_len) then
                return (a_len > b_len)
            end

            return a < b
        end)

        self.m_lLowerBanWord = l_ban_word_lower
    end
    return self.m_lLowerBanWord
end

-------------------------------------
-- function getStrictBanWordList_Lower
-- @brief 소문자로 변환한 명백하게 욕설인 단어 리스트 반환, 긴 문자열부터 반환한다.
-------------------------------------
function TableBanWord:getStrictBanWordList_Lower()
    if (self.m_lLowerStrictBanWord == nil) then
        local l_strict_ban_word_lower = {}

        for _, t_data in pairs(self.m_orgTable) do
            if t_data['strict_word'] == 1 then
                table.insert(l_strict_ban_word_lower, tostring(t_data['word']))
            end
        end

        table.sort(l_strict_ban_word_lower, function(a, b)
            local a_len = string.len(a)
            local b_len = string.len(b)

            if (a_len ~= b_len) then
                return (a_len > b_len)
            end

            return a < b
        end)

        self.m_lLowerStrictBanWord = l_strict_ban_word_lower
    end
    return self.m_lLowerStrictBanWord
end

-------------------------------------
-- function checkContainBanWord
-- @brief 해당 텍스트에 욕설이 포함되어 있는지 검사
-- @param text(String) 검사하려는 텍스트
-- @param use_ui(boolean) 해당 값이 true이면 포함되어 있을 때 일반적인 경고 팝업을 띄운다.
-------------------------------------
function TableBanWord:checkContainBanWord(text, use_ui)
    -- 모두 소문자로 변경
    local lower_str = string.lower(text)

    -- 금칙어 추출
    local l_match_list = {}
    local l_ban_word = TableBanWord.getInstance():getBanWordList_Lower()
    for _, word in ipairs(l_ban_word) do
        if string.find(lower_str, word, nil, true) then
            table.insert(l_match_list, word)
            lower_str = string.gsub(lower_str, word, '')
            
            if (string.trim(lower_str) == '') then
                break
            end
        end
        
    end

    -- match
    if (table.count(l_match_list) > 0) then
        -- 금칙어 강조된 문장 생성 (영어는 일단 소문자로 표현)
        local ret_str = string.lower(text)
        for _, word in ipairs(l_match_list) do
            ret_str = string.gsub(ret_str, word, '{@RED}' .. word .. '{@}')
        end
        ret_str = '{@}' .. ret_str
        local warning = '{@}' .. Str('금칙어가 포함되어 사용 할 수 없습니다.')
        MakeSimplePopup2(POPUP_TYPE.OK, ret_str, warning)
        return false
    end
    
    return true
end