local PARENT = Structure

-------------------------------------
-- class StructClanBuff
-------------------------------------
StructClanBuff = class(PARENT, {
		gold_bonus_rate = '',
		exp_bonus_rate = ''
    })

local THIS = StructClanBuff

CLAN_BUFF_TYPE = {
	['GOLD'] = 'gold_bonus_rate',
	['EXP'] = 'exp_bonus_rate',
}

-------------------------------------
-- function init
-------------------------------------
function StructClanBuff:init(data)
	if (not data) then
		self.gold_bonus_rate = 0
		self.exp_bonus_rate = 0
		cclog(debug.traceback())
	end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructClanBuff:getClassName()
    return 'StructClanBuff'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClanBuff:getThis()
    return THIS
end

-------------------------------------
-- function getClanBuff
-------------------------------------
function StructClanBuff:getClanBuff(clan_buff_type)
	return self[clan_buff_type]
end
