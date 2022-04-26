local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Shop_Popup_Reinforce
-------------------------------------
UI_Shop_Popup_Reinforce = class(PARENT,{
        m_selectDragonData = 'StructDragonObject',
        m_category = 'string',
        m_cbBuy = 'function',
        m_tableView = 'UIC_TableView',
    })


-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Shop_Popup_Reinforce:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Shop_Popup_Reinforce'
    self.m_bVisible = true
    self.m_titleStr = Str('강화 상점')
    self.m_subCurrency = 'topaz'
    self.m_addSubCurrency = 'clancoin'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Shop_Popup_Reinforce:init(struct_dragon)
    local vars = self:load_keepZOrder('shop_reinforce.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopBooster')

    self.m_category = 'reinforce'
    self.m_selectDragonData = struct_dragon

    self:initUI()
    self:initButton()
    self:init_TableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Shop_Popup_Reinforce:initUI()
    self.vars['expGauge']:setPercentage(0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Shop_Popup_Reinforce:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Shop_Popup_Reinforce:refresh()
    self:refresh_dragonInfo()
	self:refresh_reinforceInfo()
	self:refresh_relation()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_Shop_Popup_Reinforce:init_TableView()
    local list_table_node = self.vars['tableViewNode']

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_item_list = g_shopDataNew:getProductList(self.m_category)

    local ui_class = UI_Product
    local item_per_cell = 3
    local interval = 2
    local cell_width = 334
    local cell_height = 316

    -- 탭에서 상품 개수가 7개 이상이 되면 4줄로 노출
    if (7 <= table.count(l_item_list)) then
        ui_class = UI_ProductSmall
        item_per_cell = 4
        interval = 2
        cell_width = 250
        cell_height = 288
    end

    -- 생성 콜백
	local function create_cb_func(ui, data)
        ui:setBuyCB(function() 
            ui:refresh()
            if (data['price_type'] == 'money') then
                UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.ITEM, function() self:refresh_relation() end)
            end
        end)
	end    

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size((cell_width + interval), (cell_height + interval))
    table_view_td:setCellUIClass(UI_ProductSmall, create_cb_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td.m_nItemPerCell = item_per_cell
	--table_view_td:setAlignCenter(true)

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    table_view_td:setItemList(l_item_list)
    self.m_tableView = table_view_td

    self:sortProduct()
end

-------------------------------------
-- function sortProduct
-- @brief 상품 정렬
-------------------------------------
function UI_Shop_Popup_Reinforce:sortProduct()
    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        -- UI 우선순위 대로 정렬
        if (a_data:getUIPriority() ~= b_data:getUIPriority()) then
            return a_data:getUIPriority() > b_data:getUIPriority()
        end

        -- 우선순위가 동일할 경우 상품 ID가 낮은 순서대로 정렬
        return a_data['product_id'] < b_data['product_id']
    end

    table.sort(self.m_tableView.m_itemList, sort_func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Shop_Popup_Reinforce:click_exitBtn()
    self:close()
end








-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_Shop_Popup_Reinforce:refresh_dragonInfo()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

    -- 배경
    local attr = TableDragon:getDragonAttr(did)
    vars['bgNode']:removeAllChildren()
    local animator = ResHelper:getUIDragonBG(attr, 'idle')
    vars['bgNode']:addChild(animator.m_node)

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    animator:setScale(scr_size.width / 1280)

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(t_dragon_data:getDragonNameWithEclv())
    end

    do -- 드래곤 속성
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIconButton(attr)
        vars['attrNode']:addChild(icon)
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
    end
	
	do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data, 2)
        vars['starNode']:addChild(star_icon)
    end

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)

        vars['dragonNode']:addChild(animator.m_node)
    end
end
-------------------------------------
-- function refresh_reinforceInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_Shop_Popup_Reinforce:refresh_reinforceInfo()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

	-- 드래곤 강화 레벨
	vars['reinforceNode']:removeAllChildren()
	local rlv = t_dragon_data:getRlv()
    local icon = IconHelper:getDragonReinforceIcon(rlv)
    vars['reinforceNode']:addChild(icon)

	-- 풀강화시 예외처리
	if (t_dragon_data:isMaxRlv()) then
		vars['expGauge']:setPercentage(100)
		vars['expLabel']:setString('MAX')
		return
	end

	-- 현재 경험치 / 총 경험치
	local rexp = t_dragon_data:getRexp()
	local max_rexp = TableDragonReinforce:getCurrMaxExp(did, rlv)
	vars['expLabel']:setString(string.format('%d / %d exp', rexp, max_rexp))
	
	-- 경험치 게이지
	vars['expGauge']:runAction(cc.ProgressTo:create(0.2, (rexp / max_rexp * 100)))
end

-------------------------------------
-- function refresh_relation
-------------------------------------
function UI_Shop_Popup_Reinforce:refresh_relation()
	local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end
	
	-- 인연포인트 표시하기 위한 t_dragon 리스트 생성
    local vars = self.vars
    local did = t_dragon_data['did']
	local list = TableDragon:getSameTypeDragonList(did, g_dragonsData.m_mReleasedDragonsByDid)
	local t_ret = {}
	for i, v in ipairs(list) do
		local did = v['did']
		local idx = did % 10
		t_ret[idx] = v
	end

	-- 순서대로 찍어준다.
	for i = 1, 5 do
		vars['relationNode' .. i]:removeAllChildren(true)

		local t_dragon = t_ret[i]

		-- 인연포인트 카드 생성
		if (t_dragon) then
			local rid = t_dragon['did']

			-- 데이터
			local t_data = {
				['did'] = rid,
				['grade'] = t_dragon['birthgrade']
			}
			local struct_dragon = StructDragonObject(t_data)

			-- 카드 생성
			local ui = UI_DragonReinforceItem('dragon', struct_dragon)
			vars['relationNode' .. i]:addChild(ui.root)
            ui:disable()

			-- 연출
			--cca.fruitReact(ui.m_card.root, i)

		-- 없으면 빈아이콘 생성
		else
			local ui = UI_DragonReinforceItem('empty')
			vars['relationNode' .. i]:addChild(ui.root)
			
		end
	end

	-- 강화 포인트 생성
	do 
		vars['relationNode6']:removeAllChildren(true)

		-- 데이터
		local grade = t_dragon_data:getBirthGrade()
		local item_id = 760000 + grade
		local t_item = TableItem():get(item_id)

		-- 카드 생성
		local ui = UI_DragonReinforceItem('item', t_item)
		vars['relationNode6']:addChild(ui.root)
        ui:disable()

		-- 연출
		--cca.fruitReact(ui.m_card.root, 6)
	end

end