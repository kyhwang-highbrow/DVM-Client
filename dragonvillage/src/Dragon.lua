local PARENT = Character

-------------------------------------
-- class Dragon
-------------------------------------
Dragon = class(PARENT, {
        -- 기본 정보
        m_dragonID = '',    -- 드래곤의 고유 ID
        m_tDragonInfo = 'table', -- 유저가 보유한 드래곤 정보

        m_bActive = '',

        m_skillIndicator = '',

        m_bWaitState = 'boolean',

        m_activeSkillTimer = 'number',
        m_activeSkillCoolTime = 'number',

        m_afterimageMove = 'number',

        m_bUseSelfAfterImage = 'boolean',

        m_skillPrepareEffect = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Dragon:init(file_name, body, ...)
    self.m_charType = 'dragon'

    self.m_bActive = false
    self.m_bWaitState = false

    self.m_bUseSelfAfterImage = false
    self.m_skillPrepareEffect = nil
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Dragon:initAnimator(file_name)

end

-------------------------------------
-- function initAnimatorDragon
-------------------------------------
function Dragon:initAnimatorDragon(file_name, evolution, attr)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator(file_name, evolution, attr)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end

    -- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
    self:blockMatchingSlotShader('effect_')
end

-------------------------------------
-- function update
-------------------------------------
function Dragon:update(dt)
    if self.m_bUseSelfAfterImage then
        self:updateAfterImage(dt)
    end

    return Character.update(self, dt)
end

-------------------------------------
-- function doAppear
-------------------------------------
function Dragon:doAppear()
    if (self.m_bDead) then return end

    self.m_rootNode:setVisible(true)
    self.m_hpNode:setVisible(true)

    -- 등장 이펙트
    local effect = MakeAnimator('res/effect/tamer_magic_1/tamer_magic_1.vrp')
    effect:setPosition(self.pos.x, self.pos.y)
    effect:changeAni('bomb', false)
    effect:setScale(0.8)

    local duration = effect:getDuration()
    effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function() effect:release() end)))

    self.m_world.m_missiledNode:addChild(effect.m_node)
end

-------------------------------------
-- function doAttack
-------------------------------------
function Dragon:doAttack(x, y)
    local skill_id = self.m_reservedSkillId

    PARENT.doAttack(self, x, y)

    -- 일반 스킬에만 이펙트를 추가
    if (self.m_charTable['skill_basic'] ~= skill_id) then
        local attr = self:getAttribute()
        local res = 'res/effect/effect_missile_charge/effect_missile_charge.vrp'

        local animator = MakeAnimator(res)
        animator:changeAni('shot_' .. attr, false)
        self.m_rootNode:addChild(animator.m_node)
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function doSkill_passive
-- @brief 패시브 스킬 실행
-------------------------------------
function Dragon:doSkill_passive()
    if (self.m_bActivePassive) then return end

    local l_tar_skill_type = {'basic', 'normal'}

    for _, skill_type in pairs(l_tar_skill_type) do
        local skill_id = self:getSkillID(skill_type)
        local t_skill = self:getSkillTable(skill_id)
        if t_skill and (t_skill['chance_type'] == 'passive') then
            self:doSkill(skill_id, 0, 0)
        end
    end

    PARENT.doSkill_passive(self)
end

-------------------------------------
-- function initState
-------------------------------------
function Dragon:initState()
    PARENT.initState(self)

    self:addState('attack', Dragon.st_attack, 'attack', true)
    self:addState('charge', Dragon.st_charge, 'idle', true)
    self:addState('casting', PARENT.st_casting, 'skill_appear', true)

    --
    self:addState('skillPrepare', Dragon.st_skillPrepare, 'skill_appear', true)
    self:addState('skillAppear', Dragon.st_skillAppear, 'skill_appear', true)
    self:addState('skillIdle', Dragon.st_skillIdle, 'skill_idle', false)
    self:addState('skillDisappear', Dragon.st_skillDisappear, 'skill_disappear', false)
    --

    self:addState('wait', Dragon.st_wait, 'idle', true)

    -- success
    self:addState('success_pose', Dragon.st_success_pose, 'pose_1', false)
    self:addState('success_move', Dragon.st_success_move, 'idle', true)
end

-------------------------------------
-- function st_attack
-------------------------------------
function Dragon.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 일반 스킬에만 이펙트를 추가
        if owner.m_charTable['skill_basic'] ~= owner.m_reservedSkillId then
            local attr = owner:getAttribute()
            local res = 'res/effect/effect_missile_charge/effect_missile_charge.vrp'
                
            local animator = MakeAnimator(res)
            animator:changeAni('idle_' .. attr, false)
            owner.m_rootNode:addChild(animator.m_node)
            local duration = animator:getDuration()
            animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

            -- 텍스트
            local t_skill = owner:getSkillTable(owner.m_reservedSkillId)
            local str_map = {}
            str_map[t_skill['t_name']] = true
            owner.m_world:makePassiveStartEffect(owner, str_map)
        end

        -- 기본 공격시 이벤트
        if (owner.m_bLeftFormation) then
            owner:dispatch('hero_basic_skill', {}, owner)
        end
    end

    PARENT.st_attack(owner, dt)
end

-------------------------------------
-- function st_charge
-------------------------------------
function Dragon.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then
        local attr = owner:getAttribute()

        -- 차지 이팩트 재생
        local res = 'res/effect/effect_melee_charge/effect_melee_charge.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('idle_' .. attr, false)
        animator:setPosition(0, -50)
        owner.m_rootNode:addChild(animator.m_node)
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

    elseif (owner.m_stateTimer >= 0.5) then
        owner.m_chargeDuration = owner.m_stateTimer
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_skillPrepare
-------------------------------------
function Dragon.st_skillPrepare(owner, dt)
end

-------------------------------------
-- function st_skillAppear
-------------------------------------
function Dragon.st_skillAppear(owner, dt)
    if (owner.m_stateTimer == 0) then	
        owner.m_bEnableSpasticity = false

		-- @LOG
		do
			owner.m_world.m_logRecorder:recordLog('use_skill', 1)
		end

        -- 이벤트
        if (owner.m_bLeftFormation) then
            owner:dispatch('dragon_skill', {}, owner)
        else
            owner:changeState('skillIdle')
        end
    end
end

-------------------------------------
-- function st_skillIdle
-------------------------------------
function Dragon.st_skillIdle(owner, dt)
    if (owner.m_stateTimer == 0) then
        local active_skill_id = owner:getSkillID('active')
        local table_dragon_skill = TABLE:get('dragon_skill')
        local t_dragon_skill = table_dragon_skill[active_skill_id]
        local motion_type = t_dragon_skill['motion_type']

        -- 변수 초기화
        owner.m_bLuanchMissile = false
        owner.m_bFinishAttack = false
        owner.m_bFinishAnimation = false

        local function attack_cb(event)
            owner.m_bLuanchMissile = true

            local x, y = 0, 0

            if event then
                local string_value = event['eventData']['stringValue']
                if string_value and (string_value ~= '') then
                    local l_str = seperate(string_value, ',')
                    if l_str then
                        local scale = owner.m_animator:getScale()
                        local flip = owner.m_animator.m_bFlip

                        x = l_str[1] * scale
                        y = l_str[2] * scale

                        if flip then
                            x = -x
                        end
                    end
                end
            end
            
            local active_skill_id = owner:getSkillID('active')
            local indicatorData
            
            if (owner.m_bLeftFormation) then
                indicatorData = owner.m_skillIndicator:getIndicatorData()
                indicatorData['highlight'] = true
            end

            owner:doSkill(active_skill_id, x, y, indicatorData)
            owner.m_animator:setEventHandler(nil)
            owner.m_bFinishAttack = true

            -- 액티브 스킬 사용 이벤트 발생
            if (owner.m_bLeftFormation) then
                owner:dispatch('hero_active_skill', {}, self)
            else
                owner:dispatch('enemy_active_skill', {}, self)
            end

            -- 사운드
            local sound_name = owner:getSoundNameForSkill(owner.m_charTable['type'])
            if sound_name then
                SoundMgr:playEffect('EFFECT', sound_name)
            end
        end

        -- 모션 타입 처리
        if (motion_type == 'instant') then
            owner.m_aiParamNum = nil
            owner:addAniHandler(function()
                owner.m_bFinishAnimation = true

                if (not owner.m_bFinishAttack) then
                    attack_cb()
                end

                owner.m_aiParamNum = 0
            end)
        elseif (motion_type == 'maintain') then
            owner.m_aiParamNum = (owner.m_statusCalc.m_attackTick / 2)
            owner:addAniHandler(function()
                owner.m_bFinishAnimation = true

                if (not owner.m_bFinishAttack) then
                    attack_cb()
                end
            end)
        else
            error('스킬 테이블 motion_type이 ['.. motion_type .. '] 라고 잘못들어갔네요...')
        end

        -- 공격 타이밍이 있을 경우
        owner.m_animator:setEventHandler(attack_cb)

        -- 캐스팅 게이지
        if owner.m_castingUI then
            owner.m_castingUI:stopAllActions()
        end

        if owner.m_castingSpeechVisual then
            owner.m_castingSpeechVisual:changeAni('success', false)
            owner.m_castingSpeechVisual:registerScriptLoopHandler(function() owner.m_castingNode:setVisible(false) end)
        elseif owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
    
    elseif (owner.m_aiParamNum and (owner.m_stateTimer >= owner.m_aiParamNum)) then
        if (owner.m_bFinishAttack) then
            if (owner.m_state ~= 'delegate') then
                owner:changeState('skillDisappear')
            end
        end
    end
end

-------------------------------------
-- function st_skillDisappear
-------------------------------------
function Dragon.st_skillDisappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_bEnableSpasticity = true

        owner:addAniHandler(function()
            owner:changeState('attackDelay')
        end)
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function Dragon.st_wait(owner, dt)
    if (owner.m_stateTimer == 0) then
        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
    end
end

-------------------------------------
-- function st_success_pose
-- @brief success 세레머니
-------------------------------------
function Dragon.st_success_pose(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner.m_animator:changeAni('idle', true)
        end)
    elseif (owner.m_stateTimer >= 2.5) then
        owner:changeState('success_move')
    end
end

-------------------------------------
-- function st_success_move
-- @brief success 세레머니 후 오른쪽으로 퇴장
-------------------------------------
function Dragon.st_success_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        --local add_speed = (owner.pos['y'] / -100) * 100
        local add_speed = math_random(-2, 2) * 100
        owner:setMove(owner.pos.x + 2000, owner.pos.y, 1500 + add_speed)

        owner.m_afterimageMove = 0

        owner:setAfterImage(true)
    end
end

-------------------------------------
-- function release
-------------------------------------
function Dragon:release()
    if self.m_world then
        if self.m_bLeftFormation then
            self.m_world:removeHero(self)
			-- @LOG
			do
				self.m_world.m_logRecorder:recordLog('death_cnt', 1)
			end
        else
            self.m_world:removeEnemy(self)
        end
    end

    if self.m_hpNode then
        self.m_hpNode:removeFromParent(true)
    end
    
    self.m_hpNode = nil
    self.m_hpGauge = nil

    Entity.release(self)
end

-------------------------------------
-- function setActive
-------------------------------------
function Dragon:setActive(active)
    self.m_bActive = active

    if self.m_bActive then
        self.enable_body = true
        self.apply_movement = true
        if self.m_rootNode then
            self.m_rootNode:setVisible(true)
        end
    else
        self.enable_body = false
        self.apply_movement = false
        if self.m_rootNode then
            self.m_rootNode:setVisible(false)
        end

        -- 이동 중지
        self:resetMove()
    end

    if self.m_hpNode then
        self.m_hpNode:setVisible(active)
    end
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Dragon:makeHPGauge(hp_ui_offset)
    self.m_unitInfoOffset = hp_ui_offset
    self.m_unitInfoOffset[1] = self.m_unitInfoOffset[1] - 80

    if (self.m_hpNode) then
        self.m_hpNode:removeFromParent()
        self.m_hpNode = nil
        self.m_hpGauge = nil
        self.m_hpGauge2 = nil
        self.m_statusNode = nil
        self.m_infoUI = nil
    end

    local ui = UI_IngameDragonInfo(self)
    self.m_hpNode = ui.root
    self.m_hpNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_hpGauge = ui.vars['hpGauge']
    self.m_hpGauge2 = ui.vars['hpGauge2']

    self.m_statusNode = self.m_hpNode
    
    self.m_world.m_unitInfoNode:addChild(self.m_hpNode, 5)

    self.m_infoUI = ui
end

-------------------------------------
-- function makeCastingNode
-------------------------------------
function Dragon:makeCastingNode()
    PARENT.makeCastingNode(self)

    local x, y
    
    do
        x, y = self.m_castingMarkGauge:getPosition()
        self.m_castingMarkGauge:setPosition(x + 80, y)
    end

    do
        x, y = self.m_castingSpeechVisual:getPosition()
        self.m_castingSpeechVisual:setPosition(x + 80, y)
    end
end

-------------------------------------
-- function setHp
-------------------------------------
function Dragon:setHp(hp)
    PARENT.setHp(self, hp)

    self:dispatch('change_hp', {}, self, self.m_hp, self.m_maxHp)
end

-------------------------------------
-- function setStatusCalc
-------------------------------------
function Dragon:setStatusCalc(status_calc)
    self.m_statusCalc = status_calc

    if (not self.m_statusCalc) then
        return
    end

    -- hp 설정
    local hp = self.m_statusCalc:getFinalStat('hp')
    self.m_maxHp = hp
    self.m_hp = hp
end

-------------------------------------
-- function initStatus
-------------------------------------
function Dragon:initStatus(t_char, level, grade, evolution, doid)
    -- 캐릭터 테이블 설정
    self.m_charTable = t_char
	self.m_attribute = t_char['attr']
	self.m_attributeOrg = t_char['attr']

    -- 능력치 설정이 되지 않은 경우
    if (not self.m_statusCalc) then
        local status_calc = MakeDragonStatusCalculator(self.m_charTable['did'], level, grade, evolution)
        self:setStatusCalc(status_calc)
    end

    -- 스킬 인디케이터 초기화
    self:init_skillIndicator()
end

-------------------------------------
-- function init_skillIndicator
-- @brief 스킬 인디케이터 초기화
-------------------------------------
function Dragon:init_skillIndicator()
    local t_char = self.m_charTable
    local t_skill = self:getLevelingSkillByType('active').m_tSkill

	local type = t_skill['indicator']
		
	-- 타겟형(아군)
	if (type == 'target_ally') then
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, false)

	-- 타겟형(적군)
	elseif (type == 'target') then
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, true)

	-- 원형 범위
	elseif (type == 'round') then
		self.m_skillIndicator = SkillIndicator_AoERound(self, t_skill, false)

	-- 시전 범위 제한 있는 타겟
	elseif (type == 'range') then
		self.m_skillIndicator = SkillIndicator_Range(self)

	-- 원뿔형
	elseif (type == 'cone') then
		self.m_skillIndicator = SkillIndicator_Conic(self, t_skill)

	-- 레이저
	elseif (type == 'bar') then
		self.m_skillIndicator = SkillIndicator_Laser(self, t_skill)
	
	-- 세로로 긴 직사각형 인디케이터
	elseif (type == 'square') then
		local target_type = (t_char['type'] == 'pinkbell') and 'all' or 'enemy'
		self.m_skillIndicator = SkillIndicator_AoESquare_Height(self, t_skill, target_type)
	
	-- 여러 다발의 관통형 인디케이터
	elseif (type == 'penetration') then
		self.m_skillIndicator = SkillIndicator_Penetration(self, t_skill)

	------------------ 특수한 인디케이터들 ------------------
	
	-- 크래쉬(가루다)
	elseif (type == 'target_cone') then
		self.m_skillIndicator = SkillIndicator_Crash(self, t_skill)
	-- 리프블레이드 (리프드래곤)
	elseif (type == 'curve_twin') then
		self.m_skillIndicator = SkillIndicator_LeafBlade(self, t_skill)
	
	-- 원뿔형 확산 (허리케인)
	elseif (type == 'cone_spread') then
		self.m_skillIndicator = SkillIndicator_ConicSpread(self, t_skill)

	-- 볼테스X (볼테스X)
	elseif (type == 'voltes_x') then
		self.m_skillIndicator = SkillIndicator_X(self, t_skill, true)

    -- 굵은 가로형 직사각형 (사이커)
    elseif (type == 'square_width') then
		self.m_skillIndicator = SkillIndicator_StraightWidth(self, t_skill, true)

	-- 미정의 인디케이터
	else
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, false)
		cclog('###############################################')
		cclog('## 인디케이터 정의 되지 않은 스킬 : ' .. t_skill['type'])
		cclog('###############################################')
	end
end

-------------------------------------
-- function setWaitState
-------------------------------------
function Dragon:setWaitState(is_wait_state)
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
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Dragon:changeState(state, forced)
    if self.m_bWaitState then
        if (not isExistValue(state, 'dying', 'dead')) then
            return PARENT.changeState(self, 'wait', false)
        end
    end

    return PARENT.changeState(self, state, forced)
end

-------------------------------------
-- function initActiveSkillCoolTime
-------------------------------------
function Dragon:initActiveSkillCoolTime(percentage)
    -- 액티브 스킬 쿨타임 지정
    local active_skil_id = self:getSkillID('active')

    if (active_skil_id == 0) then
        return
    end
    
    local table_skill = TABLE:get(self.m_charType .. '_skill')
    local t_skill = table_skill[active_skil_id]

    self.m_activeSkillCoolTime = tonumber(t_skill['cooldown'])
    
    if (self.m_bLeftFormation) then
        self.m_activeSkillTimer = 100
    else
        self.m_activeSkillTimer = self.m_activeSkillCoolTime / 100 * math_random(1, 100)
    end

    if (percentage) then
        self.m_activeSkillTimer = self.m_activeSkillCoolTime * percentage / 100
    end

    if (self.m_infoUI and self.m_infoUI.vars['skillGauge']) then
        self.m_infoUI.vars['skillGauge']:setPercentage(self.m_activeSkillTimer / self.m_activeSkillCoolTime * 100)
    end
end

-------------------------------------
-- function updateActiveSkillCoolTime
-------------------------------------
function Dragon:updateActiveSkillCoolTime(dt)
    if (not self.m_activeSkillCoolTime) or (self.m_activeSkillCoolTime == 0) then
        return
    end

    if (self.m_activeSkillCoolTime == self.m_activeSkillTimer) then
        return
    end

    if (self.m_state ~= 'casting') and (self.m_state ~= 'skillPrepare') then
        self.m_activeSkillTimer = (self.m_activeSkillTimer + dt)
    end

    if (self.m_activeSkillCoolTime <= self.m_activeSkillTimer) then
        self.m_activeSkillTimer = self.m_activeSkillCoolTime

        if (self.m_infoUI.vars['skllFullVisual']) then
            self.m_infoUI.vars['skllFullVisual']:setVisible(true)
            self.m_infoUI.vars['skllFullVisual']:setRepeat(false)
            self.m_infoUI.vars['skllFullVisual']:setVisual('skill_gauge', 'charging')
            self.m_infoUI.vars['skllFullVisual']:registerScriptLoopHandler(function()
                local attr = self:getAttribute()

                self.m_infoUI.vars['skllFullVisual']:setVisual('skill_gauge', 'idle_' .. attr)
                self.m_infoUI.vars['skllFullVisual']:setRepeat(true)

                self.m_infoUI.vars['skllFullVisual2']:setVisual('skill_gauge', 'idle_s_' .. attr)
                self.m_infoUI.vars['skllFullVisual2']:setVisible(true)
            end)
        end
    end

    if (self.m_infoUI.vars['skillGauge']) then
        self.m_infoUI.vars['skillGauge']:setPercentage(self.m_activeSkillTimer / self.m_activeSkillCoolTime * 100)
    end

    --cclog(' self.m_activeSkillTimer ' .. self.m_activeSkillTimer)
end

-------------------------------------
-- function resetActiveSkillCoolTime
-------------------------------------
function Dragon:resetActiveSkillCoolTime()
    if self:isEndActiveSkillCoolTime() then
        self.m_activeSkillTimer = 0

        if (self.m_infoUI.vars['skllFullVisual']) then
            self.m_infoUI.vars['skllFullVisual']:setVisual('skill_gauge', 'idle')
            self.m_infoUI.vars['skllFullVisual']:setVisible(false)
            self.m_infoUI.vars['skllFullVisual2']:setVisible(false)
            self.m_infoUI.vars['skillGauge']:setPercentage(0)
        end
        return true
    else
        return false
    end
end

-------------------------------------
-- function isPossibleSkill
-------------------------------------
function Dragon:isPossibleSkill()
    if (self.m_bDead) then
		return false
	end

	if (not self:isEndActiveSkillCoolTime()) then
		return false
	end

    if (self.m_isSilence) then
		return false
	end

    -- 스킬 사용 불가 상태
    if (isExistValue(self.m_state, 'delegate', 'stun')) then
        return false
    end

    -- 이미 스킬을 사용하기 위한 상태일 경우
    if (isExistValue(self.m_state, 'skillPrepare', 'skillAppear', 'skillIdle')) then
        return false
    end

	return true
end

-------------------------------------
-- function isEndActiveSkillCoolTime
-------------------------------------
function Dragon:isEndActiveSkillCoolTime()
    return (self.m_activeSkillTimer == self.m_activeSkillCoolTime)
end

-------------------------------------
-- function setAfterImage
-------------------------------------
function Dragon:setAfterImage(b)
    self.m_afterimageMove = 0
    self.m_bUseSelfAfterImage = b
end

-------------------------------------
-- function updateAfterImage
-- @TODO Dragon class에 추가 됨에 따라 각각 따로 구현되었던 updateAfterImage 통합 필요
-------------------------------------
function Dragon:updateAfterImage(dt)
    local speed = self.m_world.m_mapManager.m_speed

    -- 에프터이미지
    self.m_afterimageMove = self.m_afterimageMove + (speed * dt)

    local interval = -30

    if (self.m_afterimageMove <= interval) then
        self.m_afterimageMove = self.m_afterimageMove - interval

        local duration = (interval / speed) * 1.5 -- 3개의 잔상이 보일 정도
        duration = math_clamp(duration, 0.3, 0.7)

        local res = self.m_animator.m_resName
        local accidental = MakeAnimator(res)
        accidental:changeAni(self.m_animator.m_currAnimation)
        
		local parent = self.m_rootNode:getParent()
        self.m_world.m_worldNode:addChild(accidental.m_node, 1)
        accidental:setScale(self.m_animator:getScale())
        accidental:setFlip(self.m_animator.m_bFlip)
        accidental.m_node:setOpacity(255 * 0.2)
        accidental.m_node:setPosition(self.pos.x, self.pos.y)
        
        accidental.m_node:runAction(cc.MoveBy:create(duration, cc.p(speed / 2, 0)))
        accidental.m_node:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function makeSkillPrepareEffect
-------------------------------------
function Dragon:makeSkillPrepareEffect()
    if self.m_skillPrepareEffect then return end

    local attr = self:getAttribute()
    local res = 'res/effect/effect_skillcasting_dragon/effect_skillcasting_dragon.vrp'

    self.m_skillPrepareEffect = MakeAnimator(res)
    self.m_skillPrepareEffect:changeAni('start_' .. attr, true)
    self.m_rootNode:addChild(self.m_skillPrepareEffect.m_node)

    self.m_skillPrepareEffect.m_node:setTimeScale(10)
end

-------------------------------------
-- function removeSkillPrepareEffect
-------------------------------------
function Dragon:removeSkillPrepareEffect()
    if not self.m_skillPrepareEffect then return end

    self.m_skillPrepareEffect:release()
    self.m_skillPrepareEffect = nil
end

-------------------------------------
-- function getSoundNameForSkill
-------------------------------------
function Dragon:getSoundNameForSkill(type)
    local sound_name

    if (type == 'powerdragon') then
        sound_name = 'skill_powerdragon'

    elseif (type == 'lambgon') then
        sound_name = 'skill_lambgon'
        
    elseif (type == 'applecheek') then
        sound_name = 'skill_applecheek'
        
    elseif (type == 'spine') then
        sound_name = 'skill_spine'
        
    elseif (type == 'leafdragon') then
        sound_name = 'skill_leafdragon'
        
    elseif (type == 'taildragon') then
        sound_name = 'skill_taildragon'
        
    elseif (type == 'purplelipsdragon') then
        sound_name = 'skill_purplelipsdragon'
        
    elseif (type == 'pinkbell') then
        sound_name = 'skill_pinkbell'
        
    elseif (type == 'bluedragon') then
        sound_name = 'skill_bluedragon'
        
    elseif (type == 'littio') then
        sound_name = 'skill_littio'
        
    elseif (type == 'hurricane') then
        sound_name = 'skill_hurricane'
        
    elseif (type == 'garuda') then
        sound_name = 'skill_garuda'
        
    elseif (type == 'boomba') then
        sound_name = 'skill_boomba'
        
    elseif (type == 'godaeshinryong') then
        sound_name = 'skill_godaeshinryong'
        
    elseif (type == 'crescentdragon') then
        sound_name = 'skill_crescentdragon'
        
    elseif (type == 'serpentdragon') then
        sound_name = 'skill_serpentdragon'
        
    elseif (type == 'lightningdragon') then
        sound_name = 'skill_lightningdragon'

    elseif (type == 'optatio') then
        sound_name = 'skill_optatio'

    elseif (type == 'psykerdragon') then
        sound_name = 'skill_psykerdragon'

    elseif (type == 'mutanteggdragon') then
        sound_name = 'skill_mutanteggdragon'

    elseif (type == 'fairydragon') then
        sound_name = 'skill_fairydragon'
        
    end

    return sound_name
end