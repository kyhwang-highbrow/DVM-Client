local PARENT = UI

----------------------------------------------------------------------
-- class UI_ClearTicket
----------------------------------------------------------------------
UI_ClearTicket = class(PARENT, {
    m_stageID = 'number',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_ClearTicket:init(stage_id)
    local vars = self:load('clear_ticket_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- UI 클래스명 지정
    self.m_uiName = 'UI_ClearTicket'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClearTicket')

    self:initMember(stage_id)
    self:initUI()
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicket:initMember(stage_id)
    self.m_stageID = stage_id
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicket:initUI()
    local vars = self.vars
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

    do -- 스테이지 이름 및 난이도
        local stage_name = g_stageData:getStageName(stage_id)
        vars['titleLabel']:setString(stage_name)

        local string_width = vars['titleLabel']:getStringWidth()
        local pos_x = -(string_width / 2)
        vars['difficultyLabel']:setPositionX(pos_x - 10)

        UIHelper:setDifficultyLabelWithColor(vars['difficultyLabel'], stage_id)
    end
end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ClearTicket:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicket:refresh()
end
