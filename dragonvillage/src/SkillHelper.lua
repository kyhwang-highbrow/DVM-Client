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
-- function makeStructStatusEffectList
-------------------------------------
function SkillHelper:makeStructStatusEffectList(t_skill)
	local l_ret = {}

	for i = 1, 2 do
		if (t_skill['add_option_type_' .. i] ~= '') then
			local struct_status_effect = StructStatusEffect({
				type = t_skill['add_option_type_' .. i],
				target_type = t_skill['add_option_target_' .. i],
				trigger = t_skill['add_option_trigger_' .. i],
				duration = t_skill['add_option_time_' .. i],
				rate = t_skill['add_option_rate_' .. i],
				value1 = t_skill['add_option_value_' .. i],
				value2 = t_skill['add_option_value2_' .. i]
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
-- function getSizeAndScale
-------------------------------------
function SkillHelper:getSizeAndScale(size_type, skill_size)    
	local t_size = g_constant:get('INDICATOR', 'INDICATOR_SIZE', size_type)
	local size = t_size[skill_size]
	local std_size = t_size[3]

	return {size = size, scale = (size/std_size)}
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
-- function makePassiveSkillSpeech
-- @brief 드래곤 패시브 스킬 발동시 말풍선을 생성
-------------------------------------
function SkillHelper:makePassiveSkillSpeech(dragon, str)
    local animatorWindow = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    animatorWindow:setVisual('skill_gauge', 'bubble')
    animatorWindow:setRepeat(false)
    animatorWindow:setPosition(0, 50)
    dragon.m_unitInfoNode:addChild(animatorWindow.m_node, 10)

    local duration = animatorWindow:getDuration()
    animatorWindow:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

    -- 대사
    do
        self.m_speechLabel = cc.Label:createWithTTF(str, 'res/font/common_font_01.ttf', 24, 0, cc.size(340, 100), 1, 1)
        self.m_speechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	    self.m_speechLabel:setDockPoint(cc.p(0, 0))
	    self.m_speechLabel:setColor(cc.c3b(255, 255, 255))

        local socketNode = animatorWindow.m_node:getSocketNode('skill_bubble')
        socketNode:addChild(self.m_speechLabel, 1)
    end
end

-------------------------------------
-- function getDragonActiveSkillBonusInfo
-------------------------------------
function SkillHelper:getDragonActiveSkillBonusInfo(dragon)
    local t_dragon = dragon.m_charTable
    local role_type = t_dragon['role']

    local status_effect_type
    local status_effect_time
    local status_effect_value

    if (role_type == 'tanker') then
        status_effect_type = 'feedback_defender'
        status_effect_time = 5
        status_effect_value = 10
        
    elseif (role_type == 'dealer') then
        status_effect_type = 'feedback_attacker'
        status_effect_time = 8
        status_effect_value = 10

    elseif (role_type == 'supporter') then
        status_effect_type = 'feedback_supporter'
        status_effect_time = 0
        status_effect_value = 10
                
    elseif (role_type == 'healer') then
        status_effect_type = 'feedback_healer'
        status_effect_time = 0
        status_effect_value = 20

    else
        return nil

    end

    local t_ret = {
        role_type = role_type,
        type = status_effect_type,
        time = status_effect_time,
        value = status_effect_value
    }

    return t_ret
end

-------------------------------------
-- function getDragonActiveSkillBonusDesc
-------------------------------------
function SkillHelper:getDragonActiveSkillBonusDesc(dragon)
    local desc = ''

    local t_info = self:getDragonActiveSkillBonusInfo(dragon)
    local table_status_effect = TABLE:get('status_effect')
    local t_status_effect = table_status_effect[t_info['type']]
    if (t_status_effect) then
        desc = t_status_effect['t_name']
    end

    return desc
end

-------------------------------------
-- function getDragonActiveSkillBonusLevel
-- @brief 해당 스킬 타겟수 점수(%)에 해당하는 보너스 등급을 리턴(0이면 보너스 없음)
-------------------------------------
function SkillHelper:getDragonActiveSkillBonusLevel(t_skill, score)
    local t_temp = g_constant:get('INDICATOR', 'DRAGON_SKILL_ACTIVE_INDICATOR_BONUS')
    local t_data = t_temp[t_skill['indicator']]
    if (not t_data) then
        t_data = t_temp['default']
    end

    if (score >= t_data[1]) then
        return 1
    end
    return 0
end

-------------------------------------
-- function makeDragonActiveSkillBonus
-- @brief 드래곤 드래그 스킬 사용시 직군별 보너스 부여
-------------------------------------
function SkillHelper:invokeDragonActiveSkillBonus(dragon, bonus_level)
    if (bonus_level == 0) then return end

    local t_info = self:getDragonActiveSkillBonusInfo(dragon)
    if (not t_info) then return end

    local status_effect_type    = t_info['type']
    local status_effect_time    = t_info['time']
    local status_effect_value   = t_info['value']
        
    -- 스테이터스 이펙트 적용
	local struct_status_effect = StructStatusEffect({
		type = status_effect_type,
		target_type = 'self',
		trigger = 'skill_end',
		duration = status_effect_time,
		rate = 100,
		value1 = status_effect_value,
		value2 = 0
	})
    if (struct_status_effect) then
        StatusEffectHelper:doStatusEffectByStruct(dragon, {dragon}, {struct_status_effect})
    end

    -- 연출 이펙트
    --[[
    local table_status_effect = TABLE:get('status_effect')
    local t_status_effect = table_status_effect[status_effect_type]
    
    self:makeDragonActiveSkillBonusEffect(dragon, bonus_level, t_status_effect['t_name'])
    ]]--
end

-------------------------------------
-- function makeDragonActiveSkillBonusEffect
-- @brief 드래곤 드래그 스킬 피드백(보너스) 이펙트 출력
-------------------------------------
function SkillHelper:makeDragonActiveSkillBonusEffect(dragon, level, text)
    local str

    if (level == 1) then        str = 'good'
    elseif (level == 2) then    str = 'great'
    else return
    end

    local world = dragon.m_world
    local effect = MakeAnimator('res/effect/skill_decision/skill_decision.vrp')
    effect:setPosition(dragon.pos.x, dragon.pos.y + 100)
    effect:setScale(0.3)
    effect:changeAni(str .. '_appear', false)
    effect:addAniHandler(function()
        effect:changeAni(str .. '_idle', false)
        effect:addAniHandler(function()
            effect:changeAni(str .. '_disappear', false)
            local duration = effect:getDuration()
            effect:runAction(cc.Sequence:create(
                cc.DelayTime:create(duration),
                cc.RemoveSelf:create()
            ))

            -- 발동된 패시브의 연출을 위해 world에 발동된 passive정보를 저장
			if (not world.m_mPassiveEffect[dragon]) then
				world.m_mPassiveEffect[dragon] = {}
			end
			world.m_mPassiveEffect[dragon][text] = true
        end)
    end)

    dragon.m_world.m_worldNode:addChild(effect.m_node, WORLD_Z_ORDER.SE_EFFECT)
    
    return effect
end