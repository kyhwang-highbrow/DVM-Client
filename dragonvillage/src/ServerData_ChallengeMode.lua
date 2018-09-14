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
-- function request_ancientTowerInfo
-- @brief
-------------------------------------
function ServerData_ChallengeMode:request_ancientTowerInfo(stage_id, finish_cb, fail_cb)
    -- 임시로 바로 호출
    finish_cb()
end
