local PARENT = UI_IngameUnitInfo

-------------------------------------
-- class UI_IngameBossInfo
-------------------------------------
UI_IngameBossInfo = class(PARENT, {
    m_uiTooltip = ''
})

-------------------------------------
-- function init
-------------------------------------
function UI_IngameBossInfo:init()
    self.m_uiTooltip = nil
end

-------------------------------------
-- function loadUI
-------------------------------------
function UI_IngameBossInfo:loadUI()
    local vars = self:load('ingame_boss_hp.ui')
    return vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameBossInfo:initUI()
    local vars = self.vars
    local boss = self.m_owner
    local t_boss = boss.m_charTable

    if (vars['attrNode']) then
        local attr_str = boss:getAttribute()
        local icon = IconHelper:getAttributeIcon(attr_str)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['attrNode']:addChild(icon)
        end
    end
	
	-- 디버깅용 label
	self:makeDebugingLabel()

    vars['bossSKillGauge']:setPercentage(0)

    -- 웨이브 표시 숨김
    self.m_owner.m_world.m_inGameUI.vars['waveVisual']:setVisible(false)

    -- 스킬별 버튼 생성
    --[[
    for i = 1, 9 do
        local skill_id = t_boss['skill_' .. i]
        if (skill_id == '') then break end
            
        local button = self:makeSkillButton(skill_id)
        local x = -120 * (i - 1)
        local y = 0

        button:setPosition(x, y)
    end
    ]]--
end

-------------------------------------
-- function makeSkillButton
-------------------------------------
function UI_IngameBossInfo:makeSkillButton(skill_id)
    local vars = self.vars
    local t_skill = self.m_owner:getSkillTable(skill_id)

    local node = cc.MenuItemImage:create(t_skill['res_icon'], t_skill['res_icon'], 1)
    local button = UIC_Button(node)

    button:setDockPoint(cc.p(0.5, 0.5))
    button:setAnchorPoint(cc.p(0.5, 0.5))
    button:registerScriptTapHandler(function()
        self:click_skillButton(button, skill_id)
    end)
    
    vars['bossSkillNode']:addChild(button.m_node)
        
    return button
end

-------------------------------------
-- function click_skillButton
-------------------------------------
function UI_IngameBossInfo:click_skillButton(button, skill_id)
    local str = UI_Tooltip_Skill:getSkillDescStr(self.m_owner.m_charType, skill_id)
    local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(button)

    -- 자동 닫힘 처리
    tool_tip:autoRelease(3)
end

-------------------------------------
-- function getPositionForStatusIcon
-------------------------------------
function UI_IngameBossInfo:getPositionForStatusIcon(bLeftFormation, idx)
    local x = 50 * ((idx-1) % 7)
    local y = -(math_floor((idx-1)/7) * 50)
    	
    return x, y
end

-------------------------------------
-- function getScaleForStatusIcon
-------------------------------------
function UI_IngameBossInfo:getScaleForStatusIcon()
    return 1
end