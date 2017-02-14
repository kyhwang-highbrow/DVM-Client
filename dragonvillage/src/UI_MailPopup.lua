local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())
local RENEW_INTERVAL = 10

-------------------------------------
-- class UI_MailPopup
-------------------------------------
UI_MailPopup = class(PARENT, {
		m_mTableView = '',
		m_preRenewTime = 'time',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MailPopup:init()
	self.m_mTableView = {}
	self.m_preRenewTime = 0

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
	local vars = self.vars
	vars['renewBtn']:registerScriptTapHandler(function() self:click_renewBtn() end)
	vars['rewardAllBtn']:registerScriptTapHandler(function() self:click_rewardAllBtn() end)
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

	local t_item_list = g_mailData:getMailList(tab)

	-- item ui에 보상 수령 함수 등록하는 콜백 함수
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

    -- 정렬
    g_mailData:sortMailList(table_view.m_itemList)

    self.m_mTableView[tab] = table_view
end

-------------------------------------
-- function click_renewBtn
-- @brief 우편 갱신
-------------------------------------
function UI_MailPopup:click_renewBtn()
	-- 갱신 가능 시간인지 체크한다
	local curr_time = Timer:getServerTime()
	if (curr_time - self.m_preRenewTime > RENEW_INTERVAL) then
		-- 갱신 가능하다면 메일리스트를 다시 호출한다.
		local cb_func = function()
			for tab, table_view in pairs(self.m_mTableView) do 
				local t_item_list = g_mailData:getMailList(tab)
				table_view:setItemList(t_item_list)
				g_mailData:sortMailList(table_view.m_itemList)
			end
		end
		g_mailData:request_mailList(cb_func)
		self.m_preRenewTime = Timer:getServerTime()
	else
		-- 시간이 되지 않았다면 몇초 남았는지 토스트 메세지를 띄운다
		local ramain_time = math_ceil(RENEW_INTERVAL - (curr_time - self.m_preRenewTime) + 1)
		UIManager:toastNotificationRed(Str('{1}초 후에 갱신 가능합니다.', ramain_time))
	end
end

-------------------------------------
-- function click_rewardBtn
-- @brief 단일 보상 수령
-------------------------------------
function UI_MailPopup:click_rewardBtn(t_mail_data)
	local mail_id_list = {t_mail_data['id']}
	local function finish_cb(ret)
		if (ret['status'] == 0) then
			self.m_mTableView[self.m_currTab]:delItem(t_mail_data['id'])
			
			if (g_mailData:checkTicket(t_mail_data)) then
				if (#ret['added_items']['dragons'] > 0) then
					UI_GachaResult_Dragon(ret['added_items']['dragons'])
				elseif (#ret['added_items']['runes'] > 0) then
					UI_GachaResult_Rune(ret['added_items']['runes'])
				else
					UI_RewardPopup()
				end
			else
				UI_RewardPopup()
			end
		end
	end
    
	g_mailData:request_mailRead(mail_id_list, finish_cb)
end

-------------------------------------
-- function click_rewardAllBtn
-- @brief 확정권을 제외한 모든 보상 수령
-------------------------------------
function UI_MailPopup:click_rewardAllBtn()
	
	-- 우편이 없다면 탈출
	-- @TODO 확정권 구현 이후에는 확정권을 제외하고 카운트해야함
	if (g_mailData:countMailExceptTicket(self.m_currTab) == 0) then 
		UIManager:toastNotificationRed(Str('수령할 수 있는 메일이 없습니다.'))
		return
	end

	-- 우편 모두 받기 콜백
	local get_all_reward_cb = function() 
		local function finish_cb(ret, mail_id_list)
			if (ret['status'] == 0) then
				UI_RewardPopup()
				for _, mail_id in pairs(mail_id_list) do
					self.m_mTableView[self.m_currTab]:delItem(mail_id)
				end
			end
		end
		g_mailData:request_mailReadAll(self.m_currTab, finish_cb)
	end

	-- 시작
	if (self.m_currTab == 'mail') and (g_mailData:checkExistTicket()) then
		-- 확정권이 있는 경우에는 팝업을 띄워준다.
		MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('우편을 전부 수령하십니까?\n확정권은 모두 받기에서 제외됩니다.'), get_all_reward_cb)
	else
		get_all_reward_cb()
	end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MailPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_MailPopup)