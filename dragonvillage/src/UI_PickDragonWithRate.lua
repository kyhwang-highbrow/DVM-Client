local PARENT = UI

-------------------------------------
-- class UI_PickDragonWithRate
-- @desc 드래곤 선택권 UI -> table_pick_dragon 사용
-------------------------------------
UI_PickDragonWithRate = class(PARENT,{
		m_mid = 'string',
		m_finishCB = 'function',
		m_currDragonData = 'table',

		m_orgDragonList = 'list',
		m_isCustomPick = 'bool',

        m_tableViewTD = 'UIC_TableViewTD',

		m_dragonAnimator = 'UIC_DragonAnimator',

		m_isInfo = 'boolean',

		m_itemId = 'number',

		m_mapCardUI = 'UI_DragonCard',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PickDragonWithRate:init(mid, item_id, cb_func, is_info, t_statics)
    local vars = self:load('popup_select_legend.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_PickDragonWithRate'
	self.m_isInfo = is_info
	self.m_itemId = item_id
	self.m_mapCardUI = {}

    vars['titleLabel']:setString(TableItem:getItemName(item_id))
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_PickDragonWithRate')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
	
	self.m_mid = mid
	self.m_finishCB= cb_func
	
	self.m_orgDragonList = TablePickDragon:getDragonList(item_id, g_dragonsData.m_mReleasedDragonsByDid)
	self.m_isCustomPick = TablePickDragon:isCustomPick(item_id)
	
	-- 채택 정보를 orgDragonList에 넣는다
	self:makeRateMap(t_statics)

    self:initUI(item_id)
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PickDragonWithRate:initUI(item_id)
    local vars = self.vars
	self.m_dragonAnimator = UIC_DragonAnimator()
	vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
	-- 전설 드래곤 선택권(2주년 기념)
	self:initTableView()
	
	-- did 지정 타입인 경우 별도로 처리
	if (self.m_isCustomPick) then
		self:initCusmtomPick()
	end	
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PickDragonWithRate:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
	vars['bookBtn']:registerScriptTapHandler(function() self:click_bookBtn() end)
	vars['summonBtn']:registerScriptTapHandler(function() self:click_summonBtn() end)
	vars['okBtn']:registerScriptTapHandler(function() self:close() end)

	vars['summonBtn']:setVisible(not self.m_isInfo)
	vars['okBtn']:setVisible(false)
end

-------------------------------------
-- function initCusmtomPick
-- @brief did 지정 선택권에 맞추어 UI 변경
-------------------------------------
function UI_PickDragonWithRate:initCusmtomPick()
	local vars = self.vars

	vars['roleMenu']:setVisible(false)
	vars['attrMenu']:setVisible(false)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_PickDragonWithRate:initTableView()
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

	local create_order = 1
    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data['did']
		local t_data = {}
		t_data['evolution'] = 1
		t_data['grade'] = data['birthgrade']
		local ui = UI_PickDragonWithRateSpecailListItem(data)
		ui.root:setScale(item_scale)
		
		-- click 함수 등록
		local ui_dragon = MakeSimpleDragonCard(did, t_data)
		ui.vars['dragonNode']:addChild(ui_dragon.root)
		self.m_mapCardUI[create_order] = ui_dragon 
		ui_dragon.vars['clickBtn']:registerScriptTapHandler(function()
			self:refresh(data)
			
			for _, ui_card in pairs(self.m_mapCardUI) do
				ui_card:setHighlightSpriteVisibleWithNoAction(false)
			end
			ui_dragon:setHighlightSpriteVisibleWithNoAction(true)
		end)

		if (create_order <= 3) then
			ui.vars['rankSprite']:setTexture(string.format('res/ui/icons/rank/clan_raid_020%d.png', create_order))
			ui.vars['rankMenu']:setVisible(true)
			ui.vars['percentLabel2']:setVisible(false)
		end

		-- 첫 번째 카드는 선택되어 있는 상태
		if (create_order == 1) then
			ui_dragon:setHighlightSpriteVisibleWithNoAction(true)
		end
		create_order = create_order + 1
        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(130, 158)
    table_view_td.m_nItemPerCell = 5
	table_view_td:setCellUIClass(create_func)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	table_view_td:setItemList(self.m_orgDragonList)
    -- 정렬
    self.m_tableViewTD = table_view_td
	
	-- 포커싱
	self:refresh(self.m_orgDragonList[1])
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PickDragonWithRate:refresh(t_dragon)
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
function UI_PickDragonWithRate:refresh_icons(t_dragon)
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
function UI_PickDragonWithRate:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_bookBtn
-- @brief 도감
-------------------------------------
function UI_PickDragonWithRate:click_bookBtn()
    local t_dragon = self.m_currDragonData

	local did = t_dragon['did']
    local grade = t_dragon['grade']
    local evolution = t_dragon['evolution']
	local is_pick = not self.m_isInfo
	local pick_cb = function() self:click_summonBtn() end

    UI_BookDetailPopup.open(did, grade, evolution, is_pick, pick_cb)
end

-------------------------------------
-- function click_summonBtn
-------------------------------------
function UI_PickDragonWithRate:click_summonBtn()
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
function UI_PickDragonWithRate:request_pick(mid, did)
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

-------------------------------------
-- function request_pickStatics
-- @brief 드래곤 채택률 정보
-------------------------------------
function UI_PickDragonWithRate.request_pickStatics(item_id, cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/pick_dragon_statics')
    ui_network:setParam('uid', uid)
	ui_network:setParam('itemid', item_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function makeRateMap
-------------------------------------
function UI_PickDragonWithRate:makeRateMap(t_data)
	local l_dragon = self.m_orgDragonList or {}
	local t_rate = t_data or {}
	
	-- 전체 채택률 합산
	local sum = 0
	for _, data in ipairs(l_dragon) do
		local did = tostring(data['did'])
		local pick_cnt = tonumber(t_rate[did])
		if (pick_cnt) then
			sum = sum + pick_cnt 
		end
	end

	-- 0 으로 나눌수는 없기에
	if (sum == 0) then
		sum = 1
	end

	-- rate = 채택률/전체 채택률
	for _, data in ipairs(l_dragon) do
		local did = tostring(data['did'])
		local pick_cnt = tonumber(t_rate[did]) or 0
		if (pick_cnt) then
			data['rate'] = pick_cnt/sum
		end
	end

	-- rate 순으로 정렬
	local sort_func = function(a, b)
		local a_rate = tonumber(a['rate'])
		local b_rate = tonumber(b['rate'])

		if (not a_rate) or (not b_rate) then
			return false
		end

		return a_rate > b_rate
 	end
	table.sort(l_dragon, sort_func)

	self.m_orgDragonList = l_dragon
end






local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PickDragonWithRate
-- @desc 드래곤 선택권 UI -> table_pick_dragon 사용
-------------------------------------
UI_PickDragonWithRateSpecailListItem = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PickDragonWithRateSpecailListItem:init(t_data)
    local vars = self:load('popup_select_regend_item.ui')

	self:iniUI(t_data)
end

-------------------------------------
-- function iniUI
-------------------------------------
function UI_PickDragonWithRateSpecailListItem:iniUI(t_data)
	local vars = self.vars
	local rate = tonumber(t_data['rate']) or 0 
	rate = string.format('%.2f%%', rate*100)
	vars['rankMenu']:setVisible(false)
	vars['percentLabel1']:setString(rate)
	vars['percentLabel2']:setString(rate)
end