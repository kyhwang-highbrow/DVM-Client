local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_MailListItem
-------------------------------------
UI_MailListItem = class(PARENT, {
        m_mailData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MailListItem:init(t_data)
	-- 멤버 변수
	self.m_mailData = t_data
    
	-- UI load
	self:load('mail_list_item.ui')

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MailListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MailListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MailListItem:refresh()
    local vars = self.vars
    local t_mail_data = self.m_mailData

    -- 우편 메세지
    vars['mailLabel']:setString(t_mail_data['msg'])

    -- 유효 기간 (남은 시간)
    vars['timeLabel']:setString(g_mailData:getExpireRemainTimeStr(t_mail_data))

    -- 아이템 아이콘
    local icon = self:makeMailItemIcon(t_mail_data)
    vars['rewardNode']:addChild(icon.root)

    -- 아이템 갯수
    vars['rewardLabel']:setString('X ' .. comma_value(t_mail_data['cnt']))
end

-------------------------------------
-- function makeMailItemIcon
-------------------------------------
function UI_MailListItem:makeMailItemIcon(t_mail_data)
    local t_item = t_mail_data['values']
    local count = t_mail_data['count']

    local type = t_mail_data['type']
    local item_id

    if (type == 'rune') then
        item_id = t_item['rid']

    elseif (type == 'fruit') then
        item_id = t_item['fid']
    end

    local ui = UI_ItemCard(item_id, count)
    ui.root:setSwallowTouch(false)
    return ui
end