SI_STATE_NONE = 0
SI_STATE_READY = 1
SI_STATE_APPEAR = 2
SI_STATE_IDLE = 3
SI_STATE_DISAPPEAR = 4

-------------------------------------
-- class SkillIndicator
-------------------------------------
SkillIndicator = class({
        m_world = 'GameWorld',
        m_hero = 'Hero',
        m_skillIndicatorMgr = 'SkillIndicatorMgr',
        m_siState = 'number',

        m_indicatorRootNode = 'cc.Node',
        m_indicatorEffect = 'A2D',
		m_indicatorScale = 'number',

        m_indicatorTouchPosX = '',
        m_indicatorTouchPosY = '',

        m_targetDir = '',
        m_targetPosX = '',
        m_targetPosY = '',
        m_targetChar = '',

        -- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset
        m_attackPosOffsetX = 'number',
        m_attackPosOffsetY = 'number',

		m_highlightList = ''
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator:init(hero)
    self.m_hero = hero
    self.m_siState = SI_STATE_NONE

    self.m_indicatorTouchPosX = hero.pos.x
    self.m_indicatorTouchPosY = hero.pos.y

    -- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset 지정
    self:initAttackPosOffset(hero)
end

-------------------------------------
-- function initAttackPosOffset
-- @brief 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset 지정
-------------------------------------
function SkillIndicator:initAttackPosOffset(hero)
    self.m_attackPosOffsetX = 0
    self.m_attackPosOffsetY = 0

    local animator = hero.m_animator
    
    local l_event_data = animator:getEventList('attack', 'attack')

    if (not l_event_data[1]) then
        return
    end

    local string_value = l_event_data[1]['stringValue']

    if (not string_value) or (string_value == '') then
        return
    end

    local l_str = seperate(string_value, ',')

    local scale = animator:getScale()
    self.m_attackPosOffsetX = (l_str[1] * scale)
    self.m_attackPosOffsetY = (l_str[2] * scale)
end

-------------------------------------
-- function changeSIState
-------------------------------------
function SkillIndicator:changeSIState(state)
    if (self.m_siState == state) then
        return 
    end

    self.m_siState = state

    if (state == SI_STATE_READY) then
        self:initIndicatorNode()
        self.m_indicatorRootNode:setVisible(false)
        self.m_highlightList = nil

        self.m_targetDir = nil
        self.m_targetPosX = nil
        self.m_targetPosY = nil
        self.m_targetChar = nil

    elseif (state == SI_STATE_APPEAR) then
        self.m_indicatorRootNode:setVisible(true)
        self:onEnterAppear()
		
		-- 툴팁 생성
		self.m_skillIndicatorMgr:makeSkillToolTip(self.m_hero)

        -- 영웅 스킬 준비 이펙트 생성
        self.m_hero:makeSkillPrepareEffect()

    elseif (state == SI_STATE_DISAPPEAR) then
        self.m_indicatorRootNode:setVisible(false)
        self:onDisappear()

		-- 툴팁 닫기
		self.m_skillIndicatorMgr:closeSkillToolTip()

        -- 영웅 스킬 준비 이펙트 해제
        self.m_hero:removeSkillPrepareEffect()
    end
end

-------------------------------------
-- function getWorld
-------------------------------------
function SkillIndicator:getWorld()
    if self.m_world then
        return self.m_world
    else
        self.m_world = self.m_hero.m_world
        return self.m_world
    end
end

-------------------------------------
-- function getSkillIndicatorMgr
-------------------------------------
function SkillIndicator:getSkillIndicatorMgr()
    if self.m_skillIndicatorMgr then
        return self.m_skillIndicatorMgr
    else
        local world = self:getWorld()
        self.m_skillIndicatorMgr = world.m_skillIndicatorMgr
        return self.m_skillIndicatorMgr
    end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator:onTouchMoved(x, y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator:initIndicatorNode()
    if self.m_indicatorRootNode then
        return false
    end

    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local root_node = cc.Node:create()
    root_node:setVisible(true)
    root_node:scheduleUpdateWithPriorityLua(function() self:update() end, 0)

    g_gameScene.m_gameIndicatorNode:addChild(root_node, 0)
    self.m_indicatorRootNode = root_node

    return true
end

-------------------------------------
-- function update
-------------------------------------
function SkillIndicator:update()
    if (not isExistValue(self.m_siState, SI_STATE_APPEAR, SI_STATE_IDLE)) then
        return
    end

    self.m_indicatorRootNode:setPosition(self.m_hero.pos.x, self.m_hero.pos.y)
    self:onTouchMoved(self.m_indicatorTouchPosX, self.m_indicatorTouchPosY)
	self.m_skillIndicatorMgr:updateToolTipUI(self.m_hero.pos.x, self.m_hero.pos.y, self.m_indicatorTouchPosX, self.m_indicatorTouchPosY)
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator:onEnterAppear()
    self.m_hero.m_animator:setTimeScale(5)
end

-------------------------------------
-- function onDisappear
-------------------------------------
function SkillIndicator:onDisappear()
	-- 현재 사용하는 곳이 없으나 추후 사용하면 좋을듯
end

-------------------------------------
-- function setHighlight
-------------------------------------
function SkillIndicator:setHighlightEffect(t_collision_obj)
	local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local old_target_count = 0

    local old_highlight_list = self.m_highlightList

    if self.m_highlightList then
        old_target_count = #self.m_highlightList
    end

    for i,target in ipairs(t_collision_obj) do            
        if (not target.m_targetEffect) then
            skill_indicator_mgr:addHighlightList(target)
            self:makeTargetEffect(target)
        end
            
    end

    if old_highlight_list then
        for i,v in ipairs(old_highlight_list) do
            local find = false
            for _,v2 in ipairs(t_collision_obj) do
                if (v == v2) then
                    find = true
                    break
                end
            end
            if (find == false) then
                skill_indicator_mgr:removeHighlightList(v)
            end
        end
    end

    self.m_highlightList = t_collision_obj

    local cur_target_count = #self.m_highlightList
    self:onChangeTargetCount(old_target_count, cur_target_count)
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator:onChangeTargetCount(old_target_count, cur_target_count)
end

-------------------------------------
-- function getIndicatorData
-------------------------------------
function SkillIndicator:getIndicatorData()
    local t_data = {}

    t_data['dir'] = self.m_targetDir
    t_data['x'] = self.m_targetPosX
    t_data['y'] = self.m_targetPosY
    t_data['target'] = self.m_targetChar

	self.m_targetDir = nil
    self.m_targetPosX = nil
    self.m_targetPosY = nil
    self.m_targetChar = nil

    return t_data
end

-------------------------------------
-- function makeTargetEffect
-------------------------------------
function SkillIndicator:makeTargetEffect(target_char, ani_name1, ani_name2)
    local indicator = MakeAnimator('res/indicator/indicator_effect_target/indicator_effect_target.vrp')
    indicator:setTimeScale(5)
    indicator:changeAni(ani_name1 or 'appear', false)
    indicator:addAniHandler(function() indicator:changeAni(ani_name2 or 'idle', true) end)
    target_char:setTargetEffect(indicator)

    -- 속성 상성 표시
    if ani_name1 ~= 'appear_ally' then
        local attackerAttr = self.m_hero.m_charTable['attr']
        local defenderAttr = target_char.m_charTable['attr']
        local attr_synastry = getCounterAttribute(attackerAttr, defenderAttr)
        local aniName

        if attr_synastry then
            if attr_synastry > 0 then       aniName = 'adv_arrow'
            elseif attr_synastry < 0 then   aniName = 'disadv_arrow'
            end
        end

        local attrCounterNoti
        if aniName then
            attrCounterNoti = MakeAnimator('res/ui/a2d/ingame_enemy/ingame_enemy.vrp')
            attrCounterNoti:setPosition(0, 50)
            attrCounterNoti:setTimeScale(10)
            attrCounterNoti:setVisual('attr', aniName)

            indicator.m_node:addChild(attrCounterNoti.m_node)
        end
    end
end

-------------------------------------
-- function getAttackPosition
-- @brief
-------------------------------------
function SkillIndicator:getAttackPosition()
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    pos_x = (pos_x + self.m_attackPosOffsetX)
    pos_y = (pos_y + self.m_attackPosOffsetY)
    return pos_x, pos_y
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator:findTarget(x, y)
end