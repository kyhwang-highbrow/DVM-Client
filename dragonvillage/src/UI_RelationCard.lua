local PARENT = UI_Card

--[[
# card_relation.ui �϶�
    selectSprite
    disableSprite
    checkSprite

    numberNode
    starNode
    attrNode
    inuseSprite
    frameNode
    chaNode
    bgNode
]]

-------------------------------------
-- class UI_RelationCard
-------------------------------------
UI_RelationCard = class(PARENT, {
        m_dragonData = '',

        m_attrBgRes = 'string',
        m_charIconRes = 'string',
        m_attrIconRes = 'string',
        m_starIconRes = 'string',
        m_charFrameRes = 'string',

        m_count = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RelationCard:init(t_dragon_data, count)
    self.ui_res = 'card_relation.ui'
    self:getUIInfo()

    self.m_dragonData = t_dragon_data
    self.m_count = count
    self:refreshDragonInfo()
end

-------------------------------------
-- function refreshDragonInfo
-------------------------------------
function UI_RelationCard:refreshDragonInfo()
    if (not self.m_dragonData) then
        return
    end
    
    local t_dragon_data = self.m_dragonData
    local did = t_dragon_data['did']
    local attr = t_dragon_data:getAttr()

    -- ��ư ������ ��� �̹��� ����
    self:makeClickBtn()

    -- �Ӽ� ���� ��� �̹���
    self:makeBg(attr)

    -- �巡�� ������
    self:makeDragonIcon()

    -- ī�� ������
    self:makeFrame()

    -- �Ӽ� ������ ����
    self:makeAttrIcon(attr)

    -- ��� ������ ����
    self:refresh_gradeIcon()

    -- ���� ǥ��
    self:makeNumberLabel()
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_RelationCard:makeClickBtn()
    UI_CharacterCard.makeClickBtn(self)
end

-------------------------------------
-- function makeBg
-------------------------------------
function UI_RelationCard:makeBg(attr)
    local res = 'card_rp_bg_' .. attr .. '.png'
    if (self.m_attrBgRes == res) then
        return
    end
    self.m_attrBgRes = res
    self:makeSprite('bgNode', res)
end

-------------------------------------
-- function makeDragonIcon
-- @brief �巡�� ������ ����
-- @comment clipping�� ����� �߱� ������ ���� ����� setCardInfo�� ���ÿ� ���ش�.
-------------------------------------
function UI_RelationCard:makeDragonIcon()
    local vars = self.vars
    local res = self.m_dragonData:getIconRes()
    if (self.m_charIconRes == res) then
        return
    end
    self.m_charIconRes = res

    -- �巡�� ������ ����
    local sprite = IconHelper:getIcon(res)
    vars['chaNode'] = sprite

    -- clipping node ����
    local clipping_node = cc.ClippingNode:create()
    clipping_node:setContentSize(cc.p(150, 150))

	-- stencil ����
	local stencil = cc.Node:create()
    clipping_node:setStencil(stencil)
    clipping_node:setAlphaThreshold(0)
    local stencil_sprite = cc.Sprite:createWithSpriteFrameName(self.m_attrBgRes) -- ��ư ��� ������� �����.
    if stencil_sprite then
        stencil_sprite:setAnchorPoint(CENTER_POINT)
        stencil_sprite:setDockPoint(CENTER_POINT)
        stencil:addChild(stencil_sprite)
    end

    -- ���̱�
    clipping_node:addChild(sprite)
    vars['clickBtn']:addChild(clipping_node)
    self:setCardInfo('chaNode', clipping_node)
end

-------------------------------------
-- function makeFrame
-- @brief ������ ����
-------------------------------------
function UI_RelationCard:makeFrame(res)
    local res = 'card_rp_frame.png'
    if (self.m_charFrameRes == res) then
        return
    end
    self.m_charFrameRes = res
    self:makeSprite('frameNode', res)
end

-------------------------------------
-- function makeAttrIcon
-- @brief �Ӽ� ������ ����
-------------------------------------
function UI_RelationCard:makeAttrIcon(attr)
    UI_CharacterCard.makeAttrIcon(self, attr)
end

-------------------------------------
-- function refresh_gradeIcon
-- @brief ��� ������
-------------------------------------
function UI_RelationCard:refresh_gradeIcon()
    UI_CharacterCard.refresh_gradeIcon(self)
end

-------------------------------------
-- function makeNumberLabel
-- @brief ���� ǥ��
-- @comment Label �� ���� ���� ���� ������ְ� setCardInfo�� ���ش�
-------------------------------------
function UI_RelationCard:makeNumberLabel()
    local vars = self.vars
    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 40, 2, cc.size(100, 30), 2, 1)
    self:setCardInfo('numberNode', label)

    -- �ο� ����Ʈ ��ġ
    local count = self.m_count
    if (not count) or (count == 0) then
        label:setString('')
    else
        label:setString(Str('{1}', comma_value(count)))
    end

    vars['clickBtn']:addChild(label, 5)
    vars['numberNode'] = label
end