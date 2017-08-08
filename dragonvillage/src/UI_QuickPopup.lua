local PARENT = UI

-------------------------------------
-- class UI_QuickPopup
-------------------------------------
UI_QuickPopup = class(PARENT, {
        m_loadingUI = 'UI_TitleSceneLoading',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_QuickPopup:init()
    local vars = self:load('quick_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_QuickPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuickPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuickPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)

    vars['homeBtn']:registerScriptTapHandler(function() UINavigator:goTo('lobby') end)
    vars['adventureBtn']:registerScriptTapHandler(function() UINavigator:goTo('adventure') end)
    vars['explorationBtn']:registerScriptTapHandler(function() UINavigator:goTo('exploration') end)

    vars['nest_evo_stoneBtn']:registerScriptTapHandler(function() end)
    vars['nest_treeBtn']:registerScriptTapHandler(function() end)
    vars['nest_nightmareBtn']:registerScriptTapHandler(function() end)
    vars['secret_relationBtn']:registerScriptTapHandler(function() end)

    vars['colosseumBtn']:registerScriptTapHandler(function() UINavigator:goTo('colosseum') end)
    vars['ancientBtn']:registerScriptTapHandler(function() UINavigator:goTo('ancient') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuickPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_QuickPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_settingBtn
-------------------------------------
function UI_QuickPopup:click_settingBtn()
    UI_Setting()
end


--[[
-------------------------------------
-- function click_evoStoneBtn
-- @brief 진화재료 던전
-------------------------------------
function UI_QuickPopup:click_evoStoneBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_EVO_STONE)
end

-------------------------------------
-- function click_treeBtn
-- @brief 거목 던전
-------------------------------------
function UI_QuickPopup:click_treeBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_TREE)
end

-------------------------------------
-- function click_nightmareBtn
-- @brief 악몽 던전
-------------------------------------
function UI_QuickPopup:click_nightmareBtn()
    g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_NIGHTMARE)
end

-------------------------------------
-- function click_relationBtn
-- @brief 인연 던전
-------------------------------------
function UI_QuickPopup:click_relationBtn()
    g_secretDungeonData:goToSecretDungeonScene()
end
--]]