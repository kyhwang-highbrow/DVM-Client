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

    -- 캐릭터 유형별 변수 정리(dragon or enemy)
    if isExistValue(self.m_charType, 'dragon', 'tamer') then
        is_hero = true
        phys_group = 'missile_h'
    elseif (self.m_charType == 'enemy') then
        is_hero = false
        phys_group = 'missile_e'
    else
        error()
    end

    -- 테이블 정보 가져옴
    local table_skill = TABLE:get(self.m_charType .. '_skill')
    local t_skill = table_skill[skill_id]

    if (not t_skill) then
        error('스킬 테이블이 존재하지 않는ㄷr' .. tostring(skill_id))
    end

    self:checkTarget(t_skill)

    if (not t_skill) then
        cclog('# 존재하지 않는 스킬 ID : ' .. skill_id)
        error()
    end

    local type = t_skill['type']
    local skill_form = t_skill['skill_form']
    local chance_type = t_skill['chance_type']

    ----------------------------------------------
    if (chance_type == 'passive') then
        local char = self
        local t_skill = t_skill
        return StatusEffectHelper:invokePassive(char, t_skill)

	elseif (chance_type == 'trigger') then
		local char = self
        local t_skill = t_skill
		return StatusEffectHelper:setTriggerPassive(char, t_skill)

    -- 탄막 공격 (스크립트에서 읽어와 미사일 탄막 생성)
    elseif (skill_form == 'script') then
        self:doSkill_basic_normal(t_skill, attr, is_hero, phys_group, x, y, t_data)
        return true

    -- 상태 효과
    elseif (skill_form == 'status_effect') then
        -- 1. skill의 타겟룰로 상태효과의 대상 리스트를 얻어옴
	    local l_target = self:getTargetList(t_skill)

		-- 1-1. skill 타겟 수 추가
		local target_count = clone(t_skill['val_1'])
		local _count = 0

        -- 2. 타겟 대상에 상태효과생성
	    for _,target in ipairs(l_target) do
            if (target_count == 0) then
                -- 0일 경우 모든 타겟에 적용
            elseif (_count >= target_count) then
                break
            end

		    StatusEffectHelper:invokeStatusEffect(target, t_skill['status_effect_type'], t_skill)
			_count = _count + 1
        end
        return true

    -- 코드형 스킬
    elseif (skill_form == 'code') then

		-- 공용탄 영역
        if (type == 'missile_move_ray') then
            SkillRay:makeSkillInstnceFromSkill(self, t_skill, {})
            return true
		elseif (type == 'missile_move_straight') then
            CommonMissile_Straight:makeInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_cruise') then
            CommonMissile_Cruise:makeInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_shotgun') then
            CommonMissile_Shotgun:makeInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_release') then
            CommonMissile_Release:makeInstance(self, t_skill)
            return true
		elseif (type == 'missile_move_high_angle') then
            CommonMissile_High:makeInstance(self, t_skill)
            return true


		-- 스킬 영역
        elseif (type == 'skill_laser') then
            SkillLaser:makeSkillInstnceFromSkill(self, t_skill, t_data) 
            return true
        elseif (type == 'skill_butt') then
            self:doSkill_butt(t_skill, is_hero, phys_group, x, y, t_data)
            return true
        elseif (type == 'skill_thunder') then
            self:doSkill_thunder(t_skill, attr, is_hero, phys_group, x, y)
            return true
        elseif (type == 'skill_chain_cri_chance') then
            self:doSkill_chainLightning(t_skill, attr, is_hero, phys_group, x, y)
            return true
        elseif (type == 'skill_heal_target') then
            self:doSkill_healTarget(t_skill, is_hero, phys_group, x, y)
            return true
        elseif (type == 'skill_heal_around') then
            self:doSkill_healAround(t_skill, is_hero, phys_group, x, y)
            return true
        elseif (type == 'skill_curve') then
            self:doSkill_curve(t_skill, is_hero, phys_group, x, y)
            return true
        elseif (type == 'skill_protection_spread') then
            self:doSkill_skill_protection(t_skill, t_data)
            return true
        elseif (type == 'skill_heal_single') then
            self:doSkill_skill_heal_single(t_skill, t_data)
            return true

        elseif (type == 'skill_bullet_hole') then
            self:doSkill_skill_bullet_hole(t_skill, attr, is_hero, phys_group, x, y, t_data)
            return true
        elseif (type == 'skill_deep_stab') then
            self:doSkill_skill_deep_stab(t_skill, attr, is_hero, phys_group, x, y, t_data)
            return true
        elseif (type == 'skill_crash') then
            self:doSkill_skill_crash(t_skill, attr, is_hero, phys_group, x, y, t_data)
            return true
        elseif (type == 'skill_aoe_square_heal_dmg') then
            self:doSkill_skill_healing_wind(t_skill, attr, is_hero, phys_group, x, y, t_data)
            return true
        elseif (type == 'skill_curve_twin') then
            self:doSkill_skill_leaf_blade(t_skill, attr, is_hero, phys_group, x, y, t_data)
            return true

		elseif (type == 'skill_dispel_harm') then
            self:doSkill_skill_dispel_magic(t_skill, t_data)
            return true

		elseif (type == 'skill_summon') then
            local summon_success = self:doSkill_skill_summon(t_skill, t_data)
            return summon_success


			
		-- 구조 개선 후 ----------------------------------------------------
		elseif (type == 'skill_aoe_round') then
            SkillAoERound:makeSkillInstnceFromSkill(self, t_skill, t_data)
            return true

		elseif (type == 'skill_conic') then
            SkillConicAtk:makeSkillInstnceFromSkill(self, t_skill, t_data)
			return true

		elseif (type == 'skill_aoe_cone_spread') then
            SkillConicAtk_Spread:makeSkillInstnceFromSkill(self, t_skill, t_data)
			return true

		elseif (type == 'skill_aoe_round_jump') then
            SkillExplosion:makeSkillInstnceFromSkill(self, t_skill, t_data)
			return true

		elseif (type == 'skill_strike_finish_spread') then
            SkillRolling:makeSkillInstnceFromSkill(self, t_skill, t_data)
			return true

		elseif string.find(type, 'skill_buff') then
            SkillBuff:makeSkillInstnceFromSkill(self, t_skill, t_data)
			return true

        elseif (type == 'skill_leon_basic') then
            SkillLeonBasic:makeSkillInstnceFromSkill(self, t_skill, t_data)
            return true
            
	    elseif (type == 'skill_counterattack') then
            SkillCounterAttack:makeSkillInstnceFromSkill(self, t_skill, t_data)
            return true
            
		elseif (type == 'skill_melee_atk') then
			if isExistValue(t_skill['id'], 210982, 210112, 210212) then -- 램곤, 애플칙, 붐버
				SkillMeleeHack_Specific:makeSkillInstnceFromSkill(self, t_skill, t_data)
			else
				SkillMeleeHack:makeSkillInstnceFromSkill(self, t_skill, t_data)
			end
            return true

        elseif (type == 'skill_protection') then
            SkillProtection:makeSkillInstnceFromSkill(self, t_skill, t_data)
            return true

        -- 패시브 스킬
        elseif (type == 'skill_react_armor') then
            self:doSkill_counteratk(t_skill, is_hero, phys_group, x, y, t_data)
            return true

        end
    end

	cclog('미구현 코드 스킬 : ' .. type)
    return false
end

-------------------------------------
-- function doSkill_basic_normal
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_basic_normal(t_skill, attr, is_hero, phys_group, x, y, t_data)

    local start_x = self.pos.x + x
    local start_y = self.pos.y + y

    -- 미사일 런쳐 (target, dir, left or right)
    local missile_launcher = MissileLauncher(nil)
    local t_launcher_option = missile_launcher:getOptionTable()

    -- 비주얼명 지정
    t_launcher_option['attr_name'] = attr
	
    -- 미사일 갯수 지정
    --t_launcher_option['missile_count'] = value_1

    -- 타겟이 있을 경우
    if self.m_targetChar then
        -- 브레스일 경우
        if isExistValue(t_skill['type'], 'skill_breath_1', 'skill_breath_2', 'skill_breath_3') then
            if t_data['dir'] then
                t_launcher_option['dir'] = t_data['dir']
            else
                t_launcher_option['dir'] = self:getBreathDegree(start_x, start_y, phys_group)
                if (not t_launcher_option['dir']) then
                    -- 각도 지정
                    local degree = getDegree(start_x, start_y, self.m_targetChar.pos.x, self.m_targetChar.pos.y)
                    t_launcher_option['dir'] = degree
                end
            end
        else
            -- 타겟 지정
            t_launcher_option['target'] = self.m_targetChar
       
	        -- 각도 지정
            local degree = getDegree(start_x, start_y, self.m_targetChar.pos.x, self.m_targetChar.pos.y)
            t_launcher_option['dir'] = degree
        end
	else
		self:checkTarget(t_skill)
		-- 타겟 지정
        t_launcher_option['target'] = self.m_targetChar
    end

    if is_hero then
        t_launcher_option['target_pos'] = {start_x + 500, start_y}
    else
        t_launcher_option['target_pos'] = {start_x - 500, start_y}
    end

    -- AttackDamage 생성
    local activity_carrier = self:makeAttackDamageInstance()
    activity_carrier:insertStatusEffectRate(t_skill['status_effect_type'], t_skill['status_effect_rate'])

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
-- function doSkill_laser
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_laser(t_skill, attr, is_hero, phys_group, x, y, t_data)

    -- 인디케이터에서
    if t_data['x'] and t_data['y'] then
        linear_laser.m_endPosX = t_data['x']
        linear_laser.m_endPosY = t_data['y']
    else
        if self.m_targetChar then
            linear_laser.m_endPosX = self.m_targetChar.pos.x
            linear_laser.m_endPosY = self.m_targetChar.pos.y
        end
    end

    -- 타겟이 없을 경우

end

-------------------------------------
-- function doSkill_butt
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_butt(t_skill, is_hero, phys_group, x, y, t_data)
    local target_x = nil
    local target_y = nil

    if t_data then
        target_x = t_data['x']
        target_y = t_data['y']
    end

    if (not target_x) or (not target_y) then
        if self.m_targetChar then
            target_x = self.m_targetChar.pos.x
            target_y = self.m_targetChar.pos.y
        else
            target_x = x + 500
            target_y = y
        end
    end

    self.m_attackAnimaDuration = self.m_stateTimer
    self.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)
    self:changeState('dash')
    self:setMove(target_x, target_y, 1500)


    local grade = t_skill['val_1']

    if grade == 1 then

    elseif grade == 2 then
        self:makeDashEffect(0.5)
    elseif grade == 3 then
        self:makeDashEffect(1)
    end
end


-------------------------------------
-- function doSkill_thunder
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_thunder(t_skill, attr, is_hero, phys_group, x, y)

    local phys_group = nil

    -- 캐릭터 유형별 변수 정리(dragon or enemy)
    if (self.m_charType == 'dragon') then
        is_hero = true
        phys_group = 'missile_h'
    else
        is_hero = false
        phys_group = 'missile_e'
    end

    local thunder = Thunder()

    thunder.m_physGroup = phys_group

    -- Physics, Node, GameMgr에 등록
    --self.m_world:addMissile(linear_laser, object_key)
    self.m_world.m_missiledNode:addChild(thunder.m_rootNode)
    self.m_world:addToUnitList(thunder)

    -- 리소스
    local res = string.gsub(t_skill['res_1'], '@', attr)

    thunder:setPosition(self.pos.x + x, self.pos.y - y)

    thunder.m_activityCarrier = self:makeAttackDamageInstance()
    thunder.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)

    local count = t_skill['val_1']
    thunder:init_Thunder(res, count)
end

-------------------------------------
-- function doSkill_chainLightning
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_chainLightning(t_skill, attr, is_hero, phys_group, x, y)

    local phys_group = nil

    -- 캐릭터 유형별 변수 정리(dragon or enemy)
    if (self.m_charType == 'dragon') then
        phys_group = 'missile_h'
    else
        phys_group = 'missile_e'
    end

    local skill = SkillChainLightning()

    skill.m_offsetX = x
    skill.m_offsetY = y

    skill.m_physGroup = phys_group

    -- Physics, Node, GameMgr에 등록
    --self.m_world:addMissile(linear_laser, object_key)
    self.m_world.m_missiledNode:addChild(skill.m_rootNode)
    self.m_world:addToUnitList(skill)

    skill:init_SkillChainLightning(self, t_skill, x, y)
end

-------------------------------------
-- function doSkill_healTarget
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_healTarget(t_skill, is_hero, phys_group, x, y)
    local skill = SkillHealTarget(nil)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_missiledNode:addChild(skill.m_rootNode)
    self.m_world:addToUnitList(skill)

    skill:setPosition(self.pos.x, self.pos.y)
    skill:init_skill(self, t_skill)
end

-------------------------------------
-- function doSkill_healAround
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_healAround(t_skill, is_hero, phys_group, x, y)

    local skill = SkillHealAround('res/effect/shot_heal_around/shot_heal_around.spine')
    --local skill = SkillHealAround(nil)

    -- Physics, Node, GameMgr에 등록
    --self.m_world:addMissile(linear_laser, object_key)
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)

    local pos_x = self.pos.x + x
    local pos_y = self.pos.y + y

    skill:setPosition(pos_x, pos_y)

    skill:init_skill(self, res, x, y, t_skill)
end

-------------------------------------
-- function doSkill_shield
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_shield(t_skill, is_hero, phys_group, x, y)
    local skill = SkillShield(nil)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)

    local pos_x = self.pos.x + x
    local pos_y = self.pos.y + y

    skill:setPosition(pos_x, pos_y)

    skill:init_skill(self, res, x, y, t_skill)
end

-------------------------------------
-- function doSkill_counteratk
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_counteratk(t_skill, is_hero, phys_group, x, y, t_data)

    local skill = SkillAttributeAmor(nil)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 3)
    self.m_world:addToUnitList(skill)

    local pos_x = self.pos.x + x
    local pos_y = self.pos.y + y

    skill:setPosition(pos_x, pos_y)

    skill:init_skill(self, res, x, y, t_skill, t_data)
end

-------------------------------------
-- function doSkill_curve
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_curve(t_skill, is_hero, phys_group, x, y)
    local skill = SkillCurve(nil)

    -- Physics, Node, GameMgr에 등록
    --self.m_world:addMissile(linear_laser, object_key)
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)

    local pos_x = self.pos.x + x
    local pos_y = self.pos.y + y

    skill:setPosition(pos_x, pos_y)

    skill:init_skill(self, t_skill)
end

-------------------------------------
-- function doSkill_skill_protection
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_protection(t_skill, t_data)
    local skill = SkillProtection_Spread(nil)

    -- Physics, Node, GameMgr에 등록
    --self.m_world:addMissile(linear_laser, object_key)
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)

    local pos_x = self.pos.x-- + x
    local pos_y = self.pos.y-- + y
    skill:setPosition(pos_x, pos_y)
    skill:init_skill(self, t_skill, t_data['target'])
end

-------------------------------------
-- function doSkill_skill_heal_single
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_heal_single(t_skill, t_data)
    local target = nil
    if t_data then
        target = t_data['target']
    end

    -- 지정된 타겟이 없을 경우 랜덤으로 사용
    if (not target) then

        -- 타겟 설정
        local formation_mgr = nil
        if self.m_bLeftFormation then
            formation_mgr = self.m_world.m_leftFormationMgr
        else
            formation_mgr = self.m_world.m_rightFormationMgr
        end
        target = formation_mgr:getRandomHealTarget()
    end

    local heal_rate = (t_skill['power_rate'] / 100)

    -- 타겟에 회복 수행, 이팩트 생성
    if target and (not target.m_bDead) then
        local atk_dmg = self.m_statusCalc:getFinalStat('atk')
        local heal = HealCalc_M(atk_dmg)

        local res = string.gsub(t_skill['res_1'], '@', self.m_charTable['attr'])
        local effect = self.m_world:addInstantEffect(res, 'heal_effect', target.pos.x, target.pos.y)

        target:healAbs(heal * heal_rate)

        local effect_heal = EffectHeal(res, {0,0,0})
        effect_heal:initState()
        effect_heal:changeState('move')
        effect_heal:init_EffectHeal(self.pos.x, self.pos.y, target)
        --effect_heal:setMotionStreak(self.m_world.m_gameNode1, 'res/effect/motion_streak/motion_streak_emblem_tree.png')

        self.m_world.m_physWorld:addObject('effect', effect_heal)
        self.m_world.m_worldNode:addChild(effect_heal.m_rootNode, 0)
        self.m_world:addToUnitList(effect_heal)

		-- @TODO 공격에 묻어나는 이펙트 Carrier 에 담아서..
		StatusEffectHelper:doStatusEffect(target, t_skill)
    end
end

-------------------------------------
-- function doSkill_skill_bullet_hole
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_bullet_hole(t_skill, attr, is_hero, phys_group, x, y, t_data)

    local range = t_skill['val_1']

    -- 위치, 범위, 타겟 갯수, 데미지
	local res = string.gsub(t_skill['res_1'], '@', attr)
    local skill = SkillBulletHole(res, {0, 0, range})

    skill:init_skill(self, t_data['x'], t_data['y'], t_skill)

    -- Physics, Node, GameMgr에 등록
    self.m_physWorld:addObject('hole_h', skill)
    self.m_world.m_missiledNode:addChild(skill.m_rootNode)
    self.m_world:addToUnitList(skill)
end

-------------------------------------
-- function doSkill_skill_deep_stab
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_deep_stab(t_skill, attr, is_hero, phys_group, x, y, t_data)

    -- 위치, 범위, 타겟 갯수, 데미지
    local skill = SkillDeepStab('', {0, 0, 0})

    skill:init_skill(self, t_skill)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)
end

-------------------------------------
-- function doSkill_skill_crash
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_crash(t_skill, attr, is_hero, phys_group, x, y, t_data)

    -- 위치, 범위, 타겟 갯수, 데미지
    local skill = SkillCrash('', {0, 0, 0})

    skill:init_skill(self, t_skill, t_data)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)
end

-------------------------------------
-- function doSkill_skill_healing_wind
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_healing_wind(t_skill, attr, is_hero, phys_group, x, y, t_data)

    -- 위치, 범위, 타겟 갯수, 데미지
	local res = string.gsub(t_skill['res_1'], '@', attr)
    local skill = SkillHealingWind(res, {0, 0, 0})

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_missiledNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)

    skill:init_skill(self, t_data['x'], t_data['y'], t_skill)
end



------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------




-------------------------------------
-- function doSkill_leaf_blade
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_leaf_blade(t_skill, attr, is_hero, phys_group, x, y, t_data)
    local skill = SkillLeafBlade(nil)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_worldNode:addChild(skill.m_rootNode, 0)
    self.m_world:addToUnitList(skill)

    skill:init_skill(self, t_skill, t_data)
end

-------------------------------------
-- function doSkill_skill_dispel_magic
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill_skill_dispel_magic(t_skill, t_data)
	local res = string.gsub( t_skill['res_1'], '@', self.m_charTable['attr'])
    local skill = SkillDispelMagic(res)

    -- Physics, Node, GameMgr에 등록
    self.m_world.m_missiledNode:addChild(skill.m_rootNode)
    self.m_world:addToUnitList(skill)

    skill:setPosition(self.pos.x, self.pos.y)
    skill:init_skill(self, t_skill, t_data)
end

-------------------------------------
-- function doSkill_skill_summon
-- @brief 스킬 실행
-- @return boolean true리턴 시 소환, false리턴 시 소환 실패(기본 공격 나가도록)
-------------------------------------
function Character:doSkill_skill_summon(t_skill, t_data)
    local idx = t_skill['val_1']
    if (not self.m_world.m_waveMgr:checkSummonable(idx)) then 
        return false
    end

    local skill = SkillSummon(nil)
    skill:init_skill(self, t_skill, t_data)
    
    -- Physics, Node, GameMgr에 등록
    self.m_world.m_groundNode:addChild(skill.m_rootNode)
    self.m_world:addToUnitList(skill)

    return true
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