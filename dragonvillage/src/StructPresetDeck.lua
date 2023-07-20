-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
---@class StructPresetDeck:Structure
-------------------------------------
StructPresetDeck = class(PARENT, {
    l_deck = 'Map<idx, doid>',
    name = 'string',
    formation = 'string', -- attack, defense ...
    leader = 'number',
})

local THIS = StructPresetDeck
-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructPresetDeck:getClassName()
    return 'StructPresetDeck'
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructPresetDeck:getThis()
    return THIS
end

-------------------------------------
-- function init
-------------------------------------
function StructPresetDeck.create(t_data)
    local struct_preset_deck = StructPresetDeck()
    -- 서버에서 전달 받은 key를 클라이언트 데이터에 적합하게 변경
    local t_key_change = {}
    struct_preset_deck:applyTableData(t_data, t_key_change)
    return struct_preset_deck
end

-------------------------------------
-- function init
-------------------------------------
function StructPresetDeck:init()
    --local t_data = dkjson.decode(json_string)
    self.l_deck = {}
    self.formation = 'attack'
    self.leader = 0
    self.name = Str('기본 덱')
end

-------------------------------------
-- function getJsonString
-------------------------------------
function StructPresetDeck:getJsonString()
    local str = dkjson.encode(self)
    return str
end
