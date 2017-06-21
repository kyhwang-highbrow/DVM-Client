local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_HatcheryCombinePopup
-------------------------------------
UI_HatcheryCombinePopup = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_HatcheryCombinePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_HatcheryCombinePopup'
    self.m_bVisible = true or false
    self.m_titleStr = Str('조합') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryCombinePopup:init()
    local vars = self:load('hatchery_combine_02.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_HatcheryCombinePopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcheryCombinePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HatcheryCombinePopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HatcheryCombinePopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_HatcheryCombinePopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_HatcheryCombinePopup)
