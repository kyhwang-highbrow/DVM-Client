local PARENT = Structure

-------------------------------------
-- class StructEventMatchCard
-------------------------------------
StructEventMatchCard = class(PARENT, {
        m_node = 'cc.Node',
        m_state = '',
        m_cardDid = '',

        pair = 'number', 
        grade = 'number',
    })

local THIS = StructEventMatchCard

MATCH_CARD_STATE = {
    CLOSE = 1,
    OPEN = 2,
}
-------------------------------------
-- function init
-------------------------------------
function StructEventMatchCard:init(data)
    if (data) then
        self:applyTableData(data)
    end

    self.m_state = MATCH_CARD_STATE.CLOSE
    self:setUI()
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructEventMatchCard:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
--    replacement['atd_type'] = 'attendance_type'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructEventMatchCard:getClassName()
    return 'StructEventMatchCard'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructEventMatchCard:getThis()
    return THIS
end

-------------------------------------
-- function getPair
-------------------------------------
function StructEventMatchCard:getPair()
    return self['pair']
end

-------------------------------------
-- function setState
-------------------------------------
function StructEventMatchCard:setState(state)
    self.m_state = state
end

-------------------------------------
-- function getState
-------------------------------------
function StructEventMatchCard:getState()
    return self.m_state
end

-------------------------------------
-- function changeState
-------------------------------------
function StructEventMatchCard:changeState(state)
    self:setState(state)
    self:setUI()
end

-------------------------------------
-- function setDragon
-------------------------------------
function StructEventMatchCard:setCardDid(did)
    self.m_cardDid = did
end

-------------------------------------
-- function setUI
-------------------------------------
function StructEventMatchCard:setUI()
    if (not self.m_node) then
        self.m_node = cc.Node:create()
    end

    self.m_node:removeAllChildren()

    local state = self.m_state
    if (state == MATCH_CARD_STATE.CLOSE) then
        local img = cc.Sprite:create('res/ui/icons/event_card_back_0101.png')
        img:setDockPoint(ZERO_POINT)
        img:setAnchorPoint(ZERO_POINT)
        self.m_node:addChild(img)

    elseif (state == MATCH_CARD_STATE.OPEN) then
        local grade = self['grade']

        local t_dragon_data = {}
        t_dragon_data['did'] = self.m_cardDid
        t_dragon_data['evolution'] = grade
        t_dragon_data['grade'] = TableDragon():getBirthGrade(self.m_cardDid)

        local card = UI_DragonCard(StructDragonObject(t_dragon_data))
        local btn = card.vars['clickBtn']
        btn:setEnabled(false)
        card:setSpriteVisible('starNode', res, false)
        card.root:setDockPoint(ZERO_POINT)
        card.root:setAnchorPoint(ZERO_POINT)
        
        local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
        -- 등급별 테두리 효과
        if (grade > 1) then
            local effect_name = grade == 3 and 'summon_regend' or 'summon_hero'
            rarity_effect:changeAni(effect_name, true)
            rarity_effect:setScale(1.7)
            card.root:addChild(rarity_effect.m_node)
        end

        self.m_node:addChild(card.root)
    end
end