-------------------------------------
-- class ServerData_EventIncarnationOfSins
-- g_eventIncarnationOfSinsData
-------------------------------------
ServerData_EventIncarnationOfSins = class({
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
function ServerData_EventIncarnationOfSins:getMyRank()
    -- TODO : 구현을 해야한다.
    return -1
end

-------------------------------------
-- function getMyScore
-- @brief 내 랭킹점수 받아오기
-------------------------------------
function ServerData_EventIncarnationOfSins:getMyScore()
    -- TODO : 구현을 해야한다.
    return -1
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
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventIncarnationOfSins:request_eventIncarnationOfSinsInfo(include_reward, finish_cb, fail_cb)
    
    if (not mInit) then
        mInit = true
        require('UI_EventIncarnationOfSins')
        require('UI_EventIncarnationOfSinsFullPopup')
        require('UI_EventIncarnationOfSinsEntryPopup')
        require('UI_EventIncarnationOfSinsRankingPopup')
        require('UI_EventIncarnationOfSinsRankingTotalTab')
        require('UI_EventIncarnationOfSinsRankingAttributeTab')
        require('UI_BannerIncarnationOfSins')

    end

     -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        -- TODO
            
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    -- local ui_network = UI_Network()
    -- ui_network:setUrl('/shop/event_incarnation_of_sins/info')
    -- ui_network:setParam('uid', uid)
    -- ui_network:setParam('reward', include_reward or false) -- 랭킹 보상 지급 여부
    -- ui_network:setSuccessCB(success_cb)
	-- ui_network:setFailCB(fail_cb)
    -- ui_network:setRevocable(true)
    -- ui_network:setReuse(false)
	-- ui_network:hideBGLayerColor()
    -- ui_network:request()

    -- 서버 통신 구현될때까지 임시
    success_cb()

    return ui_network
end