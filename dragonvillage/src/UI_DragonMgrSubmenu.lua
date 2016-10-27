local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonMgrSubmenu
-------------------------------------
UI_DragonMgrSubmenu = class(PARENT,{
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMgrSubmenu:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMgrSubmenu'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 관리') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMgrSubmenu:init()
    local vars = self:load('upgrade_window.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMgrSubmenu')

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
function UI_DragonMgrSubmenu:initUI()
    local function cb_swipe_event(type)
        if (type == 'up') then
            self.root:stopAllActions()
            local move = cc.MoveTo:create(0.3, cc.p(0, 124))
            local ease_in_out = cc.EaseInOut:create(move, 2)
            self.root:runAction(ease_in_out)
        elseif (type == 'down') then
            self.root:stopAllActions()
            local move = cc.MoveTo:create(0.3, cc.p(0, 0))
            local ease_in_out = cc.EaseInOut:create(move, 2)
            self.root:runAction(ease_in_out)
        end
    end


    local swipe_node = cc.Node:create()
    self.root:addChild(swipe_node, 10)
    Camera_LobbySwipe(swipe_node, cb_swipe_event)

    --[[
    self.root:setPosition(0, 124)
    local move = cc.MoveTo:create(0.5, cc.p(0, 0))
    local ease_in_out = cc.EaseInOut:create(move, 2)
    self.root:runAction(ease_in_out)
    --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonMgrSubmenu:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMgrSubmenu:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonMgrSubmenu:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonMgrSubmenu)
