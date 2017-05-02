-------------------------------------
-- class ServerData_Slimes
-------------------------------------
ServerData_Slimes = class({
        m_serverData = 'ServerData',
        m_slimesObjectMap = 'map',
        m_slimesCnt = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Slimes:init(server_data)
    self.m_serverData = server_data
    self.m_slimesObjectMap = {}
    self.m_slimesCnt = 0
end

-------------------------------------
-- function applySlimeData_list
-- @brief
-------------------------------------
function ServerData_Slimes:applySlimeData_list(l_slime_data)
    for i,v in pairs(l_slime_data) do
        local t_slime_data = v
        self:applySlimeData(t_slime_data)
    end
end

-------------------------------------
-- function applySlimeData
-- @brief
-------------------------------------
function ServerData_Slimes:applySlimeData(t_slime_data)
    local soid = t_slime_data['id']

    local slime_object = self:getSlimeObject(soid)

    -- 관리 중인 슬라임이고 변경된 사항이 없을 경우 return
    if slime_object and (slime_object['updated_at'] == t_slime_data['updated_at']) then
        return
    end

    -- 기존에 없던 슬라임이면 갯수 추가
    if (not slime_object) then
        self.m_slimesCnt = self.m_slimesCnt + 1
    end

    -- 슬라임 오브젝트 데이터 최신화(혹은 신규 생성)
    local slime_object = StructSlimeObject(t_slime_data)
    self.m_slimesObjectMap[soid] = slime_object
end

-------------------------------------
-- function getSlimeObject
-- @brief
-------------------------------------
function ServerData_Slimes:getSlimeObject(soid)
    return self.m_slimesObjectMap[soid]
end