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

        m_bPossibleControl = 'boolean',

		m_haveActive = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonPanelItem:init(world, dragon, dragon_idx)
    self.m_world = world
    self.m_dragon = dragon
    self.m_dragonIdx = dragon_idx
    self.m_bPossibleControl = nil
	self.m_skillGaugePercentage = 0

	local vars = self:load('ingame_dragon_panel_item.ui')

    dragon:addListener('character_set_hp', self)
    dragon:addListener('basic_time_skill_gauge', self)
    dragon:addListener('dragon_skill_gauge', self)
    dragon:addListener('touch_began', self)
    dragon:addListener('character_dead', self)
    dragon:addListener('character_revive', self)
    dragon:addListener('dragon_mana_reduce', self)
    dragon:addListener('dragon_mana_reduce_finish', self)

    self:refreshHP(dragon.m_hp, dragon.m_maxHp)
    self:refreshManaCost(dragon.m_activeSkillManaCost)
    self:refreshSkillGauge(0)

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
        local skill_icon

        if (skill_id ~= 0) then
            skill_icon = IconHelper:getSkillIcon('dragon', skill_id)
			self.m_haveActive = true

		-- 액티브 스킬이 없는 케이스
        else
            skill_icon = cc.Sprite:create('res/ui/icon/skill/skill_empty.png')
			self.m_haveActive = false

        end

        skill_icon:setDockPoint(CENTER_POINT)
        skill_icon:setAnchorPoint(CENTER_POINT)

        vars['skillIconNode']:addChild(skill_icon)
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

    -- 드래곤 basic_time 스킬 게이지 변경 Event
    elseif (event_name == 'basic_time_skill_gauge') then
        self:refreshBasicTimeSkillGauge(t_event['cur'], t_event['max'], t_event['run_skill'])

    -- 드래곤 드래그 스킬 게이지 변경 Event
    elseif (event_name == 'dragon_skill_gauge') then
        self:refreshSkillGauge(t_event['percentage'], t_event['enough_mana'])

    elseif (event_name == 'touch_began') then
        self:onTouchBegan(t_event)

    -- 드래곤 마나 소모량 변경 Event
    elseif (event_name == 'dragon_mana_reduce' or event_name == 'dragon_mana_reduce_finish') then
        self:refreshManaCost(t_event['value'])

    -- 드래곤 사망 시
    elseif (event_name == 'character_dead') then
        local vars = self.vars
        vars['disableSprite']:setVisible(true)
        vars['skillVisual']:setVisible(false)
        vars['skillVisual2']:setVisible(false)
        cca.stopAction(vars['skillNode'], 100)
        vars['skillNode']:setPositionY(-2)

    -- 드래곤 부활 시
    elseif (event_name == 'character_revive') then
        local vars = self.vars
        vars['disableSprite']:setVisible(false)
        
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
-- function refreshManaCost
-- @brief 드래곤 소비 마나 변경 Event
-------------------------------------
function UI_IngameDragonPanelItem:refreshManaCost(mana_cost)
    local vars = self.vars
    local mana_cost = math_floor(mana_cost)

    vars['manaLabel']:setString(mana_cost)
end

-------------------------------------
-- function refreshBasicTimeSkillGauge
-- @brief 드래곤 basic_time 스킬 게이지 변경 Event
-------------------------------------
function UI_IngameDragonPanelItem:refreshBasicTimeSkillGauge(cur, max, run_skill)
    local vars = self.vars
    local percentage = (cur / max) * 100
    vars['normalSKillGauge']:setPercentage(percentage)

    if run_skill then
        vars['normalSkillVisual']:setVisible(true)
        vars['normalSkillVisual']:changeAni('dragon_normal_skill', false)
        vars['normalSkillVisual']:addAniHandler(function() vars['normalSkillVisual']:setVisible(false) end)
    end
end

-------------------------------------
-- function refreshSkillGauge
-- @brief 드래곤 드래그 스킬 게이지 변경 Event
-------------------------------------
function UI_IngameDragonPanelItem:refreshSkillGauge(percentage, enough_mana)
    local vars = self.vars

	-- 액티브가 없다면 갱신하지 않음
	if (not self.m_haveActive) then
		return
	end

    if (self.m_skillGaugePercentage == percentage and vars['skillVisual']:isVisible() == enough_mana) then
        return
    end
    
    local prev_percentage = self.m_skillGaugePercentage or 0
    self.m_skillGaugePercentage = percentage

    vars['dragSKillGauge']:setPercentage(100 - percentage)

    if (enough_mana) then
        vars['skillVisual']:setVisible(true)
        vars['skillVisual2']:setVisible(true)
        cca.runAction(vars['skillNode'], cc.MoveTo:create(0.2, cc.p(25, 10)), 100)
    elseif (vars['skillVisual']:isVisible()) then
        vars['skillVisual']:setVisible(false)
        vars['skillVisual2']:setVisible(false)
        cca.runAction(vars['skillNode'], cc.MoveTo:create(0.2, cc.p(25, -2)), 100)
    end
end

-------------------------------------
-- function onTouchBegan
-- @brief
-------------------------------------
function UI_IngameDragonPanelItem:onTouchBegan(t_event)
    local vars = self.vars

    local location = t_event['location']

    local node_pos = vars['skillNode']:convertToNodeSpace(location)
    local size = vars['skillNode']:getContentSize()
    local half_size = (size['width'] / 2)
    local distance = math_distance(size['width'] / 2, size['height'] / 2, node_pos['x'], node_pos['y'])
    if (distance <= half_size) then
        t_event['touch'] = true
        cca.uiReactionSlow(vars['skillNode'])
    end
end

-------------------------------------
-- function setPossibleControl
-- @brief
-------------------------------------
function UI_IngameDragonPanelItem:setPossibleControl(possible)
    if (self.m_bPossibleControl == possible) then
        return
    end

    local vars = self.vars

    self.m_bPossibleControl = possible

    if possible then
        if (self.m_dragon.m_bDead == false) and (100 <= self.m_skillGaugePercentage) then
            vars['skillVisual']:setVisible(true)
            vars['skillVisual2']:setVisible(true)
        end
    else
        vars['skillVisual']:setVisible(false)
        vars['skillVisual2']:setVisible(false)
    end
end