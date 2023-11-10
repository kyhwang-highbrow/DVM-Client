local PARENT = UI
-------------------------------------
--- @class UI_ResearchAbilityPopup
-------------------------------------
UI_ResearchAbilityPopup = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_ResearchAbilityPopup:init()    
    self.m_uiName = 'UI_ResearchAbilityPopup'
    self:load('research_ability_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResearchAbilityPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()    
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResearchAbilityPopup:initUI()
	local vars = self.vars

    do -- 능력치 텍스트
        local map = g_researchData:getMyResearchAbilityMap()
        local str = TableResearch:getInstance():getResearchBuffMapToStr(map)
        if str == '' then
            vars['infoLabel']:setString(Str('아직 연구 정보가 없습니다.'))
        else
            vars['infoLabel']:setString(str)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ResearchAbilityPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() 
        self:close()
    end)
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_ResearchAbilityPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ResearchAbilityPopup.open()
    local ui = UI_ResearchAbilityPopup()
    return ui
end

--@CHECK
UI:checkCompileError(UI_ResearchAbilityPopup)
