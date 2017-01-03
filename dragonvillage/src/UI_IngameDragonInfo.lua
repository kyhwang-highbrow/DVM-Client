local PARENT = UI_IngameUnitInfo

-------------------------------------
-- class UI_IngameDragonInfo
-------------------------------------
UI_IngameDragonInfo = class(PARENT, {})

-------------------------------------
-- function loadUI
-------------------------------------
function UI_IngameDragonInfo:loadUI()
    local vars = self:load('ingame_dragon_info.ui')
    return vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameDragonInfo:initUI()
    local vars = self.vars
    local hero = self.m_owner

    if (hero.m_tDragonInfo) then
        vars['levelLabel']:setString(hero.m_tDragonInfo['lv'])
    else
        vars['levelLabel']:setString('')
    end

    local attr_str = hero.m_charTable['attr']
    local res = 'res/ui/icon/attr/attr_' .. attr_str .. '.png'
    local icon = cc.Sprite:create(res)
    if icon then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['attrNode']:addChild(icon)
    end

    vars['skillGauge']:setPercentage(0)

	-- 디버깅 체력표시용 label
    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 18, 2, cc.size(250, 100), 1, 1)
    label:setPosition(70, 0)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:addChild(label)
    self.m_label = label

end