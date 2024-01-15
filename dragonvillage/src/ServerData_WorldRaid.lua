-------------------------------------
--- @class ServerData_WorldRaid
-- g_worldRaidData
-------------------------------------
ServerData_WorldRaid = class({
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_WorldRaid:init()
end

-------------------------------------
--- @function isAvailableWorldRaid
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaid()
    return true --g_hotTimeData:isActiveEvent('world_raid')
end


-------------------------------------
--- @function getCurrentRankingList
-------------------------------------
function ServerData_WorldRaid:getCurrentRankingList()
    return {}
end

-------------------------------------
--- @function getCurrentMyRanking
-------------------------------------
function ServerData_WorldRaid:getCurrentMyRanking()
    return {}
end

-------------------------------------
--- @function getWorldRaidId
-------------------------------------
function ServerData_WorldRaid:getWorldRaidId()
    return 1001
end

-------------------------------------
--- @function getWorldRaidStageId
-------------------------------------
function ServerData_WorldRaid:getWorldRaidStageId()
    local world_raid_id = self:getWorldRaidId()
    return TableWorldRaidInfo:getInstance():getWorldRaidStageId(world_raid_id)
end

-------------------------------------
--- @function getRemainTimeString
-------------------------------------
function ServerData_WorldRaid:getRemainTimeString()
    local time = g_hotTimeData:getEventRemainTime('world_raid') or 0
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
end


-------------------------------------
--- @function getWorldRaidStageMode
-------------------------------------
function ServerData_WorldRaid:getWorldRaidStageMode(stage_id)
    return (stage_id % 10)
end

-------------------------------------
--- @function getWorldRaidBuff
-------------------------------------
function ServerData_WorldRaid:getWorldRaidBuff()
    local world_raid_id = self:getWorldRaidId()
    local buff_key = TableWorldRaidInfo:getInstance():getBuffKey(world_raid_id)
    local bonus_str, map_attr = TableContentAttr:getInstance():getBonusInfo(buff_key, true)
    return bonus_str, map_attr
end

-------------------------------------
--- @function getWorldRaidDebuff
-------------------------------------
function ServerData_WorldRaid:getWorldRaidDebuff()
    local world_raid_id = self:getWorldRaidId()
    local debuff_key = TableWorldRaidInfo:getInstance():getDebuffKey(world_raid_id)
    local penalty_str, map_attr = TableContentAttr:getInstance():getBonusInfo(debuff_key , false)
    return penalty_str, map_attr
end

-------------------------------------
--- @function request_WorldRaidInfo
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidInfo(_success_cb, _fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        SafeFuncCall(_success_cb)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/world_raid/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(_fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
--- @function request_WorldRaidStart
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidStart(stage_id, deck_name, _success_cb, _fail_cb)
    local uid = g_userData:get('uid')
    local token = g_stageData:makeDragonToken(deck_name)

    local function success_cb(ret)
        --self.m_gameState = true
        SafeFuncCall(_success_cb, ret)
    end

    local function response_status_cb(ret)
        -- 요일에 맞지 않는 속성
        if (ret['status'] == -2150) then
            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 

            MakeSimplePopup(POPUP_TYPE.OK, Str('이미 종료된 던전입니다.'), ok_cb)
            return true
        end

        return false
    end

    local ui_network = UI_Network()
    local api_url = '/world_raid/start'
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)    
    ui_network:setParam('deck_name', deck_name)    
    ui_network:setParam('token', token)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(_fail_cb)
    ui_network:request()
end

-------------------------------------
--- @function request_WorldRaidRanking
--- @param search_type : 랭킹을 조회할 그룹 (world, clan, friend)
--- @param offset : 랭킹 리스트의 offset 값 (-1 : 내 랭킹 기준, 0 : 상위 랭킹 기준, 20 : 랭킹의 20번째부터 조회..) 
--- @param param_success_cb : 받은 데이터를 이용하여 처리할 콜백 함수
--- @param param_fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidRanking(search_type, offset, limit, param_success_cb, param_fail_cb)
    local uid = g_userData:get('uid')
    local type = search_type -- default : world
    local offset = offset -- default : 0
    local limit = limit -- default : 20

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        --self:response_eventDealkingInfo(ret)
        if param_success_cb then
            param_success_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/world_raid/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('filter', type)
    ui_network:setParam('offset', offset)
    ui_network:setParam('limit', limit)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(param_fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end
