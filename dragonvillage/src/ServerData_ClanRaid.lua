-------------------------------------
-- class ServerData_ClanRaid
-------------------------------------
ServerData_ClanRaid = class({
        m_serverData = 'ServerData',

        -- 오픈/종료 시간
        m_startTime = 'number',
        m_endTime = 'number',

        -- 현재 진행중인 스테이지 ID
        m_challenge_stageID = 'number',

        -- 현재 진행중 혹은 선택한 던전 정보
        m_structClanRaid = 'StructClanRaid',

        -- 누적 기여 랭킹 리스트 (현재 진행중인 기여도 랭킹 리스트는 StructClanRaid 에서 받아옴)
        m_lRankList = 'list',

        -- 여의주 사용횟수
        m_use_cash = 'number',

        -- 클랜 보상 정보
        m_tClanRewardInfo = 'table', 

        -- 클랜던전 갱신
        m_bossLv = 'number',
        m_bossRemainHp = 'number',

        -- 오픈상태 
        m_bOpen = 'boolean',

        -- 보상에 적용되는 실제 기여도 (서버에서 넘겨줌)
        m_mapRewardContribution = 'map',

        -- 연습 전 티켓
        m_triningTicketCnt = 'number',
        m_triningTicketMaxCnt = 'number',

        -- 앞/뒤 순위 클랜 정보, UI_ReasultLeaderBoard에서 사용
        -- m_lCloseRankers = { upper_ranker = 'table', me_ranker = 'table', lower_ranker = 'table'}
        m_lCloseRankers = 'table', 

        -- UI_ReasultLeaderBoard에서 사용하는 내 랭킹 
        m_tMyClanInfo = 'table',
        -- UI_ReasultLeaderBoard에서 사용하는 이전 내 랭킹
        m_tExMyClanInfo = 'table',
    })

local USE_CASH_LIMIT = 1 -- 하루 최대 여의주 사용 입장횟수
local USE_CASH_CNT = 200
local BOSS_GOLD_REWARD = 100000 -- 보스 처치시 받는 골드 고정

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRaid:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getClanRaidStruct
-------------------------------------
function ServerData_ClanRaid:getClanRaidStruct()
    return self.m_structClanRaid
end

-------------------------------------
-- function getChallengStageID
-------------------------------------
function ServerData_ClanRaid:getChallengStageID()
    return self.m_challenge_stageID
end

-------------------------------------
-- function getCurChallengStage
-------------------------------------
function ServerData_ClanRaid:getCurChallengStage()
    return tonumber(self.m_challenge_stageID)%1000 -- ex) 1500100 -> 100층 
end

-------------------------------------
-- function getRankList
-------------------------------------
function ServerData_ClanRaid:getRankList()
    return self.m_lRankList
end

-------------------------------------
-- function getUseCashCnt
-------------------------------------
function ServerData_ClanRaid:getUseCashCnt()
    return USE_CASH_CNT
end

-------------------------------------
-- function setBossStatus
-- @brief 현재 진행중인 던전 보스의 레벨, 남은 체력 던전 갱신 체크를 위해 저장
-------------------------------------
function ServerData_ClanRaid:setBossStatus()
    local struct_clan_raid = self.m_structClanRaid
    self.m_bossLv = struct_clan_raid and struct_clan_raid:getLv() or 0
    self.m_bossRemainHp = struct_clan_raid and struct_clan_raid:getHp() or 0
end

-------------------------------------
-- function checkBossStatus
-- @brief 가지고 있는 던전 정보와 진행중인 실제 던전 정보가 다른 경우 false 리턴
-------------------------------------
function ServerData_ClanRaid:checkBossStatus()
    local hp = self.m_structClanRaid:getHp()
    local lv = self.m_structClanRaid:getLv()

    if (self.m_bossRemainHp ~= hp) or (self.m_bossLv ~= lv) then
        self:setBossStatus()
        return false
    end

    return true
end

-------------------------------------
-- function getTotalGoldReward
-- @brief 보스 처치 골드 누적량 (서버에서 따로 받지 않음, 클라에서 레벨로 계산)
-------------------------------------
function ServerData_ClanRaid:getTotalGoldReward()
    if (not self.m_challenge_stageID) then
        return 0
    end

    local curr_lv = self.m_challenge_stageID % 1000
    return math_max(0, curr_lv - 1) * BOSS_GOLD_REWARD
end

-------------------------------------
-- function isOpenClanRaid
-- @breif 던전 오픈 여부
-------------------------------------
function ServerData_ClanRaid:isOpenClanRaid()
    -- 죄악의 화신 토벌작전의 경우 다르게 검사
    if ((self.m_structClanRaid) and (self.m_structClanRaid:isEventIncarnationOfSinsMode())) then
        if (g_eventIncarnationOfSinsData) then
            local attr = self.m_structClanRaid.attr
            return g_eventIncarnationOfSinsData:isOpenAttr(attr)
        else
            return false
        end
    else
        local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local start_time = (self.m_startTime / 1000)
        local end_time = (self.m_endTime / 1000)
	    return (self.m_bOpen) and (start_time <= curr_time) and (curr_time <= end_time)
    end
end

-------------------------------------
-- function isOpenClanRaid_OnlyTime
-- @breif 던전 오픈 여부 (시간만 체크)
-------------------------------------
function ServerData_ClanRaid:isOpenClanRaid_OnlyTime()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	return (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function isClanRaidStageID
-------------------------------------
function ServerData_ClanRaid:isClanRaidStageID(stage_id)
    if (not stage_id) then return false end
    local game_mode = g_stageData:getGameMode(stage_id)
    return (game_mode == GAME_MODE_CLAN_RAID)
end

-------------------------------------
-- function getClanRaidStatusText
-------------------------------------
function ServerData_ClanRaid:getClanRaidStatusText()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
    
    local str = ''
    if (not self:isOpenClanRaid()) then
        local time = (start_time - curr_time)
        if (time < 0) then
            str = Str('오픈시간이 아닙니다.')
        else
            str = Str('클랜던전 오픈 전입니다.\n오픈까지 {1}', datetime.makeTimeDesc(time, true))
        end

    elseif (curr_time < start_time) then
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))
    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('시즌 종료까지') .. '\n' .. Str('{1} 남음', datetime.makeTimeDesc(time, true))
    else
        str = Str('시즌이 종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function getNextStageID
-- @brief
-------------------------------------
function ServerData_ClanRaid:getNextStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id + 1)

    if t_drop then
        return stage_id + 1
    else
        return nil
    end
end

-------------------------------------
-- function getSimplePrevStageID
-- @brief
-------------------------------------
function ServerData_ClanRaid:getSimplePrevStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id - 1)

    if t_drop then
        return stage_id - 1
    else
        return nil
    end
end

-------------------------------------
-- function setRewardInfo
-------------------------------------
function ServerData_ClanRaid:setRewardInfo(ret)
    if (not ret['reward']) then
        return
    end
    
    -- 클랜
    if (ret['last_clan_info']) then
        self.m_tClanRewardInfo = {}

        -- 최종 순위 유저 정보
        self.m_tClanRewardInfo['user_info'] = StructUserInfoClanRaid:create_forRanking(ret['last_scores'][1])
        self.m_tClanRewardInfo['contribution'] = ret['ratio'] 
        self.m_tClanRewardInfo['rank'] = StructClanRank(ret['last_clan_info'])
        self.m_tClanRewardInfo['reward_info'] = ret['reward_clan_info']
		self.m_tClanRewardInfo['clan_exp'] = ret['clan_exp']
    end
end

-------------------------------------
-- function request_info
-------------------------------------
function ServerData_ClanRaid:request_info(stage_id, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
    
    -- 콜백 함수
    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

		-- 클랜 정보
        if ret['clan'] then
			-- 클랜 데이터 없는 경우 : 클랜 UI가 아닌 battle menu에서 진입시
			if (not g_clanData.m_structClan) then
				g_clanData.m_structClan = StructClan(ret['clan'])
				g_clanData.m_bClanGuest = false 
			-- 갱신
			else
				g_clanData.m_structClan:applySetting(ret['clan'])
			end
        end

        -- 클랜 던전 오픈/종료 시간
        self.m_bOpen = ret['open']
        self.m_startTime = ret['start_time']
        self.m_endTime = ret['endtime']
        
        -- 클랜던전의 현재 속성을 clans/info, clans/dungeon_info 두 API에서 모두 받게 수정
        if (ret['attr'] and g_clanData) then
            g_clanData.m_cur_season_boss_attr = ret['attr']
        end
        
        self.m_challenge_stageID = ret['cur_stage']

        self.m_use_cash = ret['use_cash'] or 0

        -- 시즌 보상
        self:setRewardInfo(ret)

        -- 누적 기여도 랭킹
        local rank_list = ret['scores']
        if (rank_list) then
            self.m_lRankList = {}

            local total_score = 0

            for _, user_data in ipairs(rank_list) do
                local user_info = StructUserInfoClanRaid:create_forRanking(user_data)
                total_score = total_score + user_info.m_score
                table.insert(self.m_lRankList, user_info)
            end

            for _, user_data in ipairs(self.m_lRankList) do
                user_data:setContribution(total_score)
            end
        end
        
        -- 실제 보상에 적용되는 기여도 정보
        self.m_mapRewardContribution = {}
        if (ret['cweek_info']) then
            self.m_mapRewardContribution = ret['cweek_info']
        end 

        -- 클랜 던전 정보
        if (ret['dungeon']) then
            self.m_structClanRaid = StructClanRaid(ret['dungeon'])
            self.m_structClanRaid:resetTrainingSettingInfo()
        else
            self.m_structClanRaid = nil
        end

        -- 내 클랜 정보
        if (ret['my_claninfo']) then
            self.m_tExMyClanInfo = clone(self.m_tMyClanInfo)
            self.m_tMyClanInfo = ret['my_claninfo']
        end

        -- 앞/뒤 순위 정보
        if (ret['rank_list']) then
            self:applyCloseRankerData(ret['rank_list'])
        end
        

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/dungeon_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function requestGameStart
-------------------------------------
function ServerData_ClanRaid:requestGameStart(stage_id, deck_name, combat_power, finish_cb, is_cash)
    local uid = g_userData:get('uid')
    local is_cash = is_cash or false
    local api_url = '/clans/dungeon_start'

    -- 응답 상태 처리 함수
    local t_error = {
        [-3871] = Str('이미 클랜 던전에 입장한 유저가 있습니다.'),
        [-1371] = Str('유효하지 않은 던전입니다.'), 
    }
    local response_status_cb = MakeResponseCB(t_error)

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        local game_key = ret['gamekey']
        finish_cb(game_key)

        -- 스피드핵 방지 실제 플레이 시간 기록
        g_accessTimeData:startCheckTimer()
    end

    local attr = TableStageData:getStageAttr(stage_id) 
    local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)
    local deck_name1 = multi_deck_mgr:getDeckName('up')
    local deck_name2 = multi_deck_mgr:getDeckName('down')

    local token1 = g_stageData:makeDragonToken(deck_name1)
    local token2 = g_stageData:makeDragonToken(deck_name2)
    local teambonus1 = g_stageData:getTeamBonusIds(deck_name1)
    local teambonus2 = g_stageData:getTeamBonusIds(deck_name2)

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('deck_name1', deck_name1)
    ui_network:setParam('deck_name2', deck_name2)
    ui_network:setParam('token1', token1)
    ui_network:setParam('token2', token2)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('team_bonus1', teambonus1)
    ui_network:setParam('team_bonus2', teambonus2)

    if (is_cash) then ui_network:setParam('is_cash', is_cash) end
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end


-------------------------------------
-- function isFinalBlow
-- @brief 여의주 사용하여 던전 시작 가능한 상태인지 (파이널 블로우거나 하루 제한에 걸리지않거나)
-- @brief 20190207 파이널 블로우일 때만 다이아 사용할 수 있도록 변경
-------------------------------------
function ServerData_ClanRaid:isFinalBlow()
    local clan_raid_data = self.m_structClanRaid
    if (not clan_raid_data) then return false end

    -- 파이널 블로우인 상태 가능
    if (clan_raid_data:getState() == CLAN_RAID_STATE.FINALBLOW) then
        return true    
    else
        return false
    end
end

-------------------------------------
-- function selectEnterWayPopup
-- @brief 파이널 블로우 때 다이아, 입장권 고르는 팝업
-------------------------------------
function ServerData_ClanRaid:selectEnterWayPopup(cb_func, stage_id)
    local ui = UI()

    -- 다이아 이용해 입장할 경우
    local click_useDiaBtn = function(cb_func)
        if (not self:checkRequireCash()) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('다이아몬드가 부족합니다.\n상점으로 이동하시겠습니까?'), function() UINavigatorDefinition:goTo('package_shop', 'diamond_shop') end)
        else
            ui:close()
            cb_func(true) -- is_cash
        end
    end

    -- 티켓 이용해 입장할 경우
    local click_useTicketBtn = function(cb_func)
        if (not self:checkRequireTicket(stage_id)) then
            UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('클랜던전 입장권')))
        else
            ui:close()
            cb_func(false) -- is_cash
        end
    end

    ui:load('clan_raid_scene_enter_popup.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    ui.vars['diaBtn']:registerScriptTapHandler(function() click_useDiaBtn(cb_func) end)
    ui.vars['cldgBtn']:registerScriptTapHandler(function() click_useTicketBtn(cb_func) end)

    local cash_cnt = g_clanRaidData:getUseCashCnt()
    ui.vars['cashCountLabel']:setString(tostring(cash_cnt))
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'clan_raid_scene_enter_popup')
    UIManager:open(ui, UIManager.POPUP)
end

-------------------------------------
-- function checkRequireCash
-------------------------------------
function ServerData_ClanRaid:checkRequireCash()
    local cash_cnt = g_clanRaidData:getUseCashCnt()
    local cur_cash = g_userData:get('cash')
    
    if (cur_cash < cash_cnt) then
        return false
    end

    return true
end

-------------------------------------
-- function checkRequireTicket
-------------------------------------
function ServerData_ClanRaid:checkRequireTicket(stage_id)
    return g_staminasData:checkStageStamina(stage_id)
end

-------------------------------------
-- function getRankRewardList
-- @brief 클랜 시즌 보상 정보
-------------------------------------
function ServerData_ClanRaid:getRankRewardList()
     --[[  
        ['clan_exp']=25000;
        ['category']='dungeon';
        ['t_name']='36~40위';
        ['ratio_min']='';
        ['rank_min']=36;
        ['ratio_max']='';
        ['rank_max']=40;
        ['week']=1;
        ['rank_id']=3024;
        ['reward']='clancoin;1850';
    --]]

    local l_item_list = {}
    local table_clan_reward = TABLE:get('table_clan_reward')
    -- 클랜 던전 보상 정보만 리스트에 담는다
    for rank_id, t_data in pairs(table_clan_reward) do
        -- week가 지정되어 있고, 그 week가 현재 주차와 일치한다면 그 테이블을 사용하는 예외처리 필요 
        -- @jhakim 임의로 주차보상은 보이지 않도록 처리
        if (t_data['category'] == 'dungeon') and (t_data['week'] == 1) then
            table.insert(l_item_list, t_data)
        end
    end

    -- 테이블 정렬
    table.sort(l_item_list, function(a, b) 
        return tonumber(a['rank_id']) < tonumber(b['rank_id'])
    end)

    return l_item_list
end

-------------------------------------
-- function requestAttrRankList
-- @brief 클랜 이전 시즌 시즌 정보
-------------------------------------
function ServerData_ClanRaid:requestAttrRankList(attr_type, rank_offset, cb_func)
    local uid = g_userData:get('uid')
    
    local function success_cb(ret)
        cb_func(ret)
    end

    --[[
    -- attr 이 all일 경우
    "fire_Rankinfo":{
        "my_claninfo":{
          "cdlv":52,
          "master":"dd",
          "id":"5c0f8684e89193165bd86b3d",
          "rank":3,
          "intro":"",
          "member_max":22,
          "lv":13,
          "member_cnt":6,
          "rate":0.75,
          "join":true,
          "mark":"",
          "name":"11",
          "score":10854985
        },
        "list":[{
            "cdlv":1,
            "master":"Nacel",
            "id":"5c650e40e8919307c84cf737",
            "rank":4,
            "intro":"",
            "member_max":20,
            "lv":4,
            "member_cnt":1,
            "rate":0,
            "join":true,
            "mark":"",
            "name":"네코냥",
            "score":469834
          }]
      },
      "status":0,
      "water_Rankinfo":{
        "my_claninfo":{
          "cdlv":52,
          "master":"dd",
          "id":"5c0f8684e89193165bd86b3d",
          "rank":-1,
          "intro":"",
          "member_max":22,
          "lv":13,
          "member_cnt":6,
          "rate":1,
          "join":true,
          "mark":"",
          "name":"11",
          "score":-1
        },
    
        --]]

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/rank_history')
    ui_network:setParam('uid', uid)
    ui_network:setParam('offset', rank_offset)
    ui_network:setParam('attr', attr_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

end


-------------------------------------
-- function requestGameInfo_training
-------------------------------------
function ServerData_ClanRaid:requestGameInfo_training(finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        --g_clanRaidData:applyTrainingInfo(ret['staminas']['cldg_tr'])
        finish_cb()
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/clans/dungeon_training_info')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function applyTrainingInfo
-------------------------------------
function ServerData_ClanRaid:applyTrainingInfo(ret)
    if (not ret) then
        return
    end

    if (ret['cnt']) then
        self.m_triningTicketCnt = ret['cnt']
    end

    if (ret['max_cnt']) then
        self.m_triningTicketMaxCnt = ret['max_cnt']
    end
end

-------------------------------------
-- function applyCloseRankerData
-------------------------------------
function ServerData_ClanRaid:applyCloseRankerData(l_rankers)
--[[
    "cldg_last_info":{
        "dark":{
          "cldg_last_lv":1500007,
          "change_rank":0
        },
        "light":{
          "cldg_last_lv":1500000,
          "change_rank":0
        },
        "earth":{
          "cldg_last_lv":1500010,
          "change_rank":0
        },
        "fire":{
          "cldg_last_lv":1500000,
          "change_rank":0
        },
        "water":{
          "cldg_last_lv":1500001,
          "change_rank":0
        }
      },
      "cdlv":5,
      "master":"dd",
      "id":"5c0f8684e89193165bd86b3d",
      "cldg_Attr":["earth","water","fire","light","dark"],
      "rank":1,
      "intro":"",
      "member_max":22,
      "lv":14,
      "member_cnt":20,
      "rate":0,
      "join":true,
      "mark":"",
      "name":"11",
      "score":79983800
    },
    --]]

    local my_rank = self.m_tMyClanInfo['rank']
    local upper_rank = my_rank - 1
    local lower_rank = my_rank + 1

    self.m_lCloseRankers = {}
    self.m_lCloseRankers['me_ranker'] = nil
    self.m_lCloseRankers['upper_ranker'] = nil
    self.m_lCloseRankers['lower_rank'] = nil

    for _,data in ipairs(l_rankers) do
        if (tonumber(data['rank']) == tonumber(my_rank)) then
            self.m_lCloseRankers['me_ranker'] = data
        end

        if (tonumber(data['rank']) == tonumber(upper_rank)) then
            self.m_lCloseRankers['upper_ranker'] = data
        end

        if (tonumber(data['rank']) == tonumber(lower_rank)) then
            self.m_lCloseRankers['lower_rank'] = data
        end
    end
end

-------------------------------------
-- function getCloseRankers
-------------------------------------
function ServerData_ClanRaid:getCloseRankers()
    return self.m_lCloseRankers['upper_ranker'], self.m_lCloseRankers['me_ranker'], self.m_lCloseRankers['lower_rank']
end

-------------------------------------
-- function possibleReward_ClanRaid
-- @brief 예상 보상 정보
-------------------------------------
function ServerData_ClanRaid:possibleReward_ClanRaid(my_rank, my_ratio)
    local l_reward = g_clanRaidData:getRankRewardList()
    local my_rank = tonumber(my_rank)
    local my_ratio = tonumber(my_ratio)

    for ind, data in ipairs(l_reward) do
        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])
        

        -- 순위 필터
        if (rank_min and rank_max and rank_min ~= '' and rank_max ~= '') then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                return data
            end
        end
    end

    -- 디폴트로 마지막 보상 돌려줌
    return l_reward[#l_reward]
end