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

        curr_dice = 'number',
        lap_cnt = 'number',
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
-- function getObtainingStateDesc
-------------------------------------
function StructEventDiceInfo:getObtainingStateDesc(key)
    local curr = self[key]
    local max = self[key .. '_max']

    return Str('{@SKILL_DESC_MOD}일일 최대 {@SKILL_DESC_ENHANCE}{1}/{2}{@SKILL_DESC_MOD}개', curr, max)
end
