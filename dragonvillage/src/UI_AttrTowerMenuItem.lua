local PARENT = UI

-------------------------------------
-- class UI_AttrTowerMenuItem
-------------------------------------
UI_AttrTowerMenuItem = class(PARENT, {
        m_attr = 'string',        
        m_notiIcon = 'cc.Sprite',
     })

local THIS = UI_AttrTowerMenuItem

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTowerMenuItem:init(attr)
    self.m_attr = attr

    local vars = self:load('attr_tower_menu_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttrTowerMenuItem:initUI()
    local vars = self.vars

    local attr = self.m_attr
    vars['attrLabel']:setString(dragonAttributeName(attr))

    local color = COLOR[attr]
    vars['attrLabel']:setColor(color)

    local visual_id = 'icon_' .. attr
    vars['iconVisual']:changeAni(visual_id, true)

    local challenge_floor = g_attrTowerData:getChallengingFloorWithAttr(attr)

    if (challenge_floor == 'clear') then
        vars['gaugeLabel']:setString(Str('모두 클리어'))
    else
        vars['gaugeLabel']:setString(Str('{1}층 도전중', challenge_floor))
    end

    self:show_gauge_effect()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttrTowerMenuItem:initButton()
    local vars = self.vars

    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttrTowerMenuItem:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttrTowerMenuItem:show_gauge_effect()
    local vars = self.vars

    local attr = self.m_attr
    local node = vars['gaugeVisual']
    local visual_id = 'frame_' .. attr
    node:changeAni(visual_id, true)

    local challenge_floor = g_attrTowerData:getChallengingFloorWithAttr(attr)

    if (challenge_floor == 'clear') then
        node:setPositionY(580)

    else
        -- 도전 층까지 게이지 액션
        local time = 1.0
        local max_y = 310
        local pos = cc.p(0, max_y/50 * challenge_floor)

        local delay = cc.DelayTime:create(0.3)
        local move = cc.MoveBy:create(time, pos)
        local ease_move = cc.EaseInOut:create(move, 2)
        local sequence = cc.Sequence:create(delay, ease_move)

        -- 실행
        cca.runAction(node, sequence, nil)
    end
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_AttrTowerMenuItem:click_enterBtn()
    local attr = self.m_attr
    UINavigator:goTo('attr_tower', attr)
end