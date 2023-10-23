local PARENT = Character

-------------------------------------
-- class Monster
-------------------------------------
Monster = class(PARENT, {
        m_bWaitState = 'boolean',
		m_regenInfo = 'boolean',

        m_reservedSkillPos = 'cc.p',    -- 예약된 스킬이 가지는 특정 위치값(해당 위치로 이동해서 스킬 사용)

        m_lBodyToUseBone = 'table',     -- bone(spine)의 위치를 기준값으로 사용하는 body 리스트

        -- 몬스터 드래곤 관련
        m_mBoneEffect = 'table',        -- 본 위치에 표시되는 추가 이펙트(m_mBoneEffect[effect] = bone_name 형태로 사용)
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
function Monster:init_monster(t_monster, monster_id, level)
    -- 몬스터는 상시 부활 가능한 상태
    self.m_bPossibleRevive = true

    -- 각종 init 함수 실행
	do
		self:initDragonSkillManager('monster', monster_id, 6, true) -- monster는 skill_1~skill_6을 모두 사용
		self:initStatus(t_monster, level, 0, 0, 0)

		self:initAnimatorMonster(t_monster['res'], t_monster['attr'], t_monster['scale'], t_monster['size_type'])
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

        -- 이펙트 슬롯 숨김
        self:setVisibleSlot('effect_', false)

        if (self.m_animator.m_type == ANIMATOR_TYPE_SPINE) then
            local function makeDarkModeBoneEffect(bone_name, res, visual_name)
                -- 해당 본이 존재하는지 체크
                if (not self.m_animator.m_node:isExistBone(bone_name)) then return end

                local visual_name = visual_name or 'idle'

                -- 본 위치 사용 준비
                self.m_animator.m_node:useBonePosition(bone_name)

                local effect = MakeAnimator(res)
                effect:changeAni(visual_name, true)
                
                self.m_mBoneEffect[effect] = bone_name

                return effect
            end

            do -- 안광
                for i = 1, 6 do
                    local effect = makeDarkModeBoneEffect('monstereye_' .. i, 'res/effect/effect_monsterdragon/effect_monsterdragon_eye.vrp', 'idle')
                    if (effect) then
                        self.m_animator.m_node:addChild(effect.m_node)
                    else
                        break
                    end
                end
            end

            do -- 이펙트(앞 레이어)
                local effect = makeDarkModeBoneEffect('monstereffect', 'res/effect/effect_monsterdragon/effect_monsterdragon_f.vrp')
                if (effect) then
                    self.m_animator.m_node:addChild(effect.m_node)
                end
            end

            do -- 이펙트(뒤 레이어)
                local effect = makeDarkModeBoneEffect('monstereffect', 'res/effect/effect_monsterdragon/effect_monsterdragon_b.vrp')
                if (effect) then
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
    self:makeHPGauge({0, -(body_size[3] * 1.5)})

    if (self.m_animator) then
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
function Monster:initAnimatorMonster(file_name, attr, scale, size_type)
    if (self.m_animator) then
        return false
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeMonsterAnimator(file_name, attr)
    if (not self.m_animator.m_node) then return false end

    self.m_rootNode:addChild(self.m_animator.m_node)
	if (scale) then
        self.m_originScale = scale
		self.m_animator:setScale(scale)
    else
        self.m_originScale = 1
	end

    -- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
    self:blockMatchingSlotShader('effect_')

    -- 하이라이트 노드 설정
    self:addHighlightNode(self.m_animator.m_node)

    -- 차지 이펙트 생성
    if (size_type ~= 'xl') then
        local res = 'res/effect/effect_attack_ready/effect_attack_ready.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('idle', false)
        animator:setVisible(false)
        self.m_rootNode:addChild(animator.m_node)
        
        if (size_type == 's') then
            animator:setPosition(0, -25)
        elseif (size_type == 'm') then
            animator:setPosition(0, -50)
        elseif (size_type == 'l') then
            animator:setPosition(0, -75)
        end

        self.m_chargeDuration = animator:getDuration()
        self.m_chargeEffect = animator

        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_chargeEffect.m_node)
    end

    return true
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
-- function updatePhys
-------------------------------------
function Monster:updatePhys(dt)
    PARENT.updatePhys(self, dt)

    self:updateBonePos(dt)
end

-------------------------------------
-- function updateBonePos
-- @breif Spine Bone 정보로 갱신이 필요한 처리를 수행
-------------------------------------
function Monster:updateBonePos(dt)
    if (self.m_animator and self.m_animator.m_node) then
        -- bone(spine)의 위치를 기준값으로 사용하는 body들의 좌표 갱신(현재는 offset없이 사용)
        for _, body in ipairs(self.m_lBodyToUseBone) do
            local pos = self.m_animator.m_node:getBonePosition(body['bone'])
            
            body.x = pos.x * self.m_animator.m_node:getScaleX()
            body.y = pos.y * self.m_animator.m_node:getScaleY()

            local effect = self.m_mTargetEffect[body.key]
            if (effect) then
                effect:setPosition(body['x'], body['y'])
            end
            
            effect = self.m_mNonTargetEffect[body.key]
            if (effect) then
                effect:setPosition(body['x'], body['y'])
            end
        end
        
        -- bone의 위치를 기준값으로 사용할 추가 이펙트
        for effect, bone_name in pairs(self.m_mBoneEffect) do
            local pos = self.m_animator.m_node:getBonePosition(bone_name)
            local scale = self.m_animator.m_node:getBoneScale(bone_name)

            if (effect.m_node:getParent() ~= self.m_animator.m_node) then
                effect:setPositionX(self.pos.x - pos.x) -- 몬스터는 플립되서 사용되기 때문에 마이너스시킴
                effect:setPositionY(self.pos.y + pos.y)
                effect:setScale(self.m_animator:getScale() * scale.y)
            else
                effect:setPosition(pos)
                effect:setScale(scale.y)
            end
        end
    end
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Monster:makeHPGauge(hp_ui_offset, force)
    if (g_gameScene.m_gameMode == GAME_MODE_LEAGUE_RAID) then 
        self.m_unitInfoOffset = hp_ui_offset
        self.m_infoUI = self.m_world.m_inGameUI.m_stackableDamageUI
        self.m_statusIconNode =   self.m_world.m_inGameUI.m_stackableDamageUI.vars['bossStatusNode']
        self.m_bFixedPosHpNode = true
        self.m_infoUI.m_targetMonster = self
        return
    elseif (g_gameScene.m_gameMode == GAME_MODE_EVENT_DEALKING) then 
        PARENT.makeHPGauge(self, hp_ui_offset)
        return
    end

    if (force or (force == nil and self.m_charTable['rarity'] == 'boss')) then
        self.m_unitInfoOffset = hp_ui_offset

        if (self.m_hpNode) then
            self.m_hpNode:removeFromParent()
            
            if (isInstanceOf(self, MonsterLua_Boss)) then
                self.m_actionGauge = nil
            end
        end
            
        -- 보스 UI
        local ui = UI_IngameBossInfo(self)
        self.m_hpNode = ui.root
        self.m_hpNode:setDockPoint(cc.p(0.5, 0.5))
        self.m_hpNode:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_hpNode:setVisible(false)

        self.m_hpGauge = ui.vars['bossHpGauge1']
        self.m_hpGauge2 = ui.vars['bossHpGauge2']

        if (isInstanceOf(self, MonsterLua_Boss)) then
            self.m_actionGauge = ui.vars['bossSKillGauge']
        end
        
        self.m_world.m_inGameUI.root:addChild(self.m_hpNode, 102)

        self.m_infoUI = ui

        -- 상태효과 아이콘 표시를 위해 ui내의 node를 사용하도록 설정
        self.m_statusIconNode = ui.vars['bossStatusNode']

        -- hp노드의 위치를 고정
        self.m_bFixedPosHpNode = true
    else
        PARENT.makeHPGauge(self, hp_ui_offset)
    end
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
    local b = PARENT.setDead(self)

    if (b) then
	    -- regen된 몹이라면 waveMgr에 알려준다.
	    if (self.m_regenInfo) then
		    self.m_world.m_waveMgr:setRegenDead(self.m_regenInfo)
	    end
    end

    return b
end

-------------------------------------
-- function st_charge
-------------------------------------
function Monster.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_chargeEffect) then
            local attr = owner:getAttribute()

            owner.m_chargeEffect:setVisible(true)
            owner.m_chargeEffect:setFrame(0)
        else
            owner:changeState('attack')
        end

    elseif (owner.m_stateTimer >= owner.m_chargeDuration) then
        owner:changeState('attack')

    end
end

-------------------------------------
-- function st_casting
-------------------------------------
function Monster.st_casting(owner, dt)
    if (owner.m_stateTimer == 0) then
		if (owner:isBoss()) then
			SoundMgr:playEffect('EFFECT', 'monster_skill_cast') -- @ memo 출처 불분명하나 일단 남겨두기로함 (170928)
		end

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
    for effect, _ in pairs(self.m_mBoneEffect) do
        effect:release()
    end

    PARENT.release(self)
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
    PARENT.reserveSkill(self, skill_id)

    if (skill_id and skill_id ~= 0) then
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
    else
        self.m_reservedSkillPos = nil
    end
end

-------------------------------------
-- function isPossibleMove
-------------------------------------
function Monster:isPossibleMove(order, is_change_home_pos)
    local order = order or 0

    if (order < 0) then
        -- 설정된 공격 위치가 있었을 경우
        if (self.m_state == 'attack' and self.m_reservedSkillPos) then
            return false
        end
    end
    
    return PARENT.isPossibleMove(self, order)
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

-------------------------------------
-- function getRarity
-- @return 희귀도(보스 판정으로 사용)
-------------------------------------
function Monster:getRarity()
    local t_monster = TableMonster():get(self.m_charID)
    if (not t_monster) then
        error('invalid enemy_id : ' .. self.m_charID)
    end
    
    return monsterRarityStrToNum(t_monster['rarity'])
end

-------------------------------------
-- function getSizeType
-------------------------------------
function Monster:getSizeType()
    local t_monster = TableMonster():get(self.m_charID)
    if (not t_monster) then
        return self.m_evolutionLv, 'dragon'
    end
    
    return t_monster['size_type'], 'monster'
end