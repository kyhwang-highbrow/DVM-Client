-------------------------------------
-- class ServerData_EventIncarnationOfSins
-- g_eventIncarnationOfSinsData
-------------------------------------
ServerData_EventIncarnationOfSins = class({
        m_tMyRankInfo = 'table', -- 속성별 자신의 순위 정보가 들어있음 (light, dark, fire, water, earth, total(전체순위))
        m_rewardStatus = 'number', -- 보상 받았는지 상태 저장
    })

-------------------------------------
-- function canPlay
-- @brief canReawrd와 배타적임
-------------------------------------
function ServerData_EventIncarnationOfSins:canPlay()
    return g_hotTimeData:isActiveEvent('event_incarnation_of_sins')
end

-------------------------------------
-- function canReward
-- @brief canPlay와 배타적임
-------------------------------------
function ServerData_EventIncarnationOfSins:canReward()
    return g_hotTimeData:isActiveEvent('event_incarnation_of_sins_reward')
end

-------------------------------------
-- function getMyRank
-- @brief 내 랭킹 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getMyRank(type)
    type = (type or 'total')
    
    local result = -1

    if (m_tMyRankInfo) then
        result = m_tMyRankInfo[type]['rank']
    end

    return result
end

-------------------------------------
-- function getMyScore
-- @brief 내 랭킹점수 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getMyScore(type)
    type = (type or 'total')    

    local result = -1

    if (m_tMyRankInfo) then
        result = m_tMyRankInfo[type]['score']
    end

    return result
end

-------------------------------------
-- function getRemainTimeString
-- @brief 이벤트 남은시간 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getRemainTimeString()
    -- TODO : 구현을 해야한다.
    return g_hotTimeData:getEventRemainTimeTextDetail('event_incarnation_of_sins') or ''
end

-------------------------------------
-- function isOpenAttr
-- @brief 해당 속성이 현재 열려있는지 판단
-------------------------------------
function ServerData_EventIncarnationOfSins:isOpenAttr(attr)
    -- TODO : 구현을 해야한다.
    
    return true
end

local mInit = false
-------------------------------------
-- function request_eventIncarnationOfSinsInfo
-- @brief 이벤트 정보를 요청
-- @param include_reward : 이벤트 랭킹 보상을 받을지 여부
-------------------------------------
function ServerData_EventIncarnationOfSins:request_eventIncarnationOfSinsInfo(include_reward, finish_cb, fail_cb)
    
    local uid = g_userData:get('uid')
    local include_tables = false
    local include_reward = include_reward or false

    -- 맨 처음 한번만 require
    if (not mInit) then
        mInit = true
        require('UI_EventIncarnationOfSins')
        require('UI_EventIncarnationOfSinsFullPopup')
        require('UI_EventIncarnationOfSinsEntryPopup')
        require('UI_EventIncarnationOfSinsRankingPopup')
        require('UI_EventIncarnationOfSinsRankingTotalTab')
        require('UI_EventIncarnationOfSinsRankingAttributeTab')
        require('UI_BannerIncarnationOfSins')
        include_tables = true
    end

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        self:response_eventIncarnationOfSinsInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    local function fail_cb(ret)
    end

    -- 네트워크 통신
     local ui_network = UI_Network()
     ui_network:setUrl('/shop/incarnation_of_sins/info')
     ui_network:setParam('uid', uid)
     ui_network:setParam('include_tables', include_tables) -- 정보 관련 테이블 내려받을지 여부 
     ui_network:setParam('reward', include_reward) -- 랭킹 보상 지급 여부
     ui_network:setSuccessCB(success_cb)
	 ui_network:setFailCB(fail_cb)
     ui_network:setRevocable(true)
     ui_network:setReuse(false)
	 ui_network:hideBGLayerColor()
     ui_network:request()
end

-------------------------------------
-- function response_eventIncarnationOfSinsInfo
-------------------------------------
function ServerData_EventIncarnationOfSins:response_eventIncarnationOfSinsInfo(ret)
    if (ret['rankinfo']) then
        self.m_tMyRankInfo = ret['rankinfo']
    end
    
    if (ret['reward']) then
        self.m_rewardStatus = ret['reward']
    end 
end