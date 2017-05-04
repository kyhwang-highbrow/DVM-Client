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
    if TableSlime:isSlimeID(did) then
        return Str('슬라임!!')
    end

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

-------------------------------------
-- function getRandomPhrase
-------------------------------------
function TableDragonPhrase:getRandomPhrase()
    if (self == THIS) then
        self = THIS()
    end

    local t_row = self:getRandomRow()

    local sum_random = SumRandom()

    sum_random:addItem(1, 't_normal_phrase1')
    sum_random:addItem(1, 't_normal_phrase2')
    sum_random:addItem(1, 't_normal_phrase3')
    sum_random:addItem(1, 't_good_phrase1')
    sum_random:addItem(1, 't_good_phrase2')
    sum_random:addItem(1, 't_good_phrase3')
    sum_random:addItem(1, 't_best_phrase1')
    sum_random:addItem(1, 't_best_phrase2')
    sum_random:addItem(1, 't_best_phrase3')
    sum_random:addItem(1, 't_normal_shout1')
    sum_random:addItem(1, 't_normal_shout2')
    sum_random:addItem(1, 't_good_shout1')
    sum_random:addItem(1, 't_good_shout2')
    sum_random:addItem(1, 't_best_shout1')
    sum_random:addItem(1, 't_best_shout2')

    local key = sum_random:getRandomValue()

    local phrase = Str(t_row[key])
    return phrase
end

-------------------------------------
-- function getRandomPhrase_LobbyTouch
-------------------------------------
function TableDragonPhrase:getRandomPhrase_LobbyTouch(did)
    if (self == THIS) then
        self = THIS()
    end

    local sum_random = SumRandom()
	for i = 1, 4 do
		sum_random:addItem(1, 'lobby_touch' .. i)
	end
    local key = sum_random:getRandomValue()

    local phrase = Str(self:getValue(did, key))
    return phrase
end


-------------------------------------
-- function getRandomPhrase_LobbyTouch
-------------------------------------
function TableDragonPhrase:getRandomPhrase_Sensitivity(did, case_type)
    if (self == THIS) then
        self = THIS()
    end

    local sum_random = SumRandom()	
	
	if (case_type == 'lobby_touch') then
		for i = 1, 4 do
			sum_random:addItem(1, 'lobby_touch' .. i)
		end
	
	elseif (case_type == 'lobby_hurry_present') then
		sum_random:addItem(1, 'lobby_induce')
	
	elseif (case_type == 'lobby_get_present') then
		sum_random:addItem(1, 'lobby_present')
	
	elseif (case_type == 'lobby_after_present') then
		sum_random:addItem(1, 'lobby_end')

	elseif (case_type == 'party_in') then
		sum_random:addItem(1, 'party_in')

	elseif (case_type == 'party_out') then
		sum_random:addItem(1, 'party_out')

	else
		sum_random:addItem(1, 't_normal_phrase1')
		sum_random:addItem(1, 't_normal_phrase2')
		sum_random:addItem(1, 't_normal_phrase3')
		sum_random:addItem(1, 't_good_phrase1')
		sum_random:addItem(1, 't_good_phrase2')
		sum_random:addItem(1, 't_good_phrase3')
		sum_random:addItem(1, 't_best_phrase1')
		sum_random:addItem(1, 't_best_phrase2')
		sum_random:addItem(1, 't_best_phrase3')
		sum_random:addItem(1, 't_normal_shout1')
		sum_random:addItem(1, 't_normal_shout2')
		sum_random:addItem(1, 't_good_shout1')
		sum_random:addItem(1, 't_good_shout2')
		sum_random:addItem(1, 't_best_shout1')
		sum_random:addItem(1, 't_best_shout2')
	end

    local key = sum_random:getRandomValue()
	
	local speech = self:getValue(did, key) or '= - ='

    local phrase = Str(speech)
    return phrase
end