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
    local stage_id = self:getValue(world_raid_id, 'boss_attr')
    return stage_id
end

-------------------------------------
--- @function getWorldRaidPartyType
-------------------------------------
function TableWorldRaidInfo:getWorldRaidPartyType(world_raid_id)
    local party_type = self:getValue(world_raid_id, 'party_type')
    return party_type
end

-------------------------------------
--- @function getWorldRaidPartyTypeStr
-------------------------------------
function TableWorldRaidInfo:getWorldRaidPartyTypeStr(world_raid_id)
    local party_type = self:getWorldRaidPartyType(world_raid_id)
    if party_type == 1 then
        return Str('정예전')
    elseif party_type == 2 then
        return Str('협동전')
    elseif party_type == 3 then
        return Str('지구전')
    end
    return ''
end

-------------------------------------
--- @function getWorldRaidBuffAll
-------------------------------------
function TableWorldRaidInfo:getWorldRaidBuffAll(world_raid_id)
    local buff_key = self:getBuffKey(world_raid_id)
    local debuff_key = self:getDebuffKey(world_raid_id)
    local l_buff = TableContentAttr:getInstance():makeBuffList(buff_key)
    local l_debuff = TableContentAttr:getInstance():makeBuffList(debuff_key)
    table.addList(l_buff, l_debuff)
    return l_buff
end

-------------------------------------
--- @function getValueByPartyType
-------------------------------------
function TableWorldRaidInfo:getValueByPartyType(party_type, key)
    local list = self:filterList('party_type', party_type)
    local v = list[1]
    return v[key]
end

-------------------------------------
--- @function getStageIdByPartyType
-------------------------------------
function TableWorldRaidInfo:getStageIdByPartyType(party_type)
    local list = self:filterList('party_type', party_type)
    local v = list[1]
    return v['stage']
end

-------------------------------------
--- @function getBossAttrByPartyType
-------------------------------------
function TableWorldRaidInfo:getBossAttrByPartyType(party_type)
    local list = self:filterList('party_type', party_type)
    local v = list[1]
    return v['boss_attr']
end

