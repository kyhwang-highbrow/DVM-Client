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
function UI_UserInfoDetailPopup_SetLeader:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_bVisible = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:init(t_user_info)
    self.m_uiName = 'UI_UserInfoDetailPopup_SetLeader'

    local vars = self:load('user_info_dragon_old.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserInfoDetailPopup_SetLeader')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	self.m_tUserInfo = t_user_info
	self.m_selectDragonOID = t_user_info['leader']['id']

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
	self:init_dragonSortMgr()
    self:setDefaultSelectDragon(self.m_tUserInfo['leader']['id'])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:initButton()
    local vars = self.vars
	vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
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
function UI_UserInfoDetailPopup_SetLeader:refresh_dragon(t_dragon_data)
	local vars = self.vars

	vars['dragonNode']:removeAllChildren(true)
	vars['starNode']:removeAllChildren(true)

	local t_dragon_data = StructDragonObject(t_dragon_data or self.m_tUserInfo['leader'])
	local did = t_dragon_data['did']
	local t_dragon = TableDragon():get(did)

	-- 드래곤 애니
    -- 외형 변환 적용 Animator
	local animator = AnimatorHelper:makeDragonAnimatorByTransform(t_dragon_data)
	animator:setScale(0.6)
	vars['dragonNode']:addChild(animator.m_node)

	-- 드래곤 별
	local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data, 2)
	vars['starNode']:addChild(star_icon)
	
	-- 드래곤 이름
	local dragon_name = t_dragon_data:getDragonNameWithEclv()
	vars['nameLabel']:setString(dragon_name)
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:init_dragonTableView()    
    local list_table_node = self.vars['listNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)
		
		-- 최초 선택 표시
		if (data['id'] == self.m_selectDragonOID) then
            self:changeDragonSelectFrame(ui)
        end

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() 
			self:refresh_dragon(data)
			self.m_selectDragonOID = data['id']
			self.m_selectDragonData = data
			self:changeDragonSelectFrame(ui)
		end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewExt = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_item_list = g_dragonsData:getDragonsList()
    self.m_tableViewExt:setItemList(l_item_list)
end

-------------------------------------
-- function init_dragonSortMgr
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:init_dragonSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 대표 드래곤 등급 레벨 순으로 수정
    self.m_sortManagerDragon:pushSortOrder('lv')
    uic_sort_list:setSelectSortType('grade')

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
            self.m_sortManagerDragon:setAllAscending(ascending)
            self:apply_dragonSort()

            vars['sortSelectOrderSprite']:stopAllActions()
            if ascending then
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:click_selectBtn()
    if (not self.m_selectDragonData) then
        return
    end

	if (self.m_selectDragonData['id'] ~= self.m_tUserInfo['leader']['id']) then
		self.m_tUserInfo['leader'] = self.m_selectDragonData
		g_dragonsData:request_setLeaderDragon('lobby', self.m_selectDragonOID)
	end

	self:click_closeBtn()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_UserInfoDetailPopup_SetLeader:click_closeBtn()
    -- 닫히는 동안 버튼이 동작하지 않도록 처리
    local vars = self.vars
    vars['closeBtn']:setEnabled(false)
    vars['selectBtn']:setEnabled(false)

	-- 저장된 closeCB를 먼저 실행
    if self.m_closeCB then
	    self.m_closeCB()
	    self.m_closeCB = nil
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_UserInfoDetailPopup_SetLeader)
