-------------------------------------
-- class ServerData_EventLFBag
-- g_eventLFBagData
-------------------------------------
ServerData_EventLFBag = class({
        m_structLFBag = 'StructEventLFBag',

        m_myRanking = 'StructEventLFBagRanking',

        -- 랭킹 정보에 사용
        m_nGlobalOffset = 'number', -- 랭킹
        m_lGlobalRank = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventLFBag:init()
    self.m_structLFBag = StructEventLFBag()
    self.m_myRanking = StructEventLFBagRanking()
end

-------------------------------------
-- function getLFBag
-------------------------------------
function ServerData_EventLFBag:getLFBag()
    return self.m_structLFBag
end

-------------------------------------
-- function canOpenUI
-------------------------------------
function ServerData_EventLFBag:canOpenUI()
    return self:canPlay() or self:canReward()
end

-------------------------------------
-- function canPlay
-------------------------------------
function ServerData_EventLFBag:canPlay()
    return g_hotTimeData:isActiveEvent('event_lucky_fortune_bag')
end

-------------------------------------
-- function canReward
-------------------------------------
function ServerData_EventLFBag:canReward()
    return g_hotTimeData:isActiveEvent('event_lucky_fortune_bag_reward')
end

-------------------------------------
-------------------------------------
-- function request_eventLFBagInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagInfo(include_reward, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:response_eventLFBagInfo(ret['lucky_fortune_bag_info'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lucky_fortune_bag/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('reward', include_reward or false) -- 랭킹 보상 지급 여부
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_eventLFBagInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventLFBag:response_eventLFBagInfo(event_lfbag_info)
    if (event_lfbag_info == nil) then
        return
    end

    self.m_structLFBag:apply(event_lfbag_info)
end

-------------------------------------
-- function request_eventLFBagOpen
-- @brief 이벤트 재화 사용
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagOpen(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
	
    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        self:response_eventLFBagInfo(ret['lucky_fortune_bag_info'])
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lucky_fortune_bag/open')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_eventLFBagReward
-- @brief 이벤트 재화 누적 보상
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagReward(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        self:response_eventLFBagInfo(ret['lucky_fortune_bag_info'])
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lucky_fortune_bag/reward')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_eventLFBagRank
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagRank(type, offset, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 0
	local rank_cnt = 30

    -- 콜백 함수
    local function success_cb(ret)
        self.m_nGlobalOffset = ret['offset']

        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            table.insert(self.m_lGlobalRank, StructEventLFBagRanking():apply(v))
        end
        
        -- 플레이어 랭킹 정보 갱신
        if ret['my_info'] then
            self:refreshMyRanking(ret['my_info'], nil)
        end

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lucky_fortune_bag/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('offset', offset)
    ui_network:setParam('limit', rank_cnt)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function refreshMyRanking
-------------------------------------
function ServerData_EventLFBag:refreshMyRanking(t_my_info)
    self.m_myRanking:apply(t_my_info)
end