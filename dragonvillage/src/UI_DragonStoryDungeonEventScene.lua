local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonStoryDungeonEventScene
-------------------------------------
UI_DragonStoryDungeonEventScene = class(PARENT, {
    m_tableView = 'UIC_TableView', -- 스토리 던전
    m_seasonId = 'string', -- 시즌 아이디
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonStoryDungeonEventScene:init(season_id)
    local vars = self:load('story_dungeon_scene.ui')
    self.m_seasonId = season_id
    UIManager:open(self, UIManager.SCENE)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonStoryDungeonEventScene')
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
function UI_DragonStoryDungeonEventScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonStoryDungeonEventScene'
    self.m_titleStr = TableStoryDungeonEvent:getStoryDungeonEventName(self.m_seasonId)
    self.m_subCurrency = 'medal_angra'
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonStoryDungeonEventScene:initUI()
    local vars = self.vars	

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
    vars['bgVisual']:setLocalZOrder(-1)
end


-------------------------------------
-- function makeNestModeTableView
-------------------------------------
function UI_DragonStoryDungeonEventScene:makeNestModeTableView()
    local node = self.vars['detailTableViewNode']
    local vars = self.vars

    --local t_data = self.m_selectNestDungeonInfo['data']
    local stage_list = g_eventDragonStoryDungeon:getStoryDungeonStageIdList(self.m_seasonId)

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
    table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_x = x + content_size['width']
        ui.root:setPosition(new_x, y)

        local force = true
        ui:cellMoveTo(0.25, cc.p(x, y), force)
    end

    local ui_menu = UI_BattleMenuItem_Adventure('story_dungeon', 4)
    vars['dungeonNode']:removeAllChildren()
    vars['dungeonNode']:addChild(ui_menu.root)

    ui_menu.vars['enterBtn']:setEnabled(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonStoryDungeonEventScene:initButton()
    local vars = self.vars
    
    vars['shopBtn']:registerScriptTapHandler(function () self:click_shopBtn() end)
    vars['questBtn']:registerScriptTapHandler(function () self:click_questBtn() end)
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
-- function arrangeItemUI
-- @brief itemUI들을 정렬한다!
-------------------------------------
function UI_DragonStoryDungeonEventScene:arrangeItemUI(l_hottime)
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
function UI_DragonStoryDungeonEventScene:click_exitBtn()
	self:close()
end

-------------------------------------
-- function playScenario
-------------------------------------
function UI_DragonStoryDungeonEventScene:playScenario(stage_id, scenario_type, cb_func)
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

-------------------------------------
-- function click_shopBtn
-------------------------------------
function UI_DragonStoryDungeonEventScene:click_shopBtn()
    require('UI_StoryDungeonEventShop')
    UI_StoryDungeonEventShop.open(self.m_seasonId)
end

-------------------------------------
-- function click_questBtn
-------------------------------------
function UI_DragonStoryDungeonEventScene:click_questBtn()
    require('UI_StoryDungeonEventQuest')
    UI_StoryDungeonEventQuest.open(self.m_seasonId)
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonStoryDungeonEventScene.open()
    local request_cb = function (ret)
        local season_id = g_eventDragonStoryDungeon:getStoryDungeonSeason()
        UI_DragonStoryDungeonEventScene(season_id)
    end

    g_eventDragonStoryDungeon:requestStoryDungeonInfo(request_cb)
end

--@CHECK
UI:checkCompileError(UI_DragonStoryDungeonEventScene)
