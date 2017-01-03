local PARENT = UI_IngameUnitInfo

-------------------------------------
-- class UI_IngameBossInfo
-------------------------------------
UI_IngameBossInfo = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_IngameBossInfo:loadUI()
    local vars = self:load('ingame_boss_hp.ui')
    return vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameBossInfo:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    local boss = self.m_owner
    local t_boss = boss.m_charTable

    vars['bossSKillGauge']:setPercentage(0)

    -- 스킬별 버튼 생성
    for i = 1, 9 do
        local skill_id = t_boss['skill_' .. i]
        if (skill_id == 'x') then break end
            
        local button = self:makeSkillButton(skill_id)
        local x = -110 * (i - 1)
        local y = 0

        button:setPosition(x, y)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameBossInfo:makeSkillButton(skill_id)
    cclog('makeSkillButton skill_id = ' .. skill_id)
    local vars = self.vars

    local t_skill = TABLE:get('monster_skill')
    
    --[[
    local button = cc.MenuItemImage:create(t_skill['res_icon'], t_skill['res_icon'], 1)
    button:setDockPoint(cc.p(0.5, 0.5))
    button:setAnchorPoint(cc.p(0.5, 0.5))
    button:registerScriptTapHandler(function()
        cclog('skillButton!!')
    end)

    vars['bossSkillNode']:addChild(button)
    ]]--

    local button = IconHelper:getSkillIcon('monster', skill_id)
    vars['bossSkillNode']:addChild(button)

    return button
end

-------------------------------------
-- function getPositionForStatusIcon
-------------------------------------
function UI_IngameBossInfo:getPositionForStatusIcon(bLeftFormation, idx)
    local x = 50 * (idx - 1)
    local y = 0
    	
    return x, y
end

-------------------------------------
-- function getScaleForStatusIcon
-------------------------------------
function UI_IngameBossInfo:getScaleForStatusIcon()
    return 1
end