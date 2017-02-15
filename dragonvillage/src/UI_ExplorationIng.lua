local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ExplorationIng
-------------------------------------
UI_ExplorationIng = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ExplorationIng:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ExplorationIng'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationIng:init()
    local vars = self:load('exploration_ing.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationIng')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationIng:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationIng:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationIng:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationIng:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ExplorationIng)
