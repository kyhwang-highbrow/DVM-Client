-------------------------------------
-- class ServerData_AdventureFirstReward
-- @brief 스테이지 최초 클리어 보상
--        ServerData_Adventure에 의존된 데이터
-------------------------------------
ServerData_AdventureFirstReward = class({
        m_serverData = 'ServerData',
        m_firstRewardDataTable = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AdventureFirstReward:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function organizeFirstRewardDataTable
-------------------------------------
function ServerData_AdventureFirstReward:organizeFirstRewardDataTable(first_reward_list)
    self.m_firstRewardDataTable = table.listToMap(first_reward_list, 'stage_id')
end

-------------------------------------
-- function getFirstRewardInfo
-------------------------------------
function ServerData_AdventureFirstReward:getFirstRewardInfo(stage_id)
    return self.m_firstRewardDataTable[stage_id]
end

-------------------------------------
-- function request_firstClearReward
-------------------------------------
function ServerData_AdventureFirstReward:request_firstClearReward(stage_id, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        local desc = string.format('모험 달성도 : %d', stage_id)
        Analytics:trackGetGoodsWithRet(ret, desc)

        -- 아이템 수령
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 챕터 정보 갱신
        g_adventureData:organizeStageList_modified(ret['modified_stage'])

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/clear/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

