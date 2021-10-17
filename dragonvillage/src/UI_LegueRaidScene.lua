local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

----------------------------------------------------------------------
-- class UI_LegueRaidScene
----------------------------------------------------------------------
UI_LegueRaidScene = class(PARENT, {

})

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  Init functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LegueRaidScene:initParentVariable()
    self.m_uiName = 'UI_LegueRaidScene'
    self.m_titleStr = Str('레이드')
    --self.m_subCurrency = 'raid_coin'
    self.m_bVisible = true              
    self.m_bUseExitBtn = true           
end

----------------------------------------------------------------------
-- function init
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LegueRaidScene:init()
    local vars = self:load('league_raid.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LegueRaidScene')    
    self:doActionReset()
    self:doAction(nil, false)

    self:initMember()
    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    g_dmgateData:MakeSeasonResetPopup(nil, true)
end

----------------------------------------------------------------------
-- function initMember
----------------------------------------------------------------------
function UI_LegueRaidScene:initMember()

end

----------------------------------------------------------------------
-- function initUI
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LegueRaidScene:initUI()

end

----------------------------------------------------------------------
-- function initButton
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LegueRaidScene:initButton()
    local vars = self.vars

    if (vars['infoBtn']) then vars['infoBtn']:registerScriptTapHandler(function() UI_LegueRaidInfoPopup() end) end

    if (vars['enterBtn']) then vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end) end

end

----------------------------------------------------------------------
-- function refresh
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LegueRaidScene:refresh()

end


----------------------------------------------------------------------
-- function initTableView
-- brief : 유저별로 UIC_TableView 생성을 위한 help function
----------------------------------------------------------------------
function UI_LegueRaidScene:initTableView()


end


----------------------------------------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LegueRaidScene:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end

----------------------------------------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LegueRaidScene:onFocus() 
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  click functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LegueRaidScene:click_exitBtn()
    self:close()
end



----------------------------------------------------------------------------
-- function click_enterBtn
----------------------------------------------------------------------------
function UI_LegueRaidScene:click_enterBtn()
    local scene = SceneGame(nil, DEV_STAGE_ID, 'stage_dev', true)
    scene:runScene()
end

----------------------------------------------------------------------------
-- function click_devBtn
----------------------------------------------------------------------------
function UI_LegueRaidScene:click_devBtn()

end






--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_LegueRaidInfoPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_LegueRaidInfoPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_LegueRaidInfoPopup:init()
    local vars = self:load('league_raid_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteInfoPopup')    

    self.m_uiName = 'UI_EventRouletteInfoPopup' 
     
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end


