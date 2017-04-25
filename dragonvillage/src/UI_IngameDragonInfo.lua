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

    local attr_str = hero:getAttribute()
    local res = 'res/ui/icon/attr/attr_' .. attr_str .. '.png'
    local icon = cc.Sprite:create(res)
    if icon then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['attrNode']:addChild(icon)
    end

    -- 디버깅용 label
	self:makeDebugingLabel()
    self.m_label:setPosition(70, 0)
end

-------------------------------------
-- function showSkillFullVisual
-------------------------------------
function UI_IngameDragonInfo:showSkillFullVisual(attr)
    local vars = self.vars

    vars['skllFullVisual']:setVisible(true)
    vars['skllFullVisual']:setRepeat(false)
    vars['skllFullVisual']:setVisual('skill_gauge', 'charging')
    vars['skllFullVisual']:registerScriptLoopHandler(function()
                vars['skllFullVisual']:setVisual('skill_gauge', 'idle_' .. attr)
                vars['skllFullVisual']:setRepeat(true)

                vars['skllFullVisual2']:setVisual('skill_gauge', 'idle_s_' .. attr)
                vars['skllFullVisual2']:setVisible(true)
            end)
end

-------------------------------------
-- function hideSkillFullVisual
-------------------------------------
function UI_IngameDragonInfo:hideSkillFullVisual()
    local vars = self.vars
    vars['skllFullVisual']:setVisible(false)
    vars['skllFullVisual2']:setVisible(false)
end