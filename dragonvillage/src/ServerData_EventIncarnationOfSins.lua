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

    if (self.m_tMyRankInfo) then
        result = self.m_tMyRankInfo[type]['rank']
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

    if (self.m_tMyRankInfo) then
        result = self.m_tMyRankInfo[type]['score']
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

-------------------------------------
-- function request_EventIncarnationOfSinsAttrRanking
-- @brief 랭킹 정보를 요청하고, cb_func를 통해 랭킹 정보를 다룸
-- @param attr_type : 속성 (earth, water, fire, light, dark, all(다섯가지 속성 전부 조회), total(합산 점수))
-- @param search_type : 랭킹을 조회할 그룹 (world, clan, friend)
-- @param offset : 랭킹 리스트의 offset 값 (-1 : 내 랭킹 기준, 0 : 상위 랭킹 기준, 20 : 랭킹의 20번째부터 조회..) 
-- @param param_success_cb : 받은 데이터를 이용하여 처리할 콜백 함수
-- @param param_fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_EventIncarnationOfSins:request_EventIncarnationOfSinsAttrRanking(attr_type, search_type, offset, limit, param_success_cb, param_fail_cb)
    local uid = g_userData:get('uid')
    local attr = attr_type -- default : total
    local type = search_type -- default : world
    local offset = offset -- default : 0
    local limit = limit -- default : 20

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        self:response_eventIncarnationOfSinsInfo(ret)

        if param_success_cb then
            param_success_cb(ret)
        end
    end

    local function fail_cb(ret)
        if param_fail_cb then
            param_fail_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/incarnation_of_sins/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('attr', attr) 
    ui_network:setParam('type', type)
    ui_network:setParam('offset', offset)
    ui_network:setParam('limit', limit)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()
end