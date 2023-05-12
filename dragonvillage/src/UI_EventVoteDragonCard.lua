local PARENT = UI

-------------------------------------
-- class UI_EventVoteDragonCard
-------------------------------------
UI_EventVoteDragonCard = class(PARENT, {
        m_structDragon = 'StructDragonObject',
        m_dragonAnimator = 'UIC_DragonAnimator',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteDragonCard:init(did)
    self:setDragonDid(did)
    self:load('event_vote_ticket_choice_item.ui')

	-- UI 초기화
    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteDragonCard:initUI()
	local vars = self.vars

    self.m_dragonAnimator = UIC_DragonAnimator()
    self.m_dragonAnimator.m_node:setScale(0.3)
    self.m_dragonAnimator:setTalkEnable(false)
    self.m_dragonAnimator:setChangeAniEnable(false)

    vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteDragonCard:initButton()
end

-------------------------------------
-- function getDragonDid
-------------------------------------
function UI_EventVoteDragonCard:getDragonDid()
    return self.m_structDragon.did
end


-------------------------------------
-- function setDragonDid
-------------------------------------
function UI_EventVoteDragonCard:setDragonDid(did)
    local t_dragon_data = {}
    t_dragon_data['did'] = did or 0
    t_dragon_data['evolution'] = 3
    t_dragon_data['grade'] = 7
    self.m_structDragon = StructDragonObject(t_dragon_data)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteDragonCard:refresh()
	local vars = self.vars
    local did = self.m_structDragon.did
    local is_selected = self.m_structDragon.did ~= 0
    local struct_dragon = self.m_structDragon

    vars['selectMenu']:setVisible(is_selected)

    if is_selected == false then
        return
    end

    do -- 스파인
        self.m_dragonAnimator:setDragonAnimator(did, 3)
    end
	
    do -- 드래곤 이름
	    vars['dragonNameLabel']:setString(TableDragon:getDragonName(struct_dragon.did))
    end

    -- 배경
    do
        local attr = struct_dragon:getAttr()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        animator:setScale(0.3)
        vars['attrBgNode']:removeAllChildren()
        vars['attrBgNode']:addChild(animator.m_node)
    end
end