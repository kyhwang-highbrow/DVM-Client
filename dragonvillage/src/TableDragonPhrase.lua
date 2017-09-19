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
-- function getValue
-------------------------------------
function TableDragonPhrase:getValue(primary, column)
    local phrase = PARENT.getValue(self, primary, column)
	if (phrase) then
		return Str(phrase)
	else
		return Str('나는 대사 없는 드래곤')
	end
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
    return speech
end

-------------------------------------
-- function getDragonPhrase
-------------------------------------
function TableDragonPhrase:addPhraseByFlv(sum_random, flv)
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
end

-------------------------------------
-- function getDragonPhrase
-------------------------------------
function TableDragonPhrase:addShotByFlv(sum_random, flv)
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
end

-------------------------------------
-- function getMailPhrase
-------------------------------------
function TableDragonPhrase:getMailPhrase(did)
	if (self == THIS) then
        self = THIS()
    end
	local key = 'mail_message'

	local speech = self:getValue(did, key)
    return speech
end

-------------------------------------
-- function getRandomPhrase_Sensitivity
-------------------------------------
function TableDragonPhrase:getRandomPhrase_Sensitivity(did, flv, case_type)
    if (self == THIS) then
        self = THIS()
    end

    local sum_random = SumRandom()	
	
	if (case_type == 'lobby_touch') then
		for i = 1, 4 do
			sum_random:addItem(1, 'lobby_touch' .. i)
		end
		self:addPhraseByFlv(sum_random, flv)
		self:addShotByFlv(sum_random, flv)

	elseif (case_type == 'lobby_hurry_gift') then
		sum_random:addItem(1, 'lobby_induce')
	
	elseif (case_type == 'lobby_get_gift') then
		sum_random:addItem(1, 'lobby_present')
	
	elseif (case_type == 'lobby_after_gift') then
		sum_random:addItem(1, 'lobby_end')

	elseif (case_type == 'party_in') then
		sum_random:addItem(1, 'party_in')

	elseif (case_type == 'party_out') then
		sum_random:addItem(1, 'party_out')

	elseif (case_type == 'party_in_induce') then
		sum_random:addItem(1, 'party_in_induce')
	
	elseif (case_type == 'fruit_induce') then
		sum_random:addItem(1, 'fruit_induce')

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
	
	local speech = self:getValue(did, key)
    return speech
end

-------------------------------------
-- function getForestMoveType
-------------------------------------
function TableDragonPhrase:getForestMoveType(did)
	if (self == THIS) then
        self = THIS()
    end

    return self:getValue(did, 'myroom_move')
end