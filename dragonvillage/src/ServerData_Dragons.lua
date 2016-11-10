-------------------------------------
-- class ServerData_Dragons
-------------------------------------
ServerData_Dragons = class({
        m_serverData = 'ServerData',
        m_leaderDragonOdid = 'string', -- 리더 드래곤의 obejct id
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Dragons:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Dragons:get(key)
    return self.m_serverData:get('dragons', key)
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Dragons:get(key)
    return self.m_serverData:get('dragons', key)
end

-------------------------------------
-- function getDragonsList
-------------------------------------
function ServerData_Dragons:getDragonsList()
    local l_dragons = self.m_serverData:get('dragons')

    local l_ret = {}
    for _,v in pairs(l_dragons) do
        local unique_id = v['id']
        l_ret[unique_id] = clone(v)
    end

    return l_ret
end

-------------------------------------
-- function getDragonDataFromUid
-- @brief unique id로 드래곤 정보를 얻음
-------------------------------------
function ServerData_Dragons:getDragonDataFromUid(unique_id)
    local l_dragons = self.m_serverData:get('dragons')

    for _,v in pairs(l_dragons) do
        if (unique_id == v['id']) then
            return clone(v)
        end
    end

    return nil
end

-------------------------------------
-- function applyDragonData
-- @brief
-------------------------------------
function ServerData_Dragons:applyDragonData(t_dragon)
    local l_dragons = self.m_serverData:get('dragons')
    local unique_id = t_dragon['id']

    local idx = nil

    for i,v in pairs(l_dragons) do
        if (unique_id == v['id']) then
            idx = i
            break
        end
    end

    -- 기존에 있는 드래곤이면 갱신
    if idx then
        self.m_serverData:applyServerData(t_dragon, 'dragons', idx)
    -- 기존에 없던 드래곤이면 추가
    else
        self.m_serverData:applyServerData(t_dragon, 'dragons', #l_dragons + 1)
    end
end

-------------------------------------
-- function delDragonData
-- @brief
-------------------------------------
function ServerData_Dragons:delDragonData(dragon_object_id)
    local l_dragons = self.m_serverData:get('dragons')

    local idx = nil

    for i,v in pairs(l_dragons) do
        if (dragon_object_id == v['id']) then
            idx = i
            break
        end
    end

    if idx then
        self.m_serverData:applyServerData(nil, 'dragons', idx)
    end
end

-------------------------------------
-- function getLeaderDragon
-- @brief 리더드래곤의 정보를 얻어옴
-------------------------------------
function ServerData_Dragons:getLeaderDragon()
    
    -- 서버에서 넘어온 드래곤 리스트에서 리더를 찾음
    if (not self.m_leaderDragonOdid) then
        local l_dragons = self.m_serverData:get('dragons')
        for i,v in pairs(l_dragons) do
            if v['leader'] then
                self.m_leaderDragonOdid = v['id']
                break
            end
        end
    end

    -- 서버에서 넘어온 드래곤 리스트에서 리더를 찾음
    if (not self.m_leaderDragonOdid) then
        local l_dragons = self.m_serverData:get('dragons')
        if l_dragons[1] then
            self.m_leaderDragonOdid = l_dragons[1]['id']
        end
    end

    -- 드래곤 데이터를 리턴
    if self.m_leaderDragonOdid then
        local t_dragon_data = self:getDragonDataFromUid(self.m_leaderDragonOdid)


        if t_dragon_data then
            -- 로컬 데이터 변경
            t_dragon_data['leader'] = true
            self:applyDragonData(t_dragon_data)

            return t_dragon_data
        end
    end

    -- 아무것도 아닌 경우 새로운 리더를 지정
    do
        self.m_leaderDragonOdid = nil
        local l_dragon = self:getDragonsList()
        for doid,_ in pairs(l_dragon) do
            self.m_leaderDragonOdid = doid
            break
        end

        -- 드래곤 데이터를 리턴
        if self.m_leaderDragonOdid then
            local t_dragon_data = self:getDragonDataFromUid(self.m_leaderDragonOdid)

            if t_dragon_data then
                -- 로컬 데이터 변경
                t_dragon_data['leader'] = true
                self:applyDragonData(t_dragon_data)

                return t_dragon_data
            end
        end
    end

    return nil
end

-------------------------------------
-- function setLeaderDragon
-- @brief 리더드래곤 설정
-------------------------------------
function ServerData_Dragons:setLeaderDragon(doid)
    if (self.m_leaderDragonOdid) then
        local t_dragon_data = self:getDragonDataFromUid(self.m_leaderDragonOdid)
        t_dragon_data['leader'] = false
        self:applyDragonData(t_dragon_data)
    end

    self.m_leaderDragonOdid = doid
    if (self.m_leaderDragonOdid) then
        local t_dragon_data = self:getDragonDataFromUid(self.m_leaderDragonOdid)

        -- 로컬 데이터 변경
        t_dragon_data['leader'] = true
        self:applyDragonData(t_dragon_data)
    end
end

-------------------------------------
-- function getNumberOfRemainingSkillLevel
-- @brief 남은 드래곤 스킬 레벨 갯수 리턴
-------------------------------------
function ServerData_Dragons:getNumberOfRemainingSkillLevel(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    local skill_0 = (t_dragon_data['skill_0'] or 0) -- 최대 10
    local skill_1 = (t_dragon_data['skill_1'] or 0) -- 최대 10
    local skill_2 = (t_dragon_data['skill_2'] or 0) -- 최대 10
    local skill_3 = (t_dragon_data['skill_3'] or 0) -- 최대 1

    local total_skill_level = (skill_0 + skill_1 + skill_2 + skill_3)
    local num_of_remain_skill_level = (31 - total_skill_level)

    return num_of_remain_skill_level
end

-------------------------------------
-- function isSameTypeDragon
-- @brief 드래곤들의 원종(dragon 테이블의 type컬럼)이 같은지 확인
-------------------------------------
function ServerData_Dragons:isSameTypeDragon(doid1, doid2)
    local table_dragon = TABLE:get('dragon')
    
    local t_dragon_data_1 = self:getDragonDataFromUid(doid1)
    local t_dragon_data_2 = self:getDragonDataFromUid(doid2)

    local did_1 = t_dragon_data_1['did']
    local did_2 = t_dragon_data_2['did']

    local t_dragon_1 = table_dragon[did_1]
    local t_dragon_2 = table_dragon[did_2]

    local is_same_type = (t_dragon_1['type'] == t_dragon_2['type'])

    return is_same_type
end



T_DRAGON_SORT = {}

T_DRAGON_SORT['normal'] = function(a, b)
    local t_data_a = a['data']
    local t_data_b = b['data']
    
    if (t_data_a['did'] > t_data_b['did']) then
        return true
    elseif (t_data_a['did'] < t_data_b['did']) then
        return false
    end

    return false
end

T_DRAGON_SORT['lv'] = function(a, b)
    local t_data_a = a['data']
    local t_data_b = b['data']
    
    if (t_data_a['lv'] > t_data_b['lv']) then
        return true
    elseif (t_data_a['lv'] < t_data_b['lv']) then
        return false
    end

    

    return false
end