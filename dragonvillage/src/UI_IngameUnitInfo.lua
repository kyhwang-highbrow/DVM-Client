-------------------------------------
-- class UI_IngameUnitInfo
-------------------------------------
UI_IngameUnitInfo = class(UI, {
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
end