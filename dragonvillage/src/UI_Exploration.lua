local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Exploration
-------------------------------------
UI_Exploration = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Exploration:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Exploration'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_Exploration:init()
    local vars = self:load('exploration_map.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Exploration')

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
function UI_Exploration:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Exploration:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Exploration:refresh()
    local vars = self.vars

    for i,v in pairs(g_explorationData.m_explorationList) do
        local order = v['order']
        local epr_id = v['epr_id']
        local ui = UI_ExplorationLocationButton(epr_id)
        vars['locationNode' .. order]:addChild(ui.root)
    end    
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Exploration:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_Exploration)
