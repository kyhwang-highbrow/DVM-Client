local PARENT = Character

-------------------------------------
-- class Dragon
-------------------------------------
Dragon = class(PARENT, {
        -- 기본 정보
        m_dragonID = '',			-- 드래곤 테이블 ID (did)
        m_tDragonInfo = 'table',	-- 유저가 보유한 드래곤 정보
		
		m_skillIndicator = '',

        m_skillOffsetX = 'number',
        m_skillOffsetY = 'number',

        -- 스킬 마나
        m_activeSkillManaCost = 'number',

        -- 스킬 쿨타임
        m_activeSkillCoolTimer = 'number',
        m_activeSkillCoolTime = 'number',

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

    self.m_activeSkillManaCost = 0

    self.m_activeSkillCoolTimer = 0
    self.m_activeSkillCoolTime = 0

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

	-- 기본 정보 저장
    self.m_dragonID = dragon_id
    self.m_charTable = t_dragon
    self.m_tDragonInfo = t_dragon_data
    self.m_bLeftFormation = bLeftFormation
    self.m_bPossibleRevive = bPossibleRevive or false

	-- 각종 init 함수 실행
	do
		self:setDragonSkillLevelList(t_dragon_data['skill_0'], t_dragon_data['skill_1'], t_dragon_data['skill_2'], t_dragon_data['skill_3'])
		self:initDragonSkillManager('dragon', dragon_id, evolution)
		self:initStatus(t_dragon, lv, grade, evolution, doid, eclv)
    
		self:initAnimatorDragon(t_dragon['res'], evolution, attr, t_dragon['scale'])
		self:makeCastingNode()
		self:initTriggerListener()
		self:initLogRecorder(doid or dragon_id)
		
		self:initSkillIndicator()
	end
    
	-- 피격 처리
    self:addDefCallback(function(attacker, defender, i_x, i_y)
        self:undergoAttack(attacker, defender, i_x, i_y, 0)
    end)
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
        local skill_indivisual_info = self:getLevelingSkillByType('active')
        if (not skill_indivisual_info) then return end

        local t_skill = skill_indivisual_info.m_tSkill
        self.m_activeSkillManaCost = t_skill['req_mana'] or 0
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
	if (self.m_bLeftFormation) then        
    else
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
    self.m_animator = AnimatorHelper:makeDragonAnimator(file_name, evolution, attr)
    
    if (self.m_animator.m_node) then
        self.m_rootNode:addChild(self.m_animator.m_node)
		if (scale) then
			self.m_animator:setScale(scale / 2)
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
-- function update
-------------------------------------
function Dragon:update(dt)
    if self.m_isUseMovingAfterImage then
        self:updateMovingAfterImage(dt)
    end
                    
    return Character.update(self, dt)
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
-- function release
-------------------------------------
function Dragon:release()
    if (self.m_hpNode) then
        self.m_hpNode:removeFromParent(true)
        self.m_hpNode = nil
    end
        
    self.m_hpGauge = nil
    
    PARENT.release(self)
end

-------------------------------------
-- function doRevive
-- @brief 부할
-------------------------------------
function Dragon:doRevive(hp_rate)
    PARENT.doRevive(self, hp_rate)

    self:updateActiveSkillCool(0)
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Dragon:makeHPGauge(hp_ui_offset)
    self.m_unitInfoOffset = hp_ui_offset
    --self.m_unitInfoOffset[1] = self.m_unitInfoOffset[1] - 80

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
    self.m_hpNode:setVisible(false)

    self.m_hpGauge = ui.vars['hpGauge']
    self.m_hpGauge2 = ui.vars['hpGauge2']

    self.m_statusNode = self.m_hpNode
    
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
-- function initSkillIndicator
-- @brief 스킬 인디케이터 초기화
-------------------------------------
function Dragon:initSkillIndicator()
    local skill_indivisual_info = self:getLevelingSkillByType('active')
    if (not skill_indivisual_info) then return end

    local t_char = self.m_charTable
    local t_skill = skill_indivisual_info.m_tSkill

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

	-- 세로로 긴 직사각형
	elseif (indicator_type == 'target_cone') then
		self.m_skillIndicator = SkillIndicator_AoECone(self, t_skill)

	-- 레이저
	elseif (indicator_type == 'bar') then
		self.m_skillIndicator = SkillIndicator_Laser(self, t_skill)
	
	-- 세로로 긴 직사각형
    elseif (indicator_type == 'square_height' or indicator_type == 'square_height_bottom') then
		self.m_skillIndicator = SkillIndicator_AoESquare_Height(self, t_skill)

    elseif (indicator_type == 'square_height_top') then
        self.m_skillIndicator = SkillIndicator_AoESquare_Height_Top(self, t_skill)
	
    -- 굵은 가로형 직사각형
    elseif (indicator_type == 'square_width' or indicator_type == 'square_width_left') then
		self.m_skillIndicator = SkillIndicator_AoESquare_Width(self, t_skill, true)
    
    -- 굵은 가로형 직사각형(오른쪽 기준)
    elseif (indicator_type == 'square_width_right') then
        self.m_skillIndicator = SkillIndicator_AoESquare_Width_Right(self, t_skill, true)
    
	-- 여러 다발의 관통형
	elseif (indicator_type == 'penetration') then
		self.m_skillIndicator = SkillIndicator_Penetration(self, t_skill)

	------------------ 특수한 인디케이터들 ------------------

	-- 리프블레이드 (리프드래곤)
	elseif (indicator_type == 'curve_twin') then
		self.m_skillIndicator = SkillIndicator_LeafBlade(self, t_skill)

	-- 볼테스X (볼테스X)
	elseif (indicator_type == 'voltes_x') then
		self.m_skillIndicator = SkillIndicator_X(self, t_skill, true)

	-- 여러다발의 직사각형 (원더)
    elseif (indicator_type == 'square_multi') then
		self.m_skillIndicator = SkillIndicator_AoESquare_Multi(self, t_skill)

    elseif (indicator_type == 'cross') then
        self.m_skillIndicator = SkillIndicator_Cross(self, t_skill)
	-- 미정의 인디케이터
	else
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, false)
		cclog('###############################################')
		cclog('## 인디케이터 정의 되지 않은 스킬 : ' .. indicator_type)
		cclog('###############################################')
        return
	end
end

-------------------------------------
-- function initActiveSkillCool
-- @brief 드래그 쿨타임은 세팅
-------------------------------------
function Dragon:initActiveSkillCool()
    local active_skill_id = self:getSkillID('active')
    if (active_skill_id == 0) then return end

    local t_skill = GetSkillTable(self.m_charType):get(active_skill_id)
    if (not t_skill) then
        cclog('no skill table : ' .. active_skill_id)
        return
    end

    self.m_activeSkillCoolTimer = 0
    self.m_activeSkillCoolTime = tonumber(t_skill['cooldown'])
end

-------------------------------------
-- function updateActiveSkillCool
-- @brief 초당 드래그 게이지 증가
-------------------------------------
function Dragon:updateActiveSkillCool(dt)
	if (self:isDead()) then return end
    
    -- 드래그 스킬 쿨타임 갱신
    if (self.m_activeSkillCoolTimer > 0) then
        if (not self:isCasting() and self.m_state ~= 'skillPrepare') then
            self.m_activeSkillCoolTimer = self.m_activeSkillCoolTimer - dt

            if (self.m_activeSkillCoolTimer < 0) then
                self.m_activeSkillCoolTimer = 0
            end
        end
    end

    -- 드래그 스킬 게이지 갱신
    if (self.m_bLeftFormation) then
	    local t_event = clone(EVENT_DRAGON_SKILL_GAUGE)
	    t_event['owner'] = self
	    t_event['percentage'] = (self.m_activeSkillCoolTime - self.m_activeSkillCoolTimer) / self.m_activeSkillCoolTime * 100
        
        if (self.m_bLeftFormation) then
            t_event['enough_mana'] = (self.m_activeSkillManaCost <= self.m_world.m_heroMana:getCurrMana())
        end

        self:dispatch('dragon_skill_gauge', t_event)
    end
end

-------------------------------------
-- function startActiveSkillCoolTime
-------------------------------------
function Dragon:startActiveSkillCoolTime()
    self.m_activeSkillCoolTimer = self.m_activeSkillCoolTime

    self:dispatch('set_global_cool_time_active')
end

-------------------------------------
-- function isEndActiveSkillCool
-------------------------------------
function Dragon:isEndActiveSkillCool()
    if (self.m_activeSkillCoolTimer > 0) then
        return false
    end

    if (self.m_world.m_gameCoolTime:isWaiting(GLOBAL_COOL_TIME.ACTIVE_SKILL)) then
        return false
    end

    return true
end

-------------------------------------
-- function isPossibleSkill
-------------------------------------
function Dragon:isPossibleSkill()
    if (self:isDead()) then
		return false
	end

    if (not self.m_skillIndicator) then
        return
    end

    -- 쿨타임 체크
	if (not self:isEndActiveSkillCool()) then
		return false
	end

    -- 마나 체크
    if (self.m_bLeftFormation) then
        if (self.m_activeSkillManaCost > self.m_world.m_heroMana:getCurrMana()) then
            return false
        end

    elseif (self.m_world.m_enemyMana) then
        if (self.m_activeSkillManaCost > self.m_world.m_enemyMana:getCurrMana()) then
            return false
        end
        
    else
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
-- function setMovingAfterImage
-------------------------------------
function Dragon:setMovingAfterImage(b)
    self.m_afterimageTimer = 0
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

    local interval = -30

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
-- function runAction_Highlight
-------------------------------------
function Dragon:runAction_Highlight(duration, level)
    PARENT.runAction_Highlight(self, duration, level)
    
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
-- function getSkillManaCost
-------------------------------------
function Dragon:getSkillManaCost()
    return self.m_activeSkillManaCost
end