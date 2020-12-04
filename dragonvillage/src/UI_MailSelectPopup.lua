local PARENT = UI
local RENEW_INTERVAL = 10

-------------------------------------
-- class UI_MailSelectPopup
-------------------------------------
UI_MailSelectPopup = class(PARENT, {
        m_selectType = 'number',
        m_selectMap = '',
		m_tableView = '',
        m_dirty = 'boolean',
        m_currTab = '',
    })

MAIL_SELECT_TYPE = {
    NONE = 0,
    EXP_BOOSTER = 1,    -- 경험치 부스터 
    GOLD_BOOSTER = 2,   -- 골드 부스터 
    STAMINA = 3,        -- 날개 
    GOODS = 4,          -- 재화
    CAPSULE_COIN = 5,   -- 캡슐 코인
	ITEM = 6,			-- 메일 아이템 탭
	EVOLUTION_PACK = 7,	-- 진화 패키지 구매 시
    UPDATE_PACK = 8,    -- 승급 패키지 구매 시
    ITEM_GOOD = 9,      -- 패키지 상품 구성이 아이템+재화 일 때
    GOODS_WITH_CLOSE_CB = 10,
    RUNE_STONE = 11,    -- 룬 원석
}

-------------------------------------
-- function init
-------------------------------------
function UI_MailSelectPopup:init(select_type)
    self.m_selectType = select_type
	
	local vars = self:load('mail_select.ui')
	UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_MailSelectPopup'
    self.m_dirty = false

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_MailSelectPopup')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton() 
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MailSelectPopup:initUI()
    local vars = self.vars
    self.m_selectMap = {}

    local title 

    local type = self.m_selectType
    if (type == MAIL_SELECT_TYPE.EXP_BOOSTER or type == MAIL_SELECT_TYPE.GOLD_BOOSTER) then

        title = Str('보유한 부스터 아이템')
        self:setBoosterItem()

    elseif (type == MAIL_SELECT_TYPE.STAMINA) then

        title = Str('보유한 날개')
        self:setItemByMailType('st')

    elseif (type == MAIL_SELECT_TYPE.GOODS) then

        title = Str('우편함')
        self:setItemByMailType('goods')
        self.m_currTab = 'goods' -- 탭이 지정되면 모두 받기 가능
    
    elseif (type == MAIL_SELECT_TYPE.GOODS_WITH_CLOSE_CB) then

        title = Str('우편함')
        self:setItemByMailType('goods')
        self.m_currTab = 'goods' -- 탭이 지정되면 모두 받기 가능
        self.m_dirty = true

    elseif (type == MAIL_SELECT_TYPE.CAPSULE_COIN) then
        title = Str('우편함')
        local item_id = TableItem():getItemIDFromItemType('capsule_coin')
        self:setItemByID(item_id)

    elseif (type == MAIL_SELECT_TYPE.RUNE_STONE) then
        title = Str('우편함')
        local item_id = TableItem():getItemIDFromItemType('rune_stone')
        self:setItemByID(item_id)

	elseif (type == MAIL_SELECT_TYPE.ITEM) then
        title = Str('우편함')
        self:setItemByMailType('item')

	elseif (type == MAIL_SELECT_TYPE.EVOLUTION_PACK) then
        title = Str('진화재료')
        self:setEvolutionPackageItems()

    elseif (type == MAIL_SELECT_TYPE.UPDATE_PACK) then
        title = Str('승급재료')
        self:setUpdatePackageItems()
    
    elseif (type == MAIL_SELECT_TYPE.ITEM_GOOD) then
        title = Str('우편함')
        self:setItemByMailType('goods')
        self:setItemByMailType('item')
        self.m_dirty = true
    end

    -- 타이틀
    if (title) then
        vars['titleLabel']:setString(title)
    else
        vars['titleLabel']:setVisible(false)
    end
    
    self:makeMailTableView()
	self:customSorting()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MailSelectPopup:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    if (self.m_currTab) then
        vars['rewardAllBtn']:setVisible(true)
        vars['rewardAllBtn']:registerScriptTapHandler(function() self:click_rewardAllBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MailSelectPopup:refresh()
end

-------------------------------------
-- function setBoosterItem
-------------------------------------
function UI_MailSelectPopup:setBoosterItem()
    local type = self.m_selectType
    local item_mail_map = g_mailData.m_mMailMap['item']
    if (item_mail_map) then
        for _, struct_mail in pairs(item_mail_map) do
            if (type == MAIL_SELECT_TYPE.EXP_BOOSTER and struct_mail:isExpBooster()) then
                local id = struct_mail:getMid()
                self.m_selectMap[id] = struct_mail
            end

            if (type == MAIL_SELECT_TYPE.GOLD_BOOSTER and struct_mail:isGoldBooster()) then
                local id = struct_mail:getMid()
                self.m_selectMap[id] = struct_mail
            end
        end
    end

    self.m_dirty = true
end

-------------------------------------
-- function setEvolutionPackageItems
-- @brief 진화 패키지 아이템을 가져온다 (슬라임 + 진화석)
-------------------------------------
function UI_MailSelectPopup:setEvolutionPackageItems()
    local item_type = self.m_selectType
    local item_mail_map = g_mailData.m_mMailMap['item']

    if (item_mail_map) then
        for _, struct_mail in pairs(item_mail_map) do
            if (struct_mail:isEvolutionStone()) or (struct_mail:isSlime()) then
                local id = struct_mail:getMid()
                self.m_selectMap[id] = struct_mail
            end
        end
    end

    self.m_dirty = true
end

-------------------------------------
-- function setUpdatePackageItems
-- @brief 승급 패키지 아이템을 가져온다 (슈펴/경험치 슬라임)
-------------------------------------
function UI_MailSelectPopup:setUpdatePackageItems()
    local item_type = self.m_selectType
    local item_mail_map = g_mailData.m_mMailMap['item']

    if (item_mail_map) then
        for _, struct_mail in pairs(item_mail_map) do
            if struct_mail:isSlime() then
                local id = struct_mail:getMid()
                self.m_selectMap[id] = struct_mail
            end
        end
    end

    self.m_dirty = true
end

-------------------------------------
-- function setItemByMailType
-------------------------------------
function UI_MailSelectPopup:setItemByMailType(mail_type)
    local item_mail_map = g_mailData.m_mMailMap[mail_type]
    if (item_mail_map) then
        for _, struct_mail in pairs(item_mail_map) do
            local id = struct_mail:getMid()
            self.m_selectMap[id] = struct_mail
        end
    end
end

-------------------------------------
-- function setItemByID
-------------------------------------
function UI_MailSelectPopup:setItemByID(item_id)
    for mail_type, item_mail_map in pairs(g_mailData.m_mMailMap) do
        for _, struct_mail in pairs(item_mail_map) do
            if (struct_mail:getItemList()[1]) then
                local _item_id = struct_mail:getItemList()[1]['item_id']
                if (_item_id == item_id) then
                    local id = struct_mail:getMid()
                    self.m_selectMap[id] = struct_mail
                end
            end
        end
    end
end

-------------------------------------
-- function makeMailTableView
-------------------------------------
function UI_MailSelectPopup:makeMailTableView()
    local vars = self.vars

	-- item ui에 보상 수령 함수 등록하는 콜백 함수
	local create_cb_func = function(ui, data)
        -- 보상 버튼 등록
        local function click_rewardBtn()
            local struct_mail = data
            self:click_rewardBtn(struct_mail)
        end
        ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
	end
   
    -- 테이블 뷰 인스턴스 생성
    local l_item_list = self.m_selectMap
    local node = vars['listNode']
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 115)
    table_view:setCellUIClass(UI_MailListItem, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    table_view:makeDefaultEmptyMandragora(Str('보유한 아이템이 없다고라.'))

    self.m_tableView = table_view
end

-------------------------------------
-- function customSorting
-------------------------------------
function UI_MailSelectPopup:customSorting()
	if (not self.m_tableView) then
		return
	end
	
	local mail_type = self.m_selectType
	local item_list = self.m_tableView.m_itemList

	-- 진화 패키지 구매시 : 최근 구매한 순 / 진화석-슬라임 순
	if (mail_type == MAIL_SELECT_TYPE.EVOLUTION_PACK) then
		local sort_manager = SortManager()

		-- 시간 오름 차순 (얼마 안남은 것부터)
		sort_manager:setDefaultSortFunc(function(a, b) 
				local a_data = a['data']
				local b_data = b['data']

				local a_value = a_data['expired_at']
				local b_value = b_data['expired_at']

				if (a_data:isEvolutionStone() and (not b_data:isEvolutionStone())) then
					return true
				elseif ((not a_data:isEvolutionStone()) and b_data:isEvolutionStone()) then
					return false
				else
					return a_value > b_value
				end
		end)

		sort_manager:sortExecution(item_list)
	else	
		-- 정렬
		g_mailData:sortMailList(item_list, true) -- is_reverse : 최근 받은 우편이 위로

	end
end

-------------------------------------
-- function click_rewardBtn
-- @brief 단일 보상 수령
-------------------------------------
function UI_MailSelectPopup:click_rewardBtn(struct_mail)
    local function success_cb()
        -- 메일 삭제
    	self.m_tableView:delItem(struct_mail:getMid())
        -- 더티 처리
        self.m_dirty = true
    end

    -- 코드 중복을 막기 위해 UI_MailPopup 클래스의 기능을 활용
    UI_MailPopup.check_readType(self, struct_mail, success_cb)
end

-------------------------------------
-- function click_rewardAllBtn
-- @brief 확정권을 제외한 모든 보상 수령
-------------------------------------
function UI_MailSelectPopup:click_rewardAllBtn()    
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
				self.m_tableView:delItem(mail_id)
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
-- function click_closeBtn
-------------------------------------
function UI_MailSelectPopup:click_closeBtn()
    -- close cb는 dirty일때만 실행하도록 한다.
    if (not self.m_dirty) then
        self.m_closeCB = nil
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_MailSelectPopup)