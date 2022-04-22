local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Shop_Popup_SkillSlime
-------------------------------------
UI_Shop_Popup_SkillSlime = class(PARENT,{
        m_selectDragonData = 'StructDragonObject',
        m_category = 'string',
        m_cbBuy = 'function',
        m_tableView = 'UIC_TableView',
    })


-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Shop_Popup_SkillSlime:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Shop_Popup_SkillSlime'
    self.m_bVisible = true
    self.m_titleStr = Str('스킬 슬라임 상점')
    self.m_subCurrency = 'topaz'
    self.m_addSubCurrency = 'clancoin'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Shop_Popup_SkillSlime:init(struct_dragon)
    local vars = self:load_keepZOrder('shop_skill_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopBooster')

    self.m_category = 'skillslime'
    self.m_selectDragonData = struct_dragon

    self:initUI()
    self:initButton()
    self:init_TableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Shop_Popup_SkillSlime:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Shop_Popup_SkillSlime:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Shop_Popup_SkillSlime:refresh()
    self:refresh_dragonInfo()
    self:refresh_skillIcon()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_Shop_Popup_SkillSlime:init_TableView()
    local list_table_node = self.vars['tableViewNode']

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_item_list = g_shopData:getProductList(self.m_category)

    local ui_class = UI_Product
    local item_per_cell = 3
    local interval = 2
    local cell_width = 334
    local cell_height = 316

    -- 탭에서 상품 개수가 6개 이상이 되면 4줄로 노출
    if (6 <= table.count(l_item_list)) then
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
                UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.ITEM, function() end)
            end
        end)
	end    

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size((cell_width + interval), (cell_height + interval))
    table_view_td:setCellUIClass(UI_ProductSmall, create_cb_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td.m_nItemPerCell = item_per_cell

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
function UI_Shop_Popup_SkillSlime:sortProduct()
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
function UI_Shop_Popup_SkillSlime:click_exitBtn()
    self:close()
end








-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_Shop_Popup_SkillSlime:refresh_dragonInfo()
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
-- function refresh_skillIcon
-------------------------------------
function UI_Shop_Popup_SkillSlime:refresh_skillIcon()
	local vars = self.vars

	local t_dragon_data = self.m_selectDragonData

	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local l_skill_icon = skill_mgr:getDragonSkillIconList()

	for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
		local skill_node = vars['skillNode' .. i]
		skill_node:removeAllChildren()
            
		-- 스킬 아이콘 생성
		if l_skill_icon[i] then
			skill_node:addChild(l_skill_icon[i].root)
            l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
            l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(function()
				UI_SkillDetailPopup(t_dragon_data, i)
			end)

		-- 비어있는 스킬 아이콘 생성
		else
			local empty_skill_icon = IconHelper:getEmptySkillCard()
			skill_node:addChild(empty_skill_icon)

		end
	end
end