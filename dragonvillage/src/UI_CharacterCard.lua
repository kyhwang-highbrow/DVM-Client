-------------------------------------
-- class UI_CharacterCard
-------------------------------------
UI_CharacterCard = class({
        root = '',
        vars = '',

        m_dragonData = '',

        m_clickBtnRes = 'string',
        m_charIconRes = 'string',
        m_attrIconRes = 'string',
        m_starIconRes = 'string',
        m_charFrameRes = 'string',
        m_charLevelNumber = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CharacterCard:init(t_dragon_data)
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/character_card/character_card.plist')

    self.root = cc.Menu:create()
    self.root:setNormalSize(150, 150)
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(0, 0)

    self.vars = {}
    self.m_dragonData = t_dragon_data

    self:refreshDragonInfo()
end

-------------------------------------
-- function refreshDragonInfo
-------------------------------------
function UI_CharacterCard:refreshDragonInfo()
    if (not self.m_dragonData) then
        return
    end

    local t_dragon_data = self.m_dragonData
    local did = t_dragon_data['did']

    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)

    do -- 속성 따른 배경 이미지(버튼)
        local res = 'character_card_bg_' .. t_dragon['attr'] .. '.png'
        self:makeClickBtn(res)
    end

    do -- 드래곤 아이콘
        self:makeDragonIcon(t_dragon_data, t_dragon)
    end

    do -- 속성 아이콘 생성
        local res = 'character_card_attr_' .. t_dragon['attr'] .. '.png'
        self:makeAttrIcon(res)
    end

    do -- 등급 아이콘 생성
        if t_dragon_data['grade'] then
            local res = 'character_card_star0' .. t_dragon_data['grade'] .. '.png'
            self:makeStarIcon(res)
        end
    end

    do -- 레벨 지정
        local lv = t_dragon_data['lv']
        self:setLevelText(lv)
    end    

    do -- 카드 프레임
        local res = 'character_card_frame_' .. t_dragon['rarity'] .. '.png'
        self:makeFrame(res)
    end

    do -- 드래곤들의 덱설정 여부 데이터 갱신
        if t_dragon_data and t_dragon_data['id'] then
            local doid = t_dragon_data['id']
            local is_setted = g_deckData:isSettedDragon(doid)
            self:setReadySpriteVisible(is_setted)
        end
    end
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_CharacterCard:makeClickBtn(res)
    if (self.m_clickBtnRes == res) then
        return
    end
    self.m_clickBtnRes = res

    local btn = self.vars['clickBtn']

    if (not btn) then
        btn = cc.MenuItemImage:create()
        btn:setDockPoint(CENTER_POINT)
        btn:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn'] = UIC_Button(btn)
        self.root:addChild(btn)
    end

    btn:setNormalSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(res))
    --btn:setNormalImage(cc.Sprite:create(res))
        
    return btn
end

-------------------------------------
-- function getDragonIconRes
-- @breif 드래곤 아이콘 리소스명 생성
-------------------------------------
function UI_CharacterCard:getDragonIconRes(t_dragon_data, t_dragon)
    local res = t_dragon['icon']
    local evolution = t_dragon_data['evolution']
    local attr = t_dragon['attr']

    res = string.gsub(res, '#', '0' .. evolution)
    res = string.gsub(res, '@', attr)

    return res
end

-------------------------------------
-- function makeDragonIcon
-- @brief 드래곤 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeDragonIcon(t_dragon_data, t_dragon)
    local res = self:getDragonIconRes(t_dragon_data, t_dragon)
    if (self.m_charIconRes == res) then
        return
    end
    self.m_charIconRes = res

    local vars = self.vars

    if vars['charIcon'] then
        vars['charIcon']:removeFromParent()
    end
    
    local sprite = cc.Sprite:create(res)
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    self.vars['clickBtn']:addChild(sprite, 1)
    vars['charIcon'] = sprite
end

-------------------------------------
-- function makeAttrIcon
-- @brief 속성 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeAttrIcon(res)
    if (self.m_attrIconRes == res) then
        return
    end
    self.m_attrIconRes = res

    local vars = self.vars

    if vars['attrIcon'] then
        vars['attrIcon']:removeFromParent()
    end
    
    local sprite = cc.Sprite:createWithSpriteFrameName(res)
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    sprite:setScale(1.1)
    sprite:setPosition(-46, 46)
    self.vars['clickBtn']:addChild(sprite, 2)
    vars['attrIcon'] = sprite
end

-------------------------------------
-- function makeStarIcon
-- @brief 등급 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeStarIcon(res)
    if (self.m_starIconRes == res) then
        return
    end
    self.m_starIconRes = res

    local vars = self.vars

    if vars['starIcon'] then
        vars['starIcon']:removeFromParent()
    end
    
    local sprite = cc.Sprite:createWithSpriteFrameName(res)
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    sprite:setPosition(0, -52)
    self.vars['clickBtn']:addChild(sprite, 3)
    vars['starIcon'] = sprite
end

-------------------------------------
-- function setLevelText
-- @brief 레벨 텍스트 지정
-------------------------------------
function UI_CharacterCard:setLevelText(level)
    if (self.m_charLevelNumber == level) then
        return
    end
    self.m_charLevelNumber = level

    local vars = self.vars

    local lvSprite1 = vars['lvSprite1']
    local lvSprite2 = vars['lvSprite2']

    if (not lvSprite1) then
        lvSprite1 = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
        lvSprite1:setDockPoint(CENTER_POINT)
        lvSprite1:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(lvSprite1.m_node, 3)
        vars['lvSprite1'] = lvSprite1
        lvSprite1:changeAni('digit_0')
    end

    if (not lvSprite2) then
        lvSprite2 = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
        lvSprite2:setDockPoint(CENTER_POINT)
        lvSprite2:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(lvSprite2.m_node, 3)
        vars['lvSprite2'] = lvSprite2
        lvSprite2:changeAni('digit_5')
    end

    local pos_x = -60
    local pos_y = 0
    local font_size = 15
    if (level < 10) then
        lvSprite1:setVisible(true)
        lvSprite1:changeAni('digit_' .. level)
        lvSprite1:setPosition(pos_x + (font_size/2), pos_y)
        lvSprite2:setVisible(false)
    else
        lvSprite1:setVisible(true)
        lvSprite1:changeAni('digit_' ..  math_floor(level / 10))
        lvSprite1:setPosition(pos_x + (font_size/2), pos_y)

        lvSprite2:setVisible(true)
        lvSprite2:changeAni('digit_' .. level % 10)
        lvSprite2:setPosition(pos_x + (font_size/2) + font_size, pos_y)
    end
end

-------------------------------------
-- function setShadowSpriteVisible
-- @brief 카드 음영 표시
-------------------------------------
function UI_CharacterCard:setShadowSpriteVisible(visible)
    if self.vars['shadowSprite'] then
        self.vars['shadowSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_bg.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setOpacity(125)
        self.vars['clickBtn']:addChild(sprite, 10)
        self.vars['shadowSprite'] = sprite
    end
end

-------------------------------------
-- function makeFrame
-- @brief 프레임 생성
-------------------------------------
function UI_CharacterCard:makeFrame(res)
    if (self.m_charFrameRes == res) then
        return
    end
    self.m_charFrameRes = res

    local vars = self.vars

    if vars['charFrame'] then
        vars['charFrame']:removeFromParent()
    end
    
    local sprite = cc.Sprite:createWithSpriteFrameName(res)
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    self.vars['clickBtn']:addChild(sprite, 11)
    vars['charFrame'] = sprite
end

-------------------------------------
-- function setReadySpriteVisible
-- @brief 출전준비 표시
-------------------------------------
function UI_CharacterCard:setReadySpriteVisible(visible)
    if self.vars['readySprite'] then
        self.vars['readySprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_frame_ready.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite, 12)
        self.vars['readySprite'] = sprite
    end
end

-------------------------------------
-- function setSkillSpriteVisible
-- @brief 승급 재료 스킬상승 아이콘 표시
-------------------------------------
function UI_CharacterCard:setSkillSpriteVisible(visible)
    if self.vars['skillSprite'] then
        self.vars['skillSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_frame_skill.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite, 13)
        self.vars['skillSprite'] = sprite
    end
end

function UI_DragonCard(t_dragon_data)
    return UI_CharacterCard(t_dragon_data)
end

-------------------------------------
-- function MakeSimpleDragonCard
-------------------------------------
function MakeSimpleDragonCard(did)
    local t_dragon_data = {}
    t_dragon_data['did'] = did
    t_dragon_data['lv'] = nil
    t_dragon_data['evolution'] = 3
    t_dragon_data['grade'] = nil

    return UI_DragonCard(t_dragon_data)
end