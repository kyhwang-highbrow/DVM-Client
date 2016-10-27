local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonMgrInfo
-------------------------------------
UI_DragonMgrInfo = class(PARENT,{
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMgrInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMgrInfo'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 관리') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMgrInfo:init()
    local vars = self:load('dragon_manage_scene.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMgrInfo')

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
function UI_DragonMgrInfo:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonMgrInfo:initButton()
    local vars = self.vars
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMgrInfo:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonMgrInfo:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonMgrInfo:click_upgradeBtn()
    local function close_cb()
        --self:refreshSelectDragonInfo()
        cclog('cb')
        self.root:setVisible(true)
    end

    self.root:setVisible(false)
    local ui = UI_DragonMgrSubmenu()
    ui:setCloseCB(close_cb)
end

--@CHECK
UI:checkCompileError(UI_DragonMgrInfo)
