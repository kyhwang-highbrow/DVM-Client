-------------------------------------
-- class ValidationAssistant
-- @brief 유효성을 검사를 돕는 클래스
-------------------------------------
ValidationAssistant = class({
        m_bValid = 'boolean',
        m_lInvalidData = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function ValidationAssistant:init()
    self.m_bValid = true
    self.m_lInvalidData = {}
end


-------------------------------------
-- function addInvalidData
-------------------------------------
function ValidationAssistant:addInvalidData(msg, t_data)
    local t_item = {}
    t_item['msg'] = msg
    t_item['t_data'] = t_data

    table.insert(self.m_lInvalidData, t_item)

    self.m_bValid = false
end

-------------------------------------
-- function isValid
-------------------------------------
function ValidationAssistant:isValid()
    return self.m_bValid
end

-------------------------------------
-- function getInvalidDataList
-------------------------------------
function ValidationAssistant:getInvalidDataList()
    return self.m_lInvalidData
end