local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_MailPopup
-------------------------------------
UI_MailPopup = class(PARENT, {
		m_mTableView = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MailPopup:init()
	self.m_mTableView = {}

	local vars = self:load('mail_popup.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_MailPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	-- 통신 후 UI 출력
	local cb_func = function()
		self:initUI()
		self:initTab()
		self:initButton()
		self:refresh()
	end 
	g_mailData:request_mailList(cb_func)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MailPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MailPopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('우편함')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MailPopup:initUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_MailPopup:initTab()
    local vars = self.vars
    self:addTab('mail', vars['mailBtn'], vars['mailNode'])
    self:addTab('friend', vars['friendBtn'], vars['friendNode'])
    self:setTab('mail')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MailPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MailPopup:refresh()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_MailPopup:onChangeTab(tab, first)
	-- 최초 생성만 실행
	if first then 
        local node = self.vars[tab .. 'ListNode']
		self:makeMailTableView(tab, node)
	end
end

-------------------------------------
-- function makeMailTableView
-------------------------------------
function UI_MailPopup:makeMailTableView(tab, node)
    local vars = self.vars

	local t_item_list = self:getMailList(tab)
	
	local create_cb_func = function(ui, data)
        local function click_rewardBtn()
            local t_mail_data = data
            self:click_rewardBtn(t_mail_data)
        end
        ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 108)
    table_view:setCellUIClass(UI_MailListItem, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(t_item_list)
    table_view:makeDefaultEmptyDescLabel(Str('우편물이 없습니다.'))

    self.m_mTableView[tab] = table_view
end

-------------------------------------
-- function getMailList
-- @brief tab의 타입별 메일리스트 리턴
-------------------------------------
function UI_MailPopup:getMailList(tab)
    local item_list

    -- 우편함(우정포인트 우편 제외)
    if (tab == 'mail') then
        item_list = g_mailData:getMailList_withoutFp()

    -- 우정포인트 우편함
    elseif (tab == 'friend') then
        item_list = g_mailData:getFpMailList()

    else
        error('tab : ' .. tab)
    end

    return item_list
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_MailPopup:click_rewardBtn(t_mail_data)

    local mail_id_list = {t_mail_data['id']}
    local function finish_cb(ret)
        if (ret['status'] == 0) then
            self.m_mTableView[self.m_currTab]:delItem(t_mail_data['id'])
        end
    end
    
    g_mailData:request_mailRead(mail_id_list, finish_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MailPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_MailPopup)