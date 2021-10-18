-------------------------------------
-- class ServerData_LeagueRaid
-- g_leagueRaidData
-------------------------------------
ServerData_LeagueRaid = class({
    m_memberCount = 'number',
    m_myInfo = 'table',
    m_members = 'table',

    })


-------------------------------------
-- function init
-------------------------------------
function ServerData_LeagueRaid:init()

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

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    local function response_status_cb(ret)
        

        return false
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