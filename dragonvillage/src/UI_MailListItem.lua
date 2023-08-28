local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_MailListItem
-------------------------------------
UI_MailListItem = class(PARENT, {
        m_mailData = 'StructMail',
        m_noticeReadNotiIcon = 'cc.Sprite'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MailListItem:init(t_data)
	-- 멤버 변수
	self.m_mailData = t_data

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

    -- 공지의 경우
    if (self.m_mailData:isNotice()) then
        -- 중앙 정렬
        vars['mailLabel']:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        -- 공백 없이 개행
        vars['mailLabel']:setLineBreakWithoutSpace(true)
        -- 사이즈 조절
        vars['mailLabel']:setDimensions(800, 100)
    end
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
    local is_notice = self.m_mailData:isNotice()
    if (is_notice) then
        self:refreshNotice()
        return
    end
    
    local vars = self.vars
    local t_text = self.m_mailData:getMailTitleAndContext()

    -- 우편 제목
    vars['mailLabel']:setString(t_text['title'])


    vars['infoLabel']:setString(t_text['content'])

    -- 유효 기간 (남은 시간)
    vars['timeLabel']:setString(self.m_mailData:getExpireRemainTimeStr())

    -- 아이템 아이콘
    self:makeMailItemIcons(self.m_mailData)
end

-------------------------------------
-- function refreshNotice
-------------------------------------
function UI_MailListItem:refreshNotice()
    local vars = self.vars
    local t_text = self.m_mailData:getMailTitleAndContext()

    -- 우편 제목
    vars['mailLabel']:setString(t_text['title'])
    vars['mailLabel']:setPositionY(0)

    -- 내용과 시간은 가림
    vars['infoLabel']:setVisible(false)
    vars['timeLabel']:setVisible(false)

    vars['rewardNode']:removeAllChildren()

    -- 읽은 공지
    if (self.m_mailData:isNoticeRead()) then
        if (self.m_noticeReadNotiIcon) then
            self.m_noticeReadNotiIcon:removeFromParent()
        end
    -- 안읽은 공지 : 아이콘
    else
        -- 보상 버튼에 붙은 아이콘은 어차피 안보일테니까..
        UIHelper:attachNotiIcon(vars['rewardBtn'])
        self.m_noticeReadNotiIcon = UIHelper:attachNotiIcon(vars['openBtn'])
    end

    -- 보상 있으면 보상 아이템 보여줌
    if (self.m_mailData:isNoticeHasReward()) then
        --self:makeMailItemIcons(self.m_mailData)
        self:setRewardNotice()
    -- 보상 이미 받았거나 없는 경우
    else
        self:setReceivedNotice()
    end
end

-------------------------------------
-- function setRewardNotice
-------------------------------------
function UI_MailListItem:setRewardNotice()
    self.vars['rewardBtn']:setVisible(false)
    self.vars['openBtn']:setVisible(true)
    -- 무조건 공지팝업을 오픈
    -- readNotice 함수의 두번쨰 파라미터가 팝업을 열지 보상요청을 할지 결정
    self.vars['openBtn']:registerScriptTapHandler(function()
        self.m_mailData:readNotice(function() self:refreshNotice() end, true)
    end)

    self:makeMailItemIcons(self.m_mailData)
end

-------------------------------------
-- function setReceivedNotice
-------------------------------------
function UI_MailListItem:setReceivedNotice()
    self.vars['rewardBtn']:setVisible(false)
    self.vars['openBtn']:setVisible(true)
    -- 무조건 공지팝업을 오픈
    -- readNotice 함수의 두번쨰 파라미터가 팝업을 열지 보상요청을 할지 결정
    self.vars['openBtn']:registerScriptTapHandler(function()
        self.m_mailData:readNotice(function() self:refreshNotice() end, true)
    end)

    local icon = IconHelper:getIcon('res/ui/icons/item/dvm.png')
    self.vars['rewardNode']:addChild(icon)
end

-------------------------------------
-- function makeMailItemIcons
-------------------------------------
function UI_MailListItem:makeMailItemIcons(struct_mail)
    local l_item_list = struct_mail:getItemList()
    
    for i,v in ipairs(l_item_list) do
        local item_id = v['item_id']
        local count = v['count']

        local ui = UI_ItemCard(item_id, count)
        ui.root:setSwallowTouch(false)
        ui.root:setPositionX((i-1) * -150)

        self.vars['rewardNode']:addChild(ui.root)
    end
end