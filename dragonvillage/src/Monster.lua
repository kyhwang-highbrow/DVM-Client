local PARENT = Character

-------------------------------------
-- class Monster
-------------------------------------
Monster = class(PARENT, {
        m_bWaitState = 'boolean',
		m_regenInfo = 'boolean',

        m_reservedSkillPos = 'cc.p',    -- 예약된 스킬이 가지는 특정 위치값(해당 위치로 이동해서 스킬 사용)

        m_lBodyToUseBone = 'table',     -- bone(spine)의 위치를 기준값으로 사용하는 body 리스트

        m_mBoneEffect = 'table',        -- 본 위치에 표시되는 추가 이펙트(m_mDarkModeBoneEffect[bone_name] = effect 형태로 사용)
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster:init(file_name, body, ...)
    self.m_charType = 'monster'
    self.m_bWaitState = false
	self.m_regenInfo = nil

    self.m_lBodyToUseBone = {}

    self.m_mBoneEffect = {}
end

-------------------------------------
-- function init_monster
-------------------------------------
function Monster:init_monster(t_monster, monster_id, level, stage_id)
    local t_drop = TABLE:get('drop')[stage_id]
    local level = level + t_drop['level']

    -- 각종 init 함수 실행
	do
		self:initDragonSkillManager('monster', monster_id, 6) -- monster는 skill_1~skill_6을 모두 사용
		self:initStatus(t_monster, level, 0, 0, 0)

		self:initAnimatorMonster(t_monster['res'], t_monster['attr'], t_monster['scale'])
		self:makeCastingNode()
		self:initTriggerListener()
		self:initLogRecorder(monster_id)
	end

    -- 피격 처리
    self:addDefCallback(function(attacker, defender, i_x, i_y, k, b)
        self:undergoAttack(attacker, defender, i_x, i_y, k or 0, b)
    end)

    -- 연출 효과(몬스터 드래곤)
    if (t_monster['dark_mode'] == 1) then
        -- 기본 쉐이더 변경
        self.m_animator:setBaseShader(SHADER_DARK)

        if (self.m_animator.m_type == ANIMATOR_TYPE_SPINE) then
            local function makeDarkModeBoneEffect(bone_name, res, visual_name)
                -- 해당 본이 존재하는지 체크
                if (not self.m_animator.m_node:isExistBone(bone_name)) then return end

                local visual_name = visual_name or 'idle'

                -- 본 위치 사용 준비
                self.m_animator.m_node:useBonePosition(bone_name)

                local effect = MakeAnimator(res)
                effect:changeAni(visual_name, true)
                
                self.m_mBoneEffect[bone_name] = effect

                return effect
            end

            do -- 안광
                local effect = makeDarkModeBoneEffect('monstereye_s', 'res/effect/effect_monsterdragon/effect_monsterdragon_eye.vrp', 'idle_s')
                if (effect) then
                    self.m_animator.m_node:addChild(effect.m_node)
                end
                local effect = makeDarkModeBoneEffect('monstereye_m', 'res/effect/effect_monsterdragon/effect_monsterdragon_eye.vrp', 'idle_m')
                if (effect) then
                    self.m_animator.m_node:addChild(effect.m_node)
                end
                local effect = makeDarkModeBoneEffect('monstereye_l', 'res/effect/effect_monsterdragon/effect_monsterdragon_eye.vrp', 'idle_l')
                if (effect) then
                    self.m_animator.m_node:addChild(effect.m_node)
                end
            end

            do -- 이펙트(앞 레이어)
                local effect = makeDarkModeBoneEffect('center', 'res/effect/effect_monsterdragon/effect_monsterdragon_f.vrp')
                if (effect) then
                    self.m_animator.m_node:addChild(effect.m_node)
                end
            end

            do -- 이펙트(뒤 레이어)
                local effect = makeDarkModeBoneEffect('center', 'res/effect/effect_monsterdragon/effect_monsterdragon_b.vrp')
                if (effect) then
                    local scale = self.m_animator:getScale()
                    effect:setScale(scale)
                    self.m_world.m_groundNode:addChild(effect.m_node)
                end
            end
        end
    end
end

-------------------------------------
-- function initFormation
-------------------------------------
function Monster:initFormation(body_size)
    local hp_ui_offset = {0, -(body_size[3] * 1.5)}

	-- 진영에 따른 처리
	if (self.m_bLeftFormation) then
        self:changeState('idle')
        self:makeHPGauge(hp_ui_offset)
    else
        self:changeState('move')
	    self:makeHPGauge(hp_ui_offset)
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Monster:initAnimator(file_name)
end

-------------------------------------
-- function initAnimatorMonster
-------------------------------------
function Monster:initAnimatorMonster(file_name, attr, scale)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeMonsterAnimator(file_name, attr)
    if (not self.m_animator.m_node) then return end

    self.m_rootNode:addChild(self.m_animator.m_node)
	if (scale) then
		self.m_animator:setScale(scale)
	end

    -- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
    self:blockMatchingSlotShader('effect_')

    -- 하이라이트 노드 설정
    self:addHighlightNode(self.m_animator.m_node)
end

-------------------------------------
-- function initPhys
-- @param body
-------------------------------------
function Monster:initPhys(body)
    PARENT.initPhys(self, body)


    if (self.m_animator and self.m_animator.m_type == ANIMATOR_TYPE_SPINE) then
        local body_list = self:getBodyList()

        for _, body in ipairs(body_list) do
            if (body['bone']) then
                self.m_animator.m_node:useBonePosition(body['bone'])

                table.insert(self.m_lBodyToUseBone, body)
            end
        end
    end
end

-------------------------------------
-- function initState
-------------------------------------
function Monster:initState()
    PARENT.initState(self)

    self:addState('charge', Monster.st_charge, 'idle', true)
    self:addState('casting', Monster.st_casting, 'idle', true)

    self:addState('wait', Monster.st_wait, 'idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function Monster:update(dt)
    if (self.m_animator and self.m_animator.m_node) then
        -- bone(spine)의 위치를 기준값으로 사용하는 body들의 좌표 갱신(현재는 offset없이 사용)
        for _, body in ipairs(self.m_lBodyToUseBone) do
            local pos = self.m_animator.m_node:getBonePosition(body['bone'])
            
            body.x = pos.x * self.m_animator.m_node:getScaleX()
            body.y = pos.y * self.m_animator.m_node:getScaleY()
        end

        -- bone의 위치를 기준값으로 사용할 추가 이펙트
        for bone_name, effect in pairs(self.m_mBoneEffect) do
            local pos = self.m_animator.m_node:getBonePosition(bone_name)

            if (effect.m_node:getParent() ~= self.m_animator.m_node) then
                effect:setPositionX(self.pos.x + pos.x)
                effect:setPositionY(self.pos.y + pos.y)
            else
                effect:setPosition(pos)
            end
        end
    end 

    return PARENT.update(self, dt)
end

-------------------------------------
-- function setRegenInfo
-- @brief 리젠 정보를 저장한다.
-------------------------------------
function Monster:setRegenInfo(t_info)
    self.m_regenInfo = t_info
end

-------------------------------------
-- function setDead
-- @overriding
-------------------------------------
function Monster:setDead()
    PARENT.setDead(self)

	-- regen된 몹이라면 waveMgr에 알려준다.
	if (self.m_regenInfo) then
		local idx = self.m_regenInfo['idx']
		self.m_world.m_waveMgr:setRegenDead(idx)
	end
end

-------------------------------------
-- function st_charge
-------------------------------------
function Monster.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then
        local size_type = owner.m_charTable['size_type']
        if (size_type ~= 'xl') then
            -- 차지 이팩트 재생
            local res = 'res/effect/effect_attack_ready/effect_attack_ready.vrp'
            local animator = MakeAnimator(res)
            animator:changeAni('idle', false)
            owner.m_rootNode:addChild(animator.m_node)
            local duration = animator:getDuration()
            animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

            local size_type = owner.m_charTable['size_type']
            if (size_type == 's') then
                animator:setPosition(0, -25)
            elseif (size_type == 'm') then
                animator:setPosition(0, -50)
            elseif (size_type == 'l') then
                animator:setPosition(0, -75)
            end
        end

    elseif (owner.m_stateTimer >= 0.5) then
        owner.m_chargeDuration = owner.m_stateTimer
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_casting
-------------------------------------
function Monster.st_casting(owner, dt)
    if (owner.m_stateTimer == 0) then
        SoundMgr:playEffect('EFFECT', 'monster_skill_cast')

        -- 스킬 사용 위치 정보가 있다면 해당 위치까지 이동시킴
        if (owner.m_reservedSkillPos) then
            owner:changeHomePosByTime(owner.m_reservedSkillPos.x, owner.m_reservedSkillPos.y, owner.m_reservedSkillCastTime)
        end
    end

    PARENT.st_casting(owner, dt)
end

-------------------------------------
-- function setWaitState
-------------------------------------
function Monster:setWaitState(is_wait_state)
    self.m_bWaitState = is_wait_state

    if is_wait_state then
        if isExistValue(self.m_state, 'idle', 'attackDelay') then
            self:changeState('wait')
        end
    else
        if (self.m_state == 'wait') then
            self:changeState('attackDelay')
        end
    end
end

-------------------------------------
-- function release
-------------------------------------
function Monster:release()
    for bone_name, effect in pairs(self.m_mBoneEffect) do
        effect:release()
    end

    PARENT.release(self)

    if self.m_world then
        self.m_world:removeEnemy(self)
    end
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Monster:changeState(state, forced)
    if self.m_bWaitState then
        if (not isExistValue(state, 'dying', 'dead')) then
            return PARENT.changeState(self, 'wait', false)
        end
    end

    return PARENT.changeState(self, state, forced)
end

-------------------------------------
-- function getBodySize
-------------------------------------
function Monster:getBodySize(size_type)
	local size = g_constant:get('INGAME', 'MONSTER_BODY_SIZE')[size_type] or 50
	local body = {0, 0, size}

	return body
end

 
-------------------------------------
-- function reserveSkill
-- @brief 사용될 스킬을 예약
-------------------------------------
function Monster:reserveSkill(skill_id)
    self.m_reservedSkillPos = nil

    if (not PARENT.reserveSkill(self, skill_id)) then
        return false
    end

    
    -- 스킬 사용 위치값 저장
    local t_skill = self:getSkillTable(skill_id)
    if (t_skill['pos']) then
        local l_str = seperate(t_skill['pos'], ';')
        if (l_str) then
            local random_idx = math_random(1, #l_str)
            local key = l_str[random_idx]
            local pos = getWorldEnemyPos(self, key)
        
            self.m_reservedSkillPos = pos
        
            -- 캐스팅 시간에 이동시간을 추가
            local move_time = g_constant:get('INGAME', 'MONSTER_SKILL_MOVE_TIME') or 1
            self.m_reservedSkillCastTime = self.m_reservedSkillCastTime + move_time
        end
    end
    
    -- 에니메이션 변경
    -- (근접 공격만 스킬 내부의 애니메이션을 변경하고 스킬 시작 직전 애니메이션은 attack으로 처리)
    if (t_skill['skill_type'] == 'skill_melee_atk') then
        self.m_tStateAni['attack'] = 'attack'
    else
        self.m_tStateAni['attack'] = self:getAttackAnimationName(skill_id)
    end
    
    return true
end


-------------------------------------
-- function getAttackAnimationName
-------------------------------------
function Monster:getAttackAnimationName(skill_id)
    local default_ani = 'attack'
    
    -- 테이블 정보 가져옴
    local table_name = self.m_charType .. '_skill'
    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local animation_name = t_skill['animation']
    if (not animation_name) then
        return default_ani
    end

    if (animation_name == '') then
        return default_ani
    end

    return animation_name
end