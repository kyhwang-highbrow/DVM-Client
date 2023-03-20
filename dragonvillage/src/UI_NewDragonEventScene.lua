local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_NewDragonEventScene
-------------------------------------
UI_NewDragonEventScene = class(PARENT, {
        m_tableView = 'UIC_TableView', -- 네스트 던전의 세부 모드들 리스트
        m_selectNestDungeonInfo = 'table', -- 현재 선택된 세부 모드
        m_bDirtyDungeonList = 'boolean',

		m_stageID = 'num',
		m_dungeonType = 'string',		-- 네스트 던전 타입
		m_isIsolation = 'boolean',		-- 악몽, 황금 던전 구분
		m_tempUI = 'UI',
		m_tempData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NewDragonEventScene:init(stage_id)
    local vars = self:load('dungeon_new_dragon_scene.ui')
    self.m_dungeonType = NEST_DUNGEON_TREE
    self.m_stageID = stage_id
    UIManager:open(self, UIManager.SCENE)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_NewDragonEventScene')
    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    self:initUI()
	self:initButton()
    self:refresh()
    self:makeNestModeTableView()
    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_NewDragonEventScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_NewDragonEventScene'
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NewDragonEventScene:initUI()
    local vars = self.vars	
	self.m_tempUI = nil
	self.m_tempData = nil

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
    vars['bgVisual']:setLocalZOrder(-1)
end


-------------------------------------
-- function makeNestModeTableView
-- @brief 네스트 던전 모드 선택했을 때 오른쪽에 나오는 세부 리스트
-------------------------------------
function UI_NewDragonEventScene:makeNestModeTableView()
    local node = self.vars['detailTableViewNode']

    --local t_data = self.m_selectNestDungeonInfo['data']
    local nest_dungeon_id = 1230400 --t_data['mode_id']
    local stage_list = g_eventNewDragon:getNewDragonEventDungeonStageIdList()


    -- 셀 아이템 생성 콜백
    local function create_func(ui, data)
        local stage_id = data
        ui.vars['scenarioStartButton']:registerScriptTapHandler(function() 
            self:playScenario(stage_id, 'snro_start')
        end)
        ui.vars['scenarioEndButton']:registerScriptTapHandler(function() 
            self:playScenario(stage_id, 'snro_finish')
        end)
        return true
    end

    --local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(nest_dungeon_id)
    --local dungeon_mode = t_dungeon_id_info['dungeon_mode']

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(886, 120 + 10)

--[[     if (dungeon_mode == NEST_DUNGEON_NIGHTMARE) then
        table_view:setCellUIClass(UI_NightmareStageListItem, create_func)
    elseif (dungeon_mode == NEST_DUNGEON_ANCIENT_RUIN) then
        table_view:setCellUIClass(UI_AncientRuinStageListItem, create_func)
    else
        table_view:setCellUIClass(UI_NestDungeonStageListItem, create_func)
    end
 ]]
    local content_size = node:getContentSize()

    table_view:setCellUIClass(UI_NestDungeonStageListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(stage_list, true)
    table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_x = x + content_size['width']
        ui.root:setPosition(new_x, y)

        local force = true
        ui:cellMoveTo(0.25, cc.p(x, y), force)
    end

    -- 최종 클리어한 스테이지 focus
--[[     do
        local focus_idx  
        for _, v in ipairs(table_view.m_itemList) do
            local idx = v['unique_id']
            local stage_id = v['data']['stage']
            local is_open = g_stageData:isOpenStage(stage_id)
            if (is_open) then
                focus_idx = idx
            end
        end
        table_view:relocateContainerFromIndex(focus_idx, false)
    end ]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NewDragonEventScene:initButton()
    local vars = self.vars
	vars['dragonInfoBtn']:registerScriptTapHandler(function() self:click_dragonInfoBtn() end)

    -- 던전 드랍 정보 설명 버튼
    vars['infoBtn']:setVisible(false)
    -- 악몽 던전
    if (self.m_dungeonType == NEST_DUNGEON_NIGHTMARE) then
		vars['infoBtn']:setVisible(true)
        vars['infoBtn']:setAutoShake(true)
        vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn('nightmare') end)

    -- 고대 유적 던전
    elseif (self.m_dungeonType == NEST_DUNGEON_ANCIENT_RUIN) then
		vars['infoBtn']:setVisible(true)
        vars['infoBtn']:setAutoShake(true)
        vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn('ancient_ruin') end)
	end
    
end

-------------------------------------
-- function click_infoBtn
-- @breif 던전 정보 (룬 드랍 정보)
-------------------------------------
function UI_NewDragonEventScene:click_infoBtn(tab_type)
    UI_HelpRune('probability', tab_type)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NewDragonEventScene:refresh()
end

-------------------------------------
-- function arrangeItemUI
-- @brief itemUI들을 정렬한다!
-------------------------------------
function UI_NewDragonEventScene:arrangeItemUI(l_hottime)
    for i, ui_name in pairs(l_hottime) do
        local ui = self.vars[ui_name]
        if (ui ~= nil) then
            ui:setVisible(true)
            local pos_x = (i-1) * 72
            ui:setPositionX(pos_x)
        end
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_NewDragonEventScene:click_exitBtn()
    if self.m_selectNestDungeonInfo then
        self:closeSubMenu()
		if (not self.m_isIsolation) then
			return
		end
    end

	if (g_currScene.m_sceneName == 'SceneNestDungeon') then
		local is_use_loading = false
		local scene = SceneLobby(is_use_loading)
		scene:runScene()
	else
		self:close()
	end
end

-------------------------------------
-- function click_dragonInfoBtn
-------------------------------------
function UI_NewDragonEventScene:click_dragonInfoBtn()
	UI_RecommendedDragonInfoPopup(self.m_selectNestDungeonInfo)
end

-------------------------------------
-- function closeSubMenu
-------------------------------------
function UI_NewDragonEventScene:closeSubMenu()
	local vars = self.vars

    -- 탑바의 입장권
    g_topUserInfo:setStaminaType('st')

    if (not self.m_selectNestDungeonInfo) then
        return
    end

    -- 액션 stop
    vars['detailTableViewNode']:stopAllActions()

    -- 스테이지 리스트 테이블 뷰 삭제
    vars['detailTableViewNode']:removeAllChildren()

    local ui = self.m_selectNestDungeonInfo['ui']
    local key = self.m_selectNestDungeonInfo['key']
    local t_item = self.m_tableView:getItem(key)
    self.m_selectNestDungeonInfo = nil

    local node = ui.root
    local container = self.m_tableView.m_scrollView:getContainer()
    local node_pos = convertToAnoterParentSpace(node, container)

    node:retain()
    node:removeFromParent()
    node:setPosition(node_pos['x'], node_pos['y'])

    container:addChild(node, 100 - t_item['idx'])
    node:release()
    
    t_item['ui'] = ui
    local data = t_item['data']

    self.m_tableView:setDirtyItemList()
    
    vars['tableViewNode']:setVisible(true)

	vars['dragonInfoBtn']:stopAllActions()
	vars['dragonInfoBtn']:setVisible(false)

    for i,v in ipairs(self.m_tableView.m_itemList) do
        if (v['unique_id'] ~= key) then
            if v['ui'] then
                v['ui'].root:setScale(0)
                local scale_to = cc.ScaleTo:create(0.25, 1)
                local action = cc.EaseInOut:create(scale_to, 2)
                local sequence = cc.Sequence:create(cc.DelayTime:create(0.3 + (i-1) * 0.02), action)
                v['ui'].root:runAction(sequence)
            end
        end
    end
end

-------------------------------------
-- function playScenario
-------------------------------------
function UI_NewDragonEventScene:playScenario(stage_id, scenario_type, cb_func)
    -- 콜백
    local ui_block

    local function start()
        ui_block = UIManager:makeTouchBlock(self, true)
        if (cb_func) then
            cb_func()
        end
    end
    
    -- 스테이지 id와 시나리오 타입(start or finish)로 시나리오를 찾아와 있으면 재생
    local scenario_name = TableStageDesc:getScenarioName(stage_id, scenario_type)
    if scenario_name then
        local ui = g_scenarioViewingHistory:playScenario(scenario_name, true)
        if ui then
            if ui_block ~= nil then
                ui_block:removeFromParent()
            end
            --self.m_containerLayer:setVisible(false)
            ui:setCloseCB(start)
            ui:next()
            return
        end
    end

    -- 시나리오를 재생 못하고 콜백 콜
    start()
end


--@CHECK
UI:checkCompileError(UI_NewDragonEventScene)
