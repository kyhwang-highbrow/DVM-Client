local PARENT = UI

-------------------------------------
-- class UI_EventBingoPackagePopup
-------------------------------------
UI_EventBingoPackagePopup = class(PARENT, {
    m_closeBtn = '',
    m_contractBtn = '',
    m_timeLabel = '',

    m_buyBtns = '',
    m_itemLabels = '',

})


-------------------------------------
-- class init
-------------------------------------
function UI_EventBingoPackagePopup:init()
    local vars = self:load('package_bingo_token.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_EventBingoPackagePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initMember()
    self:initUI()
    self:initButton()
    self:refresh()
end


-------------------------------------
-- class initMember
-------------------------------------
function UI_EventBingoPackagePopup:initMember()
    local vars = self.vars

    self.m_closeBtn = vars['closeBtn']
    self.m_contractBtn = vars['closeBtn']
    local buttonNum = 1

    self.m_buyBtns = {}
    self.m_itemLabels = {}

    while(vars['buyBtn' .. tostring(buttonNum)] ~= nil) do
        self.m_buyBtns[buttonNum] = vars['buyBtn' .. tostring(buttonNum)]
        --self.m_itemLabels[buttonNum]        
        buttonNum = buttonNum + 1
    end
    
end
-------------------------------------
-- class initUI
-------------------------------------
function UI_EventBingoPackagePopup:initUI()
end


-------------------------------------
-- class initButton
-------------------------------------
function UI_EventBingoPackagePopup:initButton()
    self.m_closeBtn:registerScriptTapHandler(function() self:click_closeBtn() end)

end


-------------------------------------
-- class refresh
-------------------------------------
function UI_EventBingoPackagePopup:refresh()

end


function UI_EventBingoPackagePopup:click_closeBtn()
    self:close()
end