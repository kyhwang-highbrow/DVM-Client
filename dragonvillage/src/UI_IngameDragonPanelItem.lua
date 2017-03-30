local PARENT = class(UI, IEventListener:getCloneTable())

-------------------------------------
-- class UI_IngameDragonPanelItem
-------------------------------------
UI_IngameDragonPanelItem = class(PARENT, {
        m_world = 'GameWorld',
        m_dragon = 'Dragon',
        m_dragonIdx = 'number', -- 999번일 경우 친구?!

        ----

        m_hp = 'number',
        m_maxHP = 'number',
        m_skillGaugePercentage = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonPanelItem:init(world, dragon, dragon_idx)
    self.m_world = world
    self.m_dragon = dragon
    self.m_dragonIdx = dragon_idx
	local vars = self:load('ingame_dragon_panel_item.ui')

    dragon:addListener('character_set_hp', self)
    dragon:addListener('dragon_skill_gauge', self)
    dragon:addListener('character_dead', self)

    self:refreshHP(dragon.m_hp, dragon.m_maxHp)
    self:refreshSkillGauge(dragon.m_activeSkillAccumValue)

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameDragonPanelItem:initUI()
    local vars = self.vars
    
    local dragon = self.m_dragon

    -- 드래곤 속성 아이콘
    if (vars['attrNode']) then
        local attr_str = dragon:getAttribute()
        local res = 'res/ui/icon/attr/attr_' .. attr_str .. '.png'
        local icon = cc.Sprite:create(res)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['attrNode']:addChild(icon)
        end
    end

    do -- 드래곤 아이콘
	    local sprite = IconHelper:getDragonIconFromTable(dragon.m_tDragonInfo, dragon.m_charTable)
	    if (sprite) then
		    vars['dragonNode']:addChild(sprite)
	    end
    end

    -- 드래곤 아이콘 배경
    do
        local attr_str = dragon:getAttribute()
        local res = 'res/ui/frame/dragon_item_bg_' .. attr_str .. '.png'
	    local sprite = cc.Sprite:create(res)
	    if (sprite) then
            sprite:setDockPoint(cc.p(0.5, 0.5))
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
		    vars['bgNode']:addChild(sprite)
	    end
    end

    do -- 드래곤 드래그 스킬 아이콘
        local skill_id = dragon:getSkillID('active')
        local skill_icon = IconHelper:getSkillIcon('dragon', skill_id)
        vars['skillIconNode']:addChild(skill_icon)
    end

    do -- 드래곤 역할별 스킬 게이지 색상 지정
        local role_type = dragon:getRole()
        local color
        if (role_type == 'tanker') then
            color = cc.c3b(255, 0, 0)
        elseif (role_type == 'dealer') then
            color = cc.c3b(255, 255, 0)
        elseif (role_type == 'supporter') then
            color = cc.c3b(0, 255, 0)
        elseif (role_type == 'healer') then
            color = cc.c3b(0, 0, 255)
        else
            error('role_type : ' .. role_type)    
        end
        vars['dragSKillGauge1']:setColor(color)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_IngameDragonPanelItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IngameDragonPanelItem:refresh()
end

-------------------------------------
-- function onEvent
-------------------------------------
function UI_IngameDragonPanelItem:onEvent(event_name, t_event, ...)
    -- 드래곤 체력 변경 Event
    if (event_name == 'character_set_hp') then
        self:refreshHP(t_event['hp'], t_event['max_hp'])

    -- 드래곤 드래그 스킬 게이지 변경 Event
    elseif (event_name == 'dragon_skill_gauge') then
        self:refreshSkillGauge(t_event['percentage'])

    -- 드래곤 사망 시
    elseif (event_name == 'character_dead') then
        local vars = self.vars
        vars['disableSprite']:setVisible(true)
        vars['skillVisual']:setVisible(false)
        cca.runAction(vars['skillNode'], cc.MoveTo:create(0.2, cc.p(23, 1)), 100)
        
    end
end

-------------------------------------
-- function refreshHP
-- @brief 드래곤 체력 변경 Event
-------------------------------------
function UI_IngameDragonPanelItem:refreshHP(hp, max_hp)
    if (self.m_hp == hp) and (self.m_maxHP == max_hp) then
        return
    end
    self.m_hp = hp
    self.m_maxHP = max_hp

    local vars = self.vars
    local percentage = (hp / max_hp) * 100

    -- 체력바 가감 연출
    vars['hpGauge1']:setPercentage(percentage)
    local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ProgressTo:create(0.5, percentage))
    vars['hpGauge2']:runAction(cc.EaseIn:create(action, 2))
end

-------------------------------------
-- function refreshSkillGauge
-- @brief 드래곤 드래그 스킬 게이지 변경 Event
-------------------------------------
function UI_IngameDragonPanelItem:refreshSkillGauge(percentage)
    if (self.m_skillGaugePercentage == percentage) then
        return
    end
    local prev_percentage = self.m_skillGaugePercentage or 0
    self.m_skillGaugePercentage = percentage

    local vars = self.vars
    vars['dragSKillGauge1']:setPercentage(percentage)
    vars['dragSKillGauge2']:setPercentage(100 - percentage)

    if (percentage >= 100) then
        vars['skillVisual']:setVisible(true)
        cca.runAction(vars['skillNode'], cc.MoveTo:create(0.2, cc.p(23, 23)), 100)
    elseif (prev_percentage >= 100) then
        vars['skillVisual']:setVisible(false)
        cca.runAction(vars['skillNode'], cc.MoveTo:create(0.2, cc.p(23, 1)), 100)
    end
end