-------------------------------------
-- class ServerData_EventMatchCard
-------------------------------------
ServerData_EventMatchCard = class({
        m_boardInfo = 'table',
        m_endTime = 'time',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventMatchCard:init()
end

-------------------------------------
-- function request_eventInfo
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventMatchCard:request_eventInfo(finish_cb, fail_cb)
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
    ui_network:setUrl('/shop/match_card/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_playStart
-- @brief 게임 시작
-------------------------------------
function ServerData_EventMatchCard:request_playStart(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self.m_boardInfo = ret['board']

        if finish_cb then
            finish_cb()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/match_card/start')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_diceRoll
-- @brief 이벤트 재화 사용
-------------------------------------
function ServerData_EventMatchCard:request_diceRoll(finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
	
    -- 추가 주사위 사용 여부 지정 (골드로 일일 5회)
    local use_add_dice = false
    local curr_dice = self.m_diceInfo:getCurrDice()
    if (curr_dice <= 0) then -- 현재 주사위가 없을 경우
        if (not self.m_diceInfo:useAllAddDice()) then -- 추가 주사위 일일 횟수가 남아있을 경우
            use_add_dice = true
        end
    end

    -- 콜백
    local function success_cb(ret)
        self.m_diceInfo:apply(ret['dice_info'])
		g_serverData:networkCommonRespone(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/dice/roll')
    ui_network:setParam('uid', uid)
	ui_network:setParam('add_dice', use_add_dice)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_diceReward
-- @brief 이벤트 재화 누적 보상
-------------------------------------
function ServerData_EventMatchCard:request_diceReward(lap, finish_cb, fail_cb)
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
    ui_network:setUrl('/shop/dice/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('lap', lap)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end