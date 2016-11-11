local PARENT = TableClass

-------------------------------------
-- class TableStageDesc
-------------------------------------
TableStageDesc = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableStageDesc:init()
    self.m_tableName = 'stage_desc'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStageDesc
-- @brief 스테이지 설명을 리턴
-------------------------------------
function TableStageDesc:getStageDesc(stage_id)
    local t_table = self:get(stage_id)
    local desc = t_table['t_desc']
    return desc
end

-------------------------------------
-- function getMonsterIconList
-- @brief 스테이지에 등장하는 몬스터 아이콘 리턴
-------------------------------------
function TableStageDesc:getMonsterIconList(stage_id)
    local l_moster_id = self:getMonsterIDList(stage_id)

    local l_icon_list = {}
    for i,v in ipairs(l_moster_id) do
        local icon = UI_MonsterCard(v)
        table.insert(l_icon_list, icon)
    end
    
    return l_icon_list
end

-------------------------------------
-- function getMonsterIDList
-- @brief 스테이지에 등장하는 몬스터 ID 리스트를 리턴
-------------------------------------
function TableStageDesc:getMonsterIDList(stage_id)
    local t_table = self:get(stage_id)

    local str = t_table['monster_id']
    local l_moster_id = stringSplit(str, ';')

    for i,v in ipairs(l_moster_id) do
        l_moster_id[i] = tonumber(trim(v))
    end

    return l_moster_id or {}
end