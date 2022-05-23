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
        -- 메모리 부족으로 캐싱된 데이터가 지워진 상태에서 sprite를 생성하려다가 오류 발생
        -- 등록되어 있다면 또 등록하지 않기 때문에 사용할 때마다 등록하는 방향으로 수정 
        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/card/card.plist')
        sprite = IconHelper:createWithSpriteFrameName(res)
    end
    vars['clickBtn']:addChild(sprite)
    self:setCardInfo(lua_name, sprite)
    vars[lua_name] = sprite
end

-------------------------------------
-- function setSpriteVisible
-- @brief visible 관리하고 없다면 만든다.
-- param visible : boolean, number(1, 2, 3, 99), nil
-------------------------------------
function UI_Card:setSpriteVisible(lua_name, res, visible, no_use_frames)
    if self.vars[lua_name] then
        visible = (visible ~= nil) and (visible ~= false)
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res, no_use_frames)
    end
end

-------------------------------------
-- function makeVisual
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
-- function setAnimatorVisible_IgnoreLowMode
-- @brief visible 관리하고 없다면 만든다.
-------------------------------------
function UI_Card:setAnimatorVisible_IgnoreLowMode(lua_name, res, ani, visible)
    local vars = self.vars
    if vars[lua_name] then
        vars[lua_name]:setVisible(visible)
        return vars[lua_name]
    elseif (visible) then
        local animator = MakeAnimator(res)
        animator:changeAni(ani, true)
        animator:setIgnoreLowEndMode(true)
        vars['clickBtn']:addChild(animator.m_node)
        self:setCardInfo(lua_name, animator)
        vars[lua_name] = animator
        return animator
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

    -- 다섯자리 수 까지의 스프라이트를 지운다.
    -- (10의 자리 수를 찍은 후에 1의 자리를 설정하면 지워지지 않는 경우가 있었다)
    for idx=1, 5 do
        local lua_name = 'numberSprite' .. idx
        if vars[lua_name] then
            vars[lua_name]:removeFromParent()
            vars[lua_name] = nil
        end
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