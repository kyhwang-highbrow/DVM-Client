-- g_clanData

-------------------------------------
-- class ServerData_Clan
-------------------------------------
ServerData_Clan = class({
        m_serverData = 'ServerData',
        m_bClanGuest = 'boolean', -- 클랜 미가입 상태 여부

        -- 유저의 클랜
        m_structClan = 'StructClan',
        m_myMemberType = 'string', -- 클랜에 소속된 경우 권한 ('master', 'manager', 'member')

        -- 클랜 창설 비용
        m_createPriceType = 'string',
        m_createPriceValue = 'number',

        m_needClanInfoRefresh = 'boolean',
        m_needClanSetting = 'boolean',

        -- 클랜 리스트(가입 신청 가능한)
        m_lClanList = 'list',

        -- 클랜 가입 신청 리스트
        m_lJoinRequestList = 'map',

        -- 클랜 가입 신청 유저 리스트 (받는 기준)
        m_lJoinRequestUserList = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Clan:init(server_data)
    self.m_serverData = server_data
    self.m_bClanGuest = true

    self.m_structClan = nil

    -- 클랜 창설 비용
    self.m_createPriceType = 'gold'
    self.m_createPriceValue = 1500000

    self.m_needClanInfoRefresh = true
    self.m_needClanSetting = false
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
-- function setNeedClanInfoRefresh
-- @brief
-------------------------------------
function ServerData_Clan:setNeedClanInfoRefresh()
    self.m_needClanInfoRefresh = true
end

-------------------------------------
-- function isNeedClanInfoRefresh
-- @brief
-------------------------------------
function ServerData_Clan:isNeedClanInfoRefresh()
    return self.m_needClanInfoRefresh
end

-------------------------------------
-- function setNeedClanSetting
-- @brief
-------------------------------------
function ServerData_Clan:setNeedClanSetting()
    self.m_needClanSetting = true
end

-------------------------------------
-- function isNeedClanSetting
-- @brief
-------------------------------------
function ServerData_Clan:isNeedClanSetting()
    return self.m_needClanSetting
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
        self.m_needClanInfoRefresh = false

        if ret['clan'] then
            self.m_structClan = StructClan(ret['clan'])
            self.m_structClan:setMembersData(ret['clan_members'])
            self.m_structClan:setClanNotice(ret['clan_notice'])
            self.m_structClan:setCurrAttd(ret['clan_attd'])
            self.m_bClanGuest = false
        else
            self.m_structClan = nil
            self.m_bClanGuest = true
            self:response_clanGuestInfo(ret)
        end

        -- 클랜에 소속된 경우 권한 ('master', 'manager', 'member')
        self.m_myMemberType = ret['clan_auth']

        -- 클랜 창설 비용
        self.m_createPriceType = (ret['create_price_type'] or self.m_createPriceType)
        self.m_createPriceValue = (ret['create_price_value'] or self.m_createPriceValue)

        do -- 클랜 가입 신청 리스트 초기화
            self.m_lJoinRequestList = {}

            if ret['join_clan_list'] then
                for i,v in pairs(ret['join_clan_list']) do
                    self:addRequestedJoin(v)
                end
            end
        end

        do -- 클랜 마스터, 부마스터일 경우 들어온 요청 유저 리스트
            self.m_lJoinRequestUserList = {}

            if ret['join_user_list'] then
                for i,v in pairs(ret['join_user_list']) do
                    self:addRequestedJoinUser(v)
                end
            end
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
-- function response_clanGuestInfo
-- @brief
-------------------------------------
function ServerData_Clan:response_clanGuestInfo(ret)
    -- 가입 신청이 가능한 클랜 리스트
    self.m_lClanList = {}
    for i,v in pairs(ret['clans']) do
        local struct_clan = StructClan(v)
        table.insert(self.m_lClanList, struct_clan)
    end
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
        g_serverData:networkCommonRespone(ret)

        self:setNeedClanSetting()
        self:setNeedClanInfoRefresh()
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

-------------------------------------
-- function request_clanDestroy
-- @brief
-------------------------------------
function ServerData_Clan:request_clanDestroy(finish_cb, fail_cb)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        self:setNeedClanInfoRefresh()
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/destroy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clanExit
-- @brief
-------------------------------------
function ServerData_Clan:request_clanExit(finish_cb, fail_cb)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        self:setNeedClanInfoRefresh()
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/exit')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clanSetting
-- @brief 클랜 관리(설정)
-------------------------------------
function ServerData_Clan:request_clanSetting(finish_cb, fail_cb, intro, notice, join, mark)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        if ret['clan'] then
            self.m_structClan:applySetting(ret['clan'])
        end

        if (ret['clan_notice']) then
            self.m_structClan:setClanNotice(ret['clan_notice'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)

    if (intro ~= nil) then
        ui_network:setParam('intro', intro)
    end

    if (notice ~= nil) then
        ui_network:setParam('notice', notice)
    end

    if (join ~= nil) then
        ui_network:setParam('join', join)
    end

    if (mark ~= nil) then
        ui_network:setParam('mark', mark)
    end
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_join
-- @brief
-------------------------------------
function ServerData_Clan:request_join(finish_cb, fail_cb, clan_object_id)
    if (self.m_structClan) then
        local msg = Str('이미 가입된 클랜이 있습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        -- 즉시 가입이 된 경우
        if ret['clan'] then
            -- 클랜 정보를 다시 받도록 설정
            self:setNeedClanInfoRefresh()
        end

        -- 클랜 가입 신청 리스트가 넘어온 경우
        if ret['join_clan_list'] then
            self.m_lJoinRequestList = {}
            for i,v in pairs(ret['join_clan_list']) do
                self:addRequestedJoin(v)
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/join')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_joinCancel
-- @brief
-------------------------------------
function ServerData_Clan:request_joinCancel(finish_cb, fail_cb, clan_object_id)

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        -- 클랜 가입 신청 리스트가 넘어온 경우
        if ret['join_clan_list'] then
            self.m_lJoinRequestList = {}
            for i,v in pairs(ret['join_clan_list']) do
                self:addRequestedJoin(v)
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/cancel_join')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getClanStruct
-- @brief
-------------------------------------
function ServerData_Clan:getClanStruct()
    return self.m_structClan
end

-------------------------------------
-- function requestClanInfoDetailPopup
-- @brief
-------------------------------------
function ServerData_Clan:requestClanInfoDetailPopup(clan_object_id, close_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local struct_clan = StructClan(ret['clan'])
        struct_clan:setMembersData(ret['clan_members'])
        local ui = UI_ClanInfoDetailPopup(struct_clan)

        if close_cb then
            ui:setCloseCB(close_cb)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/detail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function requestClanInfoDetailPopup_byClanName
-- @brief
-------------------------------------
function ServerData_Clan:requestClanInfoDetailPopup_byClanName(clan_name)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local struct_clan = StructClan(ret['clan'])
        struct_clan:setMembersData(ret['clan_members'])
        UI_ClanInfoDetailPopup(struct_clan)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/detail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_name', clan_name)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function getMyMemberType
-- @brief
-------------------------------------
function ServerData_Clan:getMyMemberType()
    return self.m_myMemberType
end

-------------------------------------
-- function addRequestedJoin
-- @brief
-------------------------------------
function ServerData_Clan:addRequestedJoin(t_clan_data)
    if (not self.m_lJoinRequestList) then
        self.m_lJoinRequestList = {}
    end

    local struct_clan = StructClan(t_clan_data)
    local clan_object_id = struct_clan:getClanObjectID()
    self.m_lJoinRequestList[clan_object_id] = struct_clan
end

-------------------------------------
-- function removeRequestedJoin
-- @brief
-------------------------------------
function ServerData_Clan:removeRequestedJoin(clan_object_id)
    if (not self.m_lJoinRequestList) then
        return
    end

    self.m_lJoinRequestList[clan_object_id] = nil
end

-------------------------------------
-- function isRequestedJoin
-- @brief
-------------------------------------
function ServerData_Clan:isRequestedJoin(clan_object_id)
    if (not self.m_lJoinRequestList) then
        return false
    end

    if self.m_lJoinRequestList[clan_object_id] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function addRequestedJoinUser
-- @brief
-------------------------------------
function ServerData_Clan:addRequestedJoinUser(t_user_data)
    if (not self.m_lJoinRequestUserList) then
        self.m_lJoinRequestUserList = {}
    end

    local user_info = StructUserInfoClan:create(t_user_data)
    local uid = user_info:getUid()
    self.m_lJoinRequestUserList[uid] = user_info
end

-------------------------------------
-- function removeRequestedJoinUser
-- @brief
-------------------------------------
function ServerData_Clan:removeRequestedJoinUser(uid)
    if (not self.m_lJoinRequestUserList) then
        return
    end

    self.m_lJoinRequestUserList[uid] = nil
end

-------------------------------------
-- function getRequestedJoinUserCnt
-- @brief
-------------------------------------
function ServerData_Clan:getRequestedJoinUserCnt()
    if (self.m_lJoinRequestUserList) then
        return table.count(self.m_lJoinRequestUserList)
    end

    return 0
end

-------------------------------------
-- function isCanJoinRequest
-- @brief
-------------------------------------
function ServerData_Clan:isCanJoinRequest(clan_object_id)
    if self.m_structClan then
        return false
    end

    if self:isRequestedJoin(clan_object_id) then
        return false
    end

    return true
end