local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DungeonMenu
-------------------------------------
UI_DungeonMenu = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DungeonMenu:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DungeonMenu'
    self.m_bVisible = true
    self.m_titleStr = Str('던전')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DungeonMenu:init()
    local vars = self:load('dungeon_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DungeonMenu')

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
function UI_DungeonMenu:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DungeonMenu:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DungeonMenu:initButton()
    local vars = self.vars
    vars['dragonBtn']:registerScriptTapHandler(function() self:click_dragonBtn() end)
    vars['treeBtn']:registerScriptTapHandler(function() self:click_treeBtn() end)
    vars['nightmareBtn']:registerScriptTapHandler(function() self:click_nightmareBtn() end)
    vars['goldBtn']:registerScriptTapHandler(function() self:click_goldBtn() end)
    vars['relationBtn']:registerScriptTapHandler(function() self:click_relationBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DungeonMenu:refresh()
end

-------------------------------------
-- function click_dragonBtn
-------------------------------------
function UI_DungeonMenu:click_dragonBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_DRAGON)
end

-------------------------------------
-- function click_treeBtn
-------------------------------------
function UI_DungeonMenu:click_treeBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_TREE)
end

-------------------------------------
-- function click_nightmareBtn
-------------------------------------
function UI_DungeonMenu:click_nightmareBtn()
	g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_NIGHTMARE)
end

-------------------------------------
-- function click_goldBtn
-------------------------------------
function UI_DungeonMenu:click_goldBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_GOLD)
end

-------------------------------------
-- function click_relationBtn
-------------------------------------
function UI_DungeonMenu:click_relationBtn()
    g_secretDungeonData:goToSecretDungeonScene()
end

--@CHECK
UI:checkCompileError(UI_DungeonMenu)
