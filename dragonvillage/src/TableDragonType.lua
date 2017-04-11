local PARENT = TableClass

-------------------------------------
-- class TableDragonType
-- @brief 드래곤 원종별로 정리된 테이블 (table_dragon에서 type이 같은 기준)
--        key값은 type ('powerdragon', 'taildragon')
-------------------------------------
TableDragonType = class(PARENT, {
    })

local THIS = TableDragonType

-------------------------------------
-- function init
-------------------------------------
function TableDragonType:init()
    self.m_tableName = 'dragon_type'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getBaseDid
-- @brief 드래곤 원종의 진짜 원종 did 리턴
-------------------------------------
function TableDragonType:getBaseDid(dragon_type)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(dragon_type, 'base_did')
end

-------------------------------------
-- function getRandomSpeech
-- @brief
-------------------------------------
function TableDragonType:getRandomSpeech(dragon_type, flv)
    if (self == THIS) then
        self = THIS()
    end

    local sum_random = SumRandom()
    
    if (flv <= 2) then
        sum_random:addItem(1, 't_phrase1')
    elseif (flv <= 6) then
        sum_random:addItem(1, 't_phrase1')
        sum_random:addItem(1, 't_phrase2')
    else
        sum_random:addItem(1, 't_phrase1')
        sum_random:addItem(1, 't_phrase2')
        sum_random:addItem(1, 't_phrase3')
    end
    
    local key = sum_random:getRandomValue()

    local speech = self:getValue(dragon_type, key)
    speech = Str(speech)

    return speech
end