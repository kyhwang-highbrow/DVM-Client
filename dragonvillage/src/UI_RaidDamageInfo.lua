local PARENT = UI

-------------------------------------
-- class UI_RaidDamageInfo
-------------------------------------
UI_RaidDamageInfo = class(PARENT, {
    m_uiTooltip = ''
})

-------------------------------------
-- function init
-------------------------------------
function UI_RaidDamageInfo:init()
    self.m_uiTooltip = nil
    self:load('ingame_boss_hp.ui')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RaidDamageInfo:initUI()
    local vars = self.vars

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
end


-------------------------------------
-- function getPositionForStatusIcon
-------------------------------------
function UI_RaidDamageInfo:getPositionForStatusIcon(bLeftFormation, idx)
    local x = 50 * (idx - 1)
    local y = 0
    	
    return x, y
end

-------------------------------------
-- function getScaleForStatusIcon
-------------------------------------
function UI_RaidDamageInfo:getScaleForStatusIcon()
    return 1
end