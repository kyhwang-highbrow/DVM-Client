-------------------------------------
-- class ServerData_EventLFBag
-- g_eventLFBagData
-------------------------------------
ServerData_EventLFBag = class({
        m_structLFBag = 'StructEventLFBag',

        -- 시즌 보상 수령 시 사용
        m_lastInfo = '',
        m_lastInfoDaily = '',
        m_rewardInfo = '',
        m_rewardInfoDaily = '',

        -- 랭킹 정보에 사용
        m_nGlobalOffset = 'number', -- 랭킹
        m_lGlobalRank = 'list',
        m_myRanking = 'StructEventLFBagRanking',
        m_rankingRewardList = '',
        m_rankingRewardDailyList = '',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventLFBag:init()
end

-------------------------------------
-- function getLFBag
-------------------------------------
function ServerData_EventLFBag:getLFBag()
    return self.m_structLFBag
end

-------------------------------------
-- function addLFBag
-------------------------------------
function ServerData_EventLFBag:setLFBagCount(lfbag_count)
    if (not self:canPlay()) then
        return
    end
    if (not self.m_structLFBag) then
        return
    end

    self.m_structLFBag:setCount(lfbag_count)
end

-------------------------------------
-- function addLFBag
-------------------------------------
function ServerData_EventLFBag:addLFBag(lfbag_count)
    if (not self:canPlay()) then
        return
    end
    if (not self.m_structLFBag) then
        return
    end

    self.m_structLFBag:addCount(lfbag_count)
end

-------------------------------------
-- function isActive
-------------------------------------
function ServerData_EventLFBag:isActive()
    return self:canPlay() or self:canReward()
end

-------------------------------------
-- function canPlay
-- @brief canReawrd와 배타적임
-------------------------------------
function ServerData_EventLFBag:canPlay()
    return g_hotTimeData:isActiveEvent('event_lucky_fortune_bag')
end

-------------------------------------
-- function canReward
-- @brief canPlay와 배타적임
-------------------------------------
function ServerData_EventLFBag:canReward()
    return g_hotTimeData:isActiveEvent('event_lucky_fortune_bag_reward')
end

local mInit = false
-------------------------------------
-- function request_eventLFBagInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventLFBag:request_eventLFBagInfo(include_reward, include_tables, finish_cb, fail_cb)
    -- @mskim require 컨텐츠 별로 모아서 할 필요가 있다. 구조는 고민중
    if (not mInit) then
        mInit = true
        require('UI_EventLFBag')
        require('UI_EventLFBagNoticePopup')
        require('UI_EventLFBagRankingPopup')
        require('UI_EventLFBagRankingDailtyTab')
        require('UI_EventLFBagRankingTotalTab')
        require('UI_EventLFBagRankingRewardPopup')
        require('StructEventLFBag')
        require('StructEventLFBagRanking')
        require('TableEventLFBag')

        self.m_structLFBag = StructEventLFBag()
        self.m_myRanking = StructEventLFBagRanking()
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:response_eventLFBagInfo(ret['lucky_fortune_bag_info'])

        -- 보상이 들어왔을 경우 정보 저장, nil 여부로 보상 확인
        if (ret['lastinfo']) then
            self.m_lastInfo = StructEventLFBagRanking():apply(ret['lastinfo'])
        else
            self.m_lastInfo = nil
        end

        if (ret['lastinfo_daily']) then
            self.m_lastInfoDaily = StructEventLFBagRanking():apply(ret['lastinfo_daily'])
        else
            self.m_lastInfoDaily = nil
        end


        -- 보상 아이템 정보 들어왔을 경우 정보 저장, nil 여부로 보상 확인
        if (ret['reward_info']) then
            self.m_rewardInfo = ret['reward_info']
        else
            self.m_rewardInfo = nil
        end

        if (ret['reward_info_daily']) then
            self.m_rewardInfoDaily = ret['reward_info_daily']
        else
            self.m_rewardInfoDaily = nil
        end
        
        -- 보상정보 분류
        if (ret['table_lucky_fortune_bag_rank']) then
            local rewardData = ret['table_lucky_fortune_bag_rank']
            self.m_rankingRewardDailyList = {}
            self.m_rankingRewardList = {}

            for i, reward in ipairs(rewardData) do
                if (reward and reward['version']) then
                    if (string.find(reward['version'], 'daily')) then
                        -- 일일랭킹
                        table.insert(self.m_rankingRewardDailyList, reward)
                    else
                        -- 전체랭킹
                        table.insert(self.m_rankingRewardList, reward)
                    end
                end
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lucky_fortune_bag/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('reward', include_reward or false) -- 랭킹 보상 지급 여부
    ui_network:setParam('include_tables', include_tables) -- 보상 정보 추가 여부
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

    self.m_structLFBag.is_ceiling_exist = (event_lfbag_info['ceiling_count'] and event_lfbag_info['ceiling_max'])
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
        --g_serverData:receiveReward(ret)
        --[[
        if (ret['score_bonus'] and ret['lucky_fortune_bag_info']) then 
            if (ret['score'] and ret['lucky_fortune_bag_info']['score']) then 
                ret['lucky_fortune_bag_info']['score'] = tonumber(ret['lucky_fortune_bag_info']['score']) + tonumber(ret['score'])
            end
        end]]

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
        g_serverData:receiveReward(ret)

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
function ServerData_EventLFBag:request_eventLFBagRank(rank_type, offset, division, finish_cb, fail_cb)
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
    ui_network:setParam('type', rank_type)
    ui_network:setParam('division', division)
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

-------------------------------------
-- function openRankingPopupForLobby
-- @brief 로비에서 랭킹 팝업 바로 여는 경우 사용, 랭킹 보상이 있는지도 체크하여 출력한다.
-------------------------------------
function ServerData_EventLFBag:openRankingPopupForLobby()
    local function finish_cb()
        -- 랭킹 팝업
        UI_EventLFBagRankingPopup()
        self:tryShowRewardPopup()
    end

    self:request_eventLFBagInfo(true, false, finish_cb, nil)
end

-------------------------------------
-- function isHighlightRed
-- @brief 소원 구슬 일일/전체 랭킹 보상을 받기 위한 로직
-------------------------------------
function ServerData_EventLFBag:tryShowRewardPopup()
    local last_info = self.m_lastInfo
    local lastinfo_daily = self.m_lastInfoDaily
    local reward_info = self.m_rewardInfo
    local reward_info_daily = self.m_rewardInfoDaily

    if (last_info and reward_info) then
        -- 랭킹 보상 팝업
        UI_EventLFBagRankingRewardPopup(last_info, reward_info, false)
    end
    
    if (lastinfo_daily and reward_info_daily) then
        -- 일일랭킹 보상 팝업
        UI_EventLFBagRankingRewardPopup(lastinfo_daily, reward_info_daily, true)
    end
end

-------------------------------------
-- function isHighlightRed
-- @brief 빨간 느낌표 아이콘 출력 여부
-------------------------------------
function ServerData_EventLFBag:isHighlightRed()
    if (self.m_structLFBag == nil) then
        return false
    end
    
    -- 소원 구슬 없음
    if (self.m_structLFBag:isEmpty()) then
        return false
    end

    return true
end

-------------------------------------
-- function isCeilingExist
-- @brief 천장이 존재하는지
-------------------------------------
function ServerData_EventLFBag:isCeilingExist()
    return self.m_structLFBag:isCeilingExist()
end


-------------------------------------
-- function getTotalRankRewardList
-- @brief 전체랭킹 보상 테이블
-------------------------------------
function ServerData_EventLFBag:getTotalRankRewardList()
    return self.m_rankingRewardList
end

-------------------------------------
-- function isHighlightRed
-- @brief 일일랭킹 보상 테이블
-------------------------------------
function ServerData_EventLFBag:getDailyRankRewardList()
    return self.m_rankingRewardDailyList
end