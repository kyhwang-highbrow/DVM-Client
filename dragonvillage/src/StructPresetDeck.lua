-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
---@class StructPresetDeck:Structure
-------------------------------------
StructPresetDeck = class(PARENT, {
    idx = 'number', -- 덱 번호
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
    self.idx = 0
    self.formation = 'attack'
    self.leader = 0
    self.name = Str('기본 덱')
end

-------------------------------------
-- function correctData
-------------------------------------
function StructPresetDeck:correctData()
    local next_leader = 0
    for key, doid in pairs(self.l_deck) do
        if g_dragonsData:getDragonDataFromUidRef(doid) == nil then
            self.l_deck[key] = nil
            if self.leader == key then
                self.leader = 0
            end
        else
            if (g_dragonsData:haveLeaderSkill(doid) and next_leader == 0) then
                next_leader = key
            end
        end
    end

    if self.leader == 0 then
        self.leader = next_leader
    end
end

-------------------------------------
-- function setDeckMap
-------------------------------------
function StructPresetDeck:setDeckMap(l_deck)
    self.l_deck = l_deck
end

-------------------------------------
-- function getDeckMap
-------------------------------------
function StructPresetDeck:getDeckMap()
    return self.l_deck or {}
end

-------------------------------------
-- function getIndex
-------------------------------------
function StructPresetDeck:getIndex()
    return self.idx
end


-------------------------------------
-- function setFormation
-------------------------------------
function StructPresetDeck:setFormation(formation)
    self.formation = formation
end

-------------------------------------
-- function getFormation
-------------------------------------
function StructPresetDeck:getFormation()
    return self.formation
end

-------------------------------------
-- function setLeader
-------------------------------------
function StructPresetDeck:setLeader(leader)
    self.leader = leader
end

-------------------------------------
-- function getLeader
-------------------------------------
function StructPresetDeck:getLeader()
    return self.leader
end


-------------------------------------
-- function setPresetDeckName
-------------------------------------
function StructPresetDeck:setPresetDeckName(name)
    self.name = name
end

-------------------------------------
-- function getPresetDeckName
-------------------------------------
function StructPresetDeck:getPresetDeckName()
    return self.name
end


-------------------------------------
-- function getJsonString
-------------------------------------
function StructPresetDeck:getJsonString()
    local str = dkjson.encode(self)
    return str
end
