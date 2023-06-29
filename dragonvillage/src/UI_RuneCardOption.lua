local PARENT = UI_RuneCard
-------------------------------------
-- class UI_RuneCardOption
-------------------------------------
UI_RuneCardOption = class(PARENT, {
    m_charIconRes = 'string',
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
    self:setOptionSpriteVisible(true)
end

-------------------------------------
--- function refreshEquipDragon
-- @brief 장착 드래곤 표시
-------------------------------------
function UI_RuneCardOption:refreshEquipDragon()
    local is_equip = (self.m_runeData['owner_doid'] ~= nil)
    if is_equip == false then
        local res_cha_frame = 'card_rp_attr_dark.png'
        self:setSpriteVisible('chaFrameNode', res_cha_frame, false)
        if self.vars['chaNode'] ~= nil then
            self.vars['chaNode']:setVisible(false)
        end
        return
    end

    local doid = self.m_runeData['owner_doid']
    local t_dragon_data = g_dragonsData:getDragonDataFromUidRef(doid)
        local res = t_dragon_data:getIconRes()
    if (self.m_charIconRes == res) then
        return
    end
    self.m_charIconRes = res

    --local res = 'res/ui/icons/cha/abyssedge_earth_01.png'
    --self:makeSprite('dragonIconNode', res, true, 100) -- (lua_name, res, no_use_frames)
    --self.vars['dragonIconNode']:setScale(0.5)
    --self.vars['dragonIconNode']:setPosition(cc.p(50,50))
    self:makeSprite('chaFrameNode', 'card_rp_attr_dark.png', false)
    self:makeDragonIcon('chaNode', res)
end

-------------------------------------
-- function makeDragonIcon
-- @brief 드래곤 아이콘 생성
-- @comment clipping을 해줘야 했기 때문에 따로 만들고 setCardInfo만 적시에 해준다.
-------------------------------------
function UI_RuneCardOption:makeDragonIcon(lua_name, res, z_order)
    local vars = self.vars
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
    --vars['clickBtn']:addChild(frame_sprite)
    vars['clickBtn']:addChild(clipping_node)
    
    vars[lua_name] = clipping_node
    self:setCardInfo(lua_name, clipping_node)

    if isNumber(z_order) == true then
        clipping_node:setLocalZOrder(z_order)
    end
end