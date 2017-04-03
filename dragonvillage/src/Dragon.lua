local PARENT = Character

-------------------------------------
-- class Dragon
-------------------------------------
Dragon = class(PARENT, {
        -- 기본 정보
        m_dragonID = '',    -- 드래곤의 고유 ID
        m_tDragonInfo = 'table', -- 유저가 보유한 드래곤 정보
		
		m_skillIndicator = '',

        m_skillOffsetX = 'number',
        m_skillOffsetY = 'number',

        -- 스킬 게이지 관련
        m_activeSkillValue = 'number',
        m_activeSkillIncValuePerSec = 'number', -- 초당 회복량
        m_activeSkillAccumValue = 'number',     -- 누적값(초당 최대 획득량 제한을 위함)
        m_activeSkillAccumTimer = 'number',

        m_dragSkillNode = '',
        m_dragSkillNodeOffset = 'cc.p',
        m_skillPrepareEffect = '',

        m_afterimageMove = 'number',

        m_bUseSelfAfterImage = 'boolean',
		m_bWaitState = 'boolean',
		m_bActive = 'boolean',
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

    self.m_skillOffsetX = 0
    self.m_skillOffsetY = 0

    self.m_activeSkillValue = 0
    self.m_activeSkillIncValuePerSec = 0
    self.m_activeSkillAccumValue = 0
    self.m_activeSkillAccumTimer = -1

    self.m_dragSkillNode = nil
    self.m_dragSkillNodeOffset = cc.p(0, 0)

    self.m_bUseSelfAfterImage = false
    self.m_skillPrepareEffect = nil
end

-------------------------------------
-- function init_dragon
-------------------------------------
function Dragon:init_dragon(dragon_id, t_dragon_data, t_dragon, bLeftFormation)
	local doid = t_dragon_data['id']
    local lv = t_dragon_data['lv'] or 1
    local grade = t_dragon_data['grade'] or 1
    local evolution = t_dragon_data['evolution'] or 1
    local eclv = t_dragon_data['eclv'] or 0
    local rlv = t_dragon_data['rlv'] or 0
	local attr = t_dragon['attr']

	-- 기본 정보 저장
    self.m_dragonID = dragon_id
    self.m_charTable = t_dragon
    self.m_tDragonInfo = t_dragon_data
    self.m_bLeftFormation = bLeftFormation

	-- 각종 init 함수 실행
	self:setDragonSkillLevelList(t_dragon_data['skill_0'], t_dragon_data['skill_1'], t_dragon_data['skill_2'], t_dragon_data['skill_3'])
	self:initDragonSkillManager('dragon', dragon_id, evolution)
    self:initActiveSkillCool() -- 스킬 쿨타임 지정
	self:initAnimatorDragon(t_dragon['res'], evolution, attr, t_dragon['scale'])
    self:makeCastingNode()
    self:setStatusCalc(status_calc)
    self:initStatus(t_dragon, lv, grade, evolution, doid, eclv, rlv)
	self:initTriggerListener()

	-- 피격 처리
    self:addDefCallback(function(attacker, defender, i_x, i_y)
        self:undergoAttack(attacker, defender, i_x, i_y)
    end)

	-- @TODO character 수준으로 들어가야한다.
    self.m_charLogRecorder = self.m_world.m_logRecorder:getLogRecorderChar(dragon_id)
end

-------------------------------------
-- function initFormation
-------------------------------------
function Dragon:initFormation()
	-- 진영에 따른 처리
	if (self.m_bLeftFormation) then
        self:changeState('idle')
        self:makeHPGauge({0, -80})
    else
        self:changeState('move')
        PARENT.makeHPGauge(self, {0, -80})
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Dragon:initAnimator(file_name)

end

-------------------------------------
-- function initAnimatorDragon
-------------------------------------
function Dragon:initAnimatorDragon(file_name, evolution, attr, scale)
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
    
    if (self.m_animator.m_node) then
        self.m_rootNode:addChild(self.m_animator.m_node)
		if (scale) then
			self.m_animator:setScale(scale/2)
		end
    end

    -- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
    self:blockMatchingSlotShader('effect_')

    -- 하이라이트 노드 설정
    self:addHighlightNode(self.m_animator.m_node)

    -- 스킬 오프셋값 설정(애니메이션 정보로부터 얻음)
    local eventList = self.m_animator:getEventList('skill_disappear', 'attack')
    local event = eventList[1]
    if event then
        local string_value = event['stringValue']
        if string_value and (string_value ~= '') then
            local l_str = seperate(string_value, ',')
            if l_str then
                self.m_skillOffsetX = l_str[1]
                self.m_skillOffsetY = l_str[2]
            end
        end
    end
end

-------------------------------------
-- function setDamage
-------------------------------------
function Dragon:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)

    -- 피격시 스킬 게이지 증가
    local role_type = self:getRole()
    if (role_type == 'tanker') then
        local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_ACTIVE_POINT_INCREMENT_VALUE')
        local value
        
        -- 받은 피해가 전체 체력의 10%이상일 경우
        if ((damage / self.m_maxHp) >= 0.1) then
            value = t_temp['set_damage'] * t_temp['coef']
        else
            value = t_temp['set_damage']
        end

        self:increaseActiveSkillCool(value)
    end
end

-------------------------------------
-- function update
-------------------------------------
function Dragon:update(dt)
    if self.m_bUseSelfAfterImage then
        self:updateAfterImage(dt)
    end

    -- 스킬 게이지 제한 타이머 갱신
    if (self.m_activeSkillAccumTimer >= 0) then
        self.m_activeSkillAccumTimer = self.m_activeSkillAccumTimer + dt

        if (self.m_activeSkillAccumTimer > 1) then
            self.m_activeSkillAccumTimer = -1
            self.m_activeSkillAccumValue = 0
        end
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

    self:addState('skillPrepare', Dragon.st_skillPrepare, 'skill_appear', true)
    self:addState('skillAppear', Dragon.st_skillAppear, 'skill_idle', false)
    self:addState('skillIdle', Dragon.st_skillIdle, 'skill_disappear', false)
    
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
        local role_type = owner:getRole()

        -- 패시브 스킬에만 이펙트를 추가
        if (owner.m_charTable['skill_basic'] ~= owner.m_reservedSkillId) then
            local attr = owner:getAttribute()
            local res = 'res/effect/effect_missile_charge/effect_missile_charge.vrp'
                
            local animator = MakeAnimator(res)
            animator:changeAni('idle_' .. attr, false)
            owner.m_rootNode:addChild(animator.m_node)
            local duration = animator:getDuration()
            animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

            -- 텍스트
            local t_skill = owner:getSkillTable(owner.m_reservedSkillId)
            SkillHelper:makePassiveSkillSpeech(owner, t_skill['t_name'])
            
            -- 스킬 게이지 증가
            if (role_type == 'supporter') then
                local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_ACTIVE_POINT_INCREMENT_VALUE')

                if (t_skill['chance_type'] == 'indie_time') then
                    owner:increaseActiveSkillCool(t_temp['time_skill'])
                else
                    owner:increaseActiveSkillCool(t_temp['passive_skill'])
                end
            end
        else
            -- 기본 공격시 이벤트
            if (owner.m_bLeftFormation) then
                owner:dispatch('hero_basic_skill', {}, owner)
            end

            -- 스킬 게이지 증가
            if (role_type == 'dealer') then
                local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_ACTIVE_POINT_INCREMENT_VALUE')
                owner:increaseActiveSkillCool(t_temp['basic_skill'])
            end
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
		if (owner.m_bLeftFormation) then
			owner.m_world.m_logRecorder:recordLog('use_skill', 1)
		else
			-- 적 드래곤 (pvp, 인연던전) 체크해야할 경우 추가
		end

        owner:dispatch('dragon_active_skill', {}, owner)
    end
end

-------------------------------------
-- function st_skillIdle
-------------------------------------
function Dragon.st_skillIdle(owner, dt)
    if (owner.m_stateTimer == 0) then
        local active_skill_id = owner:getSkillID('active')
        local t_dragon_skill = TableDragonSkill():get(active_skill_id)
        local motion_type = t_dragon_skill['motion_type']

        -- 변수 초기화
        owner.m_bLuanchMissile = false
        owner.m_bFinishAttack = false
        owner.m_bFinishAnimation = false

        local function attack_cb()
            owner.m_bLuanchMissile = true

            local scale = owner.m_animator:getScale()
            local flip = owner.m_animator.m_bFlip
            local x = owner.m_skillOffsetX * scale
            local y = owner.m_skillOffsetY * scale

            if flip then
                x = -x
            end

            local active_skill_id = owner:getSkillID('active')
            local indicatorData = owner.m_skillIndicator:getIndicatorData()
            indicatorData['highlight'] = true
            
            owner:doSkill(active_skill_id, x, y, indicatorData)
            owner.m_animator:setEventHandler(nil)
            owner.m_bFinishAttack = true

            -- 액티브 스킬 사용 이벤트 발생
            if (owner.m_bLeftFormation) then
                owner:dispatch('hero_active_skill', {}, owner)
            else
                owner:dispatch('enemy_active_skill', {}, owner)
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

        attack_cb()
        
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
                owner.m_bEnableSpasticity = true
                owner:changeState('attackDelay')
            end
        end
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
			self.m_world.m_logRecorder:recordLog('death_cnt', 1)
        else
            self.m_world:removeEnemy(self)
        end
    end

    if (self.m_hpNode) then
        self.m_hpNode:removeFromParent(true)
    end
    if (self.m_dragSkillNode) then
        self.m_dragSkillNode.m_node:removeFromParent(true)
    end
    
    self.m_hpNode = nil
    self.m_hpGauge = nil
    self.m_dragSkillNode = nil

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

    self.m_dragSkillNode = ui.vars['dragSkllFullVisual']
    self.m_dragSkillNode.m_node:retain()
    self.m_dragSkillNode.m_node:removeFromParent(true)
    self.m_world.m_groundNode:addChild(self.m_dragSkillNode.m_node, 1)
    self.m_dragSkillNode.m_node:release()
        
    self.m_statusNode = self.m_hpNode
    
    --self.m_world.m_unitInfoNode:addChild(self.m_hpNode, 5)
    self.m_unitInfoNode:addChild(self.m_hpNode, 5)

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
function Dragon:initStatus(t_char, level, grade, evolution, doid, eclv)
    -- 캐릭터 테이블 설정
    self.m_charTable = t_char
	self.m_attribute = t_char['attr']
	self.m_attributeOrg = t_char['attr']
    self.m_lv = level

    -- 능력치 설정이 되지 않은 경우
    if (not self.m_statusCalc) then
        local status_calc = MakeDragonStatusCalculator(self.m_charTable['did'], level, grade, evolution, eclv, rlv)
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

	local indicator_type = t_skill['indicator']
		
	-- 타겟형(아군)
	if (indicator_type == 'target_ally') then
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, false)

	-- 타겟형(적군)
	elseif (indicator_type == 'target') then
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, true)

	-- 원형 범위
	elseif (indicator_type == 'round') then
		self.m_skillIndicator = SkillIndicator_AoERound(self, t_skill, false)
	elseif (indicator_type == 'target_round') then
		self.m_skillIndicator = SkillIndicator_AoERound(self, t_skill, true)

	-- 원점 기준 원뿔형
	elseif (indicator_type == 'wedge') then
		self.m_skillIndicator = SkillIndicator_AoEWedge(self, t_skill)
	
	-- 타점 기준 원뿔형 수직
	elseif (indicator_type == 'cone') then
		self.m_skillIndicator = SkillIndicator_AoECone(self, t_skill)
	elseif (indicator_type == 'cone_vertical') then
		self.m_skillIndicator = SkillIndicator_AoECone_Vertical(self, t_skill)

	-- 레이저
	elseif (indicator_type == 'bar') then
		self.m_skillIndicator = SkillIndicator_Laser(self, t_skill)
	
	-- 세로로 긴 직사각형
	elseif (indicator_type == 'square_height') then
		local target_type = (t_char['type'] == 'pinkbell') and 'all' or 'enemy'
		self.m_skillIndicator = SkillIndicator_AoESquare_Height(self, t_skill, target_type)
	
    -- 굵은 가로형 직사각형
    elseif (indicator_type == 'square_width') then
		self.m_skillIndicator = SkillIndicator_AoESquare_Width(self, t_skill, true)

	-- 여러 다발의 관통형
	elseif (indicator_type == 'penetration') then
		self.m_skillIndicator = SkillIndicator_Penetration(self, t_skill)

	------------------ 특수한 인디케이터들 ------------------
	
	-- 크래쉬(가루다)
	elseif (indicator_type == 'target_cone') then
		self.m_skillIndicator = SkillIndicator_Crash(self, t_skill)

	-- 리프블레이드 (리프드래곤)
	elseif (indicator_type == 'curve_twin') then
		self.m_skillIndicator = SkillIndicator_LeafBlade(self, t_skill)

	-- 볼테스X (볼테스X)
	elseif (indicator_type == 'voltes_x') then
		self.m_skillIndicator = SkillIndicator_X(self, t_skill, true)

	-- 여러다발의 직사각형 (원더)
    elseif (indicator_type == 'square_multi') then
		self.m_skillIndicator = SkillIndicator_AoESquare_Multi(self, t_skill)

	-- 미정의 인디케이터
	else
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, false)
		cclog('###############################################')
		cclog('## 인디케이터 정의 되지 않은 스킬 : ' .. indicator_type)
		cclog('###############################################')
        return
	end

    self.m_skillIndicator:initIndicatorNode()
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
-- function initActiveSkillCool
-------------------------------------
function Dragon:initActiveSkillCool(percentage)
    local active_skill_id = self:getSkillID('active')
    if (active_skill_id == 0) then
        return
    end

    local table_skill = TABLE:get(self.m_charType .. '_skill')
    local t_skill = table_skill[active_skill_id]
    if (not t_skill) then
        cclog('no skill table : ' .. active_skill_id)
        return
    end

    local role_type = self:getRole()

	-- 초당 회복량 계산
    if (role_type == 'healer') then
        local cooldown = tonumber(t_skill['cooldown'])
        local global_cooltime = g_constant:get('INGAME', 'SKILL_GLOBAL_COOLTIME')
        if (cooldown < global_cooltime) then
            cooldown = global_cooltime
        end

        self.m_activeSkillIncValuePerSec = 0.5 + (100 / cooldown)
    else
        self.m_activeSkillIncValuePerSec = 0.5
    end
                
	-- 스킬 게이지 초기화
	self.m_activeSkillValue = 0

    if (percentage) then
        self:updateActiveSkillCool(percentage / self.m_activeSkillIncValuePerSec)
    end
end

-------------------------------------
-- function increaseActiveSkillCool
-------------------------------------
function Dragon:increaseActiveSkillCool(percentage)
    if (percentage == 0) then return end
    
    local role_type = self:getRole()
    if (role_type == 'tanker') then    
        -- 1초마다 최대 증가값을 넘었다면 증가 시키지 않음
        local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_ACTIVE_POINT_INCREMENT_VALUE')
        if (self.m_activeSkillAccumValue >= t_temp['max_inc_value_per_sec']) then
            return
        end
    end

    local add_time = (percentage / self.m_activeSkillIncValuePerSec)

    self:updateActiveSkillCool(add_time)
end

-------------------------------------
-- function updateActiveSkillCool
-------------------------------------
function Dragon:updateActiveSkillCool(dt)
	-- @TODO 임시 처리
	if (self.m_bDead) then
		return
	end

    if (self.m_activeSkillValue < 100) then
        if (self.m_state ~= 'casting') and (self.m_state ~= 'skillPrepare') then
            local add_value = self.m_activeSkillIncValuePerSec * dt

            self.m_activeSkillValue = self.m_activeSkillValue + add_value
            self.m_activeSkillAccumValue = self.m_activeSkillAccumValue + add_value

            if (self.m_activeSkillAccumTimer == -1) then
                self.m_activeSkillAccumTimer = 0
            end
        end    
    end

    if (self.m_activeSkillValue > 100) then
        self.m_activeSkillValue = 100

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

    do -- 리스너에 전달
	    local t_event = clone(EVENT_DRAGON_SKILL_GAUGE)
	    t_event['owner'] = self
	    t_event['percentage'] = self.m_activeSkillValue
        self:dispatch('dragon_skill_gauge', t_event)
    end
end

-------------------------------------
-- function resetActiveSkillCool
-------------------------------------
function Dragon:resetActiveSkillCool()
    if self:isEndActiveSkillCool() then
        self.m_activeSkillValue = 0

        if (self.m_infoUI.vars['skllFullVisual']) then
            self.m_infoUI.vars['skllFullVisual']:setVisual('skill_gauge', 'idle')
            self.m_infoUI.vars['skllFullVisual']:setVisible(false)
            self.m_infoUI.vars['skllFullVisual2']:setVisible(false)
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

	if (not self:isEndActiveSkillCool()) then
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
-- function isEndActiveSkillCool
-------------------------------------
function Dragon:isEndActiveSkillCool()
    return (self.m_activeSkillValue >= 100)
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

    --self.m_skillPrepareEffect.m_node:setTimeScale(10)
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

-------------------------------------
-- function updateBasicTimeSkillTimer
-- @brief
-------------------------------------
function Dragon:updateBasicTimeSkillTimer(dt)
    local ret = PARENT.updateBasicTimeSkillTimer(self, dt)

    -- 기획적으로 드래곤에 basic_time스킬은 1개만을 사용하도록 한다.
    local skill_info = table.getFirst(self.m_lSkillIndivisualInfo['indie_time'])

    -- 스킬 정보가 있을 경우 쿨타임 진행 정보를 확인한다.
    if (skill_info) then
        local cur = skill_info.m_timer
        local max = skill_info.m_tSkill['chance_value']
        local run_skill = ret -- 스킬 동작 여부

        local t_event = {['cur']=cur, ['max']=max, ['run_skill']=run_skill}
        self:dispatch('basic_time_skill_gauge', t_event)
    end    

    return ret
end

-------------------------------------
-- function runAction_Highlight
-------------------------------------
function Dragon:runAction_Highlight(duration, level)
    PARENT.runAction_Highlight(self, duration, level)
    
    if (self.m_unitInfoNode) then
        self.m_unitInfoNode:setVisible(level == 255)
    end
end
