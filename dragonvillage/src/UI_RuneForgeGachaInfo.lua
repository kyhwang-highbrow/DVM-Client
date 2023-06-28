PARENT = UI
UI_RuneForgeGachaInfo = class(PARENT, {
    m_version = 'Number'    --일반 : 1, 고대 : 2
})

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeGachaInfo:init(version, ui_res)
    self.m_version = version

    self:load(ui_res or 'rune_forge_gacha_info.ui')
    UIManager:open(self, UIManager.POPUP)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneForgeGachaInfo')

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeGachaInfo:initUI()
    local vars = self.vars
    local version = self.m_version

    local isNormal = (version == 1)
    self:SetNormalRune(isNormal)
    self:SetAncientRune(not isNormal)

    vars['visual']:setVisible(true)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeGachaInfo:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaInfo:refresh()
end

-------------------------------------
-- function SetVisible_NormalRune
-------------------------------------
function UI_RuneForgeGachaInfo:SetNormalRune(isVisible)
    local vars = self.vars
    vars['normalRuneSprite1']:setVisible(isVisible)
    vars['normalRuneSprite2']:setVisible(isVisible)

    if (isVisible) then
        vars['runeLabel1']:setString(Str('6등급 일반 룬'))
        vars['runeLabel2']:setString(Str('7등급 일반 룬'))
    end
end

-------------------------------------
-- function SetVisible_AncientRune
-------------------------------------
function UI_RuneForgeGachaInfo:SetAncientRune(isVisible)
    local vars = self.vars
    vars['ancientRuneSprite1']:setVisible(isVisible)
    vars['ancientRuneSprite2']:setVisible(isVisible)

    if (isVisible) then
        vars['runeLabel1']:setString(Str('6등급 고대 룬'))
        vars['runeLabel2']:setString(Str('7등급 고대 룬'))
    end
end
--@CHECK
UI:checkCompileError(UI_RuneForgeGachaInfo)
