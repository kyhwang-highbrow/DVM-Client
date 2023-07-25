local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonStoryDungeonEventScene
-------------------------------------
UI_DragonStoryDungeonEventScene = class(PARENT, {
    m_tableView = 'UIC_TableView', -- 스토리 던전
    m_seasonId = 'string', -- 시즌 아이디
    m_seasonCode = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonStoryDungeonEventScene:init(move_arg)
    self.m_seasonId, self.m_seasonCode = g_eventDragonStoryDungeon:getStoryDungeonSeasonId()
    self.m_uiName = 'UI_DragonStoryDungeonEventScene'
    self:load('story_dungeon_scene.ui')

    UIManager:open(self, UIManager.SCENE)
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonStoryDungeonEventScene') -- backkey 지정
    
    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)

    cclog('시즌 아이디 : ', self.m_seasonId)
    --self:doActionReset()
    --self:doAction(nil, false)


    self:initUI()
	self:initButton()
    self:refresh()
    self:makeTableView()
    --self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonStoryDungeonEventScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_useTopUserInfo = false
    self.m_titleStr = TableStoryDungeonEvent:getStoryDungeonEventName(self.m_seasonId)
    self.m_subCurrency = TableStoryDungeonEvent:getStoryDungeonEventTokentKey(self.m_seasonId)
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonStoryDungeonEventScene:initUI()
    local vars = self.vars	

--[[     -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
    vars['bgVisual']:setLocalZOrder(-1) ]]

    local function update(dt)
        local is_noti_on = g_highlightData:isHighlightStoryDungeonQuest()
        vars['notiSprite']:setVisible(is_noti_on)
    end

    if vars['notiSprite'] ~= nil then
        vars['notiSprite']:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end

    do -- 배경 이미지
        local bg_res = TableStoryDungeonEvent:getStoryDungeonEventBgRes(self.m_seasonId)
        local animator = MakeAnimator(bg_res)

        vars['bgNode']:removeAllChildren()
        vars['bgNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function makeNestModeTableView
-------------------------------------
function UI_DragonStoryDungeonEventScene:makeTableView()
    local node = self.vars['detailTableViewNode']
    local vars = self.vars
    
    local stage_list = g_eventDragonStoryDungeon:getStoryDungeonStageIdList(self.m_seasonId)

    -- 셀 아이템 생성 콜백
    local function create_func(ui, data)
        local stage_id = data
        local scenario_name = TableStageDesc:getScenarioName(stage_id, 'snro_start')
        local is_clear = g_eventDragonStoryDungeon:getStoryDungeonStageClearCount(self.m_seasonId, stage_id)
        ui.vars['scenarioEndButton']:setVisible(scenario_name ~= nil and is_clear > 0)
        ui.vars['scenarioEndButton']:registerScriptTapHandler(function() 
            self:playScenario(stage_id, 'snro_start', function() 
                self:playScenario(stage_id, 'snro_finish')
            end)
        end)

        return true
    end

    local function make_func(data)
        return UI_DragonStoryDungeonStageListItem(self.m_seasonId, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(886, 120 + 10)

    local content_size = node:getContentSize()
    require('UI_DragonStoryDungeonStageListItem')
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(stage_list, true)
--[[     table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_x = x + content_size['width']
        ui.root:setPosition(new_x, y)

        local force = true
        ui:cellMoveTo(0.25, cc.p(x, y), force)
    end ]]

    -- focus할 stage_id가 있을 경우 
    local stage_idx = g_eventDragonStoryDungeon:getLastStageIdx()
    table_view:relocateContainerFromIndex(stage_idx, false)

    local ui_menu = UI_BattleMenuItem_Adventure('story_dungeon', 4, true)
    vars['dungeonNode']:removeAllChildren()
    vars['dungeonNode']:addChild(ui_menu.root)
--[[ 
    ui_menu.vars['enterBtn']:setEnabled(false)
    ui_menu.vars['storyEventNode']:setVisible(false)
    ui_menu.vars['timeSprite']:setVisible(false)
    ui_menu.vars['notiSprite']:notiSprite(false) ]]
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonStoryDungeonEventScene:initButton()
    local vars = self.vars
    vars['shopBtn']:registerScriptTapHandler(function () self:click_shopBtn() end)
    vars['questBtn']:registerScriptTapHandler(function () self:click_questBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function () self:click_helpBtn() end)
end

-------------------------------------
-- function click_infoBtn
-- @breif 던전 정보 (룬 드랍 정보)
-------------------------------------
function UI_DragonStoryDungeonEventScene:click_infoBtn(tab_type)
    UI_HelpRune('probability', tab_type)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonStoryDungeonEventScene:refresh()
end


-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonStoryDungeonEventScene:click_exitBtn()
	self:close()
end

-------------------------------------
-- function playScenario
-------------------------------------
function UI_DragonStoryDungeonEventScene:playScenario(stage_id, scenario_type, cb_func)
    -- 스테이지 id와 시나리오 타입(start or finish)로 시나리오를 찾아와 있으면 재생
    local scenario_name = TableStageDesc:getScenarioName(stage_id, scenario_type)
    if scenario_name then
        local ui = g_scenarioViewingHistory:playScenario(scenario_name, true)
        if ui then
            ui:setCloseCB(cb_func)
            ui:next()
            return
        end
    end
end

-------------------------------------
-- function click_shopBtn
-------------------------------------
function UI_DragonStoryDungeonEventScene:click_shopBtn()
    require('UI_StoryDungeonEventShop')
    UI_StoryDungeonEventShop.open()
end

-------------------------------------
-- function click_questBtn
-------------------------------------
function UI_DragonStoryDungeonEventScene:click_questBtn()
    local success_cb = function ()
        require('UI_StoryDungeonEventQuest')
        UI_StoryDungeonEventQuest.open(self.m_seasonId)
    end

    g_eventDragonStoryDungeon:requestStoryDungeonQuest(success_cb)
end

-------------------------------------
-- function click_questBtn
-------------------------------------
function UI_DragonStoryDungeonEventScene:click_helpBtn()
    local ui = MakePopup('story_dungeon_event_help.ui')
    -- @UI_ACTION
    ui:doActionReset()
    ui:doAction(nil, false)
end

--@CHECK
UI:checkCompileError(UI_DragonStoryDungeonEventScene)
