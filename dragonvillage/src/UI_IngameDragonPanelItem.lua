local PARENT = class(UI, IEventListener:getCloneTable())

local ACTIVE_ACTION__TAG = 100

-------------------------------------
-- class UI_IngameDragonPanelItem
-------------------------------------
UI_IngameDragonPanelItem = class(PARENT, {
        m_world = 'GameWorld',
        m_dragon = 'Dragon',
        m_dragonIdx = 'number', -- 999번일 경우 친구?! 
        m_deckName = 'string', -- 덱 이름

        m_hpRatio = 'number',
        
        m_skillCoolTime = 'number',         -- 스킬 재사용 대기 시간(초)
        m_skillGaugePercentage = 'number',  -- 스킬 재사용 대기 시간(%)

        m_dragSkillLockList = 'list<number>',

        m_bEnabled = 'boolean',
		m_bHaveActive = 'boolean',  -- 액티브 스킬 보유 여부
        m_bAttackSkill = 'boolean', -- 공격 스킬인지 여부
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonPanelItem:init(world, dragon, dragon_idx)
    self.m_world = world
    self.m_dragon = dragon
    self.m_dragonIdx = dragon_idx
    
    self.m_skillCoolTime = 0
	self.m_skillGaugePercentage = 0
    

    self.m_bEnabled = false

    local skill_id = dragon:getSkillID('active')
    local t_skill = dragon:getSkillTable(skill_id)
    if (t_skill) then
        self.m_bAttackSkill = SkillHelper:isEnemyTargetingType(t_skill)
    end

	local vars = self:load('ingame_panel_new.ui', false, true, true)

    dragon:addListener('character_set_hp', self)
    dragon:addListener('character_metamorphosis', self)
    dragon:addListener('dragon_skill_gauge', self)
    dragon:addListener('touch_began', self)
    dragon:addListener('dragon_mana_reduce', self)
    dragon:addListener('dragon_mana_reduce_finish', self)
    self.m_world:addListener('auto_mode_changed', self)
    
    self:refreshHP(dragon:getHpRate())
    self:refreshManaCost(dragon:getSkillManaCost())
    self:refreshSkill()
    self:refreshSkillGauge(0)
    self:refreshAutoDragSkillCheckBox()

    self:initDragSkillLock()
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

    self.m_bHaveActive = (t_skill ~= nil)

    vars['topMenu']:setPositionY(0)
    vars['skillGaugeVisual']:setVisible(self.m_bHaveActive)
    vars['skillFullVisual1']:setVisible(self.m_bHaveActive)
    vars['skillFullVisual2']:setVisible(self.m_bHaveActive)
    vars['skillFullVisual1']:changeAni('dragon_full_' .. str_target .. '_idle_1', true)
    vars['skillFullVisual2']:changeAni('dragon_full_' .. str_target .. '_idle_2', true)

    vars['cooltimeLabel']:setString('')
    
    -- 속성 아이콘
    if (vars['attrNode']) then
        local attr_str = dragon:getAttribute()
        local res = 'ingame_panel_attr_' .. attr_str .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if (icon) then
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
    --[[
    do -- 드래그 스킬 아이콘
        local skill_icon

        if (t_skill) then
            skill_icon = IconHelper:getSkillIcon('dragon', skill_id)
			
		-- 액티브 스킬이 없는 케이스
        else
            skill_icon = cc.Sprite:create('res/ui/icons/skill/skill_empty.png')
			
        end

        skill_icon:setDockPoint(CENTER_POINT)
        skill_icon:setAnchorPoint(CENTER_POINT)
        vars['skillNode']:addChild(skill_icon)
    end
    ]]--

    -- 인디케이터 아이콘
    if (t_skill) then
        local indicator_type = t_skill['indicator']
        local rotate = 0

        if (pl.stringx.endswith(indicator_type, '_right')) then
            indicator_type = string.gsub(indicator_type, '_right', '')
            rotate = 180
        elseif (pl.stringx.endswith(indicator_type, '_top')) then
            indicator_type = string.gsub(indicator_type, '_top', '')
            rotate = 180
        elseif (pl.stringx.endswith(indicator_type, '_touch')) then
            indicator_type = string.gsub(indicator_type, '_touch', '')
        end
        
        local res = 'ingame_panel_indicater_' .. str_target .. '_' .. indicator_type .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if (icon) then
            icon:setDockPoint(CENTER_POINT)
            icon:setAnchorPoint(CENTER_POINT)
            icon:setRotation(rotate)
            vars['indicaterNode']:addChild(icon)
        end
    end

    -- 대상 수
    if (t_skill) then
        local target_count = t_skill['target_count']
        target_count = math_min(target_count, 7)
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
    local vars = self.vars

    local did = self.m_dragon:getCharacterId()
    local active = g_settingData:isAutoDragSkillLockDid(self.m_deckName, did)
    
    --while true do end
    vars['autoDragLockBtn'] = UIC_CheckBox(vars['autoDragLockBtn'].m_node, vars['autoDragLockSprite'], active)
    vars['autoDragLockBtn']:registerScriptTapHandler(function() self:click_autoDragSkillLockCheckBox() end)
end

-------------------------------------
-- function update
-------------------------------------
function UI_IngameDragonPanelItem:update(dt, possible)
    if (self.m_dragon:isDead()) then
        possible = false

    elseif (not self.m_dragon:isPossibleActiveSkill()) then
        possible = false
        
	-- 쫄작 중 6성 아닌 드래곤(not farmer)은 스킬 사용 연출 막음
	elseif (self.m_world:isDragonFarming() and not self.m_dragon:isFarmer()) then
		possible = false

    end

    self.m_bEnabled = possible
    
    self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IngameDragonPanelItem:refresh()
    local vars = self.vars

    vars['dieSprite']:setVisible(self.m_dragon:isDead())
    vars['cooltimeLabel']:setVisible(not self.m_dragon:isDead())

    if (self.m_bEnabled == vars['skillFullVisual1']:isVisible()) then return end

    vars['skillFullVisual1']:setVisible(self.m_bEnabled)
    vars['skillFullVisual2']:setVisible(self.m_bEnabled)

    -- 연출 액션
    cca.stopAction(vars['topMenu'], ACTIVE_ACTION__TAG)

    if (self.m_bEnabled) then
        cca.runAction(vars['topMenu'], cc.MoveTo:create(0.2, cc.p(0, 54)), ACTIVE_ACTION__TAG)
    else
        cca.runAction(vars['topMenu'], cc.MoveTo:create(0.2, cc.p(0, 0)), ACTIVE_ACTION__TAG)
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function UI_IngameDragonPanelItem:onEvent(event_name, t_event, ...)
    -- 드래곤 체력 변경 Event
    if (event_name == 'character_set_hp') then
        self:refreshHP(t_event['hp_rate'])

    elseif (event_name == 'character_metamorphosis') then
        self:refreshSkill(t_event['metamorphosis'])

    -- 드래곤 드래그 스킬 게이지 변경 Event
    elseif (event_name == 'dragon_skill_gauge') then
        self:refreshSkillGauge(t_event['cool_time'], t_event['percentage'], t_event['enough_mana'])

    elseif (event_name == 'touch_began') then
        self:onTouchBegan(t_event)

    -- 드래곤 마나 소모량 변경 Event
    elseif (event_name == 'dragon_mana_reduce' or event_name == 'dragon_mana_reduce_finish') then
        self:refreshManaCost(t_event['value'])

    elseif (event_name == 'auto_mode_changed') then
        self:refreshAutoDragSkillCheckBox(true)
    end
end

-------------------------------------
-- function refreshHP
-- @brief 드래곤 체력 변경 Event
-------------------------------------
function UI_IngameDragonPanelItem:refreshHP(hp_ratio)
    if (self.m_hpRatio == hp_ratio) then 
        return
    end
    
    self.m_hpRatio = hp_ratio
    
    local vars = self.vars
    local scale = self.m_hpRatio

    -- 체력바 가감 연출
    --vars['hpGauge']:setScaleX(scale)
    vars['dragonHpGauge']:setPercentage(self.m_hpRatio * 100)
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
            if (icon) then
                icon:setDockPoint(cc.p(0.5, 0.5))
                icon:setAnchorPoint(cc.p(0.5, 0.5))
                vars['manaNode']:addChild(icon)
            end
        end
    end
end

-------------------------------------
-- function refreshSkill
-- @brief 드래곤 드래그 스킬 갱신
-------------------------------------
function UI_IngameDragonPanelItem:refreshSkill(metamorphosis)
    if (not self.m_bHaveActive) then return end

    local vars = self.vars

    local metamorphosis = metamorphosis or false
    local dragon = self.m_dragon
    local skill_id = dragon:getSkillID('active')
    local t_skill = dragon:getSkillTable(skill_id)

    self.m_bAttackSkill = SkillHelper:isEnemyTargetingType(t_skill)

    local str_target = (self.m_bAttackSkill and 'atk' or 'heal')

    vars['skillFullVisual1']:changeAni('dragon_full_' .. str_target .. '_idle_1', true)
    vars['skillFullVisual2']:changeAni('dragon_full_' .. str_target .. '_idle_2', true)

    --vars['swapSprite']:setVisible(metamorphosis)

    do -- 드래곤 아이콘
	    local sprite = IconHelper:getDragonIconFromTable(dragon.m_tDragonInfo, dragon.m_charTable, metamorphosis)
	    if (sprite) then
            vars['dragonNode']:removeAllChildren()
		    vars['dragonNode']:addChild(sprite)
	    end
    end
    --[[
    do -- 드래그 스킬 아이콘
        local skill_icon

        if (t_skill) then
            skill_icon = IconHelper:getSkillIcon('dragon', skill_id)
			
		-- 액티브 스킬이 없는 케이스
        else
            skill_icon = cc.Sprite:create('res/ui/icons/skill/skill_empty.png')
			
        end

        skill_icon:setDockPoint(CENTER_POINT)
        skill_icon:setAnchorPoint(CENTER_POINT)
        vars['skillNode']:removeAllChildren()
        vars['skillNode']:addChild(skill_icon)
    end
    ]]--

    -- 인디케이터 아이콘
    if (t_skill) then
        local indicator_type = t_skill['indicator']
        local rotate = 0

        if (pl.stringx.endswith(indicator_type, '_right')) then
            indicator_type = string.gsub(indicator_type, '_right', '')
            rotate = 180
        elseif (pl.stringx.endswith(indicator_type, '_top')) then
            indicator_type = string.gsub(indicator_type, '_top', '')
            rotate = 180
        elseif (pl.stringx.endswith(indicator_type, '_touch')) then
            indicator_type = string.gsub(indicator_type, '_touch', '')
        end
        
        local res = 'ingame_panel_indicater_' .. str_target .. '_' .. indicator_type .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if (not icon) then
            cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_panel/ingame_panel.plist')
            icon = cc.Sprite:createWithSpriteFrameName(res)
        end

        if (icon) then
            icon:setDockPoint(CENTER_POINT)
            icon:setAnchorPoint(CENTER_POINT)
            icon:setRotation(rotate)
            vars['indicaterNode']:removeAllChildren()
            vars['indicaterNode']:addChild(icon)
        end
    end

    -- 대상 수
    if (t_skill) then
        local target_count = t_skill['target_count']
        target_count = math_min(target_count, 7)
        local res = 'ingame_panel_target_' .. str_target .. '_' .. target_count .. '.png'
        local icon = cc.Sprite:createWithSpriteFrameName(res)
        if (not icon) then
            cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_panel/ingame_panel.plist')
            icon = cc.Sprite:createWithSpriteFrameName(res)
        end

        if (icon) then
            icon:setDockPoint(CENTER_POINT)
            icon:setAnchorPoint(CENTER_POINT)
            vars['targetNode']:removeAllChildren()
            vars['targetNode']:addChild(icon)
        end
    end
end

-------------------------------------
-- function refreshSkillGauge
-- @brief 드래곤 드래그 스킬 쿨타임 갱신
-------------------------------------
function UI_IngameDragonPanelItem:refreshSkillGauge(cool_time, percentage, enough_mana)
    if (not self.m_bHaveActive) then return end

    local vars = self.vars
    
    if (self.m_skillGaugePercentage ~= percentage) then
        self.m_skillCoolTime = math_floor(cool_time)
        self.m_skillGaugePercentage = percentage

        if (cool_time > 0) then
            vars['cooltimeLabel']:setString(self.m_skillCoolTime)
        else
            vars['cooltimeLabel']:setString('')
        end

        vars['skillGaugeVisual']:setAnimationPause(true)
        vars['skillGaugeVisual']:setFrame(percentage)
    end
end

-------------------------------------
-- function onTouchBegan
-- @brief
-------------------------------------
function UI_IngameDragonPanelItem:onTouchBegan(t_event)
    local vars = self.vars

    -- 스킬 사용이 안되면 터치도 안됨
    if (not self.m_bHaveActive) then
        return
    end

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
-- function setPanelInActive
-- @brief
-------------------------------------
function UI_IngameDragonPanelItem:setPanelInActive()
    self.m_bHaveActive = false
	if (self.vars['dragNotSprite']) then
    	self.vars['dragNotSprite']:setVisible(true)
        self.vars['dragNotBtn']:setVisible(true)
        self.vars['dragNotBtn']:registerScriptTapHandler(function()
            UIManager:toastNotificationRed(Str('드래그 스킬 사용 불가'))
        end)
	end
end

-------------------------------------
-- function refreshAutoDragSkillCheckBox
-------------------------------------
function UI_IngameDragonPanelItem:refreshAutoDragSkillCheckBox(is_change_event)
    local vars = self.vars
    local is_auto_mode = self.m_world:isAutoPlay()

--[[     if is_auto_mode == true then
        vars['autoDragLockBtn']:setScale(0.0)
        local scale_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 1), 1)
        vars['autoDragLockBtn']:stopAllActions()
        vars['autoDragLockBtn']:runAction(scale_action)
    else
        vars['autoDragLockBtn']:setScale(1.0)
        local scale_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 0), 1)
        vars['autoDragLockBtn']:stopAllActions()
        vars['autoDragLockBtn']:runAction(scale_action)
    end
 ]]

    vars['autoDragLockBtn']:setVisible(is_auto_mode)
end

-------------------------------------
-- function click_autoDragSkillLockCheckBox
-------------------------------------
function UI_IngameDragonPanelItem:click_autoDragSkillLockCheckBox()
    local vars = self.vars
    local did = self.m_dragon:getCharacterId()
    local dragon_name = self.m_dragon:getName()
    local dirty = false
    local checked = vars['autoDragLockBtn']:isChecked()
    local drag_did_list = g_settingData:getAutoDragSkillLockDidList(self.m_deckName)

    if checked == true then
        if table.find(drag_did_list, did) == nil then
            table.insert(drag_did_list, did)
            dirty = true
            UIManager:toastNotificationGreen(Str('{1}의 드래그 스킬 잠금', dragon_name))
        end
    else
        for idx, _did in ipairs(drag_did_list) do
            if _did == did then
                table.remove(drag_did_list, idx)
                dirty = true
            end
        end

        if dirty == true then
            UIManager:toastNotificationGreen(Str('{1}의 드래그 스킬 잠금 해제', dragon_name))
        end
    end

    if dirty == true then
        g_settingData:setAutoDragSkillLockDidList(self.m_deckName, drag_did_list)
    end
end

-------------------------------------
-- function initDragSkillLock
-------------------------------------
function UI_IngameDragonPanelItem:initDragSkillLock()
    local l_deck, formation, deck_name, leader = g_deckData:getDeck()
    self.m_deckName = deck_name
end
