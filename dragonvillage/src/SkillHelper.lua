-------------------------------------
-- table SkillHelper
-- @brief 스킬 사용에 전역적으로 필요한 함수 모음
-------------------------------------
SkillHelper = {}

-------------------------------------
-- function getAttributeRes
-- @brief 스킬에서 사용할 리소스 경로를 만들어 반환하는데 객체 생성전에 사용되므로 주의
-------------------------------------
function SkillHelper:getAttributeRes(res, owner)
	if (not res) then 
		error('비어있는 스킬 리소스 문자열')
	elseif (res == 'x') or (res == '') then
		return nil
	else
		return string.gsub(res, '@', owner:getAttributeForRes())
	end
end

-------------------------------------
-- function getValid
-- @brief 데이터 적합성을 간단하게 체크하고 ('') 아니라면 지정된 기본값 반환
-------------------------------------
function SkillHelper:getValid(value, default)
	if (not value) then 
		return default
	elseif (value == '') then
		return default
	else
		return value
	end
end

-------------------------------------
-- function isEnemyTargetingType
-- @brief 적을 대상으로 하는 스킬인지 여부
-------------------------------------
function SkillHelper:isEnemyTargetingType(t_skill)
    if (string.find(t_skill['target_type'], 'enemy')) then
        return true
    end

    return false
end

-------------------------------------
-- function makeStructStatusEffectList
-------------------------------------
function SkillHelper:makeStructStatusEffectList(t_skill)
	local l_ret = {}

	for i = 1, 4 do
        local type = t_skill['add_option_type_' .. i]
		if (type and type ~= '') then
			local struct_status_effect = StructStatusEffect({
				type = t_skill['add_option_type_' .. i],
				target_type = t_skill['add_option_target_' .. i],
				target_count = t_skill['add_option_target_count_' .. i],
				trigger = t_skill['add_option_trigger_' .. i],
				duration = t_skill['add_option_time_' .. i],
				rate = t_skill['add_option_rate_' .. i],
				value = t_skill['add_option_value_' .. i],
                source = t_skill['add_option_source_' .. i],
			})
			table.insert(l_ret, struct_status_effect)
		end
	end

	return l_ret
end

-------------------------------------
-- function calculatePositionX
-- @brief 주어진 x를 기준으로 지정된 간격의 n개의 좌표를 구한다.
-------------------------------------
function SkillHelper:calculatePositionX(line_cnt, space, pos_x)
    local pos_x = pos_x
	local space = space
	local line_cnt = line_cnt
	
	local l_ret = {}
	local half = math_floor(line_cnt/2)

	-- 홀수
	if ((line_cnt % 2) == 1) then
		-- 중앙값
		table.insert(l_ret, pos_x)
		-- 좌우값
		for i = 1, half do
			table.insert(l_ret, pos_x + (space * i))
			table.insert(l_ret, pos_x - (space * i))
		end
	-- 짝수
	else
		-- 좌우값
		for i = 1, half do
			table.insert(l_ret, pos_x + (space * (i - 1 + 0.5)))
			table.insert(l_ret, pos_x - (space * (i - 1 + 0.5)))
		end
	end

	return l_ret
end

-------------------------------------
-- function makeEffect
-- @breif 추가 이펙트 생성
-------------------------------------
function SkillHelper:makeEffect(world, res, x, y, ani_name, cb_function)
	-- 리소스 없을시 탈출
	if (res == '') then return end
	
	local ani_name = ani_name or 'idle'

    -- 이팩트 생성
    local effect = MakeAnimator(res)
    effect:setPosition(x, y)
	effect:changeAni(ani_name, false)

    local missileNode = world:getMissileNode()
    missileNode:addChild(effect.m_node, 0)

	-- 1회 재생후 동작
	local cb_ani = function() 
		if (cb_function) then 
			cb_function(effect)
		end
		effect.m_node:runAction(cc.RemoveSelf:create())
	end
	effect:addAniHandler(cb_ani)

	return effect
end

-------------------------------------
-- function makeEffect
-- @breif 좌표값에 영향을 안받는 레이어 수준에 이텍트 생성
-------------------------------------
function SkillHelper:makeEffectOnView(res, ani_name, cb_function)
	-- 리소스 없을시 탈출
	if (res == '') then return end
	
	local ani_name = ani_name or 'idle'

    -- 이팩트 생성
    local effect = MakeAnimator(res)
	effect:changeAni(ani_name, false)

	-- 1회 재생후 동작
	local cb_ani = function() 
		if (cb_function) then 
			cb_function(effect)
		end
		effect.m_node:runAction(cc.RemoveSelf:create())
	end
	effect:addAniHandler(cb_ani)

    g_gameScene.m_viewLayer:addChild(effect.m_node, 0)
	
	return effect
end

-------------------------------------
-- function getSizeAndScale
-------------------------------------
function SkillHelper:getSizeAndScale(size_type, skill_size)    
	local std_size = g_constant:get('INDICATOR', 'INDICATOR_RES_SIZE', size_type)
	local t_size = g_constant:get('INDICATOR', 'INDICATOR_SIZE', size_type)
	local size = t_size[skill_size]
	local scale
	if (std_size) then
		scale = size/std_size
	else
		scale = 1
	end

	return {size = size, scale = scale}
end

-------------------------------------
-- function makeAiAttrMap
-------------------------------------
function SkillHelper:makeAiAttrMap(t_skill)
    local mAiAttr = {}

    -- 스킬 테이블의 skill_type 칼럼값을 체크
	if (string.find(t_skill['skill_type'], 'heal')) then
        mAiAttr[SKILL_AI_ATTR__HEAL] = true

    elseif (string.find(t_skill['skill_type'], 'guardian')) then
        mAiAttr[SKILL_AI_ATTR__GUARDIAN] = true

    elseif (t_skill['skill_type'] ~= 'status_effect') then
        mAiAttr[SKILL_AI_ATTR__ATTACK] = true

    else
        -- 스킬 테이블의 add_option을 체크
        for i = 1, 2 do
            local status_effect_type = t_skill['add_option_type_' .. i]
            if (status_effect_type and status_effect_type ~= '') then
                local t_status_effect = TableStatusEffect():get(status_effect_type)
                local category = t_status_effect['category']

                if (t_status_effect['type'] == 'dot_heal') then
                    mAiAttr[SKILL_AI_ATTR__RECOVERY] = true
                
                elseif (string.find(t_status_effect['name'], 'cure')) then
                    mAiAttr[SKILL_AI_ATTR__DISPELL] = true
                
                elseif (StatusEffectHelper:isHelpful(category) and not string.find(t_status_effect['type'], 'add_dmg')) then
                    mAiAttr[SKILL_AI_ATTR__BUFF] = true
                
                elseif (StatusEffectHelper:isHarmful(category)) then
                    mAiAttr[SKILL_AI_ATTR__DEBUFF] = true
                end
            end
        end
    end

    if (table.count(mAiAttr) == 0) then
        mAiAttr[SKILL_AI_ATTR__ATTACK] = true
    end

    return mAiAttr
end

-------------------------------------
-- function printTargetNotExist
-- @brief
-------------------------------------
function SkillHelper:printTargetNotExist(skill)
	cclog('###########################################')
	cclog('-- 타겟을 못 찾았습니다')
	cclog('STATE NAME : ' .. skill.m_state)
	cclog('SKILL CASTER : ' ..  skill.m_owner:getName())
	cclog('SKILL TYPE : ' ..  skill.m_skillName)
	cclog('-------------------------------------------')
end

-------------------------------------
-- function printAttackInfo
-------------------------------------
function SkillHelper:printAttackInfo(attacker, defender, attack_type, atk_dmg, def_pwr, damage)
    local attack_activity_carrier = attacker.m_activityCarrier
    local attacker_char = attack_activity_carrier:getActivityOwner()
    if (not attacker_char) then return end

	cclog('######################################################')
	cclog('공격자 : ' .. attacker_char:getName())
	cclog('방어자 : ' .. defender:getName())
	cclog('공격 타입 : ' .. attack_type)
    cclog('--공격력 : ' .. atk_dmg)
	cclog('--방어력 : ' .. def_pwr)
	cclog('--데미지 : ' .. damage)
	cclog('------------------------------------------------------')
end

-------------------------------------
-- function makePassiveSkillSpeech
-- @brief 드래곤 패시브 스킬 발동시 말풍선을 생성
-------------------------------------
function SkillHelper:makePassiveSkillSpeech(dragon, str)
    local animatorWindow = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    animatorWindow:setVisual('skill_gauge', 'bubble')
    animatorWindow:setRepeat(false)
    animatorWindow:setPosition(0, 50)
    dragon:getDragonSpeechNode():addChild(animatorWindow.m_node, 10)

    local duration = animatorWindow:getDuration()
    animatorWindow:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

    -- 대사
    do
        local font_scale_x, font_scale_y = Translate:getFontScaleRate()
        self.m_speechLabel = cc.Label:createWithTTF(Str(str), Translate:getFontPath(), 24, 2)
        self.m_speechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	    self.m_speechLabel:setDockPoint(cc.p(0, 0))
	    self.m_speechLabel:setColor(cc.c3b(255, 255, 255))
        self.m_speechLabel:setScale(font_scale_x, font_scale_y)
        self.m_speechLabel:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        self.m_speechLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)

        local socketNode = animatorWindow.m_node:getSocketNode('skill_bubble')
        socketNode:addChild(self.m_speechLabel, 1)

        local size = self.m_speechLabel:getContentSize()
        if (size['width'] > 110) then
            animatorWindow:setScaleX(2)
            self.m_speechLabel:setScaleX(0.5 * font_scale_x)
        end
        
    end
end

-------------------------------------
-- function prepareActiveSkillByAuto
-- @brief 해당 유닛의 자동 액티브 스킬을 위한 인디케이터 정보 설정
-------------------------------------
function SkillHelper:setIndicatorDataByAuto(unit)
    local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
    if (not skill_indivisual_info) then return false end

    local t_skill = skill_indivisual_info:getSkillTable()
    local target_type = t_skill['target_type']
	local target_count = nil
    local target_formation = t_skill['target_formation']
    local ai_division = t_skill['ai_division']

    -- 대상을 찾는다
    local l_target = {}
    local fixed_target = nil

    -- 공격형
    if (string.find(target_type, 'enemy')) then
        l_target = unit:getTargetListByType(target_type, target_count, target_formation)

    else
        -- AI 대상으로 변경
        target_type = SKILL_AI_ATTR_TARGET[ai_division]

        if (not target_type) then
            error('invalid ai_division : ' .. ai_division)
        end

        l_target = unit:getTargetListByType(target_type, target_count, target_formation)
        fixed_target = l_target[1]
    end

    -- 대상을 못찾은 경우
    if (#l_target == 0) then return false end

    -- 인디케이터 정보를 설정
    return unit.m_skillIndicator:setIndicatorDataByAuto(l_target, fixed_target)
end