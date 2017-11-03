local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanMemberListItem
-------------------------------------
UI_ClanMemberListItem = class(PARENT, {
        m_structUserInfo = 'StructUserInfoClan',
        m_refreshCB = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanMemberListItem:init(data)
    self.m_structUserInfo = data
    local vars = self:load('clan_item_member.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanMemberListItem:initUI()
    local vars = self.vars

    local user_info = self.m_structUserInfo


    -- 대표 드래곤
    local card = user_info:getLeaderDragonCard()
    vars['userNode']:addChild(card.root)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanMemberListItem:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)

    
    do -- 클랜원 관리 버튼
        vars['adminBtn']:registerScriptTapHandler(function() self:click_adminBtn() end)

        vars['banishBtn']:registerScriptTapHandler(function() self:click_banishBtn() end)
        
        vars['masterBtn']:registerScriptTapHandler(function() self:click_masterBtn() end)
        vars['subMasterBtn']:registerScriptTapHandler(function() self:click_subMasterBtn() end)
        vars['memberBtn']:registerScriptTapHandler(function() self:click_memberBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanMemberListItem:refresh()
    local vars = self.vars

    local user_info = self.m_structUserInfo

    -- UI갱신이 되는 시점에서는 관리자 UI를 숨겨줌
    vars['adminMenu']:setVisible(false)

    -- 닉네임
    local nick = user_info:getNickname()
    vars['masterLabel']:setString(nick)

    -- 레벨
    local str = Str('Lv.{1}', user_info:getLv())
    vars['levelLabel']:setString(str)

    -- 접속 시간
    user_info:updateActiveTime()
    local str = user_info:getPastActiveTimeText()
    vars['timeLabel']:setString(str)

    -- 맴버 타입(권한)
    local str = user_info:getMemberTypeText()
    vars['positionLabel']:setString(str)

    -- 출석 여부
    local attended = user_info:isTodayAttendance()
    vars['attendanceNode']:setVisible(not attended)

    -- 다른 클랜의 정보를 보는 경우 nil처리를 하였음
    if (not vars['adminBtn']) then
        return
    end

    -- 맴버 권한별 버튼 노출 여부 지정
    local my_member_type = g_clanData:getMyMemberType()
    local member_type = self.m_structUserInfo:getMemberType()
    if (my_member_type and member_type) then

        if (member_type == 'master') then
            vars['adminBtn']:setVisible(false)

        elseif (my_member_type == 'master') then
            vars['adminBtn']:setVisible(true)

        elseif (my_member_type == 'manager') and (member_type == 'member') then
            vars['adminBtn']:setVisible(true)

        else
            vars['adminBtn']:setVisible(false)
        end
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_ClanMemberListItem:click_infoBtn()
    local uid = self.m_structUserInfo:getUid()
    local is_visit = true
    RequestUserInfoDetailPopup(uid, is_visit)
end

-------------------------------------
-- function click_adminBtn
-------------------------------------
function UI_ClanMemberListItem:click_adminBtn()
    local vars = self.vars
    vars['adminMenu']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_banishBtn
-- @brief 추방 버튼 클릭
-------------------------------------
function UI_ClanMemberListItem:click_banishBtn()
    local user_info = self.m_structUserInfo
    local member_uid = user_info:getUid()

    local work_ask
    local work_request
    local work_response

    work_ask = function()
        local msg = Str('클랜원을 추방하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, work_request)
    end

    work_request = function()
        g_clanData:request_kick(work_response, nil, member_uid)
    end

    work_response = function(ret)
        if self.m_refreshCB then
            self.m_refreshCB()
        end

        self:delThis()
    end

    work_ask()
end

-------------------------------------
-- function click_masterBtn
-- @brief 마스터로 지정
-------------------------------------
function UI_ClanMemberListItem:click_masterBtn()
    local my_member_type = g_clanData:getMyMemberType()
    if (my_member_type ~= 'master') then
        UIManager:toastNotificationRed(Str('권한이 없습니다.'))
        return
    end

    local user_info = self.m_structUserInfo
    local member_type = user_info:getMemberType()
    local member_uid = user_info:getUid()

    if (member_type == 'master') then
        return
    end

    if (member_type == 'member') then
        UIManager:toastNotificationRed(Str('부마스터에게만 마스터를 지정할 수 있습니다.'))
        return
    end

    if (member_type == 'manager') then
        local work_ask
        local work_request
        local work_response

        work_ask = function()
            local msg = Str('부마스터를 마스터로 지정하시겠습니까?')
            local sub_msg = Str('(마스터를 지정하면 부마스터의 지위로 내려가게 됩니다)')
            MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, sub_msg, work_request)
        end

        work_request = function()
            g_clanData:request_setAuthority(work_response, nil, member_uid, 'master')
        end

        work_response = function(ret)
            -- 클랜을 양도하였기 때문에 즉시 클랜 정보 갱신 필요함
            if g_clanData:isNeedClanInfoRefresh() then
                UINavigator:closeClanUI()
                UINavigator:goTo('clan')
            end
        end

        work_ask()
        
        return
    end
end

-------------------------------------
-- function click_subMasterBtn
-- @brief 부마스터로 지정
-------------------------------------
function UI_ClanMemberListItem:click_subMasterBtn()
    local my_member_type = g_clanData:getMyMemberType()
    if (my_member_type ~= 'master') then
        UIManager:toastNotificationRed(Str('권한이 없습니다.'))
        return
    end

    -- 부마스터 인원 체크
    local manager_cnt = g_clanData.m_structClan:managerCntCalc()
    if (3 <= manager_cnt) then
        UIManager:toastNotificationRed(Str('부마스터는 3명까지만 지정 가능합니다.'))
        return
    end

    local user_info = self.m_structUserInfo
    local member_type = user_info:getMemberType()
    local member_uid = user_info:getUid()

    if (member_type == 'manager') then
        UIManager:toastNotificationRed(Str('이미 부마스터로 지정되었습니다.'))
        return
    end

    -- 절대로 들어올 수 없는 케이스이지만 그냥 구색상 넣어둠
    if (member_type == 'master') then
        return
    end

    if (member_type == 'member') then
        local work_ask
        local work_request
        local work_response

        work_ask = function()
            local msg = Str('클랜원을 부마스터로 지정하시겠습니까?')
            MakeSimplePopup(POPUP_TYPE.YES_NO, msg, work_request)
        end

        work_request = function()
            g_clanData:request_setAuthority(work_response, nil, member_uid, 'manager')
        end

        work_response = function(ret)
            -- 정보 갱신
            self.m_structUserInfo = g_clanData.m_structClan:getMemberStruct(member_uid)
            self:refresh()
        end

        work_ask()
        
        return
    end
end

-------------------------------------
-- function click_memberBtn
-- @brief 클랜원으로 지정
-------------------------------------
function UI_ClanMemberListItem:click_memberBtn()
    local my_member_type = g_clanData:getMyMemberType()
    if (my_member_type ~= 'master') and (my_member_type ~= 'manager') then
        UIManager:toastNotificationRed(Str('권한이 없습니다.'))
        return
    end

    local user_info = self.m_structUserInfo
    local member_type = user_info:getMemberType()
    local member_uid = user_info:getUid()

    if (member_type == 'member') then
        UIManager:toastNotificationRed(Str('이미 클랜원으로 지정되었습니다.'))
        return
    end

    -- 절대로 들어올 수 없는 케이스이지만 그냥 구색상 넣어둠
    if (member_type == 'master') then
        return
    end

    if (member_type == 'manager') then
        local work_ask
        local work_request
        local work_response

        work_ask = function()
            local msg = Str('부마스터를 클랜원으로 지정하시겠습니까?')
            MakeSimplePopup(POPUP_TYPE.YES_NO, msg, work_request)
        end

        work_request = function()
            g_clanData:request_setAuthority(work_response, nil, member_uid, 'member')
        end

        work_response = function(ret)
            -- 정보 갱신
            self.m_structUserInfo = g_clanData.m_structClan:getMemberStruct(member_uid)
            self:refresh()
        end
        
        work_ask()

        return
    end
end

-------------------------------------
-- function setRefreshCB
-- @brief
-------------------------------------
function UI_ClanMemberListItem:setRefreshCB(refresh_cb)
    self.m_refreshCB = refresh_cb
end