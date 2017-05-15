local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_UserInfoDetailPopup_SetLeader
-------------------------------------
UI_UserInfoDetailPopup_SetLeader = class(PARENT, {
	m_tUserInfo = 'table',
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManage_Base:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_bVisible = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:init(t_user_info)
    self.m_uiName = 'UI_UserInfoDetailPopup_SetLeader'

    local vars = self:load('user_info_dragon.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserInfoDetailPopup_SetLeader')

	self.m_tUserInfo = t_user_info

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:initUI()
    local vars = self.vars

	self:init_dragonTableView()
    self:setDefaultSelectDragon(self.m_tUserInfo['leader']['id'])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:initButton()
    local vars = self.vars
	--vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:refresh()
    local vars = self.vars

	self:refresh_dragon()
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:refresh_dragon()
	local vars = self.vars

	vars['dragonNode']:removeAllChildren(true)
	vars['starNode']:removeAllChildren(true)

	local t_dragon_data = StructDragonObject(self.m_tUserInfo['leader'])
	local did = t_dragon_data['did']
	local t_dragon = TableDragon():get(did)

	-- 드래곤 애니
	local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
	animator:setScale(0.6)
	vars['dragonNode']:addChild(animator.m_node)

	-- 드래곤 별
	local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data:getGrade(), t_dragon_data:getEclv(), 2)
	vars['starNode']:addChild(star_icon)
	
	-- 드래곤 이름
	local dragon_name = t_dragon_data:getDragonNameWithEclv()
	vars['nameLabel']:setString(dragon_name)
end


-------------------------------------
-- function refresh_dragonUpgradeMaterialTableView
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:init_dragonTableView()    
    local list_table_node = self.vars['listNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewExt = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_item_list = self:getDragonList()
    self.m_tableViewExt:setItemList(l_item_list)
end

--@CHECK
UI:checkCompileError(UI_UserInfoDetailPopup_SetLeader)
