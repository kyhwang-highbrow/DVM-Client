local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

UI_DimensionGateScene = class(PARENT, {
    
    
    
    m_blessBtn = '',
    m_infoBtn = '',
    m_topBtn = '',
    m_bottomBtn = '',
    m_shopBtn = '',
})

function UI_DimensionGateScene:init()
    local vars = self:load('dmgate_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DimensionGateScene')
    
    --self:doActionReset()
    --self:doAction(nil, false)
    self:initMemberVariable()
    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

function UI_DimensionGateScene:initUI()
end
function UI_DimensionGateScene:initButton() 
    --local vars = self.vars
    self.m_shopBtn:registerScriptTapHandler(function() self:click_shopBtn() end)
    self.m_infoBtn:registerScriptTapHandler(function() self:click_infoBtn() end)
    self.m_blessBtn:registerScriptTapHandler(function() self:click_blessBtn() end)

end
function UI_DimensionGateScene:refresh() end

function UI_DimensionGateScene:initMemberVariable()
    local vars = self.vars

    self.m_blessBtn = vars['blessBtn']
    self.m_infoBtn = vars['infoBtn']
    self.m_topBtn = vars['topBtn']
    self.m_bottomBtn = vars['bottomBtn']
    self.m_shopBtn = vars['shopBtn']
end


-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:initParentVariable()
    self.m_uiName = 'UI_DimensionGateScene'
    self.m_titleStr = Str('차원문')
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end
-------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:onFocus() 

end


-------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:click_exitBtn()
   self:close()
end


-------------------------------------
-- function click_shopBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_shopBtn()
    UI_DimensionGateShop()
end


-------------------------------------
-- function click_infoBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_infoBtn()

end

-------------------------------------
-- function click_blessBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_blessBtn()

end
