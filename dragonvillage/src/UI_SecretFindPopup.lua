local PARENT = UI

-------------------------------------
-- class UI_SecretFindPopup
-------------------------------------
UI_SecretFindPopup = class(PARENT,{})

-------------------------------------
-- function init
-------------------------------------
function UI_SecretFindPopup:init()
    local vars = self:load('secret_dungeon_find_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SecretFindPopup')

    -- @UI_ACTION
    self:addAction(vars['rootNode'], UI_ACTION_TYPE_OPACITY, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SecretFindPopup:initUI()
    local vars = self.vars

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SecretFindPopup:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    self.vars['enterBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SecretFindPopup:refresh()
end


-- TODO: 파라미터 정의 필요
function MakeSimpleSecretFindPopup()
    local ui = UI_SecretFindPopup()
    ui.vars['dungeonLabel']:setString(title_str)
    ui.vars['dungeonDscLabel']:setString(title_str)

    return ui
end

--@CHECK
UI:checkCompileError(UI_SecretFindPopup)
