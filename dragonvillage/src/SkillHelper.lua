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

	for i = 1, 5 do
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
    if (not effect) then
        return
    end

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
-- function makeEffect_withAttrAni
-- @breif 추가 이펙트 생성
-- @breif 통합형 애니메이션의 경우 애니메이션에 속성이 붙어있음 (ex) earth_idle
-- @breif 애니메이션중에 속성 애니메이션이 있다면 적용, 없다면 기본형을 적용
-------------------------------------
function SkillHelper:makeEffect_withAttrAni(world, res, x, y, ani_name, cb_function, attr)
	-- 리소스 없을시 탈출
	if (res == '') then return end
	
	local ani_name = ani_name or 'idle'

    -- 이팩트 생성
    local effect = MakeAnimator(res)
    if (not effect) then
        return
    end

    local ani_name = effect:getAniNameAttr(ani_name, attr)
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
-- function makeEffectOnView
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
        -- @yjkil 22.01.20. add_option_type_5를 추가하는 과정에서 add_option_type_3 후로 AI 스킬 우선 순위에 고려되지 않는 것을 파악하였으나
        -- 사이드 이펙트 확인에 시간이 필요하여 수정하지 않음
        for i = 1, 2 do
            local status_effect_type = t_skill['add_option_type_' .. i]
            if (status_effect_type and status_effect_type ~= '') then
                local t_status_effect = TableStatusEffect():get(status_effect_type)
                local category = t_status_effect['category']

                if (t_status_effect['type'] == 'dot_heal') then -- 회복
                    mAiAttr[SKILL_AI_ATTR__RECOVERY] = true
                
                elseif (string.find(t_status_effect['name'], 'cure')) then -- 해로운 효과 해제
                    mAiAttr[SKILL_AI_ATTR__DISPELL] = true
                
                -- 이로운 효과
                elseif (StatusEffectHelper:isHelpful(category) and not string.find(t_status_effect['type'], 'add_dmg')) then 
                    mAiAttr[SKILL_AI_ATTR__BUFF] = true
                
                -- 해로운 효과
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
-- function calcAiAtk
-------------------------------------
function SkillHelper:calcAiAtk(unit, t_skill)
    -- 공격수치 공식 : 드래곤의 기본 공격력 x 드래그 스킬의 (power_rate x hit x (req_mana+1))
    local aiAtk = unit:getBasicStat('atk') * t_skill['power_rate'] * t_skill['hit'] * (unit:getOriginSkillManaCost() + 1)
    return aiAtk
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
function SkillHelper:makePassiveSkillSpeech(unit, str)
    local world = unit.m_world
    local animatorWindow

    -- 말풍선
    if (unit.m_passiveWindowNode) then
        unit.m_passiveWindowNode:removeFromParent(true)
        unit.m_passiveWindowNode = nil
    end
        
    local animatorWindow animatorWindow = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    animatorWindow:setVisual('skill_gauge', 'bubble')
    animatorWindow:setRepeat(false)
    world:addChild3(animatorWindow.m_node, DEPTH_DRAGON_SPEECH)

    local duration = animatorWindow:getDuration()
    animatorWindow:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
        unit.m_passiveWindowNode = nil
    end), cc.RemoveSelf:create()))

    animatorWindow:scheduleUpdate(function()
        animatorWindow:setPosition(unit.pos['x'], unit.pos['y'] + 50)
    end)

    unit.m_passiveWindowNode = animatorWindow.m_node

    -- 대사
    if (unit.m_passiveTextLabel) then
        unit.m_passiveTextLabel:removeFromParent(true)
        unit.m_passiveTextLabel = nil
    end
    
    local font_scale_x, font_scale_y = Translate:getFontScaleRate()
    local speechLabel = cc.Label:createWithTTF(Str(str), Translate:getFontPath(), 24, 2)
    speechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	speechLabel:setDockPoint(cc.p(0, 0))
	speechLabel:setColor(cc.c3b(255, 255, 255))
    speechLabel:setScale(font_scale_x, font_scale_y)
    speechLabel:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    speechLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)

    world:addChild3(speechLabel, DEPTH_DRAGON_SPEECH_TEXT)

    speechLabel:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
        unit.m_passiveTextLabel = nil
    end), cc.RemoveSelf:create()))

    speechLabel:scheduleUpdateWithPriorityLua(function()
        speechLabel:setPosition(unit.pos['x'], unit.pos['y'] + 98)
    end, 0)

    unit.m_passiveTextLabel = speechLabel

    local size = speechLabel:getContentSize()
    if (size['width'] > 110) then
        animatorWindow:setScaleX(2)
    end
end

-------------------------------------
-- function getTargetToUseActiveSkill
-- @brief 해당 유닛의 액티브 스킬을 사용할 대상을 얻음
-------------------------------------
function SkillHelper:getTargetToUseActiveSkill(unit)
    local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
    if (not skill_indivisual_info) then return end

    local t_skill = skill_indivisual_info:getSkillTable()
    local target_type = t_skill['target_type']
	local target_count = t_skill['target_count']
    local target_formation = t_skill['target_formation']
    local ai_division = t_skill['ai_division']

    -- 대상을 찾는다
    local l_target = {}
    local fixed_target = nil

    -- 공격형
    if (string.find(target_type, 'enemy')) then
        l_target = unit:getTargetListByType(target_type, nil, target_formation)

    else
        -- AI 대상으로 변경
        target_type = SKILL_AI_ATTR_TARGET[ai_division]

        if (not target_type) then
            error('invalid ai_division : ' .. ai_division)
        end

        l_target = unit:getTargetListByType(target_type, nil, target_formation)
        fixed_target = l_target[1]
    end

    return l_target, fixed_target
end

-------------------------------------
-- function setIndicatorDataByAuto
-- @brief 해당 유닛의 자동 액티브 스킬을 위한 인디케이터 정보 설정
-------------------------------------
function SkillHelper:setIndicatorDataByAuto(unit, is_arena, input_type)
    local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
    if (not skill_indivisual_info) then return false end

    local t_skill = skill_indivisual_info:getSkillTable()
    local target_type = t_skill['target_type']
    local target_count = t_skill['target_count']
    local target_formation = t_skill['target_formation']
    local ai_type = t_skill['ai_type']

    -- 대상을 찾는다
    local l_target = {}
    local fixed_target = nil
    
    -- 공격형
    if (string.find(target_type, 'enemy')) then
        if (is_arena) then
            l_target = unit:getTargetListByType('enemy_arena_attack', nil, target_formation, {
                ai_type = ai_type,
                input_type = input_type
            })
            fixed_target = l_target[1]
        else
            l_target, fixed_target = self:getTargetToUseActiveSkill(unit)
        end

    -- 회복형
    else
        l_target = unit:getTargetListByType('ally_arena_heal', nil, target_formation, {
            ai_type = ai_type,
            input_type = input_type
        })
        fixed_target = l_target[1]

        -- 회복형일 경우 모든 모드에서 아레나와 동일하게 처리
        is_arena = true
    end

    -- 대상을 못찾은 경우
    if (#l_target == 0) then return false end

    -- 인디케이터 정보를 설정
    return unit:getSkillIndicator():setIndicatorDataByAuto(l_target, target_count, fixed_target, is_arena)
end

-------------------------------------
-- function getValidSkillIdFromKey
-- @brief 해당 유닛이 가진 스킬 중 key 조건에 해당하는 스킬의 아이디 리스트를 반환
-- !!18/06/27 
-- 스킬 아이디값이 아닌 경우는 char table의 아이디의 스킬을 기준으로 조건을 체크하고
-- 변신 전후 스킬 아이디를 모두 반환
-------------------------------------
function SkillHelper:getValidSkillIdFromKey(unit, key)
    local skill_id
    local metamorphosis_skill_id
    local char_table = unit:getCharTable()
    local temp = char_table[key]

    -- 특수한 조건을 먼저 검사
    if (string.find(key, 'req_mana_')) then
        -- 필요 마나 수에 해당하는 스킬만 가져옴(액티브만 해당)
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if (skill_indivisual_info) then
            local req_mana = tonumber(string.match(key, '%d'))
            if (unit:isDragon() and unit:getOriginSkillManaCost() == req_mana) then
                skill_id = skill_indivisual_info:getSkillID()
                metamorphosis_skill_id = skill_indivisual_info.m_tSkill['metamorphosis']
            end
        end

    elseif (key == 'skill_active') then
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if (skill_indivisual_info) then
            skill_id = skill_indivisual_info:getSkillID()
            metamorphosis_skill_id = skill_indivisual_info.m_tSkill['metamorphosis']
        end

    elseif (temp) then
        -- key의 이름으로된 칼럼이 존재하는 경우 해당 값을 사용
        skill_id = temp

        local skill_indivisual_info = unit:findSkillInfoByID(skill_id)
        if (skill_indivisual_info) then
            metamorphosis_skill_id = skill_indivisual_info.m_tSkill['metamorphosis']
        end
    else
        -- 그 이외에는 key값이 스킬 아이디로 사용된 것으로 처리
        skill_id = tonumber(key)

    end

    return skill_id, metamorphosis_skill_id
end

-------------------------------------
-- function makeIndicator
-- @brief 인디케이터를 생성
-------------------------------------
function SkillHelper:makeIndicator(unit, t_skill)
    local indicator_type = t_skill['indicator']
    local indicator
		
	-- 타겟형(아군)
	if (indicator_type == 'target_ally') then
		indicator = SkillIndicator_Target(unit, t_skill, false)

	-- 타겟형(적군)
	elseif (indicator_type == 'target') then
		indicator = SkillIndicator_Target(unit, t_skill, true)

	-- 원형 범위
	elseif (indicator_type == 'round') then
		indicator = SkillIndicator_AoERound(unit, t_skill, false)

	-- 원점 기준 원뿔형
	elseif (indicator_type == 'wedge') then
		indicator = SkillIndicator_AoEWedge(unit, t_skill)

	-- 부채꼴 범위
	elseif (indicator_type == 'target_cone') then
		indicator = SkillIndicator_AoECone(unit, t_skill)

	-- 레이저
	elseif (indicator_type == 'bar') then
		indicator = SkillIndicator_Laser(unit, t_skill)
	
	-- 세로로 긴 직사각형
    elseif (indicator_type == 'square_height' or indicator_type == 'square_height_bottom') then
		indicator = SkillIndicator_AoESquare_Height(unit, t_skill)

    elseif (indicator_type == 'square_height_top') then
        indicator = SkillIndicator_AoESquare_Height_Top(unit, t_skill)

    elseif (indicator_type == 'square_height_touch') then
        indicator = SkillIndicator_AoESquare_Height_Touch(unit, t_skill)
	
    -- 굵은 가로형 직사각형
    elseif (indicator_type == 'square_width' or indicator_type == 'square_width_left') then
		indicator = SkillIndicator_AoESquare_Width(unit, t_skill, true)
    
    -- 굵은 가로형 직사각형(오른쪽 기준)
    elseif (indicator_type == 'square_width_right') then
        indicator = SkillIndicator_AoESquare_Width_Right(unit, t_skill, true)

    -- 굵은 가로형 직사각형(터치 기준)
    elseif (indicator_type == 'square_width_touch') then
        indicator = SkillIndicator_AoESquare_Width_Touch(unit, t_skill, true)
    
	-- 여러 다발의 관통형
	elseif (indicator_type == 'penetration') then
		indicator = SkillIndicator_Penetration(unit, t_skill)

	------------------ 특수한 인디케이터들 ------------------

	-- 리프블레이드 (리프드래곤)
	elseif (indicator_type == 'curve_twin') then
		indicator = SkillIndicator_LeafBlade(unit, t_skill)

	-- 볼테스X (볼테스X)
	elseif (indicator_type == 'voltes_x') then
		indicator = SkillIndicator_X(unit, t_skill, true)

	-- 여러다발의 직사각형 (원더)
    elseif (indicator_type == 'square_multi') then
		indicator = SkillIndicator_AoESquare_Multi(unit, t_skill)

    elseif (indicator_type == 'cross') then
        indicator = SkillIndicator_Cross(unit, t_skill)
	-- 미정의 인디케이터
	else
		indicator = SkillIndicator_Target(unit, t_skill, false)
		cclog('###############################################')
		cclog('## 인디케이터 정의 되지 않은 스킬 : ' .. indicator_type)
		cclog('###############################################')
	end

    return indicator
end

-------------------------------------
-- function isTeamBonusSkill
-------------------------------------
function SkillHelper:isTeamBonusSkill(skill_id)
    local key = math_floor(skill_id / 100000)
    return (key == 4)
end

-------------------------------------
-- function isAncientRuneSetSkill
-------------------------------------
function SkillHelper:isAncientRuneSetSkill(skill_id)
    local key = math_floor(skill_id / 100000)
    return (key == 5)
end