local PARENT = UI

-------------------------------------
-- class UI_LeagueRaidDamageInfo
-------------------------------------
UI_LeagueRaidDamageInfo = class(PARENT, {
    m_uiTooltip = ''
})

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidDamageInfo:init()
    self.m_uiTooltip = nil
    self:load('ingame_boss_hp.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidDamageInfo:initUI()
    local vars = self.vars

    if (vars['bossSkillSprite']) then vars['bossSkillSprite']:setVisible(false) end

    --[[
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
    g_gameScene.m_gameWorld.m_inGameUI.vars['waveVisual']:setVisible(false)
    ]]
    if (vars['bossHpLabel']) then
        vars['bossHpLabel']:setVisible(true)
        vars['bossHpLabel']:setString('')
    end
end


function UI_LeagueRaidDamageInfo:refresh()
    local vars = self.vars

    local total_damage = math_floor(g_gameScene.m_gameWorld.m_logRecorder:getLog('total_damage_to_enemy'))
    vars['bossHpLabel']:setString(comma_value(total_damage))
    local add_damage = g_leagueRaidData.m_currentDamage and g_leagueRaidData.m_currentDamage or 0
    
    local percentage = (total_damage + add_damage) / 655355555555

    -- 체력 수치 표시
    do
        local str = string.format('%s / %s (%.2f%%)', comma_value(math_floor(total_damage)), comma_value(655355555555), percentage * 100)
        vars['bossHpLabel']:setString(str)
    end

    -- 체력바 가감 연출
    if (vars['bossHpGauge1']) then
        vars['bossHpGauge1']:setScaleX(percentage)
    end
	if (vars['bossHpGauge2']) then
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
        vars['bossHpGauge2']:runAction(cc.EaseIn:create(action, 2))
    end
end


-------------------------------------
-- function getPositionForStatusIcon
-------------------------------------
function UI_LeagueRaidDamageInfo:getPositionForStatusIcon(bLeftFormation, idx)
    local x = 50 * (idx - 1)
    local y = 0
    	
    return x, y
end

-------------------------------------
-- function getScaleForStatusIcon
-------------------------------------
function UI_LeagueRaidDamageInfo:getScaleForStatusIcon()
    return 1
end