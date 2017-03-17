--[[
-- t_gacha_info 예시
{
      "price_type":"gold",
      "free_per_day":5,
      "category":"box_gacha",
      "price_value":1000,
      "free_time":0,
      "multi_price_value":0,
      "type":"box_normal",
      "free_per_cool":10,
      "multi_num":0,
      "free_cnt":0
    }
--]]

-------------------------------------
-- class ServerData_Gacha
-------------------------------------
ServerData_Gacha = class({
        m_serverData = 'ServerData',
        m_bDirtyGachaServerData = 'boolean',
        m_mGachaInfo = '',
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
	
	-- 남은 시간 계산
	local remain_time = self:getRemainGachaTime(type)
	if (remain_time > 0) then
		return false, 'cool', remain_time
	end

    return true
end

-------------------------------------
-- function canFreeGacha
-------------------------------------
function ServerData_Gacha:getRemainGachaTime(type)
    local t_gacha_info = self:getGachaInfo(type)

    -- 쿨타임 중일 경우
	if (t_gacha_info['free_time']) then
		local free_time = (t_gacha_info['free_time'] / 1000)
		local server_time = Timer:getServerTime()

		if ((free_time ~= 0) and (server_time < free_time)) then
			local remain_time = (free_time - server_time)
			return remain_time
		end
	end

    return 0
end

-------------------------------------
-- function request_friendPointGacha
-------------------------------------
function ServerData_Gacha:request_friendPointGacha(cb)
    local t_gacha_info = self:getGachaInfo('friend_normal')
    local fp = g_userData:get('fp')

    -- 우정포인트가 충분히 있는지 체크
    if (fp < t_gacha_info['price_value']) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('우정포인트가 부족합니다.'))
        return
    end

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
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_boxGachaNormal
-------------------------------------
function ServerData_Gacha:request_boxGachaNormal(is_gold, cb)
    local is_gold = is_gold and 1 or 0

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 공통 응답 처리
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 가챠 정보 갱신
        local t_gacha_info = ret['gacha_info']
        if t_gacha_info then
            local type = t_gacha_info['type']
            self.m_mGachaInfo[type] = t_gacha_info
        end

        if cb then
            cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/box/normal')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_gold', is_gold)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_boxGachaPremium
-------------------------------------
function ServerData_Gacha:request_boxGachaPremium(is_cash, cb)
    local is_cash = is_cash and 1 or 0

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 공통 응답 처리
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 가챠 정보 갱신
        local t_gacha_info = ret['gacha_info']
        if t_gacha_info then
            local type = t_gacha_info['type']
            self.m_mGachaInfo[type] = t_gacha_info
        end

        if cb then
            cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/box/premium')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end