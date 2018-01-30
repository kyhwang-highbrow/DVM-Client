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

    -- 추가된 슬라임은 도감에 추가
    local slime_id = t_slime_data['slime_id']
    g_bookData:setSlimeBook(slime_id)

    -- 슬라임 도감에 보상이 있을 경우 하일라이트 정보 갱신을 위해 호출
    if g_bookData:haveBookReward(slime_id, 1) then
        g_highlightData:setDirty(true)
    end
end

-------------------------------------
-- function delSlimeObject
-- @brief
-------------------------------------
function ServerData_Slimes:delSlimeObject(soid)
    -- 슬라임 갯수 감소
    if self.m_slimesObjectMap[soid] then
        self.m_slimesCnt = self.m_slimesCnt - 1
    end

    self.m_slimesObjectMap[soid] = nil
end


-------------------------------------
-- function getSlimeObject
-- @brief
-------------------------------------
function ServerData_Slimes:getSlimeObject(soid)
    return clone(self.m_slimesObjectMap[soid])
end

-------------------------------------
-- function getSlimeList
-- @brief
-- 복사본을 리턴할까... 그냥 리턴할까...?
-------------------------------------
function ServerData_Slimes:getSlimeList()
    return clone(self.m_slimesObjectMap)
end

-------------------------------------
-- function possibleMaterialSlime
-- @brief
-------------------------------------
function ServerData_Slimes:possibleMaterialSlime(soid, tar_slime_type)
    local slime_object = self:getSlimeObject(soid)

    if (not slime_object) then
        return false, ''
    end

    -- 잠금 체크
	if (self:isLockSlime(soid)) then
		return false, Str('잠금 상태입니다.')
	end

	-- 슬라임 타입 없거나 all 이면 true
	if (tar_slime_type == nil) or (tar_slime_type == 'all') then
		return true
	end

	-- 슬라임 타입 체크
    local slime_type = slime_object:getSlimeType()
    if (slime_type == tar_slime_type) then
        return true
    end

    return false
end

-------------------------------------
-- function isLockSlime
-- @brief 잠금 여부 체크
-------------------------------------
function ServerData_Slimes:isLockSlime(soid)
    local slime_object = self:getSlimeObject(soid)

    if (not slime_object) then
        return false
    end

    return slime_object:getLock()
end