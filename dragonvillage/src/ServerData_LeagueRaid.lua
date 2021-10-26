-------------------------------------
-- class ServerData_LeagueRaid
-- g_leagueRaidData
-------------------------------------
ServerData_LeagueRaid = class({
    m_memberCount = 'number',
    m_myInfo = 'table',
    m_members = 'table',

    m_deck_1 = 'table',
    m_deck_2 = 'table',
    m_deck_3 = 'table',
    })


-------------------------------------
-- function init
-------------------------------------
function ServerData_LeagueRaid:init()
    self.m_deck_1 = {}
    self.m_deck_2 = {}
    self.m_deck_3 = {}
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
function ServerData_LeagueRaid:getUsingDidTable()
    local table_dragon = {}
    for i, v in ipairs(self.m_deck_1) do
        table_dragon[v] = true
    end

    for i, v in ipairs(self.m_deck_2) do
        table_dragon[v] = true
    end

    for i, v in ipairs(self.m_deck_3) do
        table_dragon[v] = true
    end

    return table_dragon
end


-------------------------------------
-- function ServerData_LeagueRaid
-------------------------------------
function ServerData_LeagueRaid:request_RaidInfo(finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if (IS_DEV_SERVER()) then
            ccdump(ret)
        end

        self.m_memberCount = ret['member_count']
        self.m_myInfo = ret['my_info']
        self.m_members = ret['members']

        self:updateDeckInfo()
        
        if (finish_cb) then
            finish_cb(ret)
        end
    end

    local function response_status_cb(ret)
        if (finish_cb) then finish_cb() end

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
-- function isShowLobbyBanner
-------------------------------------
function ServerData_LeagueRaid:isShowLobbyBanner()
    return true
end