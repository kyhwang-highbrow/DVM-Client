local PARENT = UI_DragonManage_Base
local MAX_SELL_CNT = 30

-------------------------------------
-- class UI_DragonConversion
-------------------------------------
UI_DragonConversion = class(PARENT,{
		m_tConversionTable = 'list',
		m_price = 'number'
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonConversion:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonConversion'
    self.m_bVisible = true
    self.m_titleStr = Str('')
    self.m_bUseExitBtn = true
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonConversion:init(doid)
    local vars = self:load('dragon_conversion.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonConversion')

    self:sceneFadeInAction()
	
	self.m_tConversionTable = {}
	self.m_price = 0

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
	self:init_mtrDragonSortMgr(false) -- slime_first
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonConversion:initUI()
	local vars = self.vars

	self:init_bg()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonConversion:initButton()
    local vars = self.vars
    vars['conversionBtn']:registerScriptTapHandler(function() self:click_conversionBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonConversion:refresh()
    self:refresh_selectedMaterial()
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function init_bg
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonConversion:init_bg()
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
function UI_DragonConversion:refresh_dragonMaterialTableView()   
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
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 리스트가 비었을 때
--    table_view_td:makeDefaultEmptyDescLabel(Str('판매할 드래곤이 없어요 ㅠㅠ'))

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
function UI_DragonConversion:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 자기 자신 드래곤 제외
    if doid then
        dragon_dic[doid] = nil
    end

    -- 재료로 사용 불가능한 드래곤 제외
    for oid,v in pairs(dragon_dic) do
        if (not g_dragonsData:possibleConversion(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-- @override
-------------------------------------
function UI_DragonConversion:createMtrlDragonCardCB(ui, data)
    -- nothing to do
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonConversion:click_dragonMaterial(t_dragon_data)
    local function next_func()
        local doid = t_dragon_data['id']

	    -- 가격 처리 및 테이블리스트 갱신
	    do
		    local price = TableDragonExp():getDragonSellGold(t_dragon_data['grade'], t_dragon_data['lv'])

		    -- 제외
		    if (self.m_tConversionTable[doid]) then
			    self.m_tConversionTable[doid] = nil
			    self.m_price = self.m_price - price
		
		    -- 추가
		    else
			    -- 갯수 체크
			    local sell_cnt = table.count(self.m_tConversionTable)
			    if (sell_cnt >= MAX_SELL_CNT) then
				    UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_SELL_CNT))
				    return
			    end

			    self.m_tConversionTable[doid] = t_dragon_data
			    self.m_price = self.m_price + price
		    end
	    end

	    -- 갱신
        self:refresh_materialDragonIndivisual(doid)
        self:refresh_selectedMaterial()
    end

    local doid = t_dragon_data['id']
    if self.m_tConversionTable[doid] then
        -- 해제할 경우
        next_func()
    else
        -- 재료 경고
        local oid = t_dragon_data['id']
        g_dragonsData:dragonMaterialWarning(oid, next_func, nil, '선택한 드래곤을 특성 재료로 변환하시겠습니까?') -- param : oid, next_func, t_warning, warning_msg
    end
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonConversion:refresh_materialDragonIndivisual(doid)
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

	local is_select = self.m_tConversionTable[doid] and true or false
    ui:setCheckSpriteVisible(is_select)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonConversion:refresh_selectedMaterial()
	local vars = self.vars

	-- 판매 갯수
	local sell_cnt = table.count(self.m_tConversionTable)
	vars['selectLabel']:setString(string.format('%d / %d', sell_cnt, MAX_SELL_CNT))
end

-------------------------------------
-- function click_conversionBtn
-- @brief
-------------------------------------
function UI_DragonConversion:click_conversionBtn()
	-- 갯수 체크
	local sell_cnt = table.count(self.m_tConversionTable)
	if (sell_cnt <= 0) then
		UIManager:toastNotificationGreen(Str('재료 드래곤을 선택해주세요!'))
		return
	end

	local doids = ''

	for oid, t_dragon_data in pairs(self.m_tConversionTable) do
		if (t_dragon_data.m_objectType == 'dragon') then
			if (doids == '') then
                doids = tostring(oid)
            else
                doids = doids .. ',' .. tostring(oid)
            end
		end
	end

	local function cb_func(ret)
		-- 다시 초기화
		self.m_price = 0
		self.m_tConversionTable = {}
		self:refresh_dragonMaterialTableView()
        self:refresh_selectedMaterial()

		-- 외부에 변화 여부 전달
		self.m_bChangeDragonList = true

        -- 결과 출력
        UI_ObtainPopup(ret['items_list'], nil, nil, true)
	end

	g_dragonsData:request_dragonConversion(doids, cb_func)
end

--@CHECK
UI:checkCompileError(UI_DragonConversion)
