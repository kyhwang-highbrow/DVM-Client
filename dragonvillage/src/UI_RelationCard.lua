local PARENT = UI_Card

--[[
# card_relation.ui 일람
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
    local vars = self.vars

    self.ui_res = 'card_relation.ui'
    self:getUIInfo()

    t_dragon_data['grade'] = t_dragon_data:getBirthGrade()
    self.m_dragonData = t_dragon_data

    self.m_count = count
    self:refreshDragonInfo()

    vars['clickBtn']:registerScriptTapHandler(function() self:clickBtn() end)
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

    -- 버튼 생성과 배경 이미지 생성
    self:makeClickBtn()

    -- 속성 따른 배경 이미지
    self:makeBg(attr)

    -- 드래곤 아이콘
    self:makeDragonIcon()

    -- 카드 프레임
    self:makeFrame()

    -- 속성 아이콘 생성
    self:makeAttrIcon(attr)

    -- 등급 아이콘 생성
    self:refresh_gradeIcon()

    -- 수량 표시
    self:makeNumberLabel()
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_RelationCard:makeClickBtn()
    UI_CharacterCard.makeClickBtn(self)
end

-------------------------------------
-- function clickBtn
-------------------------------------
function UI_RelationCard:clickBtn()
    local t_dragon_data = self.m_dragonData
    local did = t_dragon_data['did']

    local ui = UI_Hatchery()
    ui:setTab('relation')
    ui:focusingDragonCard(did)
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
-- @brief 드래곤 아이콘 생성
-- @comment clipping을 해줘야 했기 때문에 따로 만들고 setCardInfo만 적시에 해준다.
-------------------------------------
function UI_RelationCard:makeDragonIcon()
    local vars = self.vars
    local res = self.m_dragonData:getIconRes()
    if (self.m_charIconRes == res) then
        return
    end
    self.m_charIconRes = res

    -- 드래곤 아이콘 생성
    local sprite = IconHelper:getIcon(res)
    vars['chaNode'] = sprite

    -- clipping node 생성
    local clipping_node = cc.ClippingNode:create()
    clipping_node:setContentSize(cc.p(150, 150))

	-- stencil 생성
	local stencil = cc.Node:create()
    clipping_node:setStencil(stencil)
    clipping_node:setAlphaThreshold(0)
    local stencil_sprite = cc.Sprite:createWithSpriteFrameName(self.m_attrBgRes) -- 버튼 배경 모양으로 만든다.
    if stencil_sprite then
        stencil_sprite:setAnchorPoint(CENTER_POINT)
        stencil_sprite:setDockPoint(CENTER_POINT)
        stencil:addChild(stencil_sprite)
    end

    -- 붙이기
    clipping_node:addChild(sprite)
    vars['clickBtn']:addChild(clipping_node)
    self:setCardInfo('chaNode', clipping_node)
end

-------------------------------------
-- function makeFrame
-- @brief 프레임 생성
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
-- @brief 속성 아이콘 생성
-------------------------------------
function UI_RelationCard:makeAttrIcon(attr)
    UI_CharacterCard.makeAttrIcon(self, attr)
end

-------------------------------------
-- function refresh_gradeIcon
-- @brief 등급 아이콘
-------------------------------------
function UI_RelationCard:refresh_gradeIcon()
    UI_CharacterCard.refresh_gradeIcon(self)
end

-------------------------------------
-- function makeNumberLabel
-- @brief 수량 표시
-- @comment Label 과 같은 경우는 따로 만들어주고 setCardInfo만 해준다
-------------------------------------
function UI_RelationCard:makeNumberLabel()
    local vars = self.vars
    local label = cc.Label:createWithTTF('', Translate:getFontPath(), 40, 2, cc.size(100, 50), 2, 1)
    label:enableShadow(cc.c4b(0,0,0,255), cc.size(3, -3), 1)
    self:setCardInfo('numberNode', label)

    -- 인연 포인트 수치
    local count = self.m_count
    if (not count) or (count == 0) then
        label:setString('')
    else
        label:setString(Str('{1}', comma_value(count)))
    end

    vars['clickBtn']:addChild(label, 5)
    vars['numberNode'] = label
end