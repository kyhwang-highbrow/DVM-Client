local PARENT = Structure

-------------------------------------
-- class StructEventDiceInfo
-- @brief 이벤트 팝업에 등록된 탭
------------------------------------- 
StructEventDiceInfo = class(PARENT, {
        pvp = 'number',
        pvp_max = 'number',

        adv = 'number',
        adv_max = 'number',

        explore = 'number',
        explore_max = 'number',

        dungeon = 'number',
        dungeon_max = 'number',

        today = 'number',
        today_max = 'number',
		
		add_dice = 'number',
		add_max = 'number',

        curr_dice = 'number',

        curr_cell = 'number',
        lap_cnt = 'number',

        gold_use = 'number',
    })

local THIS = StructEventDiceInfo

-------------------------------------
-- function init
-------------------------------------
function StructEventDiceInfo:init(event_data)
    self:apply(event_data)
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructEventDiceInfo:getClassName()
    return 'StructEventDiceInfo'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructEventDiceInfo:getThis()
    return THIS
end

-------------------------------------
-- function apply
-------------------------------------
function StructEventDiceInfo:apply(t_data)
    for i, v in pairs(self) do
        if (t_data[i] ~= nil) then
            self[i] = t_data[i]
        end
    end
end

-------------------------------------
-- function getCurrDice
-------------------------------------
function StructEventDiceInfo:getCurrDice()
    return self['curr_dice']
end

-------------------------------------
-- function getCurrCell
-------------------------------------
function StructEventDiceInfo:getCurrCell()
    return self['curr_cell']
end

-------------------------------------
-- function getCurrLapCnt
-------------------------------------
function StructEventDiceInfo:getCurrLapCnt()
    return self['lap_cnt']
end

-------------------------------------
-- function getObtainingStateDesc
-------------------------------------
function StructEventDiceInfo:getObtainingStateDesc(key)
    local curr = self[key]
    local max = self[key .. '_max']

    return Str('{@SKILL_DESC_MOD}(일일 최대 {@SKILL_DESC_ENHANCE}{1}/{2}{@SKILL_DESC_MOD}개)', curr, max)
end

-------------------------------------
-- function getTodayObtainingDesc
-------------------------------------
function StructEventDiceInfo:getTodayObtainingDesc()
    local key = 'today'
    local curr = self[key]
    local max = self[key .. '_max']

    return Str('{@SKILL_DESC_MOD}일일 최대 {@SKILL_DESC_ENHANCE}{1}/{2}{@SKILL_DESC_MOD}개 획득 가능', curr, max)
end


-------------------------------------
-- function getAddDice
-------------------------------------
function StructEventDiceInfo:getAddDice()
    return self['add_dice']
end

-------------------------------------
-- function useAllAddDice
-------------------------------------
function StructEventDiceInfo:useAllAddDice()
    return (self['add_max'] <= self['add_dice'])
end

-------------------------------------
-- function getAdditionalStateDesc
-------------------------------------
function StructEventDiceInfo:getAdditionalStateDesc()
	local curr = self['add_dice']
	local max = self['add_max']
    local remain = (max - curr)

	return Str('일일 {1}/{2}회 가능', remain, max)
end