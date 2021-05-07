local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanAcceptListItem
-------------------------------------
UI_ClanAcceptListItem = class(PARENT, {
        m_structUserInfo = 'StructUserInfoClan',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanAcceptListItem:init(data)
    self.m_structUserInfo = data
    local vars = self:load('clan_item_member.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanAcceptListItem:initUI()
    local vars = self.vars

    local user_info = self.m_structUserInfo

    -- 티어 아이콘
    local tier = user_info:getArenaTier()

    vars['tierNode']:removeAllChildren()
    local icon = StructUserInfoArenaNew:makeTierIcon(tier, 'big')
    vars['tierNode']:addChild(icon)

    -- 티어 이름
    local tier_name = StructUserInfoArenaNew:getTierName(tier)
    vars['tierLabel']:setString(tier_name)

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

    do -- 사용하지 않는 UI off
        vars['positionLabel']:setVisible(false)
        vars['attendanceNode']:setVisible(false)
        vars['adminBtn']:setVisible(false)
    end

    do -- 승인 UI에서만 사용하는 UI on
        vars['acceptBtn']:setVisible(true)
        vars['refuseBtn']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanAcceptListItem:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['acceptBtn']:registerScriptTapHandler(function() self:click_acceptBtn() end)
    vars['refuseBtn']:registerScriptTapHandler(function() self:click_refuseBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanAcceptListItem:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_ClanAcceptListItem:click_infoBtn()
    local uid = self.m_structUserInfo:getUid()
    local is_visit = true
    RequestUserInfoDetailPopup(uid, is_visit)
end

-------------------------------------
-- function click_acceptBtn
-- @brief 가입 승인 버튼 클릭
-------------------------------------
function UI_ClanAcceptListItem:click_acceptBtn()
    local user_info = self.m_structUserInfo
    local req_uid = user_info:getUid()

    local function finish_cb(ret)
        self:delThis()
    end

    local fail_cb = nil

    g_clanData:request_accept(finish_cb, fail_cb, req_uid)
end

-------------------------------------
-- function click_refuseBtn
-- @brief 가입 거절 버튼 클릭
-------------------------------------
function UI_ClanAcceptListItem:click_refuseBtn()
    local user_info = self.m_structUserInfo
    local req_uid = user_info:getUid()

    local function finish_cb(ret)
        self:delThis()
    end

    local fail_cb = nil

    g_clanData:request_reject(finish_cb, fail_cb, req_uid)
end


