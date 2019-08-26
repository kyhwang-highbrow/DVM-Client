local PARENT = UI

-------------------------------------
-- class UI_PickDragon
-- @desc 드래곤 선택권 UI -> table_pick_dragon 사용
-------------------------------------
UI_PickDragon = class(PARENT,{
		m_mid = 'string',
		m_finishCB = 'function',
		m_currDragonData = 'table',

		m_orgDragonList = 'list',
		m_isCustomPick = 'bool',

		m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManager = 'SortManager',

		m_dragonAnimator = 'UIC_DragonAnimator',

		m_isInfo = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PickDragon:init(mid, item_id, cb_func, is_info)
    local vars = self:load('popup_select_regend.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_PickDragon'
	self.m_isInfo = is_info

    vars['titleLabel']:setString(TableItem:getItemName(item_id))
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_PickDragon')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
	
	self.m_mid = mid
	self.m_finishCB= cb_func
	
	self.m_orgDragonList = TablePickDragon:getDragonList(item_id, g_dragonsData.m_mReleasedDragonsByDid)
	self.m_isCustomPick = TablePickDragon:isCustomPick(item_id)

    self:initUI(item_id)
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PickDragon:initUI(item_id)
    local vars = self.vars

	self.m_dragonAnimator = UIC_DragonAnimator()
    vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
	-- 전설 드래곤 선택권(2주년 기념)
	if (item_id == 700612) then
		self:initTableView_special()
	else
		self:initTableView_normal()
	end
    
	self:initSortManager()

	-- did 지정 타입인 경우 별도로 처리
	if (self.m_isCustomPick) then
		self:initCusmtomPick()

	-- 일반 타입 : 보다 드래곤이 많고 속성/직군 구분 탭 사용
	else
		self:initRadioButton()
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PickDragon:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
	vars['bookBtn']:registerScriptTapHandler(function() self:click_bookBtn() end)
	vars['summonBtn']:registerScriptTapHandler(function() self:click_summonBtn() end)
	vars['okBtn']:registerScriptTapHandler(function() self:close() end)

	vars['summonBtn']:setVisible(not self.m_isInfo)
	vars['okBtn']:setVisible(self.m_isInfo)
end

-------------------------------------
-- function initCusmtomPick
-- @brief did 지정 선택권에 맞추어 UI 변경
-------------------------------------
function UI_PickDragon:initCusmtomPick()
	local vars = self.vars

	vars['roleMenu']:setVisible(false)
	vars['attrMenu']:setVisible(false)

	-- initTableView에서 함
	--vars['listNode']:setContentSize(700, 550)

	-- 전체 드래곤 리스트 출력
    self.m_tableViewTD:setItemList(self.m_orgDragonList)
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)
	self:refresh(table.getRandom(self.m_orgDragonList))
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
        radio_button:addButtonAuto('earth', vars)
        radio_button:addButtonAuto('water', vars)
        radio_button:addButtonAuto('fire', vars)
        radio_button:addButtonAuto('light', vars)
        radio_button:addButtonAuto('dark', vars)
        radio_button:setSelectedButton('earth')
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

	-- ui편의를 위해 조건 변경 시 첫번째 드래곤을 화면에 띄운다
	self:refresh(table.getRandom(l_item_list))
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_PickDragon:initTableView_special()
    local node = self.vars['listNode']

	-- did 지정 타입 선택권인 경우 길이 늘림 (다른 버튼을 숨기므로 허전)
	if (self.m_isCustomPick) then
		node:setContentSize(700, 550)	
	end

    local l_item_list = {}

	-- cell_size 지정
    local item_size = 120
    local item_scale = 14/15
    local cell_size = cc.size(item_size*item_scale + 0, item_size*item_scale + 0)

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data['did']
		local t_data = {['evolution'] = 1, ['grade'] = data['birthgrade']}
		local ui = UI_PickDragonSpecailListItem(did, t_data)
		ui.root:setScale(item_scale)
		
		-- click 함수 등록
		local ui_dragon = MakeSimpleDragonCard(did, t_data)
		ui.vars['dragonNode']:addChild(ui_dragon.root)
		ui_dragon.vars['clickBtn']:registerScriptTapHandler(function()
			self:refresh(data)
		end)
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(125, 158)
    table_view_td.m_nItemPerCell = 5
	table_view_td:setCellUIClass(create_func)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_item_list)

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_PickDragon:initTableView_normal()
    local node = self.vars['listNode']

	-- did 지정 타입 선택권인 경우 길이 늘림 (다른 버튼을 숨기므로 허전)
	if (self.m_isCustomPick) then
		node:setContentSize(700, 550)	
	end

    local l_item_list = {}

	-- cell_size 지정
    local item_size = 150
    local item_scale = 14/15
    local cell_size = cc.size(item_size*item_scale + 0, item_size*item_scale + 0)

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data['did']
		local t_data = {['evolution'] = 1, ['grade'] = data['birthgrade']}
		local ui = MakeSimpleDragonCard(did, t_data)
		ui.root:setScale(item_scale)

		-- 클릭
		ui.vars['clickBtn']:registerScriptTapHandler(function()
			self:refresh(data)
		end)
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
    sort_manager:pushSortOrder('did')
	sort_manager:pushSortOrder('attr')
    self.m_sortManager = sort_manager
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PickDragon:refresh(t_dragon)
    local vars = self.vars
	if (not t_dragon) then
		return
	end

	-- 데이터 저장
	self.m_currDragonData = t_dragon

	-- 드래곤
	local evolution = 1
	self.m_dragonAnimator:setDragonAnimator(t_dragon['did'], evolution)

	-- 이름
	vars['dragonNameLabel']:setString(Str(t_dragon['t_name']))

	-- 등급
	vars['starNode']:removeAllChildren()
	local dummy_dragon_data = {['did'] = t_dragon['did'], ['grade'] = t_dragon['birthgrade'], ['evolution'] = evolution}
    local star_icon = IconHelper:getDragonGradeIcon(dummy_dragon_data, 2)
    vars['starNode']:addChild(star_icon)

	-- 속성, 직군, 레어도
	self:refresh_icons(t_dragon)
end

-------------------------------------
-- function refresh_icons
-- @brief 아이콘 갱신
-------------------------------------
function UI_PickDragon:refresh_icons(t_dragon)
    local vars = self.vars
    
    local attr = t_dragon['attr']
    local role_type = t_dragon['role']
    local rarity_type = t_dragon['rarity']
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    do -- 희귀도
        vars['rarityNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_PickDragon:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_bookBtn
-- @brief 도감
-------------------------------------
function UI_PickDragon:click_bookBtn()
    local t_dragon = self.m_currDragonData

	local did = t_dragon['did']
    local grade = t_dragon['grade']
    local evolution = t_dragon['evolution']
	local is_pick = true
	local pick_cb = function() self:click_summonBtn() end

    UI_BookDetailPopup.open(did, grade, evolution, is_pick, pick_cb)
end

-------------------------------------
-- function click_summonBtn
-------------------------------------
function UI_PickDragon:click_summonBtn()
	local did = self.m_currDragonData['did']
	local name = TableDragon:getDragonNameWithAttr(did)

	local msg = Str('{1}\n소환하시겠습니까?', name)
	local function ok_btn_cb()
		local mid = self.m_mid
		self:request_pick(mid, did)
	end

	MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb)
end

-------------------------------------
-- function request_pick
-- @brief 드래곤 선택!
-------------------------------------
function UI_PickDragon:request_pick(mid, did)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
		-- 드래곤 추가
		g_dragonsData:applyDragonData_list(ret['added_dragons'])

		-- 결과화면
		local gacha_type = 'immediately'
		local ui = UI_GachaResult_Dragon(gacha_type, ret['added_dragons'])
		ui:click_skipBtn()

		if (self.m_finishCB) then
			self.m_finishCB()
		end

		-- 닫기
		self:close()
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/pick_dragon')
    ui_network:setParam('uid', uid)
	ui_network:setParam('mid', mid)
    ui_network:setParam('did', did)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end





local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PickDragon
-- @desc 드래곤 선택권 UI -> table_pick_dragon 사용
-------------------------------------
UI_PickDragonSpecailListItem = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PickDragonSpecailListItem:init(did, t_data)
    local vars = self:load('popup_select_regend_item.ui')

	self:iniUI(did, t_data)
end

-------------------------------------
-- function iniUI
-------------------------------------
function UI_PickDragonSpecailListItem:iniUI(did, t_data)
	local vars = self.vars

    if (is_rank) then
		vars['rankMenu']:setVisible(is_rank)
		vars['percentLabel1']:setString('1%')
		local rank_sprite = cc.Sprite:create('res/ui/icons/rank/clan_raid_0201.png')
		vars['rankNode']:addChild(rank_sprite)
	else
		vars['percentLabel2']:setString('1%')
	end
end