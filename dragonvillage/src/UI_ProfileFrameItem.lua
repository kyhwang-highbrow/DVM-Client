local PARENT = class(UI, ITableViewCell:getCloneTable())

--------------------------------------------------------------------------
--- @class UI_ProfileFrameItem
--------------------------------------------------------------------------
UI_ProfileFrameItem = class(PARENT, {
    m_profileFrameId = 'number',
    m_dragonCard = '',
})

--------------------------------------------------------------------------
--- @function init 
--------------------------------------------------------------------------
function UI_ProfileFrameItem:init(profile_frame_id)
    self.m_profileFrameId = profile_frame_id    
    self.m_dragonCard = nil
    self:load('profile_frame_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

--------------------------------------------------------------------------
--- @function initUI 
--------------------------------------------------------------------------
function UI_ProfileFrameItem:initUI()
    local vars = self.vars
    -- 프로필 테두리 추가
    local profile_frame_animator = self:makeProfileFrameAnimator()
    vars['profileFrameNode']:removeAllChildren()
    if profile_frame_animator ~= nil then
        vars['profileFrameNode']:addChild(profile_frame_animator.m_node)
    end
end

-------------------------------------
--- @function makeProfileFrameAnimator
--- @brief 프로필 프레임 에니메이터 생성
--- @return table
-------------------------------------
function UI_ProfileFrameItem:makeProfileFrameAnimator()    
    local profile_frame_id = self.m_profileFrameId
    local res = TableProfileFrame:getInstance():getProfileFrameRes(profile_frame_id)

    local animator = MakeAnimator(res)
    if (animator) then
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:setScale(1.1)
        animator:changeAni('idle', true)
    end
    return animator
end

--------------------------------------------------------------------------
--- @function initButton 
--------------------------------------------------------------------------
function UI_ProfileFrameItem:initButton()
    local vars = self.vars
end

--------------------------------------------------------------------------
--- @function refresh 
--------------------------------------------------------------------------
function UI_ProfileFrameItem:refresh()
    local vars = self.vars
    local dragon_obj = g_dragonsData:getLeaderDragon()
    if dragon_obj == nil then
        return
    end
    
    local card = UI_DragonCard(dragon_obj, nil, nil, nil,true)
    card.vars['clickBtn']:setEnabled(false)
    vars['charNode']:removeAllChildren()
    vars['charNode']:addChild(card.root)
    self.m_dragonCard = card
end


--------------------------------------------------------------------------
--- @function setSelect 
--------------------------------------------------------------------------
function UI_ProfileFrameItem:setSelect(b)
    if self.m_dragonCard == nil then
        return
    end

    self.m_dragonCard:setCheckSpriteVisible(b)
end

