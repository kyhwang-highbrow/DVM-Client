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

    for _,t_set_data in pairs(rune_set_analysis) do
        if t_set_data and t_set_data['active'] then
            for j=1, t_set_data['active_cnt'] do
                table.insert(active_set_list, t_set_data['set_id'])
            end
        end
    end

    return active_set_list
end

-------------------------------------
-- function getRuneSetStatus
-------------------------------------
function StructRuneSetObject:getRuneSetStatus()
    local table_option = TableOption()
    local l_add_status = {}
    local l_multi_status = {}

    local active_set_list = self:getActiveRuneSetList()

    local table_rune_set = TableRuneSet()
    for _,set_id in pairs(active_set_list) do
        local stat_type, action, value = table_rune_set:getRuneSetStatus(set_id)

        if (action == 'add') then
            if (not l_add_status[stat_type]) then
                l_add_status[stat_type] = 0
            end
            l_add_status[stat_type] = l_add_status[stat_type] + value

        elseif (action == 'multi') then
            if (not l_multi_status[stat_type]) then
                l_multi_status[stat_type] = 0
            end
            l_multi_status[stat_type] = l_multi_status[stat_type] + value

        elseif (stat_type) then
            error('# action : ' .. action)

        end

    end

    return l_add_status, l_multi_status
end

-------------------------------------
-- function getRuneSetSkill
-------------------------------------
function StructRuneSetObject:getRuneSetSkill()
    local m_skill_id = {}

    local active_set_list = self:getActiveRuneSetList()

    local table_rune_set = TableRuneSet()
    for _, set_id in pairs(active_set_list) do
        local skill_id = table_rune_set:getRuneSetSkill(set_id)
        if (skill_id) then
            if (not m_skill_id[skill_id]) then
                m_skill_id[skill_id] = 0
            end

            -- 중첩 카운트를 계산
            m_skill_id[skill_id] = m_skill_id[skill_id] + 1
        end
    end

    return m_skill_id
end