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

	local vars = self:load('mail.ui')
	UIManager:open(self, UIManager.SCENE)

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
	local l_tab = g_mailData:getMailTypeList()
	for _, tab in pairs(l_tab) do
		self:addTab(tab, vars[tab .. 'Btn'], vars[tab .. 'ListNode'])
	end
    self:setTab('goods')
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
			
			-- 확정권인 경우
			if (g_mailData:checkTicket(t_mail_data)) then
				-- 드래곤은 결과 화면으로
				if (#ret['added_items']['dragons'] > 0) then
					UI_GachaResult_Dragon(ret['added_items']['dragons'])

				-- 룬은 룬 결과 화면
				elseif (#ret['added_items']['runes'] > 0) then
                    local item_id, count, t_sub_data = g_itemData:parseAddedItems_firstItem(ret['added_items'] or ret['add_items'])
                    local ui = MakeSimpleRewarPopup(Str('룬'), item_id, count, t_sub_data)
				
				-- 그외는 보상 수령
				else
					UI_ToastPopup()

				end
			else
				-- 단일 보상 수령 시 토스트 팝업
				local t_item = t_mail_data['items_list'][1]
				local item_str = UIHelper:makeItemStr(t_item)
				UI_ToastPopup(item_str)
			end

            -- 노티 정보를 갱신하기 위해서 호출
            g_highlightData:setLastUpdateTime()
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
	local possible = g_mailData:canReadAll(self.m_currTab)
	if (not possible) then 
		UIManager:toastNotificationRed(Str('수령할 수 있는 메일이 없습니다.'))
		return
	end

	-- 우편 모두 받기 콜백
	local get_all_reward_cb = function() 
		local function finish_cb(ret, mail_id_list)
			
			-- 모두 받기의 경우 리스트 팝업
			UI_ObtainPopup(ret['added_items']['items_list'])

			for _, mail_id in pairs(mail_id_list) do
				self.m_mTableView[self.m_currTab]:delItem(mail_id)
			end

            -- 노티 정보를 갱신하기 위해서 호출
            g_highlightData:setLastUpdateTime()
		end
		g_mailData:request_mailReadAll(self.m_currTab, finish_cb)
	end

	-- 시작
	get_all_reward_cb()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MailPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_MailPopup)