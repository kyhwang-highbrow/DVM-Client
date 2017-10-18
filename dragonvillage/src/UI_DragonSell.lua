local PARENT = UI_DragonManage_Base
local MAX_SELL_CNT = 30

-------------------------------------
-- class UI_DragonSell
-------------------------------------
UI_DragonSell = class(PARENT,{
		m_tSellTable = 'list',
		m_price = 'number'
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSell:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSell'
    self.m_bVisible = true
    self.m_titleStr = Str('')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSell:init(doid)
    local vars = self:load('dragon_sell.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonSell')

    self:sceneFadeInAction()
	
	self.m_tSellTable = {}
	self.m_price = 0

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
	local is_slime_fisrt = false
	self:init_mtrDragonSortMgr(is_slime_fisrt)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSell:initUI()
	local vars = self.vars

	self:init_bg()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSell:initButton()
    local vars = self.vars
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
    vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSell:refresh()
    self:refresh_inventoryLabel()
    self:refresh_selectedMaterial()
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function init_bg
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonSell:init_bg()
    local vars = self.vars

    -- 배경
    local animator = ResHelper:getUIDragonBG('earth', 'idle')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function refresh_dragonMaterialTableView
-- @brief 재료 테이블 뷰 갱신
-- @override
-------------------------------------
function UI_DragonSell:refresh_dragonMaterialTableView()   
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.80)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		self:createMtrlDragonCardCB(ui, data)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(128.8, 128.8)
    table_view_td.m_nItemPerCell = 9
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('판매할 드래곤이 없어요 ㅠㅠ'))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)
	
	self:apply_mtrlDragonSort()
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 판매 - 잠금/ 리더 제외한 모두
-- @override
-------------------------------------
function UI_DragonSell:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 자기 자신 드래곤 제외
    if doid then
        dragon_dic[doid] = nil
    end

    -- 재료로 사용 불가능한 드래곤 제외
    for oid,v in pairs(dragon_dic) do
        if (not g_dragonsData:possibleMaterialDragon(oid)) then
            dragon_dic[oid] = nil
        end
    end

	-- 슬라임 추가
	local slime_dic = g_slimesData:getSlimeList()
	for oid, v in pairs(slime_dic) do
		dragon_dic[oid] = v
	end

    return dragon_dic
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-- @override
-------------------------------------
function UI_DragonSell:createMtrlDragonCardCB(ui, data)
    -- nothing to do
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonSell:click_dragonMaterial(t_dragon_data)
    local function next_func()
        local doid = t_dragon_data['id']

	    -- 가격 처리 및 테이블리스트 갱신
	    do
		    local price = TableDragonExp():getDragonSellGold(t_dragon_data['grade'], t_dragon_data['lv'])

		    -- 제외
		    if (self.m_tSellTable[doid]) then
			    self.m_tSellTable[doid] = nil
			    self.m_price = self.m_price - price
		
		    -- 추가
		    else
			    -- 갯수 체크
			    local sell_cnt = table.count(self.m_tSellTable)
			    if (sell_cnt >= MAX_SELL_CNT) then
				    UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_SELL_CNT))
				    return
			    end

			    self.m_tSellTable[doid] = t_dragon_data
			    self.m_price = self.m_price + price
		    end
	    end

	    -- 갱신
        self:refresh_materialDragonIndivisual(doid)
        self:refresh_selectedMaterial()
    end

    local doid = t_dragon_data['id']
    if self.m_tSellTable[doid] then
        -- 해제할 경우
        next_func()
    else
        -- 재료 경고
        local oid = t_dragon_data['id']
        g_dragonsData:dragonMaterialWarning(oid, next_func)
    end
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonSell:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    local item = self.m_mtrlTableViewTD:getItem(doid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

	local is_select = self.m_tSellTable[doid] and true or false
    ui:setCheckSpriteVisible(is_select)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonSell:refresh_selectedMaterial()
	local vars = self.vars

	-- 판매 갯수
	local sell_cnt = table.count(self.m_tSellTable)
	vars['selectLabel']:setString(string.format('%d / %d', sell_cnt, MAX_SELL_CNT))

	-- 가격
    vars['priceLabel']:setString(comma_value(self.m_price))
end

-------------------------------------
-- function refresh_inventoryLabel
-- @brief
-------------------------------------
function UI_DragonSell:refresh_inventoryLabel()
    local vars = self.vars
    local inven_type = 'dragon'
    local dragon_count = g_dragonsData:getDragonsCnt()
    local max_count = g_inventoryData:getMaxCount(inven_type)
    self.vars['inventoryLabel']:setString(Str('{1}/{2}', dragon_count, max_count))
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-- @override
-------------------------------------
function UI_DragonSell:checkDragonSelect(doid)
	-- 재료용 검증 함수이지만 판매와 동일하기 때문에 사용
    local possible, msg = g_dragonsData:possibleMaterialDragon(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function click_inventoryBtn
-- @brief 인벤 확장
-------------------------------------
function UI_DragonSell:click_inventoryBtn()
    local item_type = 'dragon'
    local function finish_cb()
        self:refresh_inventoryLabel()
    end

    g_inventoryData:extendInventory(item_type, finish_cb)
end

-------------------------------------
-- function click_sellBtn
-- @brief
-------------------------------------
function UI_DragonSell:click_sellBtn()
	-- 갯수 체크
	local sell_cnt = table.count(self.m_tSellTable)
	if (sell_cnt <= 0) then
		UIManager:toastNotificationGreen(Str('판매할 드래곤을 선택해주세요'))
		return
	end

	local doids = ''
	local soids = ''

	for oid, t_dragon_data in pairs(self.m_tSellTable) do
		if (t_dragon_data.m_objectType == 'dragon') then
			if (doids == '') then
                doids = tostring(oid)
            else
                doids = doids .. ',' .. tostring(oid)
            end

		elseif (t_dragon_data.m_objectType == 'slime') then
			if (soids == '') then
                soids = tostring(oid)
            else
                soids = soids .. ',' .. tostring(oid)
            end

		end
	end

	local function cb_func()
		-- 다시 초기화
		self.m_price = 0
		self.m_tSellTable = {}
        self:refresh_inventoryLabel()
		self:refresh_dragonMaterialTableView()
        self:refresh_selectedMaterial()

		-- 외부에 변화 여부 전달
		self.m_bChangeDragonList = true
	end

	g_dragonsData:request_dragonSell(doids, soids, cb_func)
end

--@CHECK
UI:checkCompileError(UI_DragonSell)
