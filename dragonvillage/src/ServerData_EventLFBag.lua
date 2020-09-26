-------------------------------------
-- class ServerData_EventLFBag
-- g_eventLFBagData
-------------------------------------
ServerData_EventLFBag = class({
        m_structLFBag = 'StructEventLFBag',
        m_endTime = 'timestamp',

    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventLFBag:init()
    self.m_structLFBag = StructEventLFBag()
end

-------------------------------------
-- function getLFBag
-------------------------------------
function ServerData_EventLFBag:getLFBag()
    return self.m_structLFBag
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventLFBag:getStatusText()
    local curr_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData_EventLFBag:confirm_reward(ret)
    local item_info = ret['item_info'] or nil
    if (item_info) then
        UI_MailRewardPopup(item_info)
    else
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()
    end
end

-------------------------------------
-- function request_eventLFBagInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagInfo(include_reward, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        ccdump(ret)
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
-- function request_eventLFBagNext
-- @brief 이벤트 재화 사용
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagNext(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
	
    -- 콜백
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lucky_fortune_bag/next')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_eventLFBagStop
-- @brief 이벤트 재화 누적 보상
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagStop(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lucky_fortune_bag/stop')
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
function ServerData_EventLFBag:request_eventLFBagRank(offset, type, _rank_cnt, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 0
	local rank_cnt = _rank_cnt or 30

    -- 콜백 함수
    local function success_cb(ret)
        self.m_nGlobalOffset = ret['offset']

        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoArena:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
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