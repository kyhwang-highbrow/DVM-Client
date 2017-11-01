-- g_clanData

-------------------------------------
-- class ServerData_Clan
-------------------------------------
ServerData_Clan = class({
        m_serverData = 'ServerData',
        m_bClanGuest = 'boolean', -- 클랜 미가입 상태 여부

        -- 유저의 클랜
        m_structClan = 'StructClan',

        -- 클랜 창설 비용
        m_createPriceType = 'string',
        m_createPriceValue = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Clan:init(server_data)
    self.m_serverData = server_data
    self.m_bClanGuest = true

    -- 클랜 창설 비용
    self.m_createPriceType = 'gold'
    self.m_createPriceValue = 1500000
end

-------------------------------------
-- function isClanGuest
-- @brief 클랜 미가입 상태 여부
-- @return boolean
-------------------------------------
function ServerData_Clan:isClanGuest()
    return self.m_bClanGuest
end

-------------------------------------
-- function update_clanInfo
-- @brief
-------------------------------------
function ServerData_Clan:update_clanInfo(finish_cb, fail_cb)
    return self:request_clanInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function getClanCreatePriceInfo
-- @brief 클랜 창설 비용 정보
-------------------------------------
function ServerData_Clan:getClanCreatePriceInfo()
    local price_type = self.m_createPriceType
    local price_value = self.m_createPriceValue
    return price_type, price_value
end

-------------------------------------
-- function request_clanInfo
-- @brief
-------------------------------------
function ServerData_Clan:request_clanInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        if ret['clan'] then
            self.m_structClan = StructClan(ret['clan'])
            ccdump(self.m_structClan)
            self.m_bClanGuest = false
        else
            self.m_structClan = nil
            self.m_bClanGuest = true
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clanCreate
-- @brief
-------------------------------------
function ServerData_Clan:request_clanCreate(finish_cb, fail_cb, name, join, intro, flag)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/create')
    ui_network:setParam('uid', uid)
    ui_network:setParam('name', name)
    ui_network:setParam('join', join)
    ui_network:setParam('intro', intro)
    ui_network:setParam('flag', flag)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end