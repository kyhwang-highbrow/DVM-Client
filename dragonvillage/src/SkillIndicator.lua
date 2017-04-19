SI_STATE_NONE = 0
SI_STATE_READY = 1
SI_STATE_APPEAR = 2
SI_STATE_IDLE = 3
SI_STATE_DISAPPEAR = 4

--[[
@MS 2016.11.25
1. 이펙트 관리 멤버변수 통일
  기본 - m_indicatorEffect 
  추가 - m_indicatorAddEffect (필요한 경우 개별적으로 추가)
  특수 - 개별관리

2. 리소스 경로는 Constant.lua 에서 관리

3. 공통되는 로직은 최대한 합쳐서 관리
]]

-------------------------------------
-- class SkillIndicator
-------------------------------------
SkillIndicator = class({
        m_world = 'GameWorld',
        m_hero = 'Dragon',
        m_skillIndicatorMgr = 'SkillIndicatorMgr',
        m_siState = 'number',

        m_indicatorRootNode = 'cc.Node',
        m_indicatorEffect = 'A2D',
		m_indicatorScale = 'number',
		m_indicatorAngleLimit = 'number',  
		m_indicatorDistanceLimit = 'number',

        m_indicatorTouchPosX = '',
        m_indicatorTouchPosY = '',
        m_bDirty = '',

        m_targetDir = '',
        m_targetPosX = '',
        m_targetPosY = '',
        m_targetChar = '',

		m_targetType = 'str',
		m_targetLimit = 'num',
		m_targetFormation = 'str',

        -- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset
        m_attackPosOffsetX = 'number',
        m_attackPosOffsetY = 'number',

		m_highlightList = '',
        m_highlightBodyList = '',

		-- 인디케이터의 보너스 효과 레벨 관련
		m_preBonusLevel = 'number',
        m_bonus = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator:init(hero, t_skill, ...)
    self.m_world = hero.m_world
    self.m_hero = hero
    self.m_siState = SI_STATE_NONE

    self.m_indicatorTouchPosX = hero.pos.x
    self.m_indicatorTouchPosY = hero.pos.y
    self.m_bDirty = true

	self.m_preBonusLevel = -1
    self.m_bonus = -1

    -- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset 지정
    self:initAttackPosOffset(hero)

	-- 필요한 변수 지정
	self:init_indicator(t_skill, ...)

	-- indicator node 생성
    self:initIndicatorNode()
end

-------------------------------------
-- function init_indicator
-- @brief 멤버 변수 선언
-------------------------------------
function SkillIndicator:init_indicator(t_skill, ...)
	self.m_targetType = SkillHelper:getValid(t_skill['target_type'])
	self.m_targetLimit = SkillHelper:getValid(t_skill['target_count'])
	self.m_targetFormation = SkillHelper:getValid(t_skill['target_formation'])
end

-------------------------------------
-- function initAttackPosOffset
-- @brief 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset 지정
-------------------------------------
function SkillIndicator:initAttackPosOffset(hero)
    self.m_attackPosOffsetX = 0
    self.m_attackPosOffsetY = 0

    local animator = hero.m_animator
    
    local l_event_data = animator:getEventList('skill_disappear', 'attack')

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

    if (animator.m_bFlip) then
        self.m_attackPosOffsetX = -self.m_attackPosOffsetX
    end
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
        self:setIndicatorVisible(false)

        self.m_bDirty = true
        self.m_highlightList = nil
        self.m_highlightBodyList = nil

        self.m_targetDir = nil
        self.m_targetPosX = nil
        self.m_targetPosY = nil
        self.m_targetChar = nil
        self.m_bonus = -1

    elseif (state == SI_STATE_APPEAR) then
        self:setIndicatorVisible(true)
        self:onEnterAppear()
		
		-- 툴팁 생성
        self:getSkillIndicatorMgr():makeSkillToolTip(self.m_hero)

        -- 영웅 스킬 준비 이펙트 생성
        self.m_hero:makeSkillPrepareEffect()

    elseif (state == SI_STATE_DISAPPEAR) then
        self.m_indicatorRootNode:setVisible(false)
        self:onDisappear()
		
		-- 툴팁 닫기
		self:getSkillIndicatorMgr():closeSkillToolTip()

        -- 영웅 스킬 준비 이펙트 해제
        self.m_hero:removeSkillPrepareEffect()

        -- 타겟 이펙트 해제(테스트 필요)
        if (self.m_highlightList) then
            for i, v in ipairs(self.m_highlightList) do
                v:removeTargetEffect()
            end
            self.m_highlightList = nil
        end
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
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
    self.m_indicatorEffect:setPosition(touch_x - pos_x, touch_y - pos_y)
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
    root_node:setVisible(false)
    root_node:scheduleUpdateWithPriorityLua(function() self:update() end, 0)

    g_gameScene.m_gameIndicatorNode:addChild(root_node, 0)
    self.m_indicatorRootNode = root_node

    return true
end

-------------------------------------
-- function update
-------------------------------------
function SkillIndicator:update()
    self.m_indicatorRootNode:setPosition(self.m_hero.pos.x, self.m_hero.pos.y)

    if (not isExistValue(self.m_siState, SI_STATE_APPEAR, SI_STATE_IDLE)) then
        return
    end

    self:onTouchMoved(self.m_indicatorTouchPosX, self.m_indicatorTouchPosY)
	self.m_skillIndicatorMgr:updateToolTipUI(self.m_hero.pos.x, self.m_hero.pos.y, self.m_indicatorTouchPosX, self.m_indicatorTouchPosY)
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator:onEnterAppear()
	if (not self.m_indicatorEffect) then 
		return
	end

    self.m_indicatorEffect:changeAni('appear')
	self.m_indicatorEffect:addAniHandler(function()
		self.m_indicatorEffect:changeAni('idle', true)
	end)
end

-------------------------------------
-- function onDisappear
-------------------------------------
function SkillIndicator:onDisappear()
	-- 현재 사용하는 곳이 없으나 추후 사용하면 좋을듯 @MS 2016.11.24
end

-------------------------------------
-- function setIndicatorVisible
-------------------------------------
function SkillIndicator:setIndicatorVisible(isVisible)
	if self.m_indicatorRootNode then
		self.m_indicatorRootNode:setVisible(isVisible)
	end
end

-------------------------------------
-- function setHighlightEffect
-------------------------------------
function SkillIndicator:setHighlightEffect(t_collision_obj, l_collision_bodys)
    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local old_target_count = 0

    local old_highlight_list = self.m_highlightList
    local old_highlight_body_list = self.m_highlightBodyList

    if self.m_highlightList then
        old_target_count = #self.m_highlightList
    end

    for i, target in ipairs(t_collision_obj) do
        if (target ~= self.m_hero) then
            for i, body_key in ipairs(l_collision_bodys[i]) do
                self:makeTargetEffect(target, body_key)
            end
        end

        skill_indicator_mgr:addTarget(target)
    end

    if old_highlight_list then
        for i, v in ipairs(old_highlight_list) do
            local find = false
            for j, v2 in ipairs(t_collision_obj) do
                if (v == v2) then
                    find = true
                    for _, k in ipairs(old_highlight_body_list[i]) do
                        local find_body = false
                        for _, k2 in ipairs(l_collision_bodys[j]) do
                            if (k == k2) then
                                find_body = true
                                break
                            end
                        end

                        if (not find_body) then
                            v:removeTargetEffect(k)
                        end
                    end
                end
            end

            if (not find) then
                v:removeTargetEffect()
            end
        end
    end

    self.m_highlightList = t_collision_obj
    self.m_highlightBodyList = l_collision_bodys

    local cur_target_count = #self.m_highlightList
    self:onChangeTargetCount(old_target_count, cur_target_count)
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
    if (cur_target_count > 0) then
		-- 타겟수에 따른 보너스 등급 저장
		self.m_bonus = DragonSkillBonusHelper:getBonusLevel(self.m_hero, cur_target_count)

		if (self.m_preBonusLevel ~= self.m_bonus) then
			self:onChangeIndicatorEffect(self.m_indicatorEffect, self.m_bonus, self.m_preBonusLevel)
		end

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_bonus = -1
		self:initIndicatorEffect(self.m_indicatorEffect)
    end

	self.m_preBonusLevel = self.m_bonus
end

-------------------------------------
-- function onChangeIndicatorEffect
-- @brief 인디케이터 보너스 단계별로 다른 연출을 한다.
-------------------------------------
function SkillIndicator:onChangeIndicatorEffect(indicator, bonus_lv, pre_bonus_lv)
	-- 인디케이터 색상 변경
	local l_color_lv = g_constant:get('INDICATOR', 'COLOR_LEVEL')
	local color_key = l_color_lv[tostring(bonus_lv)]
	local color = COLOR[color_key]
	indicator:setColor(color)

	-- 인디케이터 애니메이션 변경
	if (pre_bonus_lv >= 2) and (bonus_lv < 2) then
		indicator:changeAni('idle', true)
	elseif (pre_bonus_lv < 2) and (bonus_lv >= 2) then
		indicator:changeAni('idle_2', true)
	end
end

-------------------------------------
-- function initIndicatorEffect
-- @brief 인디케이터 연출 초기화
-------------------------------------
function SkillIndicator:initIndicatorEffect(indicator)
	indicator:setColor(COLOR['gray'])
	indicator:changeAni('idle', true)
end

-------------------------------------
-- function setIndicatorDataByChar
-------------------------------------
function SkillIndicator:setIndicatorDataByChar(char)
    local pos_x, pos_y = self:getAttackPosition()
    --local pos_x, pos_y = self.m_hero.pos.x, self.m_hero.pos.y
    local x, y = char:getPosition()
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
    
    self.m_targetDir = dir
    self.m_targetPosX = x
    self.m_targetPosY = y
    self.m_targetChar = char
    self.m_bDirty = true
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
    t_data['bonus'] = self.m_bonus
    --[[
	self.m_targetDir = nil
    self.m_targetPosX = nil
    self.m_targetPosY = nil
    self.m_targetChar = nil
    self.m_bonus = -1
    ]]--

    return t_data
end

-------------------------------------
-- function makeTargetEffect
-------------------------------------
function SkillIndicator:makeTargetEffect(target_char, body_key)
    if (body_key and target_char.m_mTargetEffect[body_key]) then return end
    if (self.m_siState ~= SI_STATE_APPEAR) then return end
    
    local ani_name1
    local ani_name2

    if (self.m_hero.m_bLeftFormation == target_char.m_bLeftFormation) then
        ani_name1 = 'appear_ally'
        ani_name2 = 'idle_ally'
    else
        ani_name1 = 'appear'
        ani_name2 = 'idle'
    end

	local indicator_res = g_constant:get('INDICATOR', 'RES', 'effect')
    local indicator = MakeAnimator(indicator_res)
    indicator:changeAni(ani_name1, false)
    indicator:addAniHandler(function() indicator:changeAni(ani_name2, true) end)
    indicator:setScale(0.1)
	indicator:runAction(cc.ScaleTo:create(0.2, 1)) -- timescale 주의

    target_char:setTargetEffect(indicator, body_key)
    
	-- 적군의 경우 속성 상성 표시
    if (self.m_hero.m_bLeftFormation ~= target_char.m_bLeftFormation) then
		self:makeAttributeEffect(target_char, indicator)
    end
end

-------------------------------------
-- function makeAttributeEffect
-------------------------------------
function SkillIndicator:makeAttributeEffect(target_char, indicator)
	local attackerAttr = self.m_hero:getAttribute()
    local defenderAttr = target_char:getAttribute()
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
        attrCounterNoti:setVisual('attr', aniName)

        indicator.m_node:addChild(attrCounterNoti.m_node)
    end
end

-------------------------------------
-- function getAttackPosition
-- @brief
-------------------------------------
function SkillIndicator:getAttackPosition()
    local pos_x, pos_y

    if (self.m_indicatorRootNode) then
        pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    else
        pos_x, pos_y = self.m_hero.pos.x, self.m_hero.pos.y
    end

    pos_x = (pos_x + self.m_attackPosOffsetX)
    pos_y = (pos_y + self.m_attackPosOffsetY)
    return pos_x, pos_y
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator:findTarget(x, y)
end

-------------------------------------
-- function findTarget
-- @brief 타겟룰에 의해 적절한 타겟리스트 가져옴
-------------------------------------
function SkillIndicator:getProperTargetList()
	return self.m_hero:getTargetListByType(self.m_targetType, self.m_targetLimit, self.m_targetFormation)
end

-------------------------------------
-- function checkIndicatorLimit
-------------------------------------
function SkillIndicator:checkIndicatorLimit(angle, distance)
	local is_change_angle, is_change_distance = true, true

	-- 1. check angle
    if (self.m_hero.m_bLeftFormation) then
	    if (angle) then 
		    if (angle > self.m_indicatorAngleLimit) and (angle < 180) then 
			    angle = self.m_indicatorAngleLimit
			    is_change_angle = false
		    elseif (angle < (360 - self.m_indicatorAngleLimit)) and (angle > 180) then
			    angle = (360 - self.m_indicatorAngleLimit)
			    is_change_angle = false
		    else
			    is_change_angle = true
		    end
	    end
    end

	-- 2. check distance
	if (distance) then
		-- 최소 거리
		if (distance < self.m_indicatorDistanceLimit) then 
			distance = self.m_indicatorDistanceLimit
			is_change_distance = false
		else
			is_change_distance = true
		end
	end

	return {
		angle = angle, 
		distance = distance, 
		is_change = (is_change_angle and is_change_distance)
	}
end

-------------------------------------
-- function getTargetForHighlight
-- @brief 피격(하이라이트) 대상을 미리 얻어오기 위해 임시 추가
-------------------------------------
function SkillIndicator:getTargetForHighlight()
    local x, y
    
    if (self.m_targetPosX and self.m_targetPosY) then
        x = self.m_targetPosX
        y = self.m_targetPosY

    else
        cclog('getTargetForHighlight no target')
        return {}
        --[[
        local l_target = self.m_hero:getProperTargetList()
	    local target = l_target[1]

	    if target then
		    x = target.pos.x
            y = target.pos.y
        else
            x = self.m_owner.pos.x
            y = self.m_owner.pos.y
        end
        ]]--
    end

    self:onTouchMoved(x, y)

    local l_ret = self.m_highlightList or {}
    return l_ret
end

-------------------------------------
-- function setIndicatorTouchPos
-------------------------------------
function SkillIndicator:setIndicatorTouchPos(x, y)
    self.m_indicatorTouchPosX = x
    self.m_indicatorTouchPosY = y
    self.m_bDirty = true
end