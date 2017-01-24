local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RuneEnchantPopup
-------------------------------------
UI_RuneEnchantPopup = class(PARENT, {
        m_tRuneData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneEnchantPopup:init(t_rune_data)
    self.m_tRuneData = t_rune_data

    local vars = self:load('dragon_rune_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneEnchantPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RuneEnchantPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneEnchantPopup'
    self.m_bVisible = true
    self.m_titleStr = Str('룬 강화')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RuneEnchantPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneEnchantPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneEnchantPopup:initButton()
    local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_RuneEnchantPopup:refresh()
    local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_RuneEnchantPopup)
