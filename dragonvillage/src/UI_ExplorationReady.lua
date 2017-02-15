local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ExplorationReady
-------------------------------------
UI_ExplorationReady = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ExplorationReady:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ExplorationReady'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험 준비') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationReady:init()
    local vars = self:load('exploration_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationReady')

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
function UI_ExplorationReady:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationReady:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationReady:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationReady:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ExplorationReady)
