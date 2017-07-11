local PARENT = UI_IngameUnitInfo

-------------------------------------
-- class UI_IngameDragonInfo
-------------------------------------
UI_IngameDragonInfo = class(PARENT, {})

-------------------------------------
-- function loadUI
-------------------------------------
function UI_IngameDragonInfo:loadUI()
    local vars = self:load_useSpriteFrames('ingame_dragon_info.ui')
    return vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameDragonInfo:initUI()
    PARENT.initUI(self)

    -- 디버깅용 label
	self:makeDebugingLabel()
    self.m_label:setPosition(70, 0)
end