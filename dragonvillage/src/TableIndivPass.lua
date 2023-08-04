local PARENT = TableClass
-------------------------------------
-- class TableIndivPassReward
-------------------------------------
TableIndivPass = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableIndivPass:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_indiv_pass'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableIndivPass instance
-------------------------------------
function TableIndivPass:getInstance()
    if (instance == nil) then
        instance = TableIndivPass()
    end
    return instance
end

-------------------------------------
-- function getIndivPassName
-------------------------------------
function TableIndivPass:getIndivPassName(id)
    return Str(self:getValue(id, 't_pass_name'))
end

-------------------------------------
-- function getAdvancePassPid
-------------------------------------
function TableIndivPass:getAdvancePassPid(id)
    return self:getValue(id, 'advance_pid')
end

-------------------------------------
-- function getPremiumPassPid
-------------------------------------
function TableIndivPass:getPremiumPassPid(id)
    return self:getValue(id, 'premium_pid')
end