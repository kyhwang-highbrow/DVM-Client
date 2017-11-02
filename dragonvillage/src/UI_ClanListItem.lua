local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanListItem
-------------------------------------
UI_ClanListItem = class(PARENT, {
        m_structClan = 'StructClan',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanListItem:init(data)
    self.m_structClan = data
    local vars = self:load('clan_item_info.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanListItem:initUI()
    local vars = self.vars

    local struct_clan = self.m_structClan

    -- 클랜 마크(문장)
    local icon = struct_clan:makeClanMarkIcon()
    vars['userNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['nameLabel']:setString(clan_name)
    
    -- 마스터 닉네임
    local master_nick = struct_clan:getMasterNick()
    vars['masterLabel']:setString(master_nick)

    -- 클랜원
    local member_cnt_text = struct_clan:getMemberCntText()
    vars['memberLabel']:setString(member_cnt_text)

    -- 자동 가입 여부
    local is_auto_join = struct_clan:isAutoJoin()
    vars['autoNode']:setVisible(is_auto_join)

    -- 클랜 소개
    local intro_text = struct_clan:getClanIntroText()
    vars['introduceLabel']:setString(intro_text)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanListItem:refresh()
    local vars = self.vars
end