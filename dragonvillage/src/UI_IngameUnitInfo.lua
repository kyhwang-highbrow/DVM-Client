-------------------------------------
-- class UI_IngameUnitInfo
-------------------------------------
UI_IngameUnitInfo = class(UI, {
        m_owner = '',
		m_label = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameUnitInfo:init(unit)
    self.m_owner = unit

    local vars = self:loadUI()

    self:initUI()
end

-------------------------------------
-- function loadUI
-------------------------------------
function UI_IngameUnitInfo:loadUI()
    --local vars = self:load('ingame_enemy_info.ui')
    local vars = self:load_useSpriteFrames('ingame_enemy_info.ui')
    return vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameUnitInfo:initUI()
    local vars = self.vars
    local enemy = self.m_owner

    if (vars['attrNode']) then
        local attr_str = enemy:getAttribute()
        --local res = 'res/ui/icon/attr/attr_' .. attr_str .. '.png'
        --local icon = cc.Sprite:create(res)
        local res = 'ingame_enemy_info_attr_' .. attr_str .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['attrNode']:addChild(icon)
        end
    end

    if (vars['levelLabel']) then
        vars['levelLabel']:setVisible(false)
		-- @TODO level 임시로 찍지 않도록 함
        local lv = ''--enemy.m_lv
        vars['levelLabel']:setString(lv)
    end

	-- 디버깅용 label
	self:makeDebugingLabel()
end

-------------------------------------
-- function makeDebugingLabel
-------------------------------------
function UI_IngameUnitInfo:makeDebugingLabel()
    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 17, 2, cc.size(250, 100), 1, 1)
    label:setPosition(0, -30)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:addChild(label)
    self.m_label = label
end

-------------------------------------
-- function getPositionForStatusIcon
-------------------------------------
function UI_IngameUnitInfo:getPositionForStatusIcon(bLeftFormation, idx)
    -- 4개를 넘어가면 y 값 조정
	local factor_y = 0
	if idx > 4 then 
		idx = idx - 4
		factor_y = -20
	end

    local x, y
    
	if (bLeftFormation) then 
        x = 60 + 18 * (idx - 1)
        y = -8 + factor_y
	else
        x = -20 + 18 * (idx - 1)
        y = -23 + factor_y
		
	end

    return x, y
end

-------------------------------------
-- function getScaleForStatusIcon
-------------------------------------
function UI_IngameUnitInfo:getScaleForStatusIcon()
    return 0.375
end