-------------------------------------
-- class UI_IngameUnitInfo
-------------------------------------
UI_IngameUnitInfo = class(UI, {
		m_label = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameUnitInfo:init(enemy)
    local vars = self:load('ingame_enemy_info.ui')

    local attr_str = enemy.m_charTable['attr']
    local res = 'res/ui/icon/attr/attr_' .. attr_str .. '.png'
    local icon = cc.Sprite:create(res)
    if icon then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['attrNode']:addChild(icon)
    end

	-- 디버깅 체력표시용 label
    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 17, 2, cc.size(250, 100), 1, 1)
    label:setPosition(0, 0)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:addChild(label)
    self.m_label = label
end