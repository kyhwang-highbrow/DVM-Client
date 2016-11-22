-------------------------------------
-- function doSkill
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill(skill_id, attr, x, y, t_data)
	
    ----------------------------------------------
    --[[
    if (self.m_charType == 'enemy' ) then
        --skill_id = 220031
    else
        --cclog('self.phys_idx ' .. self.phys_idx)
        if (self.phys_idx == 1) then
            skill_id = 220091
        end
    end
    --]]
    -----------------------------------------------

    local x = x or self.m_attackOffsetX or 0
    local y = y or self.m_attackOffsetY or 0
	local t_data = t_data or {}

    local is_hero = true
    local phys_group = 'missile_h'
    local attr = attr or self.m_charTable['attr'] or self.m_charTable['attr_1']
	local t_skill = nil

    -- 캐릭터 유형별 변수 정리(dragon or enemy)
    if (self.m_charType == 'dragon') then
        is_hero = true
        phys_group = 'missile_h'
		-- @TODO 스킬 레벨이 반영된 테이블 정보 가져옴
		t_skill = self:getLevelingSkillById(skill_id)
    elseif (self.m_charType == 'enemy') then
        is_hero = false
        phys_group = 'missile_e'
		local table_skill = TABLE:get(self.m_charType .. '_skill')
		t_skill = table_skill[skill_id]
    else
        error()
    end

	-- 스킬 테이블 체크
    if (not t_skill) then
        error('ID '.. tostring(skill_id) ..' 에 해당하는 스킬 테이블이 없습니다')
    end

    self:checkTarget(t_skill)

    if (not self.m_targetChar) then
        return false
    end

    if (not t_skill) then
        cclog('# 존재하지 않는 스킬 ID : ' .. skill_id)
        error()
    end

    local type = t_skill['type']
    local skill_form = t_skill['skill_form']
    local chance_type = t_skill['chance_type']

    ----------------------------------------------
    if (chance_type == 'passive') then 
	    if (type == 'skill_shield') then
            SkillShield:makeSkillInstance(self, t_skill, t_data)
            return true
		else
			local char = self
			local t_skill = t_skill
			return StatusEffectHelper:invokePassive(char, t_skill)
		end

	elseif (chance_type == 'trigger') then
		local char = self
        local t_skill = t_skill
		return StatusEffectHelper:setTriggerPassive(char, t_skill)

    -- 탄막 공격 (스크립트에서 읽어와 미사일 탄막 생성)
    elseif (skill_form == 'script') then
        self:do_script_shot(t_skill, attr, is_hero, phys_group, x, y, t_data)
        return true

    -- 상태 효과
    elseif (skill_form == 'status_effect') then
        -- 1. skill의 타겟룰로 상태효과의 대상 리스트를 얻어옴
	    local l_target = self:getTargetList(t_skill)

		-- 2. 상태효과 문자열(;로 구분)
		local status_effect_str = {t_skill['status_effect_1'], t_skill['status_effect_2']}

        -- 3. 타겟에 상태효과생성
		StatusEffectHelper:doStatusEffectByStr(self, l_target, status_effect_str)
        return true

    -- 코드형 스킬
    elseif (skill_form == 'code') then

		-- 공용탄 영역
        if (type == 'missile_move_ray') then
            SkillRay:makeSkillInstance(self, t_skill, {})
            return true
		elseif (type == 'missile_move_straight') then
			CommonMissile_Straight:makeMissileInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_cruise') then
            CommonMissile_Cruise:makeMissileInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_shotgun') then
            CommonMissile_Shotgun:makeMissileInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_release') then
            CommonMissile_Release:makeMissileInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_high_angle') then
            CommonMissile_High:makeMissileInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_bounce') then
            CommonMissile_Bounce:makeMissileInstance(self, t_skill)
            return true

		-- 스킬 영역

		-- 패시브 스킬
        elseif (type == 'skill_react_armor') then
            self:doSkill_counteratk(t_skill, is_hero, phys_group, x, y, t_data)
            return true


		-- 구조 개선 후 ----------------------------------------------------

        elseif (type == 'skill_curve_twin') then
            SkillLeafBlade:makeSkillInstance(self, t_skill, t_data)
            return true

		elseif (type == 'skill_aoe_round') then
            SkillAoERound:makeSkillInstance(self, t_skill, t_data)
            return true

		elseif (type == 'skill_conic') then
            SkillConicAtk:makeSkillInstance(self, t_skill, t_data)
			return true

		elseif (type == 'skill_aoe_cone_spread') then
            SkillConicAtk_Spread:makeSkillInstance(self, t_skill, t_data)
			return true

		elseif (type == 'skill_aoe_round_jump') then
            SkillExplosion:makeSkillInstance(self, t_skill, t_data)
			return true

		elseif (type == 'skill_strike_finish_spread') then
            SkillRolling:makeSkillInstance(self, t_skill, t_data)
			return true

		elseif string.find(type, 'skill_buff') then
            SkillDrawBuff:makeSkillInstance(self, t_skill, t_data)
			return true

	    elseif (type == 'skill_counterattack') then
            SkillCounterAttack:makeSkillInstance(self, t_skill, t_data)
            return true
            
		elseif (type == 'skill_melee_atk') then
			if isExistValue(skill_id, 210982, 210112, 210212) then -- 램곤, 애플칙, 붐버
				SkillMeleeHack_Specific:makeSkillInstance(self, t_skill, t_data)
			else
				SkillMeleeHack:makeSkillInstance(self, t_skill, t_data)
			end
            return true

        elseif (type == 'skill_protection') then
            SkillProtection:makeSkillInstance(self, t_skill, t_data)
            return true

        elseif (type == 'skill_aoe_square_heal_dmg') then
			SkillHealingWind:makeSkillInstance(self, t_skill, t_data)
            return true
		
		elseif (type == 'skill_crash') then
			SkillCrash:makeSkillInstance(self, t_skill, t_data)
            return true

        elseif (type == 'skill_laser') then
            SkillLaser:makeSkillInstance(self, t_skill, t_data) 
            return true

		elseif (type == 'skill_dispel_harm') then
            SkillDispelMagic:makeSkillInstance(self, t_skill, t_data)
            return true

        elseif (type == 'skill_heal_single') then
			SkillHealSingle:makeSkillInstance(self, t_skill, t_data)
            return true

		elseif (type == 'skill_heal_around') then
            SkillHealAround:makeSkillInstance(self, t_skill, t_data)
            return true

        elseif (type == 'skill_protection_spread') then -- 파워드래곤 스킬 '수호'
            SkillGuardian:makeSkillInstance(self, t_skill, t_data)
            return true


		-- 특수 스킬들
		elseif (type == 'skill_summon') then
            return SkillSummon:makeSkillInstance(self, t_skill, t_data)

        end
    end

	cclog('미구현 코드 스킬 : ' .. type)
    return false
end

-------------------------------------
-- function do_script_shot
-- @brief 스크립트 탄막 실행 
-------------------------------------
function Character:do_script_shot(t_skill, attr, is_hero, phys_group, x, y, t_data)
	
    local start_x = self.pos.x + x
    local start_y = self.pos.y + y

    -- 미사일 런쳐 (target, dir, left or right)
    local missile_launcher = MissileLauncher(nil)
    local t_launcher_option = missile_launcher:getOptionTable()

    -- 비주얼명 지정
    t_launcher_option['attr_name'] = attr

    -- 타겟이 있을 경우
    if self.m_targetChar then
        -- 브레스일 경우
        if isExistValue(t_skill['type'], 'skill_breath_1', 'skill_breath_2', 'skill_breath_3') then
            if t_data['dir'] then
                t_launcher_option['dir'] = t_data['dir']
            else
                t_launcher_option['dir'] = self:getBreathDegree(start_x, start_y, phys_group)
            end
        else
            -- 타겟 지정
            t_launcher_option['target'] = self.m_targetChar
        end
	else
		-- 타겟 지정
		self:checkTarget(t_skill)
        t_launcher_option['target'] = self.m_targetChar
    end

	-- 각도 지정
	if (not t_launcher_option['dir']) then
        local degree = getDegree(start_x, start_y, self.m_targetChar.pos.x, self.m_targetChar.pos.y)
        t_launcher_option['dir'] = degree
	end

    if is_hero then
        t_launcher_option['target_pos'] = {start_x + 500, start_y}
    else
        t_launcher_option['target_pos'] = {start_x - 500, start_y}
    end

    -- AttackDamage 생성
    local activity_carrier = self:makeAttackDamageInstance(t_skill['sid'])
    activity_carrier:insertStatusEffectRate({t_skill['status_effect_1'], t_skill['status_effect_2']})

    missile_launcher.m_bHeroMissile = is_hero
    self.m_world:addToUnitList(missile_launcher)
    self.m_world.m_worldNode:addChild(missile_launcher.m_rootNode)
    missile_launcher:init_missileLauncher(t_skill, phys_group, activity_carrier, 1)
    missile_launcher.m_animator:changeAni('animation', true)
    missile_launcher:setPosition(start_x, start_y)

    -- 미사일의 파워 비율
    missile_launcher.m_powerRate = (t_skill['power_rate'] / 100)

    -- 스킬 방향 지정
    local skill_dir = tonumber(t_skill['dir'])
    if skill_dir then
        -- -1 : 타겟 방향으로 발사
        if (skill_dir == -1) then
            -- 위쪽 코드에서 타겟 방향으로 dir를 지정했음

        -- -2 : 진형에 따라 0 or 180으로 발사
        elseif (skill_dir == -2) then
            if self.m_bLeftFormation then
                t_launcher_option['dir'] = 0
            else
                t_launcher_option['dir'] = 180
            end

        -- 0~360 : 해당 각도로 발사
        elseif (0 <= skill_dir and skill_dir <= 360) then
            t_launcher_option['dir'] = skill_dir
        end
    end
end

-------------------------------------
-- function doSkill_counteratk
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_counteratk(t_skill, is_hero, phys_group, x, y, t_data)

    local skill = SkillAttributeAmor(nil)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 3)
    self.m_world:addToSkillList(skill)

    local pos_x = self.pos.x + x
    local pos_y = self.pos.y + y

    skill:setPosition(pos_x, pos_y)

    skill:init_skill(self, res, x, y, t_skill, t_data)
end

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------


-------------------------------------
-- function getBreathDegree
-- @brief 브레스 발사 시, 가장 적을 많이 맞출 수 있는 각도
-------------------------------------
function Character:getBreathDegree(x, y, phys_group)

    local start_dir = nil
    local end_dir = nil
    local interval = 5
    local ret_dir = nil

    -- 진형별 각도 체크
    if self.m_bLeftFormation then
        ret_dir = 0
        start_dir = -45
        end_dir = 45
    else
        ret_dir = 180
        start_dir = 135
        end_dir = 225
    end


    local max_count = nil
    local dir_list = nil
    for dir=start_dir, end_dir, interval do
        local end_pos = getPointFromAngleAndDistance(dir, 3000)

        -- 레이저에 충돌된 모든 객체 리턴
        local l_collision_obj = self.m_world.m_physWorld:getLaserCollision(x, y, x+end_pos['x'], y+end_pos['y'], 30, phys_group)

        local count = #l_collision_obj

        if (count > 0) then
            if (not max_count) then
                max_count = count
                ret_dir = dir
                dir_list = {}
                table.insert(dir_list, dir)
            elseif (count == max_count) then
                table.insert(dir_list, dir)
            elseif (count > max_count) then
                max_count = count
                ret_dir = dir
                dir_list = {}
                table.insert(dir_list, dir)
            end
        end
    end

    if (not dir_list) then
        return nil
    end

    if (max_count <= 1) then
        return nil
    end

    if (#dir_list == 1) then
        return dir_list[1]
    end

    local rand_num = math_random(1, #dir_list)
    return dir_list[rand_num]
end

-------------------------------------
-- function cancelSkill
-- @brief 캐스팅 중이던 스킬을 취소시킴
-------------------------------------
function Character:cancelSkill()
    if (self.m_state ~= 'casting') then return false end

    local timeScale = 0.2

    -- 스킬 캔슬 이펙트
    if self.m_castingEffect then
        self.m_castingEffect.m_node:stopAllActions()

        local rarity = self.m_charTable['rarity']
        if rarity == 'boss' or rarity == 'subboss' then
            self.m_castingEffect:changeAni('end_boss', false)
        else
            self.m_castingEffect:changeAni('end', false)
        end

        local duration = self.m_castingEffect:getDuration()
        self.m_castingEffect:setTimeScale(duration / timeScale)
        self.m_castingEffect:addAniHandler(function()
            self.m_castingEffect:runAction(cc.RemoveSelf:create())
            self.m_castingEffect = nil
        end)
    end

    -- 스킬 캔슬 이모티콘
    do
        local emoticon = MakeAnimator('res/ui/a2d/enemy_skill_speech/enemy_skill_speech.vrp')
        emoticon:setPosition(50, 100)
        self.m_rootNode:addChild(emoticon.m_node)

        -- 현재 캐스팅 게이지 상태에 따른 비주얼 분기 처리
        local castingPercentage = 0
        if self.m_castingMarkGauge then
            castingPercentage = self.m_castingMarkGauge:getPercentage()
        end

        if castingPercentage >= 90 then
            emoticon:changeAni('cancel_01', false)
        elseif castingPercentage >= 70 then
            emoticon:changeAni('cancel_02', false)
        else
            emoticon:changeAni('cancel_03', false)
        end

        local duration = emoticon:getDuration()
        emoticon:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    end

    -- 일시적인 슬로우 처리
    self.m_world.m_gameTimeScale:set(timeScale, 0.3)

    -- 화면 흔듬
    ShakeDir2(math_random(335-20, 335+20), 1500)

    self:changeState('attackDelay')

    return true
end