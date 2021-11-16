local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())
local RENEW_INTERVAL = 10

-------------------------------------
-- class UI_MailPopup
-------------------------------------
UI_MailPopup = class(PARENT, {
		m_mTableView = '',
		m_preRenewTime = 'time',
        m_dirty = 'bool',
        m_tNotiSpriteTable = 'sprite',
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
	self:doActionReset()
	self:doAction(nil, false)

    self.m_dirty = false
    self.m_tNotiSpriteTable = {}

	-- 통신 후 UI 출력
	self:initUI()
    self:initTab()
    self:initButton()
    --self:refresh()

	--g_mailData:request_mailList(cb_func)
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
	local l_tab = g_mailData:getMailCategoryList()
	for _, tab in pairs(l_tab) do
		self:addTabAuto(tab, vars, vars[tab .. 'ListNode'])
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
function UI_MailPopup:refresh(tab)
    local vars = self.vars
    local tab = tab or self.m_currTab
    
    -- 현재 탭의 메일이 없다면 이미지 출력
    vars['emptySprite']:setVisible(self.m_mTableView[tab]:getItemCount() == 0)
    
    -- 아이템 및 공지 탭 모두 받기 막음
    local is_block_read_all = (tab == 'notice')
    vars['rewardAllBtn']:setVisible(not is_block_read_all)

    -- noti 갱신
	self:refresh_noti()
end

-------------------------------------
-- function refresh_noti
-------------------------------------
function UI_MailPopup:refresh_noti()
    UIHelper:autoNoti(g_mailData:getNewMailMap(), self.m_tNotiSpriteTable, 'TabBtn', self.vars)
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

    self:refresh(tab)
end

-------------------------------------
-- function makeMailTableView
-------------------------------------
function UI_MailPopup:makeMailTableView(tab, node)

	local t_item_list = g_mailData:getMailList(tab)

	-- item ui에 보상 수령 함수 등록하는 콜백 함수
	local create_cb_func = function(ui, data)
        -- 보상 버튼 등록
        local function click_rewardBtn()
            self:click_rewardBtn(ui, data)
        end
        ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein_fast'])

    table_view.m_defaultCellSize = cc.size(1160, 115)
    table_view:setCellUIClass(UI_MailListItem, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(t_item_list)

	-- 정렬
	if (tab == 'notice') then
		g_mailData:sortNoticeList(table_view.m_itemList)
	else
		g_mailData:sortMailList(table_view.m_itemList)
	end

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
				if (tab == 'notice') then
					g_mailData:sortNoticeList(table_view.m_itemList)
				else
					g_mailData:sortMailList(table_view.m_itemList)
				end
			end
            self:refresh()
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
-- function click_renewBtn_force
-- @brief 우편 갱신 통신까지 강제로
-------------------------------------
function UI_MailPopup:click_renewBtn_force()
    local cb_func = function()
    	for tab, table_view in pairs(self.m_mTableView) do 
    		local t_item_list = g_mailData:getMailList(tab)
    		table_view:setItemList(t_item_list)
    		if (tab == 'notice') then
    			g_mailData:sortNoticeList(table_view.m_itemList)
    		else
    			g_mailData:sortMailList(table_view.m_itemList)
    		end
    	end
        self:refresh()
    end
    g_mailData:request_mailList(cb_func)
    self.m_preRenewTime = Timer:getServerTime()	
end

-------------------------------------
-- function click_rewardBtn
-- @brief 단일 보상 수령
-------------------------------------
function UI_MailPopup:click_rewardBtn(ui, struct_mail)
    -- @jhakim 190701
    -- 닉네임 변경권 수령전에 (신규유저라면 무료 변경 가능하다는) 팝업 띄워줘야 해서 수령 전 조건 체크 함수 추가
    if (self:canNotReward(struct_mail)) then
        return
    end
    
    -- 읽고 난 후 콜백은 동일
	local function success_cb(is_refresh) -- 우편함 갱신(통신 한번 더)
		if (struct_mail:isNotice()) then
			ui:refreshNotice()
		else
			-- 메일 삭제
			self.m_mTableView[self.m_currTab]:delItem(struct_mail:getMid())
		end

        -- 우편함 갱신
        self:refresh()
        -- 더티 처리
        self.m_dirty = true

        if (is_refresh) then
            self:click_renewBtn_force() -- is_force
        end
    end

    self:check_readType(struct_mail, success_cb)
end

-------------------------------------
-- function canNotReward
-------------------------------------
function UI_MailPopup:canNotReward(struct_mail)
    if (not struct_mail) then
        return false
    end
    
    local l_mail_item = struct_mail:getItemList() or {}
    
    for _, data in ipairs(l_mail_item) do
        if (data['item_id']) then
            -- 닉네임 변경권일 경우
            if (data['item_id'] == 700301) then
                -- 닉네임 최초 1회 변경했는지 여부값 갱신        
                local first_nick_change = g_userData:isFirstNickChange()
                if (first_nick_change) then
                    UI_SimplePopup(POPUP_TYPE.OK, Str('유저 상세 정보에서 처음 1회만 변경권 없이 닉네임 변경을 할 수 있습니다.'), nil, nil)
                    return true
                end
            end
        end  
    end

    return false
end

-------------------------------------
-- function check_readType
-- @brief 메일 타입별 액션 - 외부에서도 쓰기 위해 분리함 (UI_MailSelectPopup)
-------------------------------------
function UI_MailPopup:check_readType(struct_mail, success_cb)

    -- 일반 메일 외에 별도 처리가 필요한 것들을 걸러냄
    -- 종류가 너무 많아진다면 여기에서 처리하지 말구 더 분화하자
    -- 닉네임 변경권
    if (struct_mail:isChangeNick()) then
        struct_mail:readChangeNick(success_cb)
	
	-- 아이템 선택권
	elseif (struct_mail:isPickItem()) then
        struct_mail:readPickItem(success_cb)
    -- 드래곤 선택권
	elseif (struct_mail:isPick()) then
        struct_mail:readPickDragon(success_cb)

    -- 부스터 아이템
    elseif (struct_mail:isBooster()) then
        struct_mail:readBoosterItem(success_cb)
        
	-- 공지
    elseif (struct_mail:isNotice()) then
        -- callback 뒤 flag는 공지 팝업을 띄울지 판단한다
        -- 공동로직을 파괴 안하고 메일에서 보상형 공지를 보기 위함
        struct_mail:readNotice(success_cb, true)
		
    -- 나머지
    else
        struct_mail:readMe(success_cb)
    end
end

-------------------------------------
-- function click_rewardAllBtn
-- @brief 확정권을 제외한 모든 보상 수령
-------------------------------------
function UI_MailPopup:click_rewardAllBtn()    
	-- 우편이 없다면 탈출
	local possible = g_mailData:canReadAll(self.m_currTab)
	if (not possible) then 
		if (self.m_currTab == 'item') then
			UIManager:toastNotificationRed(Str('모두 받기가 가능한 아이템이 없습니다.'))
		else
			UIManager:toastNotificationRed(Str('수령할 수 있는 메일이 없습니다.'))
		end
		return
	end

	-- 우편 모두 받기 콜백
	local get_all_reward_cb = function() 
		local function finish_cb(ret, mail_id_list)

			UI_ObtainPopup(ret['added_items']['items_list'], nil, nil, true)
			
			for _, mail_id in pairs(mail_id_list) do
				self.m_mTableView[self.m_currTab]:delItem(mail_id)
			end
            
            -- 우편함 갱신
            self:refresh()
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
    -- close cb는 dirty일때만 실행하도록 한다.
    self.m_closeCB(self.m_dirty)
    self.m_closeCB = nil

    self:close()
end

--@CHECK
UI:checkCompileError(UI_MailPopup)