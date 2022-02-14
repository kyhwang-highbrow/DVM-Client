local PARENT = UI_Package

-------------------------------------
-- class UI_Package_AdventureClear01
-------------------------------------
UI_Package_AdventureClear01 = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AdventureClear01:init(struct_product, is_popup)
    -- 모험돌파 패키지 구매 전, 기능 설정하지않고 return UI만 출력
    if (struct_product) then
        self.vars['closeBtn']:setVisible(false)
        self.vars['closeBtn']:setEnabled(false)
        return
    end

    local vars = self:load('package_adventure_clear.ui')
    
    self.m_isPopup = is_popup or false
    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_AdventureClear01')
    end

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
    self:refresh()
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AdventureClear01:refresh()
    PARENT.refresh(self)

    self:init_tableView()

    local vars = self.vars
    if g_adventureClearPackageData01:isActive() then
        vars['completeNode']:setVisible(true)
        vars['contractBtn']:setVisible(false)
        vars['buyBtn']:setVisible(false)
    else
        vars['completeNode']:setVisible(false)
        vars['buyBtn']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AdventureClear01:initButton()
    local vars = self.vars

    vars['closeBtn']:setVisible(true)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['closeBtn2']:registerScriptTapHandler(function() self:setInfoPopup(false) end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:setInfoPopup(false) end)
end

-------------------------------------
-- function setInfoPopup
-------------------------------------
function UI_Package_AdventureClear01:setInfoPopup(visible)
   local vars = self.vars
   vars['popupMenu']:setVisible(visible)
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_Package_AdventureClear01:init_tableView()
    local vars = self.vars
    vars['productNode']:removeAllChildren()
    vars['productNodeLong']:removeAllChildren()

    local node = vars['productNode']
    if g_adventureClearPackageData01:isActive() then
        node = vars['productNodeLong']
        vars['productNode']:setVisible(false)
        vars['productNodeLong']:setVisible(true)
    else
        vars['productNode']:setVisible(true)
        vars['productNodeLong']:setVisible(false)
    end

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 80+5)
    table_view:setCellUIClass(UI_Package_AdventureClearListItem01, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)


    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_item_list = TABLE:get('table_package_stage')
    table_view:setItemList(l_item_list)

    do -- 정렬
        local function sort_func(a, b)
            local a_value = a['data']['stage']
            local b_value = b['data']['stage']
            return a_value < b_value
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    -- 보상 받기 가능한 idx로 이동
    local stage_id, idx = g_adventureClearPackageData01:getFocusRewardStage()
    if stage_id then
        table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        table_view:relocateContainerFromIndex(idx, false)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_AdventureClear01:click_buyBtn()
	local struct_product = self.m_structProduct

    if (not struct_product) then
        return
    end

	local function cb_func(ret)
        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        -- 갱신
        self:request_serverInfo()
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function request_serverInfo
-------------------------------------
function UI_Package_AdventureClear01:request_serverInfo()
    local function cb_func()
        self:refresh()
    end

    g_adventureClearPackageData01:request_adventureClearInfo(cb_func)
end
