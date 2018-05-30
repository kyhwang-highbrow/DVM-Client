local PARENT = Structure

-------------------------------------
-- class StructEventMatchCard
-------------------------------------
StructEventMatchCard = class(PARENT, {
        m_node = 'cc.Node',
        m_frontImg = 'cc.Sprite',
        m_backImg = 'cc.Sprite',

        m_state = '',
        m_cardDid = '',

        slot = 'number',
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
function StructEventMatchCard:init(data, random_did)
    if (data) then
        self:applyTableData(data)
    end

    self.m_state = MATCH_CARD_STATE.CLOSE
    self.m_cardDid = random_did
    self:makeUI()
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructEventMatchCard:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}

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
-- function getGrade
-------------------------------------
function StructEventMatchCard:getGrade()
    return self['grade']
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
-- function makeUI
-------------------------------------
function StructEventMatchCard:makeUI()
    self.m_node = cc.Node:create()

    do -- 카드 뒷면
        local slot = self['slot']
        local img
        if (slot%2 == 1) then
            img = cc.Sprite:create('res/ui/icons/event_card_back_0101.png')
        else
            img = cc.Sprite:create('res/ui/icons/event_card_back_0102.png')
        end
        img:setDockPoint(ZERO_POINT)
        img:setAnchorPoint(ZERO_POINT)
        self.m_node:addChild(img)
        self.m_backImg = img
    end

    do -- 카드 앞면
        local grade = self['grade']
        local t_dragon_data = {}
        t_dragon_data['did'] = self.m_cardDid
        t_dragon_data['evolution'] = math_min(grade - 2, 3) -- (3,4,5로 들어옴) 
        t_dragon_data['grade'] = TableDragon():getBirthGrade(self.m_cardDid)

        local card = UI_DragonCard(StructDragonObject(t_dragon_data))
        local btn = card.vars['clickBtn']
        btn:setEnabled(false)
        card:setSpriteVisible('starNode', res, false)
        card.root:setDockPoint(ZERO_POINT)
        card.root:setAnchorPoint(ZERO_POINT)
        
        local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
        -- 등급별 테두리 효과 - 서버에서 3,4,5로 넘김
        if (grade > 3) then
            local effect_name = (grade == 5) and 'summon_regend_2' or 'summon_hero'
            rarity_effect:changeAni(effect_name, true)
            rarity_effect:setScale(1.7)
            card.root:addChild(rarity_effect.m_node)
        end

        self.m_node:addChild(card.root)
        self.m_frontImg = card.root
    end

    self.m_backImg:setVisible(true)
    self.m_frontImg:setVisible(false)

    -- 액션을 위해 앵커포인트 센터로 변경
    changeAnchorPointWithOutTransPos(self.m_backImg, CENTER_POINT)
    changeAnchorPointWithOutTransPos(self.m_frontImg, CENTER_POINT)
end

-------------------------------------
-- function setUI
-------------------------------------
function StructEventMatchCard:setUI()
    local state = self.m_state

    local action_delay = 0.15
    if (state == MATCH_CARD_STATE.CLOSE) then
        cca.filpCard(self.m_frontImg, self.m_backImg, action_delay)

    elseif (state == MATCH_CARD_STATE.OPEN) then
        cca.filpCard(self.m_backImg, self.m_frontImg, action_delay)
    end
end