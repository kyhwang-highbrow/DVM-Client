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
end

-------------------------------------
-- function setAnimatorVisible
-- @brief visible 관리하고 없다면 만든다.
-------------------------------------
function UI_Card:setAnimatorVisible(lua_name, res, ani, visible)
    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeVisual(lua_name, res, ani)
    end
end

-------------------------------------
-- function setNumberText
-- @brief 숫자 텍스트 생성용
-------------------------------------
function UI_Card:setNumberText(num, use_plus)
    local vars = self.vars
    if (not num) then
		return
	end

    local sprite_1 = vars['numberSprite1']
    local sprite_2 = vars['numberSprite2']
    local sprite_3 = vars['numberSprite3']

    if (not sprite_1) then
        sprite_1 = MakeAnimator('res/ui/a2d/card/card.vrp')
        sprite_1:setDockPoint(CENTER_POINT)
        sprite_1:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite_1.m_node, 5)
        vars['sprite_1'] = sprite_1
        sprite_1:changeAni('digit_0')
    end

    if (not sprite_2) then
        sprite_2 = MakeAnimator('res/ui/a2d/card/card.vrp')
        sprite_2:setDockPoint(CENTER_POINT)
        sprite_2:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite_2.m_node, 5)
        vars['sprite_2'] = sprite_2
        sprite_2:changeAni('digit_5')
    end

    if (not sprite_3) then
        sprite_3 = MakeAnimator('res/ui/a2d/card/card.vrp')
        sprite_3:setDockPoint(CENTER_POINT)
        sprite_3:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite_3.m_node, 5)
        vars['sprite_3'] = sprite_3
        sprite_3:changeAni('digit_5')
    end

    local pos_x = -60
    local pos_y = -27
    local font_size = 20
    if (num <= 0) then
        sprite_1:setVisible(false)
        sprite_2:setVisible(false)
        sprite_3:setVisible(false)
    elseif (num < 10) then
        sprite_1:setVisible(true)
        sprite_1:changeAni('digit_' .. num)
        sprite_1:setPosition(pos_x + (font_size/2), pos_y)
        sprite_2:setVisible(false)
        sprite_3:setVisible(false)
    elseif (num < 100) then
        sprite_1:setVisible(true)
        sprite_1:changeAni('digit_' ..  math_floor(num / 10))
        sprite_1:setPosition(pos_x + (font_size/2), pos_y)

        sprite_2:setVisible(true)
        sprite_2:changeAni('digit_' .. num % 10)
        sprite_2:setPosition(pos_x + (font_size/2) + font_size, pos_y)
        sprite_3:setVisible(false)
    else
        sprite_1:setVisible(true)
        sprite_1:changeAni('digit_' ..  math_floor(num / 100))
        sprite_1:setPosition(pos_x + (font_size/2), pos_y)

        sprite_2:setVisible(true)
        sprite_2:changeAni('digit_' .. math_floor(num % 100 / 10))
        sprite_2:setPosition(pos_x + (font_size/2) + font_size, pos_y)
        
        sprite_3:setVisible(true)
        sprite_3:changeAni('digit_' .. math_floor(num % 10))
        sprite_3:setPosition(pos_x + (font_size/2) + font_size + font_size, pos_y)
    end
end