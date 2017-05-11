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
	ccdump(t_data)
	-- UI load
	self:load('mail_item.ui')

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
    local t_mail_data = self:makePrettyData(self.m_mailData)

    -- 우편 제목
    vars['mailLabel']:setString(t_mail_data['title'])

	-- 우편 본문
    vars['infoLabel']:setString(t_mail_data['context'])

    -- 유효 기간 (남은 시간)
    vars['timeLabel']:setString(g_mailData:getExpireRemainTimeStr(self.m_mailData))

    -- 아이템 아이콘
    self:makeMailItemIcons(self.m_mailData)
end

-------------------------------------
-- function makeMailItemIcons
-------------------------------------
function UI_MailListItem:makeMailItemIcons(t_mail_data)
    local l_item_list = t_mail_data['items_list']

    for i,v in ipairs(l_item_list) do
        local item_id = v['item_id']
        local count = v['count']

        local ui = UI_ItemCard(item_id, count)
        ui.root:setSwallowTouch(false)
        ui.root:setPositionX((i-1) * -150)

        self.vars['rewardNode']:addChild(ui.root)
    end
end

-------------------------------------
-- function makePrettyData
-------------------------------------
function UI_MailListItem:makePrettyData(t_mail_data)
	local t_mail_context = t_mail_data['msg_content']['data']
	local event_type = t_mail_data['msg_content']['event']

	local t_mail_text = MailHelper:getMailText(event_type, t_mail_context)

	-- 메일 제목
	local mail_title = t_mail_text['title']
	if (mail_title == '') then
		mail_title = t_mail_context['title']
	end

	-- 메일 본문
	local mail_context = t_mail_text['context']
	if (mail_context == '') then
		mail_context = t_mail_data['msg']
	end

	return {title = mail_title, context = mail_context}
end