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
        
        --masterBtn
        --subMasterBtn
        --memberBtn
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanMemberListItem:refresh()
    local vars = self.vars

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
-- function setRefreshCB
-- @brief
-------------------------------------
function UI_ClanMemberListItem:setRefreshCB(refresh_cb)
    self.m_refreshCB = refresh_cb
end