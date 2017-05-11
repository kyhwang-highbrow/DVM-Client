local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ChatIgnoreListItem
-------------------------------------
UI_ChatIgnoreListItem = class(PARENT, {
        m_data = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatIgnoreListItem:init(data)
    self.m_data = data

    local vars = self:load('chat_block_ltem.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatIgnoreListItem:initUI()
    local vars = self.vars

    vars['infoLabel']:setString(self.m_data['nickname'])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatIgnoreListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatIgnoreListItem:refresh()
    local vars = self.vars
end