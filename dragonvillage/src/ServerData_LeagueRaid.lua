-------------------------------------
-- class ServerData_LeagueRaid
-- g_leagueRaidData
-------------------------------------
ServerData_LeagueRaid = class({
    m_memberCount = 'number',
    m_myInfo = 'table',
    m_members = 'table',
    m_seasonReward = 'table',
    m_lastScore = 'number',

    m_infoData = 'table',

    m_deck_1 = 'table',
    m_deck_2 = 'table',
    m_deck_3 = 'table',

    m_currentDamage = 'number',
    m_curDeckIndex = 'number',
    m_curStageData = 'table',


    m_attackedChar_A = 'table',
    m_attackedChar_B = 'table',
    m_attackedChar_C = 'table',

    m_leagueRaidData = 'table',

    m_raidLobbyData = 'table', --  자세한건 applyServerData 에서 확인
    })


-------------------------------------
-- function init
-------------------------------------
function ServerData_LeagueRaid:init()
    self.m_deck_1 = {}
    self.m_deck_2 = {}
    self.m_deck_3 = {}

    self.m_raidLobbyData = {}

    self.m_lastScore = 0

    self.m_leagueRaidData = TABLE:get('table_league_raid_data')
end


-------------------------------------
-- function getMemberCount
-------------------------------------
function ServerData_LeagueRaid:resetIngameData()
    self.m_currentDamage = 0
    self.m_curDeckIndex = 1

    self.m_attackedChar_A = nil
    self.m_attackedChar_B = nil
    self.m_attackedChar_C = nil
end


-------------------------------------
-- function getMemberCount
-------------------------------------
function ServerData_LeagueRaid:getOneDoidByIndex(index)
    local result = ''
    local target_list = {}

    if (index == 1) then
        target_list = self.m_deck_1
    elseif (index == 2) then
        target_list = self.m_deck_2
    elseif (index == 3) then
        target_list = self.m_deck_3
    end

    for i, v in ipairs(target_list) do
        if (v) then result = v break end
    end

    return result
end


-------------------------------------
-- function getMemberCount
-------------------------------------
function ServerData_LeagueRaid:getMemberCount()
    return self.m_memberCount
end

-------------------------------------
-- function getMyInfo
-------------------------------------
function ServerData_LeagueRaid:getMyInfo()
    return self.m_myInfo
end

-------------------------------------
-- function getMemberList
-------------------------------------
function ServerData_LeagueRaid:getMemberList()
    return self.m_members
end


-------------------------------------
-- function ServerData_LeagueRaid
-------------------------------------
function ServerData_LeagueRaid:updateDeckInfo()
    self.m_deck_1 = g_deckData:getDeck('league_raid_1')
    self.m_deck_2 = g_deckData:getDeck('league_raid_2')
    self.m_deck_3 = g_deckData:getDeck('league_raid_3')
end


-------------------------------------
-- function ServerData_LeagueRaid
-------------------------------------
function ServerData_LeagueRaid:getDeckIndex(doid)
    local index = 99

    for i = 1, #self.m_deck_1 do
        if self.m_deck_1[i] == doid then index = 1 end
    end

    for i = 1, #self.m_deck_2 do
        if self.m_deck_2[i] == doid then index = 2 end
    end

    for i = 1, #self.m_deck_3 do
        if self.m_deck_3[i] == doid then index = 3 end
    end

    return tonumber(index)
end


-------------------------------------
-- function ServerData_LeagueRaid
-------------------------------------
function ServerData_LeagueRaid:getUsingDidTable()
    local table_dragon = {}
    for i, v in ipairs(self.m_deck_1) do
        table_dragon[v] = 'league_raid_1'
    end

    for i, v in ipairs(self.m_deck_2) do
        table_dragon[v] = 'league_raid_2'
    end

    for i, v in ipairs(self.m_deck_3) do
        table_dragon[v] = 'league_raid_3'
    end

    return table_dragon
end

-------------------------------------
-- function getMyInfo
-------------------------------------
function ServerData_LeagueRaid:getMyData()
    local uid = g_userData:get('uid')
    for i, v in ipairs(self.m_members) do
        if (v and v['uid'] == uid) then return v end
    end
end


-------------------------------------
-- function getRewardInfo
-------------------------------------
function ServerData_LeagueRaid:getRewardInfo()
    return self.m_seasonReward
end



-------------------------------------
-- function request_raidClear
-------------------------------------
function ServerData_LeagueRaid:request_raidClear(finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if (ret['added_items'] and ret['added_items']['items_list']) then
            g_serverData:networkCommonRespone_addedItems(ret)
        end
        
        if (self.m_myInfo) then
            self.m_myInfo['today_play_count'] = math.min(self.m_myInfo['today_play_count'] + 1, self.m_myInfo['max_play_count'])
            self.m_myInfo['cost_value'] = ret['raid_use_staminas']
            
        end

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    local function response_status_cb(ret)
        -- 현재 시간에 잠겨 있는 속성
        if (ret['status'] == -1351) then

            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 

            MakeSimplePopup(POPUP_TYPE.OK, Str('입장 가능한 시간이 아닙니다.'), ok_cb)
            return true
        end

        --"status":-1351,
        --"message":"invalid time"

        return true
    end

    local ui_network = UI_Network()
    local api_url = '/raid/clear'
    ui_network:setUrl(api_url)
    ui_network:setParam('stage', self.m_myInfo['stage'])
    ui_network:setParam('uid', uid)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end


-------------------------------------
-- function ServerData_LeagueRaid
-------------------------------------
function ServerData_LeagueRaid:request_RaidInfo(finish_cb, fail_cb, dont_update)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if (dont_update) then if (finish_cb) then finish_cb(ret) end end

        self.m_infoData = ret

        self.m_memberCount = ret['member_count']
        self.m_myInfo = ret['my_info']
        self.m_members = ret['members']

        self:updateDeckInfo()

        if (ret['added_items'] and ret['added_items']['items_list']) then
            g_serverData:networkCommonRespone_addedItems(ret)
            self.m_seasonReward = ret['added_items']['items_list']
        else
            self.m_seasonReward = nil
        end

        if (ret['last_score']) then
            self.m_lastScore = ret['last_score']
        end
        
        if (finish_cb) then finish_cb(ret) end
    end

    local function response_status_cb(ret)
        -- 현재 시간에 잠겨 있는 속성
        if (ret['status'] == -1351) then

            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 

            MakeSimplePopup(POPUP_TYPE.OK, Str('입장 가능한 시간이 아닙니다.'), ok_cb)
            return true
        end

        --"status":-1351,
        --"message":"invalid time"

        return true
    end

    local ui_network = UI_Network()
    local api_url = '/raid/info'
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function isNewSeason
-------------------------------------
function ServerData_LeagueRaid:isNewSeason()
    if (self.m_infoData and self.m_infoData['last_score']) then return true end

    return false
end



-------------------------------------
-- function isShowLobbyBanner
-------------------------------------
function ServerData_LeagueRaid:isShowLobbyBanner()
    return true
end


-------------------------------------
-- function getCurrentDamageLevel
-------------------------------------
function ServerData_LeagueRaid:getCurrentDamageLevel()
    local damage = self.m_currentDamage
    local next_damage = 0
    local table_item_count = table.count(self.m_leagueRaidData)
    local cur_lv = 1
    local not_found = true

    for lv = 1, table_item_count do
        local data = self.m_leagueRaidData[lv]

        next_damage = next_damage + data['hp']

        if (damage <= next_damage) then
            cur_lv = lv
            not_found = false
            break
        end
    end

    if (not_found) then cur_lv = table_item_count end

    return cur_lv
end



-------------------------------------
-- function applyServerData
-------------------------------------
function ServerData_LeagueRaid:applyServerData(ret)
    if (not ret) then return end

    -- 레이드 현재 시즌
    if (ret['league_raid_season']) then self.m_raidLobbyData['league_raid_season'] = ret['league_raid_season'] end

    -- 레이드 스테이지 정보
    if (ret['league_raid_stage']) then self.m_raidLobbyData['league_raid_stage'] = ret['league_raid_stage'] end

    -- 레이드 오픈 여부
    if (ret['league_raid_is_open']) then self.m_raidLobbyData['league_raid_is_open'] = ret['league_raid_is_open'] end

    -- 레이드 플레이 가능 여부 ( 고대유적 10층 클리어)
    if (ret['league_raid_play_condition']) then self.m_raidLobbyData['league_raid_play_condition'] = ret['league_raid_play_condition'] end

    -- 현재 시즌 레이드 참여 여부
    if (ret['league_raid_is_play']) then self.m_raidLobbyData['league_raid_is_play'] = ret['league_raid_is_play'] end
end


-------------------------------------
-- function isLobbyPopupRequired
-------------------------------------
function ServerData_LeagueRaid:isLobbyPopupRequired()
    local result = false

    -- 레이드 오픈
    -- 고대유적 10층 클리어
    -- 레이드 아직 참여 안함
    if (self.m_raidLobbyData['league_raid_is_open'] == true) then
        if (self.m_raidLobbyData['league_raid_play_condition'] == true) then
            if (self.m_raidLobbyData['league_raid_is_play'] == false) then
                self.m_raidLobbyData['league_raid_is_play'] = true
                result = true
            end
        end
    end

    return result
end

-------------------------------------
-- function getStageId
-------------------------------------
function ServerData_LeagueRaid:getStageIdAndSeason()
    local stage_id = self.m_raidLobbyData['league_raid_stage'] or 0
    local season = self.m_raidLobbyData['league_raid_season'] or 0

    return stage_id, season
end