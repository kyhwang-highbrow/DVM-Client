local PARENT = TableClass

-------------------------------------
-- class TableDragonPhrase
-------------------------------------
TableDragonPhrase = class(PARENT, {
    })

local THIS = TableDragonPhrase

-------------------------------------
-- function init
-------------------------------------
function TableDragonPhrase:init()
    self.m_tableName = 'table_dragon_phrase'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonPhrase
-------------------------------------
function TableDragonPhrase:getDragonPhrase(did, flv)
    if (self == THIS) then
        self = THIS()
    end

    local sum_random = SumRandom()
    
    if (flv <= 2) then
        sum_random:addItem(1, 't_normal_phrase1')
        sum_random:addItem(1, 't_normal_phrase2')
        sum_random:addItem(1, 't_normal_phrase3')
    elseif (flv <= 6) then
        sum_random:addItem(1, 't_good_phrase1')
        sum_random:addItem(1, 't_good_phrase2')
        sum_random:addItem(1, 't_good_phrase3')
    else
        sum_random:addItem(1, 't_best_phrase1')
        sum_random:addItem(1, 't_best_phrase2')
        sum_random:addItem(1, 't_best_phrase3')
    end
    
    local key = sum_random:getRandomValue()

    local speech = self:getValue(did, key)
    speech = Str(speech)

    return speech 
end

-------------------------------------
-- function getDragonShout
-------------------------------------
function TableDragonPhrase:getDragonShout(did, flv)
    if (self == THIS) then
        self = THIS()
    end

    local sum_random = SumRandom()
    
    if (flv <= 2) then
        sum_random:addItem(1, 't_normal_shout1')
        sum_random:addItem(1, 't_normal_shout2')
    elseif (flv <= 6) then
        sum_random:addItem(1, 't_good_shout1')
        sum_random:addItem(1, 't_good_shout2')
    else
        sum_random:addItem(1, 't_best_shout1')
        sum_random:addItem(1, 't_best_shout2')
    end
    
    local key = sum_random:getRandomValue()

    local speech = self:getValue(did, key)
    speech = Str(speech)

    return speech 
end
