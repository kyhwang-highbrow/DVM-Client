local PARENT = UI_RuneCard
-------------------------------------
-- class UI_RuneCardOption
-------------------------------------
UI_RuneCardOption = class(PARENT, {
    m_charIconRes = 'string',
    m_charAttrIconRes = 'string',

    m_moptAbilityIconRes = 'string',
    m_filterPointStr = 'string',
})

-------------------------------------
-- function loadUI
-------------------------------------
function UI_RuneCardOption:loadUI()
    self.ui_res = 'card_rune_option.ui'
    self:getUIInfo()
end

-------------------------------------
--- function refreshOption
-- @brief 옵션 표시
-------------------------------------
function UI_RuneCardOption:refreshOption()
    local vars = self.vars
    -- 바깥 테두리는 무조건 표시해줌
    self:setOptionSpriteVisible(true)

    local res, val, is_per
    local is_filter_point = g_settingData:get('option_rune_filter', 'look_rune_filter_point')

    if is_filter_point == true then
        res, val = 'card_option_atk.png', math_floor(self.m_runeData:getRuneFilterPoint())
        -- 숫자
        self:setPointNumberText(val)

        if vars['pointIconNode'] ~= nil then
            vars['pointIconNode']:setVisible(false)
        end
    else
        res, val, is_per = self.m_runeData:getRuneAbilityIconResAndVal('mopt')
        -- 숫자
        self:setPointNumberText(val, not is_per, is_per)
        -- 아이콘
        self:makeRuneAbilityIcon(res)

        if vars['pointIconNode'] ~= nil then
            vars['pointIconNode']:setVisible(true)
        end
    end
end

-------------------------------------
-- function makeRuneAbilityIcon
-- @brief 룬 주옵션 아이콘 생성
-------------------------------------
function UI_RuneCardOption:makeRuneAbilityIcon(res)
    if (self.m_moptAbilityIconRes == res) then
        return
    end
    self.m_moptAbilityIconRes = res
    self:makeSprite('pointIconNode', res)
end

-------------------------------------
--- function refreshEquipDragon
-- @brief 장착 드래곤 표시
-------------------------------------
function UI_RuneCardOption:refreshEquipDragon()
    self:makeDragonAttrIcon()
    self:makeDragonIcon()
end

-------------------------------------
-- function makeDragonAttrIcon
-- @brief 드래곤 속성 아이콘 생성
-------------------------------------
function UI_RuneCardOption:makeDragonAttrIcon()
    -- 드래곤 속성 아이콘
    local doid = self.m_runeData['owner_doid']

    -- 장착했는지?
    if doid == nil then
        self:setSpriteVisible('chaFrameNode', 'none', false)
        return
    end

    local t_dragon_data = g_dragonsData:getDragonDataFromUidRef(doid)
    local attr = t_dragon_data:getAttr() or 'fire'
    local res = 'card_cha_attr_' .. attr .. '.png'
    
    if (self.m_charAttrIconRes == res) then
        return
    end

    self.m_charAttrIconRes = res
    self:setSpriteVisible('chaFrameNode', res, true)
end

-------------------------------------
-- function makeDragonIcon
-- @brief 드래곤 아이콘 생성
-------------------------------------
function UI_RuneCardOption:makeDragonIcon()
    local vars = self.vars

    -- 드래곤 속성 아이콘
    local doid = self.m_runeData['owner_doid']

    -- 장착했는지?
    if doid == nil then
        if vars['chaNode'] ~= nil then
            vars['chaNode']:setSpriteVisible(false)
        end
        return
    end
    
    local t_dragon_data = g_dragonsData:getDragonDataFromUidRef(doid)
    local res = t_dragon_data:getIconRes()
    
    if (self.m_charIconRes == res) then
        return
    end

    self.m_charIconRes = res
    -- 드래곤 아이콘 생성
    local sprite = IconHelper:getIcon(res)
    sprite:setScale(0.3)
    
    -- clipping node 생성
    local clipping_node = cc.ClippingNode:create()
    clipping_node:setContentSize(cc.p(48, 48))

	-- stencil 생성
	local stencil = cc.Node:create()
    clipping_node:setStencil(stencil)
    clipping_node:setAlphaThreshold(0)
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/card/card.plist')
    local stencil_sprite = cc.Sprite:createWithSpriteFrameName('card_rp_attr_dark.png') -- 버튼 배경 모양으로 만든다.
    
    if stencil_sprite then
        stencil_sprite:setAnchorPoint(CENTER_POINT)
        stencil_sprite:setDockPoint(CENTER_POINT)
        stencil:addChild(stencil_sprite)
    end

    -- 붙이기
    clipping_node:addChild(sprite)
    vars['clickBtn']:addChild(clipping_node)
    
    vars['chaNode'] = clipping_node
    self:setCardInfo('chaNode', clipping_node)
end

-------------------------------------
-- function setPointNumberText
-- @brief 숫자 텍스트 생성용
-------------------------------------
function UI_RuneCardOption:setPointNumberText(num, use_plus, use_per)
    if (not num) then
		return
	end

    if self.m_filterPointStr ==  num then
        return
    end

    local vars = self.vars

	local str
	if (use_plus) then
		str = 'a' .. num
    elseif (use_per) then
        str = num .. 'p'
	else
		str = tostring(num)
	end

    -- 다섯자리 수 까지의 스프라이트를 지운다.
    -- (10의 자리 수를 찍은 후에 1의 자리를 설정하면 지워지지 않는 경우가 있었다)
    for idx=1, 5 do
        local lua_name = 'pointNumberSprite' .. idx
        if vars[lua_name] then
            vars[lua_name]:removeFromParent()
            vars[lua_name] = nil
        end
    end

	-- 모든 글자와 매치되는 반복자
    local font_size = 10
	local idx = 0
	for char in string.gmatch(str, '.') do
		if (char == 'a') then
			char = 'plus'
        elseif (char == 'p') then
            char = 'per'
            font_size = 12
		end

		local lua_name = 'pointNumberSprite' .. idx
		local res = string.format('card_option_num_%s.png', char)
		self:makeSprite(lua_name, res)

		local sprite = vars[lua_name]
		self:setCardInfo('pointNumberNode', sprite)

		local pos_x = (font_size/2) + (font_size * idx)
		sprite:setPositionX(pos_x)

		idx = idx + 1
	end

    self.m_filterPointStr =  num
end