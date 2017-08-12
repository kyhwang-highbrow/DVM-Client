local PARENT = class(UI, IEventListener:getCloneTable())

local ACTIVE_ACTION__TAG = 100

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

        m_skillCoolTime = 'number',         -- 스킬 재사용 대기 시간(초)
        m_skillGaugePercentage = 'number',  -- 스킬 재사용 대기 시간(%)

        m_bPossibleControl = 'boolean',

		m_haveActive = 'boolean',

        m_bAttackSkill = 'boolean', -- 공격 스킬인지 여부
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonPanelItem:init(world, dragon, dragon_idx)
    self.m_world = world
    self.m_dragon = dragon
    self.m_dragonIdx = dragon_idx
    self.m_bPossibleControl = nil
    self.m_skillCoolTime = 0
	self.m_skillGaugePercentage = 0

    local skill_id = dragon:getSkillID('active')
    local t_skill = dragon:getSkillTable(skill_id)
    if (t_skill) then
        self.m_bAttackSkill = SkillHelper:isEnemyTargetingType(t_skill)
    end

	local vars = self:load('ingame_panel.ui', false, true)

    dragon:addListener('character_set_hp', self)
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
    local skill_id = dragon:getSkillID('active')
    local t_skill = dragon:getSkillTable(skill_id)
    local str_target = (self.m_bAttackSkill and 'atk' or 'heal')

    self.m_haveActive = (t_skill ~= nil)

    vars['topMenu']:setPositionY(0)
    vars['skillGaugeVisual']:setVisible(self.m_haveActive)
    vars['skillFullVisual1']:setVisible(self.m_haveActive)
    vars['skillFullVisual2']:setVisible(self.m_haveActive)
    vars['skillFullVisual1']:changeAni('dragon_full_' .. str_target .. '_idle_1', true)
    vars['skillFullVisual2']:changeAni('dragon_full_' .. str_target .. '_idle_2', true)

    vars['cooltimeLabel']:setString('')

    -- 속성 아이콘
    if (vars['attrNode']) then
        local attr_str = dragon:getAttribute()
        local res = 'ingame_panel_attr_' .. attr_str .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if icon then
            icon:setDockPoint(CENTER_POINT)
            icon:setAnchorPoint(CENTER_POINT)
            vars['attrNode']:addChild(icon)
        end
    end
    
    do -- 드래곤 아이콘
	    local sprite = IconHelper:getDragonIconFromTable(dragon.m_tDragonInfo, dragon.m_charTable)
	    if (sprite) then
		    vars['dragonNode']:addChild(sprite)
	    end
    end

    do -- 드래그 스킬 아이콘
        local skill_icon

        if (t_skill) then
            skill_icon = IconHelper:getSkillIcon('dragon', skill_id)
			
		-- 액티브 스킬이 없는 케이스
        else
            skill_icon = cc.Sprite:create('res/ui/icon/skill/skill_empty.png')
			
        end

        skill_icon:setDockPoint(CENTER_POINT)
        skill_icon:setAnchorPoint(CENTER_POINT)
        vars['skillNode']:addChild(skill_icon)
    end

    -- 인디케이터 아이콘
    if (t_skill) then
        local indicator_type = t_skill['indicator']
        local res = 'ingame_panel_indicater_' .. str_target .. '_' .. indicator_type .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if icon then
            icon:setDockPoint(CENTER_POINT)
            icon:setAnchorPoint(CENTER_POINT)
            vars['indicaterNode']:addChild(icon)
        end
    end

    -- 대상 수
    if (t_skill) then
        local target_count = t_skill['target_count']
        local res = 'ingame_panel_target_' .. str_target .. '_' .. target_count .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if (icon) then
            icon:setDockPoint(CENTER_POINT)
            icon:setAnchorPoint(CENTER_POINT)
            vars['targetNode']:addChild(icon)
        end
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
        self:refreshSkillGauge(t_event['cool_time'], t_event['percentage'], t_event['enough_mana'])

    elseif (event_name == 'touch_began') then
        self:onTouchBegan(t_event)

    -- 드래곤 마나 소모량 변경 Event
    elseif (event_name == 'dragon_mana_reduce' or event_name == 'dragon_mana_reduce_finish') then
        self:refreshManaCost(t_event['value'])

    -- 드래곤 사망 시
    elseif (event_name == 'character_dead') then
        local vars = self.vars
        vars['dieSprite']:setVisible(true)
        vars['skillFullVisual1']:setVisible(false)
        vars['skillFullVisual2']:setVisible(false)
        cca.stopAction(vars['topMenu'], ACTIVE_ACTION__TAG)
        vars['topMenu']:setPositionY(0)

    -- 드래곤 부활 시
    elseif (event_name == 'character_revive') then
        local vars = self.vars
        vars['dieSprite']:setVisible(false)
        
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
    local percentage = (hp / max_hp)

    -- 체력바 가감 연출
    vars['hpGauge']:setScaleX(percentage)
end

-------------------------------------
-- function refreshManaCost
-- @brief 드래곤 소비 마나 변경 Event
-------------------------------------
function UI_IngameDragonPanelItem:refreshManaCost(mana_cost)
    local vars = self.vars
    local mana_cost = math_floor(mana_cost)

    if (vars['manaNode']) then
        vars['manaNode']:removeAllChildren()

        if (mana_cost > 0) then
            local res = 'ingame_panel_mana_' .. mana_cost .. '.png'
            local icon = cc.Sprite:createWithSpriteFrameName(res)
            if icon then
                icon:setDockPoint(cc.p(0.5, 0.5))
                icon:setAnchorPoint(cc.p(0.5, 0.5))
                vars['manaNode']:addChild(icon)
            end
        end
    end
end

-------------------------------------
-- function refreshSkillGauge
-- @brief 드래곤 드래그 스킬 쿨타임 갱신
-------------------------------------
function UI_IngameDragonPanelItem:refreshSkillGauge(cool_time, percentage, enough_mana)
    local vars = self.vars

	-- 액티브가 없다면 갱신하지 않음
	if (not self.m_haveActive) then
		return
	end

    if (self.m_skillGaugePercentage == percentage and vars['skillFullVisual1']:isVisible() == enough_mana) then
        return
    end
    
    self.m_skillCoolTime = math_floor(cool_time)
    self.m_skillGaugePercentage = percentage

    if (cool_time > 0) then
        vars['cooltimeLabel']:setString(self.m_skillCoolTime)
    else
        vars['cooltimeLabel']:setString('')
    end

    vars['skillGaugeVisual']:setAnimationPause(true)
    vars['skillGaugeVisual']:setFrame(percentage)

    if (enough_mana and self.m_skillGaugePercentage >= 100) then
        vars['skillFullVisual1']:setVisible(true)
        vars['skillFullVisual2']:setVisible(true)
        cca.runAction(vars['topMenu'], cc.MoveTo:create(0.2, cc.p(0, 54)), ACTIVE_ACTION__TAG)
    elseif (vars['skillFullVisual1']:isVisible()) then
        vars['skillFullVisual1']:setVisible(false)
        vars['skillFullVisual2']:setVisible(false)
        cca.runAction(vars['topMenu'], cc.MoveTo:create(0.2, cc.p(0, 0)), ACTIVE_ACTION__TAG)
    end
end

-------------------------------------
-- function onTouchBegan
-- @brief
-------------------------------------
function UI_IngameDragonPanelItem:onTouchBegan(t_event)
    local vars = self.vars

    local location = t_event['location']
    local node = vars['topMenu']

    local node_pos = node:convertToNodeSpace(location)
    local size = node:getContentSize()
    local half_size = (size['width'] / 2)
    local distance = math_distance(size['width'] / 2, size['height'] / 2, node_pos['x'], node_pos['y'])
    if (distance <= half_size) then
        t_event['touch'] = true
        cca.uiReactionSlow(self.root)
    end
end

-------------------------------------
-- function setPossibleControl
-- @brief
-------------------------------------
function UI_IngameDragonPanelItem:setPossibleControl(possible)
    if (self.m_bPossibleControl == possible) then return end
    if (self.m_dragon:isDead()) then return end

    local vars = self.vars

    self.m_bPossibleControl = possible

    if possible then
        local enough_mana = (self.m_dragon.m_activeSkillManaCost <= self.m_world.m_heroMana:getCurrMana())

        self:refreshSkillGauge(self.m_skillCoolTime, self.m_skillGaugePercentage, enough_mana)
    else
        self:refreshSkillGauge(self.m_skillCoolTime, self.m_skillGaugePercentage, false)
    end
end