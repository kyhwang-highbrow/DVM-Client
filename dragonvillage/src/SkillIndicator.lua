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
        m_critical = '',

		m_targetType = 'str',
		m_targetLimit = 'num',
		m_targetFormation = 'str',

        -- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset
        m_attackPosOffsetX = 'number',
        m_attackPosOffsetY = 'number',

		m_highlightList = '',
        m_collisionList = '',
        m_collisionListByVirtualTest = '',
        
		-- 인디케이터의 보너스 효과 레벨 관련
		m_preBonusLevel = 'number',
        m_bonus = 'number',

        m_additionalInfo = 'map',
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

    self.m_additionalInfo = {}
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
    if (not l_str) then
        error('invalid attack event : ' .. string_value)
    end

    local scale = animator:getScale()
    self.m_attackPosOffsetX = (l_str[1] * scale)
    self.m_attackPosOffsetY = (l_str[2] * scale)

    if (not hero.m_bLeftFormation) then
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
        self.m_collisionList = nil
        
        self.m_targetDir = nil
        self.m_targetPosX = nil
        self.m_targetPosY = nil
        self.m_targetChar = nil
        self.m_critical = nil
        self.m_bonus = -1

    elseif (state == SI_STATE_APPEAR) then
        self:setIndicatorVisible(true)
        self:onEnterAppear()
		
		-- 툴팁 생성
        --self:getSkillIndicatorMgr():makeSkillToolTip(self.m_hero)

        -- 영웅 스킬 준비 이펙트 생성
        self.m_hero:makeSkillPrepareEffect()

    elseif (state == SI_STATE_DISAPPEAR) then
        self.m_indicatorRootNode:setVisible(false)
        self:onDisappear()
		
		-- 툴팁 닫기
		self:getSkillIndicatorMgr():closeSkillToolTip()

        -- 영웅 스킬 준비 이펙트 해제
        self.m_hero:removeSkillPrepareEffect()

        -- 타겟 이펙트 해제
        if (self.m_highlightList) then
            for i, v in ipairs(self.m_highlightList) do
                self:removeAllTargetEffect(v)
            end
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
function SkillIndicator:onTouchMoved(x, y, is_virtual_test)
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
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator:onEnterAppear()
	if (not self.m_indicatorEffect) then 
		return
	end
    self.m_indicatorEffect:setIgnoreLowEndMode(true)
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
-- @brief 현재는 하이라이트 리스트는 저장만하고 충돌되는 바디별 타겟 이펙트를 생성 및 삭제함
-------------------------------------
function SkillIndicator:setHighlightEffect(l_collision)
    local skill_indicator_mgr = self:getSkillIndicatorMgr()
    local old_target_count = 0
    local old_highlight_list = self.m_highlightList

    -- 이펙트 생성 및 해제 정보를 맵형태로 임시 저장
    local map = {}

    -- 새 충돌 정보로 이펙트 생성 정보 세팅
    -- TODO: 타겟 카운트에 따라 처리되어야함
    for _, collision in ipairs(l_collision) do
        local body_key = collision:getBodyKey()
        local target = collision:getTarget()
        --[[
        if (target.m_bUseBinding and target.m_parentChar) then
            body_key = target.m_bodyKey
            target = target.m_parentChar
        end
        ]]--
        if (not map[target]) then
            map[target] = {}

            for _, body in ipairs(target:getBodyList()) do
                map[target][body['key']] = 0
            end
        end

        map[target][body_key] = 1
    end

    -- 이전 하이라이트 리스트의 이펙트 해제 정보 세팅
    if (old_highlight_list) then
        old_target_count = #old_highlight_list

        for i, v in ipairs(old_highlight_list) do
            if (not map[v]) then
                map[v] = {}

                for _, body in ipairs(v:getBodyList()) do
                    map[v][body['key']] = -1
                end
            end
        end
    end

    -- 맵정보로 이펙트 생성 및 해제,  하이라이트 리스트 생성
    local highlightList = {}

    for target, map_bodys in pairs(map) do
        local is_created = true

        for body_key, v in pairs(map_bodys) do
            if (v == 1) then
                self:makeTargetEffect(target, body_key)
            elseif (v == 0) then
                self:makeNonTargetEffect(target, body_key)
            elseif (v == -1) then
                self:removeAllTargetEffect(target)
                is_created = false
                break
            end
        end

        if (is_created) then
            table.insert(highlightList, target)
        end
    end

    self.m_highlightList = highlightList
    self.m_collisionList = l_collision

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
	local color = l_color_lv[tostring(bonus_lv)]
	if (type(color) == 'string') then
		color = COLOR[color]
	else
		color = cc.c3b(color[1], color[2], color[3])
	end
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
-- function setIndicatorData
-------------------------------------
function SkillIndicator:setIndicatorData(x, y)
    local pos_x, pos_y = self:getAttackPosition()

    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
    
    self.m_targetDir = dir
    self.m_targetPosX = x
    self.m_targetPosY = y
    self.m_targetChar = char
    self.m_critical = nil
    self.m_bDirty = true

    self:onTouchMoved(x, y)
end

-------------------------------------
-- function setIndicatorDataByChar
-------------------------------------
function SkillIndicator:setIndicatorDataByChar(char)
    local pos_x, pos_y = self:getAttackPosition()
    local x, y = char:getPosition()
    local body = char:getBody()
    
    x = x + body.x
    y = y + body.y

    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
    
    self.m_targetDir = dir
    self.m_targetPosX = x
    self.m_targetPosY = y
    self.m_targetChar = char
    self.m_critical = nil
    self.m_bDirty = true

    self:onTouchMoved(x, y)
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
    t_data['target_list'] = self.m_highlightList
    t_data['collision_list'] = self.m_collisionList
    t_data['critical'] = self.m_critical
    t_data['bonus'] = self.m_bonus
    t_data['additional_info'] = self.m_additionalInfo
     
    -- 대상수가 1인 경우면 수식에서 skill_target을 사용할 수 있도록 설정
    if (self.m_targetLimit == 1 and self.m_highlightList) then
        t_data['target'] = self.m_highlightList[1]
    end
    
    return t_data
end

-------------------------------------
-- function makeTargetEffect
-------------------------------------
function SkillIndicator:makeTargetEffect(target_char, body_key)
    if (self.m_siState ~= SI_STATE_APPEAR) then return end
    if (target_char:isExistTargetEffect(body_key)) then return end
    
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
    
    if (target_char:isExistNonTargetEffect(body_key)) then
        indicator:changeAni(ani_name2, true)
        indicator:setScale(1)
    else
        indicator:changeAni(ani_name1, false)
        indicator:addAniHandler(function() indicator:changeAni(ani_name2, true) end)
        indicator:setScale(0.1)
	    indicator:runAction(cc.ScaleTo:create(0.2, 1)) -- timescale 주의
    end

    target_char:setTargetEffect(indicator, body_key)
    
	-- 적군의 경우 속성 상성 표시
    if (self.m_hero.m_bLeftFormation ~= target_char.m_bLeftFormation) then
		self:makeAttributeEffect(target_char, indicator)
    end
end

-------------------------------------
-- function makeNonTargetEffect
-------------------------------------
function SkillIndicator:makeNonTargetEffect(target_char, body_key)
    if (self.m_siState ~= SI_STATE_APPEAR) then return end
    if (target_char:isExistNonTargetEffect(body_key)) then return end

    -- 적군만 표시
    if (self.m_hero.m_bLeftFormation == target_char.m_bLeftFormation) then return end
    
    local ani_name1 = 'appear'
    local ani_name2 = 'idle'
    local indicator_res = g_constant:get('INDICATOR', 'RES', 'effect2')
    local indicator = MakeAnimator(indicator_res)
    
    if (target_char:isExistTargetEffect(body_key)) then
        indicator:changeAni(ani_name2, true)
        indicator:setScale(1)
    else
        indicator:changeAni(ani_name1, false)
        indicator:addAniHandler(function() indicator:changeAni(ani_name2, true) end)
        indicator:setScale(0.1)
	    indicator:runAction(cc.ScaleTo:create(0.2, 1)) -- timescale 주의
    end

    target_char:setNonTargetEffect(indicator, body_key)
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
-- function removeAllTargetEffect
-------------------------------------
function SkillIndicator:removeAllTargetEffect(target_char)
    target_char:removeTargetEffect()
    target_char:removeNonTargetEffect()
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
-- function findCollision
-------------------------------------
function SkillIndicator:findCollision(x, y)
end

-------------------------------------
-- function getProperTargetList
-- @brief 타겟룰에 의해 적절한 타겟리스트 가져옴
-------------------------------------
function SkillIndicator:getProperTargetList()
	return self.m_hero:getTargetListByType(self.m_targetType, nil, self.m_targetFormation, nil, true)
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
-- function getIndicatorTargetForHighlight
-- @brief 현재 인디케이터 정보로부터 피격(하이라이트) 대상을 얻어옴
-------------------------------------
function SkillIndicator:getIndicatorTargetForHighlight()
    local x, y
    if (self.m_indicatorTouchPosX and self.m_indicatorTouchPosY) then
        x = self.m_indicatorTouchPosX
        y = self.m_indicatorTouchPosY
    elseif (self.m_targetPosX and self.m_targetPosY) then
        x = self.m_targetPosX
        y = self.m_targetPosY
    else
        cclog('getTargetForHighlight no target')
        return {}
    end

    self:onTouchMoved(x, y)
    local l_ret = self.m_highlightList or {}
    return l_ret
end

---------------------------------
-- function getTargetForHighlight
-- @brief 현재 타겟 정보로부터 피격(하이라이트) 대상을 얻어옴
-------------------------------------
function SkillIndicator:getTargetForHighlight()
    local x, y
    if (self.m_targetPosX and self.m_targetPosY) then
        x = self.m_targetPosX
        y = self.m_targetPosY
    else
        cclog('getTargetForHighlight no target')
        return {}
    end

    self:onTouchMoved(x, y)

    local l_ret = self.m_highlightList or {}
    return l_ret
end

-------------------------------------
-- function getTargetForVirtualTest
-------------------------------------
function SkillIndicator:getTargetForVirtualTest()
    local x, y
    
    if (self.m_targetPosX and self.m_targetPosY) then
        x = self.m_targetPosX
        y = self.m_targetPosY

    else
        cclog('getTargetForVirtualTest no target')
        return {}
    end

    self:onTouchMoved(x, y, true)

    local l_ret = SkillTargetFinder:getTargetFromCollisionList(self.m_collisionListByVirtualTest)
    return l_ret
end

-------------------------------------
-- function setIndicatorDataByAuto
-- @brief l_target의 대상들을 가장 많이 피격할 수 있도록 인디케이터 정보를 세팅
-------------------------------------
function SkillIndicator:setIndicatorDataByAuto(l_target, target_count, fixed_target, is_arena)
    local bPass = false

    -- 스킬 피격 대상이 한명인 경우
    if (target_count == 1) then
        bPass = true

    -- 대상이 하나이고 하나의 충돌영역만 가진 경우는 
    elseif (#l_target == 1) then
        local target = l_target[1]
        local body_list = target:getBodyList()

        if (#body_list == 1) then
            bPass = true
        end
    end

    if (not bPass) then
        -- 최적의 위치를 찾아서 인디케이터 정보를 설정(확정 대상을 포함한 최대한 많은 대상)
        if (is_arena) then
            if (self:optimizeIndicatorDataByArena(l_target)) then
                return true
            end
        else
            if (self:optimizeIndicatorData(l_target, fixed_target)) then
                return true
            end
        end
    end

    -- 최적의 대상을 얻고 그 대상을 기준으로 인디케이터 정보 설정
    local target = self:getBestTargetForAuto(l_target, fixed_target)
    if (target) then
        self:setIndicatorDataByChar(target)
        return true
    end
    
    return false
end

-------------------------------------
-- function optimizeIndicatorData
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator:optimizeIndicatorData(l_target, fixed_target)
    -- 자식 클래스에서 개별로 정의
    return false
end

-------------------------------------
-- function optimizeIndicatorDataByArena
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정(아레나)
-------------------------------------
function SkillIndicator:optimizeIndicatorDataByArena(l_target)
    -- 자식 클래스에서 개별로 정의
    return false
end

-------------------------------------
-- function getBestTargetForAuto
-- @brief l_target의 대상들 중에서 가장 많이 피격할 수 있는 경우의 대상을 가져옴
-------------------------------------
function SkillIndicator:getBestTargetForAuto(l_target, fixed_target)
    local max_count = -1
    local ret

    for _, target in ipairs(l_target) do
        self:setIndicatorDataByChar(target)

        local list = self.m_collisionList or {}
        local count = #list

        if (fixed_target) then
            if (not table.find(self.m_highlightList, fixed_target)) then
                count = -1
            end
        end
        
        if (max_count < count) then
            max_count = count
            ret = target

            if (max_count == #l_target) then break end
        end
    end

    return ret
end

-------------------------------------
-- function setIndicatorTouchPos
-------------------------------------
function SkillIndicator:setIndicatorTouchPos(x, y)
    if (self.m_indicatorTouchPosX == x and self.m_indicatorTouchPosY == y) then
        return
    end

    self.m_indicatorTouchPosX = x
    self.m_indicatorTouchPosY = y
    self.m_bDirty = true
end

-------------------------------------
-- function isExistTarget
-------------------------------------
function SkillIndicator:isExistTarget()
    if (not self.m_highlightList) then return false end

    return (#self.m_highlightList > 0)
end

-------------------------------------
-- function getCollisionCountByVirtualTest
-- @brief 인디케이터가 파라미터의 위치일때 선택될 피격지점 갯수를 리턴
-------------------------------------
function SkillIndicator:getCollisionCountByVirtualTest(x, y, fixed_target)
    self.m_targetChar = nil
    self.m_targetPosX = x
    self.m_targetPosY = y
    self.m_critical = nil
    self.m_bDirty = true

    self.m_collisionListByVirtualTest = {}

    local l_target = self:getTargetForVirtualTest() -- 타겟 리스트를 사용하지 않고 충돌리스트 수로 체크

    local list = self.m_collisionListByVirtualTest or {}
    local count = #list

    -- 반드시 포함되어야하는 타겟이 존재하는지 확인
    if (fixed_target) then
        if (not table.find(l_target, fixed_target)) then
            count = -1
        end
    end
        
    return count
end

-------------------------------------
-- function getTotalSortValueByVirtualTest
-- @brief 인디케이터가 파라미터의 위치일때 선택될 피격지점들의 소팅값 합을 리턴
-------------------------------------
function SkillIndicator:getTotalSortValueByVirtualTest(x, y)
    self.m_targetChar = nil
    self.m_targetPosX = x
    self.m_targetPosY = y
    self.m_critical = nil
    self.m_bDirty = true

    self.m_collisionListByVirtualTest = {}

    local l_target = self:getTargetForVirtualTest() -- 타겟 리스트를 사용하지 않고 충돌리스트 수로 체크

    local list = self.m_collisionListByVirtualTest or {}
    local count = #list
    local total_sort_value = 0

    for _, v in ipairs(list) do
        local target = v:getTarget()
        total_sort_value = total_sort_value + target.m_sortValue
    end

    return total_sort_value, count
end