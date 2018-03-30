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

        m_haveDragon = 'boolean',
        m_detail_popup = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus_Dragon:init(owner_ui)
    self.m_owner_ui = owner_ui
    self.m_haveDragon = false
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_TeamBonus_Dragon:onEnterTab(first)
    if (first) then
        self:initUI()
        self:initButton()
    end

    -- 상세 팝업 노출시 리스트 노출 안함
    if (self.m_detail_popup) then
        self.m_owner_ui.vars['dragonListNode1']:setVisible(false)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TeamBonus_Dragon:initUI()
    local vars = self.m_owner_ui.vars
    vars['checkSprite']:setVisible(self.m_haveDragon)

    self:makeSortManager()
    self:initTableView()

    --- 선택한 드래곤이 있다면 진입시 상세 팝업 노출
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
    -- 보유한 드래곤만 보기
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)

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
        radio_button:addButtonAuto('fire', vars)
        radio_button:addButtonAuto('water', vars)
        radio_button:addButtonAuto('earth', vars)
        radio_button:addButtonAuto('dark', vars)
        radio_button:addButtonAuto('light', vars)
        radio_button:setSelectedButton('fire')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

    -- 선택한 드래곤이 있다면 해당 역할, 속성 최초 진입시 선택
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

    -- 최초에 한번 실행
    self:onChangeOption()
end

-------------------------------------
-- function makeSortManager
-- @brief
-------------------------------------
function UI_TeamBonus_Dragon:makeSortManager()
    local sort_manager = SortManager_Dragon()
	
	-- did 순, 등급 순으로 정렬
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

	-- 속성을 옮길 경우 항상 전체직업군을 가리키도록 한다.
	if (role_option ~= 'all') and (attr_option ~= self.m_preAttr) then
		self.m_preAttr = attr_option
		self.m_roleRadioButton:setSelectedButton('all')
		return
	end

    local l_item_list = self:getDragonList(role_option, attr_option)

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_tableViewTD:mergeItemList(l_item_list)

    -- 정렬
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

	-- cell_size 지정
    local item_size = 150
    local item_scale = 0.75
    local cell_size = cc.size(item_size*item_scale + 12, item_size*item_scale + 12)

	local table_view_td

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        self:cellCreateCB(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 8
	table_view_td:setCellUIClass(UI_BookDragonCard, create_func)
    table_view_td:setItemList(l_item_list)
	
	table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:makeDefaultEmptyMandragora(Str('보유중인 드래곤이 없다고라'))

    -- 정렬
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

    local function insert_dragon(data, idx)
        local did = data['did']
		local t_dragon = clone(data)

        -- 무조건 성룡
		t_dragon['evolution'] = 3
        t_dragon['grade'] = TableDragon:getBirthGrade(did)
		t_dragon['bookType'] = 'dragon'
        t_dragon['lv'] = 1
		l_ret[did + (idx * 1000000)] = t_dragon
    end

    for i, v in pairs(table_dragon.m_orgTable) do
        -- 개발 중인 드래곤은 도감에 나타내지 않는다.
        if (v['test'] == 0) then
		
        -- 직업군, 속성 걸러내기
		elseif (role_type ~= 'all') and (role_type ~= v['role']) then
        elseif (attr_type ~= 'all') and (attr_type ~= v['attr']) then

        -- 위 조건들에 해당하지 않은 경우만 추가
        else
            -- 보유드래곤 체크된 상태
            if (self.m_haveDragon) then
                local did = v['did']
                if (g_dragonsData:getNumOfDragonsByDid(did) > 0) then
                    insert_dragon(v, i)
                end
            else
                insert_dragon(v, i)
            end
        end
    end
    return l_ret
end

-------------------------------------
-- function cellCreateCB
-- @static
-- @brief cell 생성 후의 콜백
-------------------------------------
function UI_TeamBonus_Dragon:cellCreateCB(ui, data)
	local did = data['did']
	local grade = data['grade']
	local evolution = data['evolution']

    -- scale 조정
	ui.root:setScale(0.8)

    -- 등급은 노출 안함
    ui.vars['starNode']:setVisible(false)

	-- 버튼 클릭시 적용가능한 팀보너스 보여줌
	ui.vars['clickBtn']:registerScriptTapHandler(function()
        self:showDetailPopup(did)
	end)
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_TeamBonus_Dragon:click_checkBtn()
    local vars = self.m_owner_ui.vars
    self.m_haveDragon = not self.m_haveDragon
    vars['checkSprite']:setVisible(self.m_haveDragon)

    -- 연속 클릭시 테이블뷰 리스트 머지 꼬이는 현상 방지
    local block_time = 0.5
    local btn = vars['checkBtn']
    btn:setEnabled(false)
    cca.reserveFunc(btn, block_time, function() btn:setEnabled(true) end)

    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton
    local l_item_list = self:getDragonList(role_option, attr_option)

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_tableViewTD:mergeItemList(l_item_list)

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)
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

    local ui = UI_TeamBonus_Detail(self.m_owner_ui, did)
    ui:setCloseCB(function() 
        self.m_detail_popup = nil
        node:setVisible(true) 
    end)

    self.m_detail_popup = ui

    menu:addChild(ui.root)
end