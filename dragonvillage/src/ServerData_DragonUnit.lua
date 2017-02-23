-------------------------------------
-- class ServerData_DragonUnit
-------------------------------------
ServerData_DragonUnit = class({
        m_serverData = 'ServerData',
        m_mDragonUnitDataList = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonUnit:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function organizeData
-- @brief 클라이언트에서 사용하기 위한 데이터 가공
-------------------------------------
function ServerData_DragonUnit:organizeData()

    -- 테이블에서 리스트업
    local table_dragon_unit = TableDragonUnit()
    self.m_mDragonUnitDataList = clone(table_dragon_unit.m_orgTable)

    local table_dragon_unit = TableDragonUnit()

    for unit_id,v in pairs(self.m_mDragonUnitDataList) do

        -- 조건 드래곤 리스트
        v['unit_list'] = table_dragon_unit:getUnitDragonList(unit_id)

        local active = true

        for _,unit in ipairs(v['unit_list']) do
            local type = unit['type']
            local value = unit['value']

            -- 드래곤이 있는지 체크
            unit['exist'] = self:checkExistDragon(type, value)

            if (not unit['exist']) then
                active = false
            end
        end

        -- 모든 드래곤이 포함되어 있으면 active가 true
        v['active'] = active
    end
end

-------------------------------------
-- function getDragonUnitData
-------------------------------------
function ServerData_DragonUnit:getDragonUnitData(unit_id)
    return self.m_mDragonUnitDataList[unit_id]
end

-------------------------------------
-- function getDragonUnitIDList
-------------------------------------
function ServerData_DragonUnit:getDragonUnitIDList()
    self:organizeData()

    local t_dragon_unit = TableDragonUnit()

    local t_ret = {}

    for i,v in pairs(t_dragon_unit.m_orgTable) do
        table.insert(t_ret, i)
    end

    return t_ret
end

-------------------------------------
-- function checkExistDragon
-- @brief 무리 버프에서 사용되는 드래곤 항목(원종이 같은 드래곤들이거나 개별 드래곤)
-------------------------------------
function ServerData_DragonUnit:checkExistDragon(type, value)
    local l_dragons = self.m_serverData:getRef('dragons')

    local table_dragon = TableDragon()

    for _,t_dragon_data in pairs(l_dragons) do
        if (type == 'dragon') then
            if (t_dragon_data['did'] == value) then
                return true
            end
        elseif (type == 'category') then
            local did = t_dragon_data['did']
            local dragon_type = table_dragon:getValue(did, 'type')
            if (dragon_type == value) then
                return true
            end
        end
    end

    return false
end