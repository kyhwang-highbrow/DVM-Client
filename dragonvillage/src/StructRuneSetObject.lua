-------------------------------------
-- class StructRuneSetObject
-- @instance rune_set_obj
-------------------------------------
StructRuneSetObject = class({
        m_lRuneObject = 'list', -- slot 기반
    })

-------------------------------------
-- function init
-------------------------------------
function StructRuneSetObject:init()
    self.m_lRuneObject = {}
end

-------------------------------------
-- function setRuneObjectList
-------------------------------------
function StructRuneSetObject:setRuneObjectList(rune_obj_list)
    for _,rune_obj in pairs(rune_obj_list) do
        self:addRuneObject(rune_obj)
    end
end

-------------------------------------
-- function addRuneObject
-------------------------------------
function StructRuneSetObject:addRuneObject(rune_obj)
    if (not rune_obj) then
        return
    end

    local slot = rune_obj['slot']
    self.m_lRuneObject[slot] = rune_obj
end

-------------------------------------
-- function delRuneObject
-------------------------------------
function StructRuneSetObject:delRuneObject(slot)
    self.m_lRuneObject[slot] = nil
end


-------------------------------------
-- function getRidList
-------------------------------------
function StructRuneSetObject:getRidList()
    local l_rid = {}

    for i,v in pairs(self.m_lRuneObject) do
        table.insert(l_rid, v['rid'])
    end

    return l_rid
end

-------------------------------------
-- function getActiveRuneSetList
-------------------------------------
function StructRuneSetObject:getActiveRuneSetList()
    local l_rid = self:getRidList()
    local rune_set_analysis = TableRuneSet:runeSetAnalysis(l_rid)

    local active_set_list = {}

    for i=1, RUNE_SLOT_MAX do
        local t_set_data = rune_set_analysis[i]
        if t_set_data and t_set_data['active'] then
            table.insert(active_set_list, t_set_data['set_id'])
        end
    end

    return active_set_list
end