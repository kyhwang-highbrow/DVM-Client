local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_BattleMenu
-------------------------------------
UI_BattleMenu = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_BattleMenu:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_BattleMenu'
    self.m_bVisible = true
    self.m_titleStr = Str('전투')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenu:init()
    local vars = self:load('battle_menu.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BattleMenu')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_BattleMenu:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenu:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BattleMenu:initButton()
    local vars = self.vars
    vars['dragonBtn']:registerScriptTapHandler(function() self:click_dragonBtn() end)
    vars['treeBtn']:registerScriptTapHandler(function() self:click_treeBtn() end)
    vars['nightmareBtn']:registerScriptTapHandler(function() self:click_nightmareBtn() end)
    vars['goldBtn']:registerScriptTapHandler(function() self:click_goldBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BattleMenu:refresh()
end

-------------------------------------
-- function click_dragonBtn
-------------------------------------
function UI_BattleMenu:click_dragonBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_DRAGON)
end

-------------------------------------
-- function click_treeBtn
-------------------------------------
function UI_BattleMenu:click_treeBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_TREE)
end

-------------------------------------
-- function click_nightmareBtn
-------------------------------------
function UI_BattleMenu:click_nightmareBtn()
	g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_NIGHTMARE)
end

-------------------------------------
-- function click_goldBtn
-------------------------------------
function UI_BattleMenu:click_goldBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_GOLD)
end

--@CHECK
UI:checkCompileError(UI_BattleMenu)
