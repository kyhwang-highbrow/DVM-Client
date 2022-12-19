-- @inherit ServerData_Base
local DATA_KEY = { DAILY_CNT = 'daily_roulette_cnt', LAST_ROLLED_AT = 'last_roulette_rolled_at' }
-------------------------------------
---@class ServerData_Roulette
-------------------------------------
ServerData_Roulette = class({
    m_serverData = 'ServerData',

    daily_roulette_cnt = 'number',
    last_roulette_rolled_at = 'number'
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_Roulette:init()
    self.m_serverData = ServerData:getInstance()
    self.daily_roulette_cnt = 0
    self.last_roulette_rolled_at = 0
end

local instance = nil

-------------------------------------
-- function getInstance
---@return ServerData_Roulette
-------------------------------------
function ServerData_Roulette:getInstance()
    if (instance == nil) then
        instance = ServerData_Roulette()
    end

    return instance
end

-------------------------------------
-- function showAdRoulettePopup
-- @brief 광고 보기 룰렛 팝업 노출
-------------------------------------
function ServerData_Roulette:showAdRoulettePopup(ad_type, finish_cb)
    PerpleSdkManager.getCrashlytics():setLog('showAdvPopup_0')

	-- -- 광고 비활성화 시
	-- if (AdSDKSelector:isAdInactive()) then
	-- 	AdSDKSelector:makePopupAdInactive()
	-- 	return
	-- end

    local function show_popup()
        PerpleSdkManager.getCrashlytics():setLog('showAdvPopup_1')
        local ui = UI_AdsRoulettePopup()
        if (finish_cb) then
            ui:setCloseCB(finish_cb)
        end
    end
    
    if (ad_type == AD_TYPE.RANDOM_BOX_LOBBY) then
        -- 보상 정보 있다면 호출 x
        show_popup()
    elseif (ad_type == AD_TYPE.NONE) then
        show_popup()
    end
end

-------------------------------------
-- function getServerDataName
-------------------------------------
function ServerData_Roulette:getServerDataName()
    return 'ServerData_Roulette'
end

-------------------------------------
-- function getDailyCount
-------------------------------------
function ServerData_Roulette:getDailyCount()
    return self.daily_roulette_cnt
end

-------------------------------------
-- function getLastRollTimestamp
-------------------------------------
function ServerData_Roulette:getLastRollTimestamp()
    return self.last_roulette_rolled_at
end

-------------------------------------
-- function isFirstRoll
-------------------------------------
function ServerData_Roulette:isFirstRoll()
    return self.daily_roulette_cnt == 0
end

-------------------------------------
-- function isAvailableRoulette
-------------------------------------
function ServerData_Roulette:isAvailableRoulette()

    -- local daily_max_count = TableBalanceConfig:getInstance():getBalanceConfigValue('max_roulette_cnt')
    local daily_max_count = 10
    local cur_count       = self:getDailyCount()
    if (daily_max_count <= cur_count) then
        return false
    end

    local cur_time_msd = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local delta_time_ms = cur_time_msd - self:getLastRollTimestamp()

    -- local term_sec = TableBalanceConfig:getInstance():getBalanceConfigValue('roulette_term')
    local term_sec = 5
    local term_ms = term_sec * 60000
    return term_ms < delta_time_ms
end

-------------------------------------
-- function applyResponse
-------------------------------------
function ServerData_Roulette:applyResponse(ret)
    local info = ret['roulette_info']
    if (info ~= nil) then
        self:applyTableData(info)
        self:setUpdateTimeForData()
    end
end

--#region Request

-------------------------------------
-- function request_rouletteInfo
-- @breif 룰렛 정보 요청
---@param success_cb? function
---@param fail_cb? function
---@param status_cb? function
-------------------------------------
function ServerData_Roulette:request_rouletteInfo(success_cb, fail_cb, status_cb)
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function _success_cb(ret)

        -- -- 공통 데이터 갱신
        -- ServerData:getInstance():applyCommonResponse(ret)
        self:applyResponse(ret)

        if success_cb then
            success_cb(ret)
        end
    end

    -- 실패 콜백
    local _fail_cb = fail_cb

    -- 성공 이외의 상태 처리
    -- (true를 리턴하면 임의 처리를 완료했다는 의미)
    local _status_cb = status_cb

    -- 네트워크 통신
    local ui_network = UI_Network()
    --ui_network:setSuccessCBDelayTime(1) -- 로그인 레이턴시 강제로 조정 (개발 중에 통신 중임을 확인하기 위함)
    ui_network:hideBGLayerColor() -- 배경에 어두은 음영 숨김
    ui_network:setLoadingMsg(Str('통신 중 ...')) -- 메세지
    ui_network:setUrl('/shop/randombox_info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(_success_cb)
    ui_network:setResponseStatusCB(_status_cb)
    ui_network:setFailCB(_fail_cb)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_rouletteRoll
-- @breif 룰렛 돌리기 요청
---@param success_cb? function
---@param fail_cb? function
---@param status_cb? function
-------------------------------------
function ServerData_Roulette:request_rouletteRoll(ad_network, log, success_cb, fail_cb, status_cb)
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function _success_cb(ret)

        -- 공통 데이터 갱신
        -- g_serverData:applyCommonResponse(ret)
        self:applyResponse(ret)

        if success_cb then
            success_cb(ret)
        end
    end

    -- 실패 콜백
    local _fail_cb = fail_cb

    -- 성공 이외의 상태 처리
    -- (true를 리턴하면 임의 처리를 완료했다는 의미)
    local _status_cb = status_cb

    -- 네트워크 통신
    local ui_network = UI_Network()
    --ui_network:setSuccessCBDelayTime(1) -- 로그인 레이턴시 강제로 조정 (개발 중에 통신 중임을 확인하기 위함)
    ui_network:hideBGLayerColor() -- 배경에 어두은 음영 숨김
    ui_network:setLoadingMsg(Str('통신 중 ...')) -- 메세지
    ui_network:setUrl('/users/lobby/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('ad_network', ad_network)
    ui_network:setParam('log', log)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(_success_cb)
    ui_network:setResponseStatusCB(_status_cb)
    ui_network:setFailCB(_fail_cb)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_resetRouletteInfo
-- @breif 룰렛 돌리기 요청
---@param roll_count? number
---@param last_roll_at? number
---@param success_cb? function
---@param fail_cb? function
---@param status_cb? function
---@return UI_Network
-------------------------------------
function ServerData_Roulette:request_resetRouletteInfo(roll_count, last_roll_at, success_cb, fail_cb, status_cb)
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function _success_cb(ret)

       -- 공통 데이터 갱신
       g_serverData:applyCommonResponse(ret)
        self:applyResponse(ret)

        if success_cb then
            success_cb(ret)
        end
    end

    -- 실패 콜백
    local _fail_cb = fail_cb

    -- 성공 이외의 상태 처리
    -- (true를 리턴하면 임의 처리를 완료했다는 의미)
    local _status_cb = status_cb

    -- 네트워크 통신
    local ui_network = UI_Network()
    --ui_network:setSuccessCBDelayTime(1) -- 로그인 레이턴시 강제로 조정 (개발 중에 통신 중임을 확인하기 위함)
    ui_network:hideBGLayerColor() -- 배경에 어두은 음영 숨김
    ui_network:setLoadingMsg(Str('통신 중 ...')) -- 메세지
    ui_network:setUrl('manage/reset_roulette_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('daily_roll_cnt', roll_count)
    ui_network:setParam('last_rolled_at', last_roll_at)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(_success_cb)
    ui_network:setResponseStatusCB(_status_cb)
    ui_network:setFailCB(_fail_cb)
    ui_network:request()

    return ui_network
end

--#endregion
