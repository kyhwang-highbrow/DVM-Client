-------------------------------------
-- class UI_TeamBonus_Dragon
-------------------------------------
UI_TeamBonus_Dragon = class({
        m_owner_ui = '',

        m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',
        m_preAttr = 'string',

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManager = 'SortManager',

        m_detail_popup = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus_Dragon:init(owner_ui)
    self.m_owner_ui = owner_ui
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_TeamBonus_Dragon:onEnterTab(first)
    if (first) then
        self:initUI()
        self:initButton()
    end

    -- �� �˾� ����� ����Ʈ ���� ����
    if (self.m_detail_popup) then
        self.m_owner_ui.vars['dragonListNode1']:setVisible(false)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TeamBonus_Dragon:initUI()
    self:makeSortManager()
    self:initTableView()

    --- ������ �巡���� �ִٸ� ���Խ� �� �˾� ����
    local sel_did = self.m_owner_ui.m_selDid
    if (sel_did) then
        self:showDetailPopup(sel_did)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TeamBonus_Dragon:initButton()
    local vars = self.m_owner_ui.vars

    do -- ����(role)
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

    do -- �Ӽ�(attribute)
        local radio_button = UIC_RadioButton()
        radio_button:addButtonAuto('fire', vars)
        radio_button:addButtonAuto('water', vars)
        radio_button:addButtonAuto('earth', vars)
        radio_button:addButtonAuto('dark', vars)
        radio_button:addButtonAuto('light', vars)
        radio_button:setSelectedButton('fire')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

    -- ������ �巡���� �ִٸ� �ش� ����, �Ӽ� ���� ���Խ� ����
    local sel_did = self.m_owner_ui.m_selDid
    if (sel_did) then
        local table_dragon = TableDragon()
        local t_dragon = table_dragon:get(sel_did)
        local attr = t_dragon['attr']
        self.m_attrRadioButton:setSelectedButton(attr)
        self.m_preAttr = attr

        local role = t_dragon['role']
        self.m_roleRadioButton:setSelectedButton(role)
    end

    -- ���ʿ� �ѹ� ����
    self:onChangeOption()
end

-------------------------------------
-- function makeSortManager
-- @brief
-------------------------------------
function UI_TeamBonus_Dragon:makeSortManager()
    local sort_manager = SortManager_Dragon()
	
	-- did ��, ��� ������ ����
    sort_manager:pushSortOrder('did')
    sort_manager:pushSortOrder('grade')

    self.m_sortManager = sort_manager
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_TeamBonus_Dragon:onChangeOption()
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton

	-- �Ӽ��� �ű� ��� �׻� ��ü�������� ����Ű���� �Ѵ�.
	if (role_option ~= 'all') and (attr_option ~= self.m_preAttr) then
		self.m_preAttr = attr_option
		self.m_roleRadioButton:setSelectedButton('all')
		return
	end

    local l_item_list = self:getDragonList(role_option, attr_option)

    -- ����Ʈ ���� (���ǿ� �´� �׸� ����)
    self.m_tableViewTD:mergeItemList(l_item_list)

    -- ����
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)

	self.m_preAttr = attr_option
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_TeamBonus_Dragon:initTableView()
    local vars = self.m_owner_ui.vars
    local node = vars['dragonListNode1']

    local l_item_list = {}

	-- cell_size ����
    local item_size = 150
    local item_scale = 0.75
    local cell_size = cc.size(item_size*item_scale + 12, item_size*item_scale + 12)

	local table_view_td

    -- ����Ʈ ������ ���� �ݹ�
    local function create_func(ui, data)
        self:cellCreateCB(ui, data)
    end

    -- ���̺� �� �ν��Ͻ� ����
    table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 8
	table_view_td:setCellUIClass(UI_BookDragonCard, create_func)
    table_view_td:setItemList(l_item_list)
	
	table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)

    -- ����
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_TeamBonus_Dragon:getDragonList(role_type, attr_type)
    local role_type = (role_type or 'all')
    local attr_type = (attr_type or 'all')

    local l_ret = {}

    local table_dragon = TableDragon()
    for i, v in pairs(table_dragon.m_orgTable) do
        -- ���� ���� �巡���� ������ ��Ÿ���� �ʴ´�.
        if (v['test'] == 0) then
		
        -- ������, �Ӽ� �ɷ�����
		elseif (role_type ~= 'all') and (role_type ~= v['role']) then
        elseif (attr_type ~= 'all') and (attr_type ~= v['attr']) then

        -- �� ���ǵ鿡 �ش����� ���� ��츸 �߰�
        else
            local did = v['did']
			local key = did
			local t_dragon = clone(v)

            -- ������ ��ġ��
			t_dragon['evolution'] = 1
            t_dragon['grade'] = TableDragon:getBirthGrade(did)
			t_dragon['bookType'] = 'dragon'
            t_dragon['lv'] = 1
			l_ret[key + (i * 1000000)] = t_dragon
        end
    end
    return l_ret
end

-------------------------------------
-- function cellCreateCB
-- @static
-- @brief cell ���� ���� �ݹ�
-------------------------------------
function UI_TeamBonus_Dragon:cellCreateCB(ui, data)
	local did = data['did']
	local grade = data['grade']
	local evolution = data['evolution']

    -- scale ����
	ui.root:setScale(0.8)

    -- ����� ���� ����
    ui.vars['starNode']:setVisible(false)

	-- ��ư Ŭ���� ���밡���� �����ʽ� ������
	ui.vars['clickBtn']:registerScriptTapHandler(function()
        self:showDetailPopup(did)
	end)
end

-------------------------------------
-- function showDetailPopup
-------------------------------------
function UI_TeamBonus_Dragon:showDetailPopup(did)
    local vars = self.m_owner_ui.vars
    local node = vars['dragonListNode1']
    node:setVisible(false)

    local menu = vars['detailMenu']
    menu:removeAllChildren()

    local ui = UI_TeamBonus_Detail(did)
    ui:setCloseCB(function() 
        self.m_detail_popup = nil
        node:setVisible(true) 
    end)

    self.m_detail_popup = ui

    menu:addChild(ui.root)
end