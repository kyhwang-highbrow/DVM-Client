
local T_DRAGON_PREMIUM_MILEAGE = {}
T_DRAGON_PREMIUM_MILEAGE['mileage'] = 0
T_DRAGON_PREMIUM_MILEAGE['reward_20'] = 703004 -- item_id
T_DRAGON_PREMIUM_MILEAGE['reward_50'] = 703005
T_DRAGON_PREMIUM_MILEAGE['reward_150'] = 703006

-------------------------------------
-- class ServerData_Gacha
-------------------------------------
ServerData_Gacha = class({
        m_serverData = 'ServerData',
        m_bDirtyGachaServerData = 'boolean',
        m_mGachaInfo = '',
        m_dragonPremiumMileage = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Gacha:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyGachaServerData = true
end

-------------------------------------
-- function refresh_gachaInfo
-------------------------------------
function ServerData_Gacha:refresh_gachaInfo(cb)
    if self.m_bDirtyGachaServerData then
        self:request_gachaInfo(cb)
    else
        cb()
    end
end

-------------------------------------
-- function request_gachaInfo
-------------------------------------
function ServerData_Gacha:request_gachaInfo(cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_gachaInfo(ret)

        if cb then
            cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/gacha/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_gachaInfo
-------------------------------------
function ServerData_Gacha:response_gachaInfo(ret)
    -- 가챠 정보들 맵 형태로 저장
    self.m_mGachaInfo = {}
    for i,v in ipairs(ret['gacha_list']) do
        local type = v['type']
        self.m_mGachaInfo[type] = v
    end

    -- 드래곤 프리미엄 소환 마일리지 정보 갱신
    self.m_dragonPremiumMileage = clone(T_DRAGON_PREMIUM_MILEAGE)
    self.m_dragonPremiumMileage['mileage'] = ret['mileage']
    self.m_dragonPremiumMileage['reward_20'] = ret['reward_20']
    self.m_dragonPremiumMileage['reward_50'] = ret['reward_50']
    self.m_dragonPremiumMileage['reward_150'] = ret['reward_150']

    self.m_bDirtyGachaServerData = false
end

-------------------------------------
-- function getGachaInfo
-------------------------------------
function ServerData_Gacha:getGachaInfo(type)
    return self.m_mGachaInfo[type]
end

-------------------------------------
-- function canFreeGacha
-------------------------------------
function ServerData_Gacha:canFreeGacha(type)
    local t_gacha_info = self:getGachaInfo(type)

    -- 하루 뽑기 가능 횟수 초과
    if (t_gacha_info['free_per_day'] <= t_gacha_info['free_cnt']) then
        return false, 'max'
    end

    -- 쿨타임 중일 경우
    local free_time = (t_gacha_info['free_time'] / 1000)
    local server_time = Timer:getServerTime()

    if ((free_time ~= 0) and (server_time < free_time)) then
        local remain_time = (free_time - server_time)
        return false, 'cool', remain_time
    end
end

-------------------------------------
-- function request_friendPointGacha
-------------------------------------
function ServerData_Gacha:request_friendPointGacha(cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 받은 아이템 처리
        g_serverData:networkCommonRespone_addedItems(ret)

        if cb then
            cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/box/fpoint')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end