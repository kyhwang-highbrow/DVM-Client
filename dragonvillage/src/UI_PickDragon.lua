local PARENT = UI

-------------------------------------
-- class UI_PickDragon
-------------------------------------
UI_PickDragon = class(PARENT,{
		m_orgDragonList = 'list',

		m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManager = 'SortManager',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PickDragon:init(mid, item_id, cb_func)
    local vars = self:load('popup_select_regend.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_PickDragon'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_PickDragon')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

	self.m_orgDragonList = TablePickDragon:getDragonList(item_id)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PickDragon:initUI()
    local vars = self.vars

    self:initTableView()
	self:initSortManager()
	self:initRadioButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PickDragon:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function initRadioButton
-------------------------------------
function UI_PickDragon:initRadioButton()
    local vars = self.vars

    do -- 역할(role)
        local radio_button = UIC_RadioButton()
        radio_button:addButtonWithLabel('all', vars['roleAllRadioBtn'], vars['roleAllRadioLabel'])
        radio_button:addButtonAuto('tanker', vars)
        radio_button:addButtonAuto('dealer', vars)
        radio_button:addButtonAuto('supporter', vars)
        radio_button:addButtonAuto('healer', vars)
        radio_button:setSelectedButton('all')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_roleRadioButton = radio_button
    end

    do -- 속성(attribute)
        local radio_button = UIC_RadioButton()
        --radio_button:addButton('all', vars['attrAllBtn'])
        radio_button:addButtonAuto('fire', vars)
        radio_button:addButtonAuto('water', vars)
        radio_button:addButtonAuto('earth', vars)
        radio_button:addButtonAuto('dark', vars)
        radio_button:addButtonAuto('light', vars)
        radio_button:setSelectedButton('fire')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

    -- 최초에 한번 실행
    self:onChangeOption()
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_PickDragon:onChangeOption()
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton

    local l_item_list = {}
	for _, t_dragon in ipairs(self.m_orgDragonList) do
		local b = true

		-- 직군
		if (role_option ~= 'all') and (role_option ~= t_dragon['role']) then 
			b = false
		end

		-- 속성
		if (attr_option ~= t_dragon['attr']) then
			b = false
		end

		if (b) then
			table.insert(l_item_list, t_dragon)
		end
	end
	
    -- 리스트 갱신
    self.m_tableViewTD:setItemList(l_item_list)

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_PickDragon:initTableView()
    local node = self.vars['listNode']

    local l_item_list = {}

	-- cell_size 지정
    local item_size = 150
    local item_scale = 14/15
    local cell_size = cc.size(item_size*item_scale + 0, item_size*item_scale + 0)

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data['did']
		local t_data = {['evolution'] = 1}
		local ui = MakeSimpleDragonCard(did, t_data)
		ui.root:setScale(item_scale)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 5
	table_view_td:setCellUIClass(create_func)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_item_list)

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function initSortManager
-- @brief
-------------------------------------
function UI_PickDragon:initSortManager()
    local sort_manager = SortManager_Dragon()
	
	-- did 순, 등급 순, 진화도 순으로 정렬
    sort_manager:pushSortOrder('did')
    sort_manager:pushSortOrder('grade')
	sort_manager:pushSortOrder('evolution')

    self.m_sortManager = sort_manager
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PickDragon:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_PickDragon:click_closeBtn()
    self:close()
end