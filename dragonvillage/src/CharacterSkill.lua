-------------------------------------
-- function doSkill
-- @brief 스킬 실행
-------------------------------------
function Character:doSkill(skill_id, x, y, t_data, t_skill_derived)
    --local x = x or self.m_attackOffsetX
    --local y = y or self.m_attackOffsetY
	local t_data = t_data or {}

    local attr = self:getAttribute()
	local t_skill = t_skill_derived or self:getSkillTable(skill_id)

    -- 스킬 사용 불가 상태
    local basic_skill_id = self:getSkillID('basic')
    if (basic_skill_id ~= skill_id and self:hasStatusEffectToDisableSkill()) then
        return false
	end

	-- 스킬 테이블 체크
    if (not t_skill) then
        error('ID '.. tostring(skill_id) ..' 에 해당하는 스킬 테이블이 없습니다')
    end

    -- @ E.T.
    g_errorTracker:appendSkillHistory(skill_id, self:getName())

    if (self:doSkillBySkillTable(t_skill, t_data)) then
        local skill_indivisual_info = self:findSkillInfoByID(skill_id)
        if (skill_indivisual_info) then
            skill_indivisual_info:startCoolTime()
        end

        return true
    end

    return false
end

-------------------------------------
-- function doSkillBySkillTable
-- @brief 스킬의 시발점
-------------------------------------
function Character:doSkillBySkillTable(t_skill, t_data)
    if (not t_skill) then
        error('ID '.. tostring(skill_id) ..' 에 해당하는 스킬 테이블이 없습니다')
    end
	local t_data = t_data or {}
    local skill_form = t_skill['skill_form']

    ----------------------------------------------
    -- [스크립트] (스크립트에서 읽어와 미사일 탄막 생성)
    if (skill_form == 'script') then
		local x = self.m_attackOffsetX or 0
		local y = self.m_attackOffsetY or 0
		local attr = self:getAttribute()
		local phys_group = self:getMissilePhysGroup()

        local b = self:do_script_shot(t_skill, attr, phys_group, x, y, t_data)

        if (b) then
            -- 텍스트
            if (self.m_charType == 'dragon') then
                if (t_skill['sid'] == self.m_charTable['skill_1'] or t_skill['sid'] == self.m_charTable['skill_2']) then
                    self.m_world:addSkillSpeech(self, t_skill['t_name'])
                end
            end
        end

        return b
        
    -- 코드형 스킬
    elseif (skill_form == 'code') then
        self:checkTarget(t_skill, t_data)

        if (not self.m_targetChar) then
            return false
        end

		local skill_type = t_skill['skill_type']
		local chance_type = t_skill['chance_type']
		local chance_value = t_skill['chance_value']
        
		-- [패시브]
		if (chance_type == 'leader' or chance_type == 'passive') then
            -- 발동된 패시브의 연출을 위해 world에 발동된 passive정보를 저장

			local function apply_world_passive_effect(char)
                if (chance_type == 'passive' and self.m_charType ~= 'tamer') then
                    -- passive스킬은 테이머를 제외하고는 표시하지 않음
                else
				    self.m_world:addPassiveStartEffect(char, t_skill['t_name'])
                end
			end

			StatusEffectHelper:doStatusEffectByTable(self, t_skill, apply_world_passive_effect)
            return true

		-- [상태 효과]만 거는 스킬
		elseif string.find(skill_type, 'status_effect') then
            -- 특정 스킬의 말풍선 표시를 추가 상태효과가 부여되었을때만 표시하기 위한 하드코딩...
            if (isExistValue(t_skill['sid'], 208131, 208132, 208134)) then
                StatusEffectHelper:doStatusEffectByTable(self, t_skill, function()
                    -- 텍스트
                    if ( self.m_charType == 'dragon') then
                        self.m_world:addSkillSpeech(self, t_skill['t_name'])
                    end
                end, t_data)
            else
			    StatusEffectHelper:doStatusEffectByTable(self, t_skill, nil, t_data)
            
                -- 텍스트
                if ( self.m_charType == 'dragon') then
                    self.m_world:addSkillSpeech(self, t_skill['t_name'])
                end
            end

			return true

		-- [스킬]
		else

            -- 텍스트
            if ( self.m_charType == 'dragon') then
                if ( t_skill['sid'] == self.m_charTable['skill_1'] or t_skill['sid'] == self.m_charTable['skill_2']) then
                    self.m_world:addSkillSpeech(self, t_skill['t_name'])
                end
            end
			-- 공용탄 영역-------------------------------------------
			if (skill_type == 'missile_move_ray') then
				SkillRay:makeSkillInstance(self, t_skill, {})
				return true
			elseif (skill_type == 'missile_move_straight') then
				CommonMissile_Straight:makeMissileInstance(self, t_skill)
				return true
			elseif (skill_type == 'missile_move_guide') then
				CommonMissile_Guide:makeMissileInstance(self, t_skill)
				return true
			elseif (skill_type == 'missile_move_cruise') then
				CommonMissile_Cruise:makeMissileInstance(self, t_skill)
				return true
			elseif (skill_type == 'missile_move_shotgun') then
				CommonMissile_Shotgun:makeMissileInstance(self, t_skill)
				return true
			elseif (skill_type == 'missile_move_release') then
				CommonMissile_Release:makeMissileInstance(self, t_skill)
				return true
			elseif (skill_type == 'missile_move_high_angle') then
				CommonMissile_High:makeMissileInstance(self, t_skill)
				return true
			elseif (skill_type == 'missile_move_bounce') then
				CommonMissile_Bounce:makeMissileInstance(self, t_skill)
				return true
			elseif (skill_type == 'missile_move_multi') then
				CommonMissile_Multi:makeMissileInstance(self, t_skill)
				return true

			-- 스킬 영역-------------------------------------------
			elseif (skill_type == 'skill_curve_twin') then
				SkillLeafBlade:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_aoe_cross') then
				SkillAoECross:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_aoe_round') then
				SkillAoERound:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_aoe_round_sura') then
				SkillAoERound_Sura:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_aoe_round_throw') then
				SkillAoERound_Throw:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_aoe_round_hide') then
				SkillAoERound_Hide:makeSkillInstance(self, t_skill, t_data)
				return true
	
			elseif (skill_type == 'skill_aoe_square_height' or skill_type == 'skill_aoe_square_height_bottom') then
                -- 설정된 인디케이터에 맞춰지도록 처리
                if (string.find(t_skill['indicator'], 'height_top')) then
                    SkillAoESquare_Height_Top:makeSkillInstance(self, t_skill, t_data)
                else
                    SkillAoESquare_Height:makeSkillInstance(self, t_skill, t_data)
                end
                return true

            elseif (skill_type == 'skill_aoe_square_height_top') then
				SkillAoESquare_Height_Top:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_heal_aoe_square_height') then
				SkillHealAoESquare_Height:makeSkillInstance(self, t_skill, t_data)
				return true
				
            elseif (skill_type == 'skill_heal_aoe_square_width') then
                SkillHealAoESquare_Width:makeSkillInstance(self, t_skill, t_data)
                return true

			elseif (skill_type == 'skill_aoe_square_width' or skill_type == 'skill_aoe_square_width_left') then
                -- 설정된 인디케이터에 맞춰지도록 처리
                if (string.find(t_skill['indicator'], 'width_right')) then
                    SkillAoESquare_Width_Right:makeSkillInstance(self, t_skill, t_data)
                else
                    SkillAoESquare_Width:makeSkillInstance(self, t_skill, t_data)
                end
				return true

            elseif (skill_type == 'skill_aoe_square_width_right') then
				SkillAoESquare_Width_Right:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_aoe_square_charge') then
				SkillAoESquare_Charge:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_aoe_square_multi') then
				SkillAoESquare_Wonder:makeSkillInstance(self, t_skill, t_data)
				return true
			
			elseif (skill_type == 'skill_aoe_cone') then
				SkillAoECone:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_aoe_cone_crash') then
				SkillAoECone_Crash:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_aoe_wedge') then
				SkillAoEWedge:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_leap_atk') then
				SkillLeap:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_aoe_round_jump') then
				SkillExplosion:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_suicide') then
				SkillSuicideExplosion:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_strike_finish_spread') then
				SkillRolling:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_spatter') then
				SkillSpatter:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif string.find(skill_type, 'skill_buff') then
				SkillThrowBuff:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_laser') then
				SkillLaser:makeSkillInstance(self, t_skill, t_data) 
				return true

            elseif (skill_type == 'skill_laser_bomb') then
                SkillLaserBomb:makeSkillInstance(self, t_skill, t_data)
                return true

            elseif (skill_type == 'skill_laser_darknix') then
				SkillLaser_Darknix:makeSkillInstance(self, t_skill, t_data) 
				return true

            elseif (skill_type == 'skill_laser_zet') then
				SkillLaser_Zet:makeSkillInstance(self, t_skill, t_data) 
				return true

			elseif (skill_type == 'skill_lightning') then
				SkillChainLightning:makeSkillInstance(self, t_skill, t_data) 
				return true

			elseif (skill_type == 'skill_heal_single') then
				SkillHealSingle:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_heal_around') then
				SkillHealAround:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_heal_aoe_round') then
				SkillHealAoERound:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_guardian') then
				SkillGuardian:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_voltes_x') then
				SkillVoltesX:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_cross') then
                SkillCross:makeSkillInstance(self, t_skill, t_data)
                return true

			elseif (skill_type == 'skill_enumrate_normal') then
				SkillEnumrate_Normal:makeSkillInstance(self, t_skill, t_data)
				return true
    
			elseif (skill_type == 'skill_enumrate_curve') then
				SkillEnumrate_Curve:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_enumrate_penetration') then
				SkillEnumrate_Penetration:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_rapid_shot') then
				SkillRapidShot:makeSkillInstance(self, t_skill, t_data)
				return true
			
			elseif (skill_type == 'skill_rapid_shot_add_atk') then
				SkillRapidShot_AddAttack:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_linked_soul') then
				SkillLinkedSoul:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_conditional_add_effect') then
				SkillConditionalAddEffect:makeSkillInstance(self, t_skill, t_data)
				return true

			-- 특수 스킬들 또는 몬스터 전용 스킬 .. (특수하게 처리)-------------------
			elseif (skill_type == 'skill_summon') then
				local is_success = SkillSummon:makeSkillInstance(self, t_skill, t_data)
				return is_success

            elseif (skill_type == 'skill_transform') then
				SkillTransform:makeSkillInstance(self, t_skill, t_data)
				return true

            --[[
			elseif (skill_type == 'skill_counterattack') then
				SkillCounterAttack:makeSkillInstance(self, t_skill, t_data)
				return true
            ]]--

			elseif (skill_type == 'skill_heart_of_ruin') then
				SkillHeartOfRuin:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_charge') then
				SkillCharge:makeSkillInstance(self, t_skill, t_data)
				return true
            
			elseif (skill_type == 'skill_rush') then
				SkillRush:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_melee_atk') then
				SkillMeleeHack:makeSkillInstance(self, t_skill, t_data)
				return true
				
			elseif (skill_type == 'skill_spider_web') then
				SkillSpiderWeb:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_bind') then
                SkillBind:makeSkillInstance(self, t_skill, t_data)
                return true

			elseif (skill_type == 'skill_status_effect_burst') then
				SkillBurst:makeSkillInstance(self, t_skill, t_data)
				return true

			elseif (skill_type == 'skill_status_effect_field_check') then
				SkillFieldCheck:makeSkillInstance(self, t_skill, t_data)
				return true

            elseif (skill_type == 'skill_random') then
                SkillRandom:makeSkillInstance(self, t_skill, t_data)
                return true

            elseif (skill_type == 'skill_boss_clanraid_2') then
                SkillScript_ClanRaidBoss:makeSkillInstance(self, t_skill, t_data)
                return true

            elseif (skill_type == 'skill_boss_clanraid_9') then
                SkillScript_ClanRaidBossFinish:makeSkillInstance(self, t_skill, t_data)
                return true
			end

			cclog('미구현 코드 스킬 : ' .. skill_type)
		end
	end

	return false
end

-------------------------------------
-- function do_script_shot
-- @brief 스크립트 탄막 실행 
-------------------------------------
function Character:do_script_shot(t_skill, attr, phys_group, x, y, t_data)
    local x = x or self.m_attackOffsetX
    local y = y or self.m_attackOffsetX
    local t_data = t_data or {}

    local start_x = self.pos.x + x
    local start_y = self.pos.y + y

    -- 미사일 런쳐 (target, dir, left or right)
    local missile_launcher = MissileLauncher(nil)
    local t_launcher_option = missile_launcher:getOptionTable()

    -- 비주얼명 지정
    t_launcher_option['attr_name'] = attr

    -- 타겟을 얻는다
    local l_target = self:getTargetListByTable(t_skill)
    if (#l_target == 0) then return false end
    
    self.m_targetChar = l_target[1]

    -- 브레스일 경우
    if isExistValue(t_skill['skill_type'], 'skill_breath_1', 'skill_breath_2', 'skill_breath_3') then
        if t_data['dir'] then
            t_launcher_option['dir'] = t_data['dir']
        else
            t_launcher_option['dir'] = self:getBreathDegree(start_x, start_y, phys_group)
        end
    else
        -- 타겟 지정
        t_launcher_option['target'] = self.m_targetChar
        t_launcher_option['target_list'] = l_target
    end
    	
	-- 각도 지정
	if (not t_launcher_option['dir']) then
        local degree = getDegree(start_x, start_y, self.m_targetChar.pos.x, self.m_targetChar.pos.y)
        t_launcher_option['dir'] = degree
	end

    -- AttackDamage 생성
    local activity_carrier = self:makeAttackDamageInstance()
    activity_carrier:setAtkDmgStat(t_skill['power_source'])
    activity_carrier:setAttackType(t_skill['chance_type'])
    activity_carrier:setSkillId(t_skill['sid'])
    activity_carrier:setSkillHitCount(t_skill['hit'])
    activity_carrier:setPowerRate(t_skill['power_rate'])
    activity_carrier:setAddCriPowerRate(t_skill['critical_damage_add'])
		
    self.m_world:addToMissileList(missile_launcher)
    self.m_world.m_worldNode:addChild(missile_launcher.m_rootNode)

    missile_launcher:init_missileLauncher(t_skill, phys_group, activity_carrier, 1, t_data['script'])
    missile_launcher.m_animator:changeAni('animation', true)

    -- 발사 위치를 해당 캐릭터의 위치를 기준이 되도록 설정
    missile_launcher:setPosition(self.pos.x, self.pos.y)
    missile_launcher:setLauncherOwner(self, x, y)
    
    -- 스킬 방향 지정
    local skill_dir = tonumber(t_skill['dir'])
    if skill_dir then
        -- -1 : 타겟 방향으로 발사
        if (skill_dir == -1) then
            -- 위쪽 코드에서 타겟 방향으로 dir를 지정했음
            missile_launcher.m_bUseTargetDir = true

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

    return true, missile_launcher
end

-------------------------------------
-- function doSkill_passive
-- @brief 패시브 스킬 실행
-------------------------------------
function Character:doSkill_passive()
    if (self.m_bActivePassive) then return end

    local l_passive = self.m_lSkillIndivisualInfo['passive']
    if (l_passive) then
        for i, skill_info in pairs(l_passive) do
            local skill_id = skill_info.m_skillID
            self:doSkill(skill_id, 0, 0)
        end
    end

    self.m_bActivePassive = true
end

-------------------------------------
-- function doSkill_leader
-- @brief 리더 버프 실행
-------------------------------------
function Character:doSkill_leader()
    local leader_skill_info = self.m_lSkillIndivisualInfo['leader']
	if (leader_skill_info) then
		local skill_id = leader_skill_info.m_skillID
        self:doSkill(skill_id, 0, 0)
	end
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
-- function checkToStopSkill
-- @brief 진행 중인 스킬을 멈춰야하는지 여부
-------------------------------------
function Character:checkToStopSkill()
    if (self:isDead()) then
		return true
	end

    if (self:hasStatusEffectToDisableSkill()) then
		return true
	end

    return false
end