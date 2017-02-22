-------------------------------------
-- class ServerData_User
-------------------------------------
ServerData_User = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_User:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_User:get(...)
    return self.m_serverData:get('user', ...)
end

-------------------------------------
-- function getRef
-------------------------------------
function ServerData_User:getRef(...)
    return self.m_serverData:getRef('user', ...)
end

-------------------------------------
-- function applyServerData
-------------------------------------
function ServerData_User:applyServerData(data, ...)
    return self.m_serverData:applyServerData(data, 'user', ...)
end

-------------------------------------
-- function getFruitList
-- @brief 보유중인 열매 리스트 리턴(인벤토리에서 사용)
-------------------------------------
function ServerData_User:getFruitList()
    local l_fruis = self:getRef('fruits')

    -- key가 item_id(=fruit_id)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_fruis) do
        local fruit_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['fid'] = fruit_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function getFruitCount
-- @brief 보유중인 열매 갯수 리턴
-------------------------------------
function ServerData_User:getFruitCount(fruit_id)
    local fruit_id = tostring(fruit_id)
    local count = self:get('fruits', fruit_id) or 0
    return count
end

-------------------------------------
-- function getResetFruitCount
-- @brief 망각의 열매 갯수 리턴
-------------------------------------
function ServerData_User:getResetFruitCount()
    local fruit_id = self:getResetFruitID()
    return self:getFruitCount(fruit_id)
end

-------------------------------------
-- function getResetFruitID
-- @brief 망각의 열매 ID
-------------------------------------
function ServerData_User:getResetFruitID()
    -- 망각의 열매 id : 702009
    return 702009
end

-------------------------------------
-- function getEvolutionStoneList
-- @brief 보유중인 진화석 리스트 리턴(인벤토리에서 사용)
-------------------------------------
function ServerData_User:getEvolutionStoneList()
    local l_evolution_stone = self:getRef('evolution_stones')

    -- key가 item_id(=esid)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_evolution_stone) do
        local evolution_stone_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['esid'] = evolution_stone_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function getEvolutionStoneCount
-- @brief 보유중인 진화재료 갯수 리턴
-------------------------------------
function ServerData_User:getEvolutionStoneCount(evolution_stone_id)
    local evolution_stone_id = tostring(evolution_stone_id)
    local count = self:get('evolution_stones', evolution_stone_id) or 0
    return count
end

-------------------------------------
-- function getUserLevelInfo
-- @brief
-------------------------------------
function ServerData_User:getUserLevelInfo()
    local table_user_level = TableUserLevel()

    local lv = g_userData:get('lv')
    local exp = g_userData:get('exp')
    local percentage = table_user_level:getUserLevelExpPercentage(lv, exp)

    return lv, exp, percentage
end

-------------------------------------
-- function getFruitPackCount
-- @brief 인벤에서 슬롯을 차지하는 열매 갯수
-------------------------------------
function ServerData_User:getFruitPackCount()
    local l_evolution_stone = self:getRef('fruits')

    local count = 0
    for i,v in pairs(l_evolution_stone) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function getEvolutionStonePackCount
-- @brief 인벤에서 슬롯을 차지하는 진화석 갯수
-------------------------------------
function ServerData_User:getEvolutionStonePackCount()
    local l_evolution_stone = self:getRef('evolution_stones')

    local count = 0
    for i,v in pairs(l_evolution_stone) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function getTamerInfo
-- @brief 테이머 정보
-------------------------------------
function ServerData_User:getTamerInfo()
	local t_tamer = self:getRef('tamer')
	if (t_tamer == 0) then
		local rand_idx = math_random(1, 6)
		t_tamer = L_TAMER_LIST[1]
	end
    return t_tamer
end

-- table_tamer가 나중에 대체할것
L_TAMER_LIST = {
	{tmid = 100001, res = 'res/character/tamer/goni_i/goni_i.spine', res_sd = 'res/character/tamer/goni/goni.spine', res_icon = 'res/ui/icon/cha/tamer_goni.png', t_name = '고니', t_desc = '고니는 남자아이이다.', b_obtain = true},
	{tmid = 100002, res = 'res/character/tamer/nuri_i/nuri_i.spine', res_sd = 'res/character/tamer/nuri/nuri.spine', res_icon = 'res/ui/icon/cha/tamer_nuri.png', t_name = '누리', t_desc = '누리는 여자아이이다.', b_obtain = true},
	{tmid = 100003, res = 'res/character/tamer/leon_i/leon_i.spine', res_sd = 'res/character/tamer/leon/leon.spine', res_icon = 'res/ui/icon/cha/tamer_mokoji.png', t_name = '레온', t_desc = '레온은 지금 존재하지 않는다.', b_obtain = true},
	{tmid = 100004, res = 'res/character/tamer/goni_i/goni_i.spine', res_sd = 'res/character/tamer/goni/goni.spine', res_icon = 'res/ui/icon/cha/tamer_durun.png', t_name = '고니2', t_desc = '고니2는 고니의 반복이다.', b_obtain = false},
	{tmid = 100005, res = 'res/character/tamer/nuri_i/nuri_i.spine', res_sd = 'res/character/tamer/nuri/nuri.spine', res_icon = 'res/ui/icon/cha/tamer_kesath.png', t_name = '누리2', t_desc = '누리2는 누리의 반복이다.', b_obtain = false},
	{tmid = 100006, res = 'res/character/tamer/leon_i/leon_i.spine', res_sd = 'res/character/tamer/dede/dede.spine', res_icon = 'res/ui/icon/cha/tamer_dede.png', t_name = '데데', t_desc = '데데지만 레온이다.', b_obtain = true},
}
