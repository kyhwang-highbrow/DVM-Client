-------------------------------------
-- class ServerData_ChallengeMode
-------------------------------------
ServerData_ChallengeMode = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ChallengeMode:init(server_data)
end


-------------------------------------
-- function isActive_challengeMode
-- @brief 챌린지 모드 이벤트가 진행 중인지 여부 true or false
-------------------------------------
function ServerData_ChallengeMode:isActive_challengeMode()
    -- 임시로 오픈
    return true
end


-------------------------------------
-- function request_challengeModeInfo
-- @brief 챌린지 모드(그림자의 신전) info 요청
-------------------------------------
function ServerData_ChallengeMode:request_challengeModeInfo(stage_id, finish_cb, fail_cb)
    -- 임시로 바로 호출
    finish_cb()
end

-------------------------------------
-- function request_challengeModeStart
-- @brief 챌린지 모드(그림자의 신전) 게임 시작 통신
-------------------------------------
function ServerData_ChallengeMode:request_challengeModeStart(finish_cb, fail_cb)
    if true then
        finish_cb()
        return
    end


    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 공격자의 콜로세움 전투력 저장
    --local combat_power = g_arenaData.m_playerUserInfo:getDeckCombatPower(true)
    local combat_power = 0
    
    -- 성공 콜백
    local function success_cb(ret)
        -- 상대방 정보 여기서 설정
        if (ret['match_user']) then
            --self:makeMatchUserInfo(ret['match_user'])
        else
            --error('콜로세움 상대방 정보 없음')
        end

        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)

        self.m_gameKey = ret['gamekey']
        --vs_dragons
        --vs_runes
        --vs_deck
        --vs_info

        -- 실제 플레이 시간 로그를 위해 체크 타임 보냄
        g_accessTimeData:startCheckTimer()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        --[[
        if (ret['status'] == -1108) then
            -- 비슷한 티어 매칭 상대가 없는 상태
            -- 콜로세움 UI로 이동
            local function ok_cb()
                UINavigator:goTo('arena')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('현재 점수 구간 내의 대전 가능한 상대가 없습니다.\n다른 상대의 콜로세움 참여를 기다린 후에 다시 시도해 주세요.'), ok_cb)
            return true
        end
        --]]

        return false
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/challenge/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('token', self:makeDragonToken())
    ui_network:setParam('team_bonus', self:getTeamBonusIds())
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end