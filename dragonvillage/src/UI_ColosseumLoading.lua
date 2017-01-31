local PARENT = UI

-------------------------------------
-- class UI_ColosseumLoading
-------------------------------------
UI_ColosseumLoading = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumLoading:init()
    local vars = self:load('colosseum_loading.ui')

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_ColosseumLoading')

    -- @UI_ACTION
    --self:doActionReset()
    --self:doAction(nil, false)

    --self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumLoading:initUI()
    self:init_playerInfo()
    self:init_opponentInfo()
end

-------------------------------------
-- function init_playerInfo
-- @breif 내 정보 초기화
-------------------------------------
function UI_ColosseumLoading:init_playerInfo()
    local vars = self.vars
    
    local l_deck = g_deckData:getDeck()
    local doid = self:getRepresentativeDragon(l_deck)
    local animator = g_dragonsData:getDragonAnimator(doid)
    animator:changeAni('idle', true)
    vars['dragonNode1']:addChild(animator.m_node)
    

    vars['nameLabel1']:setString('sdfsdf')
    
    --pointLabel1
    --nameLabel1
    --tierLabel1
    --dragonNode1
end

-------------------------------------
-- function init_opponentInfo
-- @brief 상대방 정보 초기화
-------------------------------------
function UI_ColosseumLoading:init_opponentInfo()
    local vars = self.vars

    local l_deck = g_colosseumData:getOpponentDeck()
    local doid = self:getRepresentativeDragon(l_deck)
    local t_dragon_data = g_colosseumData:getOpponentDragon(doid)
    local animator = g_dragonsData:makeDragonAnimator(t_dragon_data)
    animator:changeAni('idle', true)
    vars['dragonNode2']:addChild(animator.m_node)

    local user_info = g_colosseumData.m_vsInfo
    vars['nameLabel2']:setString(user_info['nickname'])

    vars['pointLabel2']:setString(comma_value(user_info['rp']))

    vars['tierLabel2']:setString(self:getTierName(user_info['tier']))
end

-------------------------------------
-- function getRepresentativeDragon
-- @brief 덱에서 대표 드래곤 추출
-------------------------------------
function UI_ColosseumLoading:getRepresentativeDragon(l_deck)
    for i=1, 10 do
        local doid = l_deck[tonumber(i)] or l_deck[tostring(i)]
        if (doid and doid~='') then
            return doid
        end
    end

    return nil
end

-------------------------------------
-- function getTierName
-- @brief
-------------------------------------
function UI_ColosseumLoading:getTierName(tier)
    local l_str = seperate(tier, '_')

    local tier = l_str and l_str[1] or tier
    local grade = l_str and l_str[2] or ''

    -- 오타 방지
    if (tier == 'blonze') then
        tier = 'bronze'
    end

    local str = ''
    if (tier == 'legend') then
        str = '전설'
    elseif (tier == 'master') then
        str = '정복자'
    elseif (tier == 'challenger') then
        str = '도전자'
    elseif (tier == 'diamond') then
        str = '금강석'
    elseif (tier == 'platinum') then
        str = '백금'
    elseif (tier == 'gold') then
        str = '금'
    elseif (tier == 'silver') then
        str = '은'
    elseif (tier == 'bronze') then
        str = '청동'
    else
        
    end

    if (not isExistValue(tier, 'legend', 'master')) then
        str = Str(str) .. ' ' .. grade
    end

    return str
end