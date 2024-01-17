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
--- @function isAvailableWorldRaidReward
-------------------------------------
function ServerData_WorldRaid:isAvailableWorldRaidReward()
  return true --g_hotTimeData:isActiveEvent('world_raid')
end

-------------------------------------
--- @function getCurrentMyRanking
-------------------------------------
function ServerData_WorldRaid:getCurrentMyRanking()
    return {
        lv = 31,
        tier = "bronze_3",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110002,
        costume = 730204,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = false,
        un = 9463,
        score = -1,
        total = 0,
        nick = "ksjang3",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 121854,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "ksjang3",
        rank = -1
      }
end

-------------------------------------
--- @function getCurrentRankingList
-------------------------------------
function ServerData_WorldRaid:getCurrentRankingList()

    local list = { {
        lv = 31,
        tier = "bronze_3",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110002,
        costume = 730204,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = false,
        un = 9463,
        score = -1,
        total = 0,
        nick = "ksjang3",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 121854,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "ksjang3",
        rank = -1
      }, {
        lv = 99,
        tier = "bronze_3",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110003,
        costume = 730300,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = false,
        un = 130839362,
        score = -1,
        total = 0,
        nick = "l은달lHenesK",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 122055,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "MFqooDQK9maoJkK3UzMKQ5zFhLB2",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110001,
        costume = 730100,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 9443,
        score = -1,
        total = 0,
        nick = "ksjang112",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 121683,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "ksjang",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110004,
        costume = 730406,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 1956459,
        score = -1,
        total = 0,
        nick = "TEST001",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121962,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "vEH4nldukuRKrj032pVBAhetafz1",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110004,
        costume = 730400,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 9223,
        score = -1,
        total = 0,
        nick = "고니",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121752,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "ykil",
        rank = -1
      }, {
        lv = 34,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110002,
        costume = 730200,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 9698,
        score = -1,
        total = 0,
        nick = "test1228",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121954,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "test1228",
        rank = -1
      }, {
        lv = 97,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110003,
        costume = 730300,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 141049,
        score = -1,
        total = 0,
        nick = "HeinCheese",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 122055,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "2I5hY6XUrnTnEjnixGUkVrbUSB73",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110005,
        costume = 730502,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 71984,
        score = -1,
        total = 0,
        nick = "꿔바로우",
        leader = {
          lv = 60,
          mastery_lv = 10,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 121595,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 10
        },
        uid = "1hFq4remJYO0v85189RfUbofist1",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110004,
        costume = 730403,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 130862025,
        score = -1,
        total = 0,
        nick = "kamari",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121792,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "YeoFSrDmUxZY3nM02LEjh5zrSft2",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110005,
        costume = 730503,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 2176990,
        score = -1,
        total = 0,
        nick = "I은달I동그라미",
        leader = {
          lv = 60,
          mastery_lv = 10,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 120185,
          transform = 3,
          mastery_skills = {
            ["110301"] = 3,
            ["110101"] = 3,
            ["110203"] = 3,
            ["110402"] = 1
          },
          evolution = 3,
          mastery_point = 0
        },
        uid = "cqKc3TF98AZDRsmjfBBiF3OcwK62",
        rank = -1
      } }

    return list
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

-------------------------------------
--- @function request_WorldRaidBoardRanking
--- @param search_type : 랭킹을 조회할 그룹 (world, clan, friend)
--- @param offset : 랭킹 리스트의 offset 값 (-1 : 내 랭킹 기준, 0 : 상위 랭킹 기준, 20 : 랭킹의 20번째부터 조회..) 
--- @param param_success_cb : 받은 데이터를 이용하여 처리할 콜백 함수
--- @param param_fail_cb : 통신 실패 처리할 콜백 함수
-------------------------------------
function ServerData_WorldRaid:request_WorldRaidBoardRanking(search_type, offset, limit, param_success_cb, param_fail_cb)
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
    ui_network:setUrl('/world_raid/board_ranking')
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