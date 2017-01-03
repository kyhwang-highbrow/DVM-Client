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

    vars['bossSKillGauge']:setPercentage(0)
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