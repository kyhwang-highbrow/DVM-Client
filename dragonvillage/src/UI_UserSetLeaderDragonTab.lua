local PARENT = UI_DragonManage_Base
-------------------------------------
-- class UI_UserSetLeaderDragonTab
-------------------------------------
UI_UserSetLeaderDragonTab = class(PARENT, {
	m_tUserInfo = 'table',
    m_selectDragonOID = 'string',
    m_ownerUI = '',
    m_tabName = '',
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_UserSetLeaderDragonTab:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_bVisible = false
    self.m_useTopUserInfo = false
end

-------------------------------------
-- function init_after
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_UserSetLeaderDragonTab:init_after()
end

-------------------------------------
-- function init
-------------------------------------
function UI_UserSetLeaderDragonTab:init(t_user_info)    
    self:load('user_info_dragon_setting_leader.ui')
	self.m_tUserInfo = t_user_info
	self.m_selectDragonOID = t_user_info['leader']['id']

    self:initUI()
    self:initButton()
    self:refresh()

    --self:releaseI_TopUserInfo_EventListener()
    --g_currScene:removeBackKeyListener(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserSetLeaderDragonTab:initUI()
    local vars = self.vars

	self:init_dragonTableView()
	self:init_dragonSortMgr()
    self:setDefaultSelectDragon(self.m_tUserInfo['leader']['id'])
end



-------------------------------------
-- function initButton
-------------------------------------
function UI_UserSetLeaderDragonTab:initButton()
    local vars = self.vars
	vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)
	--vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_UserSetLeaderDragonTab:onEnterTab(first)
    cclog('## UI_UserSetLeaderDragonTab:onEnterTab(first)')
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_UserSetLeaderDragonTab:onExitTab()
    cclog('## UI_UserSetLeaderDragonTab:onExitTab()')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserSetLeaderDragonTab:refresh()
    local vars = self.vars

	self:refresh_dragon()
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_UserSetLeaderDragonTab:refresh_dragon(t_dragon_data)
	local vars = self.vars

	vars['dragonNode']:removeAllChildren(true)
	vars['starNode']:removeAllChildren(true)

	local t_dragon_data = StructDragonObject(t_dragon_data or self.m_tUserInfo['leader'])

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
function UI_UserSetLeaderDragonTab:init_dragonTableView()    
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
function UI_UserSetLeaderDragonTab:init_dragonSortMgr()
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
function UI_UserSetLeaderDragonTab:click_selectBtn()
    if (not self.m_selectDragonData) then
        return
    end

    local before_doid = self.m_tUserInfo['leader']['id']
    local success_cb = function ()
        local curr_doid = self.m_tUserInfo['leader']['id']

		if (before_doid ~= curr_doid) then
			self:refresh_dragon()
            UIManager:toastNotificationGreen(Str('대표 드래곤이 변경되었습니다.'))
		end
    end

	if (self.m_selectDragonData['id'] ~= self.m_tUserInfo['leader']['id']) then
		self.m_tUserInfo['leader'] = self.m_selectDragonData
		g_dragonsData:request_setLeaderDragon('lobby', self.m_selectDragonOID, success_cb)
	end

	--self:click_closeBtn()
end

-------------------------------------
-- function onClose
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_UserSetLeaderDragonTab:onClose()

end

--@CHECK
UI:checkCompileError(UI_UserSetLeaderDragonTab)
