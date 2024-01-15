local PARENT = TableClass
-------------------------------------
-- class TableWorldRaidInfo
-------------------------------------
TableWorldRaidInfo = class(PARENT, {
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableWorldRaidInfo:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_world_raid_info'
    self.m_orgTable = TABLE:get(self.m_tableName)    
end

-------------------------------------
--- @function getInstance
---@return TableWorldRaidInfo instance
-------------------------------------
function TableWorldRaidInfo:getInstance()
    if (instance == nil) then
        instance = TableWorldRaidInfo()
    end
    return instance
end

-------------------------------------
--- @function getAdvantageAttrList
-------------------------------------
function TableWorldRaidInfo:getAdvantageAttrList(world_raid_id)
    local buff_key = self:getValue(world_raid_id, 'buff_key')
    local attr_list = TableContentAttr:getInstance():getAttrList(buff_key)
    return attr_list
end

-------------------------------------
--- @function getAdvantageBuffList
-------------------------------------
function TableWorldRaidInfo:getAdvantageBuffList(world_raid_id)
    local buff_key = self:getValue(world_raid_id, 'buff_key')
    local attr_list = TableContentAttr:getInstance():getAttrList(buff_key)
    return attr_list
end

-------------------------------------
--- @function getDisadvantageAttrList
-------------------------------------
function TableWorldRaidInfo:getDisadvantageAttrList(world_raid_id)
    local debuff_key = self:getValue(world_raid_id, 'debuff_key')
    local attr_list = TableContentAttr:getInstance():getAttrList(debuff_key)
    return attr_list
end

-------------------------------------
--- @function getBuffKey
-------------------------------------
function TableWorldRaidInfo:getBuffKey(world_raid_id)
    local buff_key = self:getValue(world_raid_id, 'buff_key')
    return buff_key
end

-------------------------------------
--- @function getDebuffKey
-------------------------------------
function TableWorldRaidInfo:getDebuffKey(world_raid_id)
    local debuff_key = self:getValue(world_raid_id, 'debuff_key')
    return debuff_key
end

-------------------------------------
--- @function getWorldRaidStageId
-------------------------------------
function TableWorldRaidInfo:getWorldRaidStageId(world_raid_id)
    local stage_id = self:getValue(world_raid_id, 'stage')
    return stage_id
end

-------------------------------------
--- @function getWorldRaidAttr
-------------------------------------
function TableWorldRaidInfo:getWorldRaidAttr(world_raid_id)
    local stage_id = self:getValue(world_raid_id, 'attr')
    return stage_id
end

-------------------------------------
--- @function getWorldRaidPartyTypeStr
-------------------------------------
function TableWorldRaidInfo:getWorldRaidPartyTypeStr(world_raid_id)
    local party_type = self:getValue(world_raid_id, 'party_type')
    if party_type == 1 then
        return Str('정예전')
    elseif party_type == 2 then
        return Str('협동전')
    elseif party_type == 3 then
        return Str('지구전')
    end
    return ''
end
