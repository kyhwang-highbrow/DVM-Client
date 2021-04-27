local PARENT = Character

-------------------------------------
-- class Dragon
-------------------------------------
Dragon = class(PARENT, {
        -- 기본 정보
        m_dragonID = '',			-- 드래곤 테이블 ID (did)
        m_tDragonInfo = 'table',	-- 유저가 보유한 드래곤 정보

        m_skillOffsetX = 'number',
        m_skillOffsetY = 'number',

        m_evolutionLv = 'number',

        -- 스킬 마나
        m_activeSkillManaCost = 'SecurityNumberClass',
        m_originActiveSkillManaCost = 'SecurityNumberClass',

        m_skillPrepareEffect = '',
		
        m_isUseMovingAfterImage = 'boolean',
		m_bWaitState = 'boolean',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Dragon:init(file_name, body, ...)
    self.m_charType = 'dragon'
    
    self.m_bWaitState = false

    self.m_skillOffsetX = 0
    self.m_skillOffsetY = 0

    self.m_activeSkillManaCost = SecurityNumberClass(0) -- Mana Reduce 등에 의해 가변
    self.m_originActiveSkillManaCost = SecurityNumberClass(0) -- 테이블의 값 그대로 가지고 있음. 불변.

    self.m_isUseMovingAfterImage = false
    self.m_skillPrepareEffect = nil
end

-------------------------------------
-- function init_dragon
-------------------------------------
function Dragon:init_dragon(dragon_id, t_dragon_data, t_dragon, bLeftFormation, bPossibleRevive)
	local doid = t_dragon_data['id']
    local lv = t_dragon_data['lv'] or 1
    local grade = t_dragon_data['grade'] or 1
    local evolution = t_dragon_data['evolution'] or 1
    local eclv = t_dragon_data['eclv'] or 0
	local attr = t_dragon['attr']
    local scale = t_dragon['scale_' .. evolution] or 0.8

	-- 기본 정보 저장
    self.m_dragonID = dragon_id
    self.m_charTable = t_dragon
    self.m_tDragonInfo = t_dragon_data
    self.m_bLeftFormation = bLeftFormation
    self.m_bPossibleRevive = bPossibleRevive or false
    self.m_evolutionLv = evolution
    self.m_originScale = scale

	-- 각종 init 함수 실행
	do
        self:initAnimatorDragon(t_dragon['res'], evolution, attr, scale)
		self:setDragonSkillLevelList(t_dragon_data['skill_0'], t_dragon_data['skill_1'], t_dragon_data['skill_2'], t_dragon_data['skill_3'])
		self:initDragonSkillManager(t_dragon_data)
		self:initStatus(t_dragon, lv, grade, evolution, doid, eclv)
        
        -- under_self_hp 스킬들은 스텟 구한다음 chance_value 순으로 다시 정렬해줌
        self:setSelfHpSkillOrder()
		
        self:makeCastingNode()
		self:initTriggerListener()
		self:initLogRecorder(doid or dragon_id)
	end
    
	-- 피격 처리
    self:addDefCallback(function(attacker, defender, i_x, i_y)
        self:undergoAttack(attacker, defender, i_x, i_y, 0)
    end)
end

-------------------------------------
-- function initDragonSkillManager
-------------------------------------
function Dragon:initDragonSkillManager(t_dragon_data)
    local evolution = t_dragon_data['evolution'] or 1
    local table_dragon_skill = TableDragonSkill()

    --차원문 시즌효과
    local is_dmgate_stage = g_dmgateData:isStageDimensionGate(self.m_world.m_stageID)

    local is_skip_rune_skill = false

    PARENT.initDragonSkillManager(self, 'dragon', self.m_dragonID, evolution, true)

    if (is_dmgate_stage) then 
        local chapter_id = g_dmgateData:getChapterID(tonumber(self.m_world.m_stageID))

        if (chapter_id > 1) then
            local buff_list = g_dmgateData:getBuffList(DIMENSION_GATE_ANGRA)

            if (#buff_list > 0) then
                for _, t_skill in pairs(buff_list) do
                    local skill_id = t_skill['sid']

                    if (isNullOrEmpty(t_skill) or isNullOrEmpty(skill_id)) then
                        error('invalid bless skill : ' .. skill_id)
                    end

                    -- bless  로 시작 패시브를 걸거나
                    -- {chance_type}로 다른 타입의 스킬을 저장
                    local bless_skill_type = t_skill['chance_type'] == 'passive' and 'bless' or t_skill['chance_type']
                    local bless_skill_info = self:setSkillID(bless_skill_type, skill_id, 1, 'new')
                    
                    if (bless_skill_info) then
                        bless_skill_info:setToIgnoreCC(true)
                        bless_skill_info:setToIgnoreReducedCool(true)
                    end
                end

            end
        --[[
        else
            is_skip_rune_skill = true]]
        end
    end

    if (is_skip_rune_skill) then return end

    -- 룬 셋트 스킬 적용
    local dragon_obj = StructDragonObject(t_dragon_data)

    for skill_id, count in pairs(dragon_obj:getRuneSetSkill()) do
        local t_skill = table_dragon_skill:get(skill_id)
        if (not t_skill) then
            error('invalid rune set skill : ' .. skill_id)
        end
        
        --cclog('rune set skill name : ' .. Str(t_skill['t_name']) .. '(' .. count .. ')')

        local skill_indivisual_info = self:setSkillID(t_skill['chance_type'], skill_id, 1, 'new')
        skill_indivisual_info:setToIgnoreCC(true)
        skill_indivisual_info:setToIgnoreReducedCool(true)

        -- 고대룬 2셋트 효과들은 중첩을 별도로 처리
        if (skill_id == 500200) then
            -- 반격 세트는 중첩시 기절 시간 증가
            if (count > 1) then
                local add_value = count - 1
                skill_indivisual_info:addBuff('hit', add_value, 'add', true)
            end

        elseif (skill_id == 500300) then
            -- 생존 세트는 중첩시 무적 시간 증가(수식이 사용되지 않았다고 가정)
            if (count > 1) then
                local add_value = t_skill['add_option_time_1'] * (count - 1)
                skill_indivisual_info:addBuff('add_option_time_1', add_value, 'add', true)
            end

        elseif (skill_id == 500400) then
            -- 앙심 세트는 중첩시 발동 확률 증가
            if (count > 1) then
                local add_value = t_skill['chance_value'] * (count - 1)
                skill_indivisual_info:addBuff('chance_value', add_value, 'add', true)
            end
        end
    end
end

-------------------------------------
-- function setStatusCalc
-------------------------------------
function Dragon:setStatusCalc(status_calc)
    PARENT.setStatusCalc(self, status_calc)

    if (not self.m_statusCalc) then
        return
    end

    -- 스킬 마나 지정
    do
        local skill_indivisual_info = self:getSkillIndivisualInfo('active')
        if (not skill_indivisual_info) then return end

        local t_skill = skill_indivisual_info.m_tSkill
        local req_mana = t_skill['req_mana']

        if (not req_mana or req_mana == '') then
            req_mana = 1
        end

        self.m_activeSkillManaCost:set(req_mana)
        self.m_originActiveSkillManaCost:set(req_mana)
    end

    -- 스킬 쿨타임 지정
    self:initActiveSkillCool()
end

-------------------------------------
-- function initFormation
-------------------------------------
function Dragon:initFormation()
    self:makeHPGauge({0, -80})

	-- 진영에 따른 처리
	if (not self.m_bLeftFormation) then        
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
        self.m_animator:release()
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimatorByTransform(self.m_tDragonInfo)
    --self.m_animator = AnimatorHelper:makeDragonAnimator(file_name, evolution, attr)
    
    if (self.m_animator.m_node) then
        self.m_rootNode:addChild(self.m_animator.m_node)

        -- scale을 강제로 조정...
		if (scale) then
			self.m_animator:setScale(scale / 2)
		end

        self.m_originScale = self.m_animator:getScale()
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

    -- 차지 이펙트 생성
    do
        local res = 'res/effect/effect_melee_charge/effect_melee_charge.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('idle_' .. attr, false)
        animator:setPosition(0, -50)
        animator:setVisible(false)
        self.m_rootNode:addChild(animator.m_node)
        
        self.m_chargeDuration = animator:getDuration()
        self.m_chargeEffect = animator

        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_chargeEffect.m_node)
    end
end

-------------------------------------
-- function update
-------------------------------------
function Dragon:update(dt)
    -- 잔상
    if (self.m_isUseMovingAfterImage) then
        self:updateMovingAfterImage(dt)
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function doAppear
-------------------------------------
function Dragon:doAppear()
    if (self:isDead()) then return end

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
function Dragon:doAttack(skill_id, x, y)
    PARENT.doAttack(self, skill_id, x, y)

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
-- function initWorld
-- @param game_world
-------------------------------------
function Dragon:initWorld(game_world)
    if (not self.m_unitStatusIconNode) then
        self.m_unitStatusIconNode = cc.Node:create()
        game_world.m_unitStatusNode:addChild(self.m_unitStatusIconNode, 2)
        
        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_unitStatusIconNode)
    end

    if (not self.m_unitInfoNode) then
        self.m_unitInfoNode = cc.Node:create()
        game_world.m_dragonInfoNode:addChild(self.m_unitInfoNode)

        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_unitInfoNode)
    end

    PARENT.initWorld(self, game_world)
end


-------------------------------------
-- function setDead
-------------------------------------
function Dragon:setDead()
    local b = PARENT.setDead(self)

    if (b) then
        if (self.m_bLeftFormation) then
            -- @LOG : 죽은 아군 수 (소환을 하는 경우 추가 될 수 있음)
	        self.m_world.m_logRecorder:recordLog('death_cnt', 1)
        end
    end

    return b
end

-------------------------------------
-- function doRevive
-- @brief 부할
-------------------------------------
function Dragon:doRevive(hp_rate, caster, is_abs)
    local b = PARENT.doRevive(self, hp_rate, caster, is_abs)

    self:updateActiveSkillTimer(0)

    return b
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Dragon:makeHPGauge(hp_ui_offset)
    self.m_unitInfoOffset = hp_ui_offset

    if (self.m_hpNode) then
        self.m_hpNode:removeFromParent()
    end

    local ui

    if (self.m_bLeftFormation) then
        ui = UI_IngameDragonInfo(self)
    else
        ui = UI_IngameUnitInfo(self)
    end

    self.m_hpNode = ui.root
    self.m_hpNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setVisible(false)

    self.m_hpGauge = ui.vars['hpGauge']
    self.m_hpGauge2 = ui.vars['hpGauge2']

    self.m_unitInfoNode:addChild(self.m_hpNode, 5)

    self.m_infoUI = ui

    self:makeStatusIconNode(self.m_unitStatusIconNode)
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
-- function initActiveSkillCool
-- @brief 드래그 쿨타임은 세팅
-------------------------------------
function Dragon:initActiveSkillCool(sec)
    local sec = sec or 0
    local skill_info = self:getSkillIndivisualInfo('active')

    if (skill_info) then
        skill_info:setCoolTime(sec)
    end
end

-------------------------------------
-- function updateActiveSkillTimer
-- @brief 초당 드래그 게이지 증가
-------------------------------------
function Dragon:updateActiveSkillTimer(dt)
	if (self:isDead()) then return end
    if (self:isCasting()) then return end
    if (self.m_state == 'skillPrepare') then return end

    local drag_cool = self:getStat('drag_cool') or 0
    PARENT.updateActiveSkillTimer(self, dt, drag_cool)

    -- 드래그 스킬 게이지 갱신
    if (self.m_bLeftFormation) then
        local skill_info = self:getSkillIndivisualInfo('active')
        if (skill_info) then
            local timer, percentage = skill_info:getCoolTimeForGauge()
            local t_event = clone(EVENT_DRAGON_SKILL_GAUGE)

	        t_event['owner'] = self
            t_event['cool_time'] = timer
	        t_event['percentage'] = percentage
            t_event['enough_mana'] = (self.m_activeSkillManaCost:get() <= self.m_world:getMana(self):getCurrMana())
        
            self:dispatch('dragon_skill_gauge', t_event)
        end
    end
end

-------------------------------------
-- function isEndActiveSkillCool
-------------------------------------
function Dragon:isEndActiveSkillCool()
    local skill_info = self:getSkillIndivisualInfo('active')
    if (skill_info and not skill_info:isEndCoolTime()) then
        return false
    end

    if (self.m_world.m_gameCoolTime:isWaiting(GLOBAL_COOL_TIME.ACTIVE_SKILL)) then
        return false
    end

    return true
end

-------------------------------------
-- function isPossibleActiveSkill
-------------------------------------
function Dragon:isPossibleActiveSkill(map_except)
    local map_except = map_except or {}
    local b = true
    local m_reason = {}

    if (self:isDead()) then
        if (not map_except[REASON_TO_DO_NOT_USE_SKILL.DEAD]) then
            b = false
            m_reason[REASON_TO_DO_NOT_USE_SKILL.DEAD] = true
        end
	end

    if (not self:getSkillIndicator()) then
        if (not map_except[REASON_TO_DO_NOT_USE_SKILL.NO_INDICATOR]) then
            b = false
            m_reason[REASON_TO_DO_NOT_USE_SKILL.NO_INDICATOR] = true
        end
    end

    -- 이미 스킬을 사용하기 위한 상태나 사용 중인 경우
    if (isExistValue(self.m_state, 'skillPrepare', 'skillAppear', 'skillIdle', 'delegate')) then
        if (not map_except[REASON_TO_DO_NOT_USE_SKILL.USING_SKILL]) then
            b = false
            m_reason[REASON_TO_DO_NOT_USE_SKILL.USING_SKILL] = true
        end
    end

    -- 스킬 사용 불가 상태효과가 있을 경우
    if (self:hasStatusEffectToDisableSkill()) then
        if (not map_except[REASON_TO_DO_NOT_USE_SKILL.STATUS_EFFECT]) then
            b = false
            m_reason[REASON_TO_DO_NOT_USE_SKILL.STATUS_EFFECT] = true
        end
    end
    
    -- 마나 체크
    if (self.m_activeSkillManaCost:get() > self.m_world:getMana(self):getCurrMana()) then
        if (not map_except[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK]) then
            b = false
            m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = true
        end
    end
    
    -- 쿨타임 체크
	if (not self:isEndActiveSkillCool()) then
        if (not map_except[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME]) then
            b = false
            m_reason[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME] = true
        end
	end

    return b, m_reason
end

-------------------------------------
-- function setMovingAfterImage
-------------------------------------
function Dragon:setMovingAfterImage(b)
    self.m_afterimageTimer = 0

    if (isLowEndMode()) then
        self.m_isUseMovingAfterImage = false
        return
    end

    self.m_isUseMovingAfterImage = b

end

-------------------------------------
-- function updateMovingAfterImage
-- @brief updateAfterImage와는 생성한 잔상이 직접 움직인다는 차이점이 있다.
-------------------------------------
function Dragon:updateMovingAfterImage(dt)
    local speed = self.m_world.m_mapManager.m_speed

    -- 에프터이미지
    self.m_afterimageTimer = self.m_afterimageTimer + (speed * dt)

    local interval = -60
    if (self.m_afterimageTimer <= interval) then
        self.m_afterimageTimer = self.m_afterimageTimer - interval

        local duration = (interval / speed) * 1.5 -- 3개의 잔상이 보일 정도
        duration = math_clamp(duration, 0.3, 0.7)

        local res = self.m_animator.m_resName
        local scale = self.m_animator:getScale()

        -- GL calls를 줄이기 위해 월드를 통해 sprite를 얻어옴
        local sprite = self.m_world:getDragonBatchNodeSprite(res, scale)
        sprite:setFlippedX(self.m_animator.m_bFlip)
        sprite:setOpacity(255 * 0.2)
        sprite:setPosition(self.pos.x, self.pos.y)
        
        sprite:runAction(cc.MoveBy:create(duration, cc.p(speed / 2, 0)))
        sprite:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))
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
-- function runAction_Highlight
-------------------------------------
function Dragon:runAction_Highlight(duration, level)
    PARENT.runAction_Highlight(self, duration, level)

    if (self.m_unitStatusIconNode) then
        self.m_unitStatusIconNode:setVisible(level == 255)
    end
    
    if (self.m_unitInfoNode) then
        self.m_unitInfoNode:setVisible(level == 255)
    end
end

-------------------------------------
-- function getRarity
-- @return 희귀도(보스 판정으로 사용)
-------------------------------------
function Dragon:getRarity()
    -- 드래곤은 몬스터보다 무조건 높아야하고 레벨로 설정함
    local rarity = 10 + self.m_lv
    return rarity
end

-------------------------------------
-- function getGrade
-------------------------------------
function Dragon:getGrade()
    if (not self.m_tDragonInfo) then return 1 end

	return self.m_tDragonInfo['grade']
end

-------------------------------------
-- function getLevel
-------------------------------------
function Dragon:getLevel()
    if (not self.m_tDragonInfo) then return 1 end

	return self.m_tDragonInfo['lv']
end

-------------------------------------
-- function getExp
-------------------------------------
function Dragon:getExp()
    if (not self.m_tDragonInfo) then return 0 end

	return self.m_tDragonInfo['exp']
end

-------------------------------------
-- function isFarmer
-------------------------------------
function Dragon:isFarmer()
    if (not self.m_tDragonInfo) then 
		return false 
	end
	return self.m_tDragonInfo:isFarmer()
end

-------------------------------------
-- function getTotalLevel
-------------------------------------
function Dragon:getTotalLevel()
    local prev_grade = self:getGrade() - 1
    local total_lv = 0
    
    for i = 1, prev_grade do
        local max_level = dragonMaxLevel(i)
        total_lv = total_lv + max_level
    end
    
    total_lv = total_lv + self.m_lv

	return total_lv
end

-------------------------------------
-- function getOriginSkillManaCost
-------------------------------------
function Dragon:getOriginSkillManaCost()
    return self.m_originActiveSkillManaCost:get()
end

-------------------------------------
-- function getSkillManaCost
-------------------------------------
function Dragon:getSkillManaCost()
    return self.m_activeSkillManaCost:get()
end

-------------------------------------
-- function setSkillManaCost
-------------------------------------
function Dragon:setSkillManaCost(value)
    self.m_activeSkillManaCost:set(value)
end

-------------------------------------
-- function getSizeType
-------------------------------------
function Dragon:getSizeType()
    return self.m_evolutionLv, 'dragon'
end

-------------------------------------
-- function getSkillIndicator
-------------------------------------
function Dragon:getSkillIndicator()
    local skill_info = self:getSkillIndivisualInfo('active')
    if (skill_info) then
        return skill_info.m_indicator
    end
end

-------------------------------------
-- function updateDebugingInfo
-- @brief 인게임 정보 출력용 업데이트
-------------------------------------
function Dragon:updateDebugingInfo()
    -- 화면에 드래그 쿨타임 표시
	if (g_constant:get('DEBUG', 'DISPLAY_ENEMY_MANA_COOLDOWN')) then 
        local skill_info = self:getSkillIndivisualInfo('active')
        if (skill_info and not skill_info:isEndCoolTime()) then
            local cool_time = skill_info:getCoolTimeForGauge()
            self.m_infoUI.m_label:setString(string.format('%d', cool_time))
        else
            self.m_infoUI.m_label:setString('')
        end

    else
        PARENT.updateDebugingInfo(self)

    end
end