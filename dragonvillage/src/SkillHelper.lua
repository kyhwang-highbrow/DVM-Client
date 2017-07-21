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
	cclog('######################################################')
	cclog('공격자 : ' .. attacker:getName())
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
        self.m_speechLabel = cc.Label:createWithTTF(str, 'res/font/common_font_01.ttf', 24, 0, cc.size(340, 100), 1, 1)
        self.m_speechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	    self.m_speechLabel:setDockPoint(cc.p(0, 0))
	    self.m_speechLabel:setColor(cc.c3b(255, 255, 255))

        local socketNode = animatorWindow.m_node:getSocketNode('skill_bubble')
        socketNode:addChild(self.m_speechLabel, 1)
    end
end