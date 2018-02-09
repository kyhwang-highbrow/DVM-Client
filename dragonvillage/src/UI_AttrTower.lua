local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_AttrTower
-------------------------------------
UI_AttrTower = class(PARENT, {
        m_tableView = 'UIC_TableView', -- 탑 층 리스트
        
        m_floorInfo = 'UI_AttrTowerFloorInfo', -- 탑 정보 UI
        m_rankInfo = 'UI_AttrTowerRank', -- 순위 정보 UI

		m_challengingFloor = 'number', -- 현재 진행중인 층
        m_selectedStageID = 'number', -- 현재 선택된 스테이지 아이디
    })

UI_AttrTower.TAB_INFO = 1
UI_AttrTower.TAB_RANK = 2

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTower:init()
    local vars = self:load_keepZOrder('attr_tower_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AttrTower')

    -- 층 정보
    self.m_floorInfo = UI_AttrTowerFloorInfo(self)
    self.m_rankInfo = UI_AttrTowerRank(self)

    -- 현재 진행중인 층
    local challengingFloor = g_attrTowerData:getChallengingFloor()
    local challengingStageID = g_attrTowerData:getChallengingStageID()

    self.m_challengingFloor = challengingFloor
    self.m_selectedStageID = challengingStageID

    self:initUI()
    self:initTab()
    self:initButton()

    -- 최초 진입시 도전 층 정보 표시
    self:refresh(g_attrTowerData.m_challengingInfo)

    self:sceneFadeInAction()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_AttrTower:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AttrTower'
    self.m_bUseExitBtn = true
    self.m_titleStr = g_attrTowerData:getAttrTopName()
    self.m_staminaType = 'tower'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttrTower:initUI()
    local vars = self.vars

    local attr = g_attrTowerData:getSelAttr()

    local bg_path = 'res/bg/tower_bg_' .. attr .. '.png'
    local bg = cc.Sprite:create(bg_path)
    if (bg) then
        bg:setDockPoint(ZERO_POINT)
        bg:setAnchorPoint(ZERO_POINT)
        vars['bgNode']:addChild(bg)

        vars['bgSprite'] = bg
    end
    
    local visual_id = 'icon_' .. attr
    vars['iconVisual']:changeAni(visual_id, true)

	do -- 테이블 뷰 생성
        local node = vars['floorNode']
        node:removeAllChildren()
        
		-- 층 생성
		local t_floor = clone(g_attrTowerData:getAttrTower_stageList())
        table.insert(t_floor, { stage = ANCIENT_TOWER_STAGE_ID_START, is_bottom = true })
        table.insert(t_floor, { stage = g_attrTowerData:getTopStageID() + 1, is_top = true })

		-- 셀 아이템 생성 콜백
		local create_func = function(ui, data)
            if (data['is_bottom'] or data['is_top']) then
                return
            end

            ui.vars['floorBtn']:registerScriptTapHandler(function()
                self:selectFloor(data)
            end)

            local stage_id = data['stage']
            if (stage_id == self.m_selectedStageID) then
                self:changeFloorVisual(stage_id, ui)
            end

			return true
        end

        local make_func = function(data)
            if (data['is_bottom']) then
                return UI_AttrTowerListBottomItem(data)
            elseif (data['is_top']) then
                return UI_AttrTowerListTopItem(data)
            else
			    return UI_AttrTowerListItem(data)
            end
        end
		
        -- 테이블 뷰 인스턴스 생성
        self.m_tableView = UIC_TableView(node)
        self.m_tableView:setUseVariableSize(true)
        self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
        self.m_tableView:setCellUIClass(make_func, create_func)
        self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.m_tableView:setItemList(t_floor)

        self.m_tableView.m_scrollView:setLimitedOffset(true)

        local function sort_func(a, b)
            return a['data']['stage'] < b['data']['stage']
        end
        table.sort(self.m_tableView.m_itemList, sort_func)
        
        self.m_tableView:makeAllItemUINoAction()
                
        -- 현재 도전중인 층이 바로 보이도록 처리
        local floor = g_attrTowerData:getFloorFromStageID(self.m_selectedStageID)
        self.m_tableView:relocateContainerFromIndex(floor + 1)
    end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_AttrTower:initTab()
    local vars = self.vars
    self:addTabWithLabel(UI_AttrTower.TAB_INFO, vars['towerTabBtn'], vars['towerTabLabel'], vars['towerMenu'])
    self:addTabWithLabel(UI_AttrTower.TAB_RANK, vars['rankingTabBtn'], vars['rankingTabLabel'], vars['rankingMenu'])
    self:setTab(UI_AttrTower.TAB_INFO)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttrTower:initButton()
    local vars = self.vars
    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_AttrTower:onChangeTab(tab, first)
    if (not first) then return end

    -- 최초 탭 누를 경우에만 랭킹 정보 가져옴
    if (tab == UI_AttrTower.TAB_RANK) then
        self.m_rankInfo:request_Rank()
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_AttrTower:update(dt)
    local vars = self.vars

    -- 시험의탑 테이블뷰 offset에 맞춰서 배경도 같이 스크롤 시킴

    -- 테이블뷰의 현재 스크롤 비율을 계산
    local _, min_offset = self.m_tableView:minContainerOffset()
    local _, max_offset = self.m_tableView:maxContainerOffset()
    local tower_offset = self.m_tableView.m_scrollView:getContentOffset()
    local scroll_rate = (tower_offset['y'] - min_offset) / (max_offset - min_offset)

    -- 배경 스크롤 좌표를 계산(화면 크기 고려)
    local bg_size = vars['bgSprite']:getContentSize()
    local scr_size = cc.Director:getInstance():getWinSize()
    local bg_scope = bg_size['height'] - scr_size['height']
    local bg_scroll_y = bg_scope * scroll_rate - (bg_scope / 2)

    vars['bgSprite']:setPosition(0, bg_scroll_y)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttrTower:refresh(floor_info)
    local vars = self.vars

    -- 층 정보 UI 갱신
    self.m_floorInfo:refresh(floor_info)

    -- 준비 버튼 활성화/비활성화
    local select_floor = floor_info.m_floor + ANCIENT_TOWER_STAGE_ID_START
    local is_open = g_attrTowerData:isOpenStage(select_floor)
    vars['readyBtn']:setEnabled(is_open)
    vars['lockSprite']:setVisible(not is_open)
end

-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_AttrTower:click_readyBtn()
	local func = function()
        local stage_id = self.m_selectedStageID

        local function close_cb()
            self:sceneFadeInAction()
        end

        local ui = UI_ReadySceneNew(stage_id)
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AttrTower:click_exitBtn()
    self:close()
end

-------------------------------------
-- function selectFloor
-------------------------------------
function UI_AttrTower:selectFloor(floor_info)
    local stage_id = floor_info['stage']

    if (self.m_selectedStageID ~= stage_id) then
        local finish_cb 
        finish_cb = function(ret)
            local prev_stage_id = self.m_selectedStageID
            self.m_selectedStageID = stage_id

            local stage_info = ret['tower_stage']
            local floor_info = StructAttrTowerFloorData(stage_info)
            self:refresh(floor_info)
            self:changeFloorVisual(prev_stage_id)
            self:changeFloorVisual(self.m_selectedStageID)
        end

        local attr = g_attrTowerData:getSelAttr()
        g_attrTowerData:request_attrTowerInfo(attr, stage_id, finish_cb)
    end
end

-------------------------------------
-- function changeFloorVisual
-------------------------------------
function UI_AttrTower:changeFloorVisual(stage_id, ui)
    local t_item = self.m_tableView.m_itemMap[stage_id]
    local ui = ui or t_item['ui']
    
    local is_selected = (stage_id == self.m_selectedStageID)
    local is_opened = g_attrTowerData:isOpenStage(stage_id)
    local visual_id

    if (is_selected) then
        visual_id = g_attrTowerData:getSelAttr() .. '_select'
    else
        visual_id = g_attrTowerData:getSelAttr() .. '_normal'
    end

    ui.vars['towerVisual']:changeAni(visual_id, true)
end

--@CHECK
UI:checkCompileError(UI_AttrTower)