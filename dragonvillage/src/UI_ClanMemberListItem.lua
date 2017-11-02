local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanMemberListItem
-------------------------------------
UI_ClanMemberListItem = class(PARENT, {
        m_structUserInfo = 'StructUserInfoClan',
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanMemberListItem:initButton()
    local vars = self.vars
    vars['adminBtn']:registerScriptTapHandler(function() self:click_adminBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanMemberListItem:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_adminBtn
-------------------------------------
function UI_ClanMemberListItem:click_adminBtn()
    local vars = self.vars
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_ClanMemberListItem:click_infoBtn()
    local uid = self.m_structUserInfo:getUid()
    local is_visit = true
    RequestUserInfoDetailPopup(uid, is_visit)
end