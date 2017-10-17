local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ClassFormUseTopUserInfo
-------------------------------------
UI_ClassFormUseTopUserInfo = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClassFormUseTopUserInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClassFormUseTopUserInfo'
    self.m_bVisible = true or false
    self.m_titleStr = Str('타이틀') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClassFormUseTopUserInfo:init()
    local vars = self:load('uiName.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClassFormUseTopUserInfo')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClassFormUseTopUserInfo:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClassFormUseTopUserInfo:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClassFormUseTopUserInfo:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClassFormUseTopUserInfo:click_exitBtn()
    error('\nUI name : ' .. (self.m_uiName or 'no name'))
end

--@CHECK
UI:checkCompileError(UI_ClassFormUseTopUserInfo)
