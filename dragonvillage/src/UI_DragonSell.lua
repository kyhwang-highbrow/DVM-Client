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
    self.m_titleStr = Str('드래곤 판매')
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

    -- 첫 선택 드래곤 지정
    --self:setDefaultSelectDragon(doid)

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
	--vars['priceLabel']:setString(0)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSell:initButton()
    local vars = self.vars
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSell:refresh()
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
    local dragon_dic = g_dragonsData:getDragonsListRef()

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

    return table.merge(dragon_dic, slime_dic)
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonSell:click_dragonMaterial(t_dragon_data)
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

	local is_select = self.m_tSellTable[doid] or false
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
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonSell:createDragonCardCB(ui, data)
    local doid = data['id']

    local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
    if (not possible) then
        if ui then
            ui:setShadowSpriteVisible(true)
        end
    end
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
		local str = Str('{1} 골드를 받았습니다', self.m_price)
		UI_ToastPopup(str)

		-- 다시 초기화
		self.m_price = 0
		self.m_tSellTable = {}
		self:refresh_dragonMaterialTableView()
	end

	g_dragonsData:request_dragonSell(doids, soids, cb_func)
end

--@CHECK
UI:checkCompileError(UI_DragonSell)
