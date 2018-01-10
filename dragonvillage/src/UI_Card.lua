local PARENT = ITableViewCell:getCloneClass()

G_CARD_UI = {}
-------------------------------------
-- class UI_Card
-------------------------------------
UI_Card = class(PARENT, {
        root = '',
        vars = '',
        ui_res = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Card:init()
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/card/card.plist')
    
    self.root = cc.Menu:create()
    self.root:setNormalSize(150, 150)
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(0, 0)

    self.vars = {}
end

-------------------------------------
-- function getUIInfo
-- @brief 최초 생성시 지정된 ui 파일을 불러와 모든 정보를 테이블로 저장한다.
-- 이후에는 생성시 저장된 정보를 통하여 클라에서 생성하게 된다.
-------------------------------------
function UI_Card:getUIInfo()
    local res = self.ui_res
    if (G_CARD_UI[res]) then
        return
    end

    G_CARD_UI[res] = {}

    local ui = UI()
    local vars = ui:load_keepZOrder(res)
    
    local pos_x, pos_y, width, height
    local t_data

    for lua_name, node in pairs(vars) do
        pos_x, pos_y = node:getPosition()
        t_data = {
            ['pos'] = {['x'] = pos_x, ['y'] = pos_y},
            ['anchor'] = node:getAnchorPoint(),
            ['dock'] = node:getDockPoint(),
            ['scale'] = node:getScale(),
            ['z_order'] = node:getLocalZOrder(),
            ['lua_name'] = lua_name,
        }
        G_CARD_UI[res][lua_name] = t_data
    end
end

-------------------------------------
-- function setCardInfo
-------------------------------------
function UI_Card:setCardInfo(lua_name, node)
    local t_info = G_CARD_UI[self.ui_res][lua_name]

    if (not t_info) then
        return
    end

    node:setAnchorPoint(t_info['anchor'])
    node:setDockPoint(t_info['dock'])
    
    node:setPosition(t_info['pos']['x'], t_info['pos']['y'])
    
    node:setScale(t_info['scale'])
    node:setLocalZOrder(t_info['z_order'])
end

-------------------------------------
-- function makeSprite
-- @brief 카드에 사용되는 sprite는 모두 이 로직으로 생성
-------------------------------------
function UI_Card:makeSprite(lua_name, res, no_use_frames)
    local vars = self.vars

    if vars[lua_name] then
        vars[lua_name]:removeFromParent()
        vars[lua_name] = nil
    end
    
    local sprite
    if (no_use_frames) then
        sprite = IconHelper:getIcon(res)
    else
        sprite = IconHelper:createWithSpriteFrameName(res)
    end
    vars['clickBtn']:addChild(sprite)
    self:setCardInfo(lua_name, sprite)
    vars[lua_name] = sprite
end

-------------------------------------
-- function setSpriteVisible
-- @brief visible 관리하고 없다면 만든다.
-------------------------------------
function UI_Card:setSpriteVisible(lua_name, res, visible)
    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res)
    end
end

-------------------------------------
-- function makeAnimator
-- @brief animator사용
-- @comment 여기 res는 사실상 필요없는데...
-------------------------------------
function UI_Card:makeVisual(lua_name, res, ani)
    local vars = self.vars

    if vars[lua_name] then
        vars[lua_name]:removeFromParent()
        vars[lua_name] = nil
    end
    
    local animator = MakeAnimator(res)
    animator:changeAni(ani, true)
    vars['clickBtn']:addChild(animator.m_node)
    self:setCardInfo(lua_name, animator)
    vars[lua_name] = animator

    return animator
end

-------------------------------------
-- function setAnimatorVisible
-- @brief visible 관리하고 없다면 만든다.
-------------------------------------
function UI_Card:setAnimatorVisible(lua_name, res, ani, visible)
    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
        return self.vars[lua_name]
    elseif (visible) then
        return self:makeVisual(lua_name, res, ani)
    end
end

-------------------------------------
-- function setNumberText
-- @brief 숫자 텍스트 생성용
-------------------------------------
function UI_Card:setNumberText(num, use_plus)
    if (not num) or (num == 0) then
		return
	end

    local vars = self.vars

	local str
	if (use_plus) then
		str = '+' .. num
	else
		str = tostring(num)
	end

	-- 모든 글자와 매치되는 반복자
    local font_size = 20
	local idx = 0
	for char in string.gmatch(str, '.') do
		if (char == '+') then
			char = 'plus'
		end

		local lua_name = 'numberSprite' .. idx
		local res = string.format('card_cha_num_%s.png', char)
		self:makeSprite(lua_name, res)

		local sprite = vars[lua_name]
		self:setCardInfo('numberNode', sprite)

		local pos_x = (font_size/2) + (font_size * idx)
		sprite:setPositionX(pos_x)

		idx = idx + 1
	end
end