-------------------------------------
-- class ServerData_EventAdvent
-------------------------------------
ServerData_EventAdvent = class({
        -- 깜짝 출현 정보
        m_adventDragonList = 'table',
    })
-------------------------------------
-- function init
-------------------------------------
function ServerData_EventAdvent:init()
end

-------------------------------------
-- function setAdventDragonList
-------------------------------------
function ServerData_EventAdvent:setAdventDragonList(list_str)
    self.m_adventDragonList = {}
    local l_ret = plSplit(list_str[1], ',')
    for i, v in ipairs(l_ret) do
        table.insert(self.m_adventDragonList, tonumber(v))
    end
end

-------------------------------------
-- function getAdventDragonList
-------------------------------------
function ServerData_EventAdvent:getAdventDragonList()
    return self.m_adventDragonList
end

-------------------------------------
-- function getAdventTitle
-- @brief 깜짝 출현 타이틀
-------------------------------------
function ServerData_EventAdvent:getAdventTitle()
    if (not self.m_adventDragonList) and (not self.m_adventDragonList[1]) then
        return Str('드래곤')
    end

    local dragon_name = TableDragon:getDragonName(self.m_adventDragonList[1])
    return Str('{1} 깜짝 출현!', dragon_name)
end

-------------------------------------
-- function getAdventStageCount
-- @brief 깜짝 출현 던전 개수
-------------------------------------
function ServerData_EventAdvent:getAdventStageCount()
    if (not self.m_adventDragonList) and (not self.m_adventDragonList[1]) then
        return 0
    end

    return #self.m_adventDragonList
end