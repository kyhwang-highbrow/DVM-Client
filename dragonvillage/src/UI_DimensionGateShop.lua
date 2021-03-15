local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())


UI_DimensionGateShop = class(PARENT, {

})


-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateShop:init() 
    local vars = self:load('dmgate_shop.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DimensionGateShop')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateShop:initUI() 

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DimensionGateShop:initButton() 

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DimensionGateShop:refresh() 

end



-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:initParentVariable()
    self.m_uiName = 'UI_DimensionGateShop'
    self.m_titleStr = Str('차원문 상점')
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end
-------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:onFocus() 

end


-------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:click_exitBtn()
   self:close()
end

