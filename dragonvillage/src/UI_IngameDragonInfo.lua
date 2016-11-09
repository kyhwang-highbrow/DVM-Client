-------------------------------------
-- class UI_IngameDragonInfo
-------------------------------------
UI_IngameDragonInfo = class(UI, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonInfo:init(hero)
    local vars = self:load('ingame_dragon_info.ui')

    if (hero.m_tDragonInfo) then
        vars['levelLabel']:setString(hero.m_tDragonInfo['lv'])
    else
        vars['levelLabel']:setString('')
    end

    if (hero.m_charType == 'tamer') then
        vars['levelLabel']:setString(g_userDataOld.m_userData['lv'])
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
end