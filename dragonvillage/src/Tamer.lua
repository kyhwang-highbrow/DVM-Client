local PARENT = Character

local TAMER_SKILL_ACTIVE = 1
local TAMER_SKILL_PASSIVE = 2

local MAX_TAMER_SKILL = 3
local TAMER_Z_POS = 100

local TAMER_ACTION_TAG__MOVE_Z = 10

-------------------------------------
-- class Tamer
-------------------------------------
Tamer = class(PARENT, {
        -- 기본 정보
        m_tamerID = '',    -- 드래곤의 고유 ID

        m_barrier = '',

        m_afterimageMove = 'number',
        m_bUseSelfAfterImage = 'boolean',
        m_bWaitState = 'boolean',

        m_lSkill = 'list',
        m_lSkillCoolTimer = 'list',
		m_bActiveSKillUsable = 'boolean',

        m_roamTimer = '',
        m_baseAnimatorScale = '',

        m_targetItem = 'DropItem',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Tamer:init(file_name, body, ...)
    self.m_charType = 'tamer'
	self.m_attribute = 'earth'

    self.m_bWaitState = false
    self.m_bUseSelfAfterImage = false

    self.m_lSkill = {}
    self.m_lSkillCoolTimer = {}
	self.m_bActiveSKillUsable = true

    self.m_roamTimer = 0
    self.m_baseAnimatorScale = 0.5

    self.m_targetItem = nil
end

-------------------------------------
-- function init_tamer
-------------------------------------
function Tamer:init_tamer(t_tamer, bLeftFormationend)
    self.m_charTable = t_tamer
    self.m_bLeftFormation = bLeftFormationend

    local t_tamer = self.m_charTable
	local table_tamer_skill = TableTamerSkill()
	
	-- @TODO
	for i = 1, MAX_TAMER_SKILL do
		local skill_id = 249001 + (i * 100) --t_tamer['skill_' .. i]
		self.m_lSkill[i] = table_tamer_skill:getTamerSkill(skill_id)
		self.m_lSkillCoolTimer[i] = self.m_lSkill[i]['cooldown']
	end

	-- TAMER UI 생성
	self.m_world.m_inGameUI:initTamerUI(self)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Tamer:initAnimator(file_name)
    PARENT.initAnimator(self, file_name)

    -- 보호막
    self.m_barrier = MakeAnimator('res/effect/effect_tamer_shield/effect_tamer_shield.vrp')
    self.m_animator.m_node:addChild(self.m_barrier.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function Tamer:initState()
    self:addState('appear', Tamer.st_appear, 'i_idle', true)
    self:addState('idle', PARENT.st_idle, 'i_idle', true)
    self:addState('roam', Tamer.st_roam, 'i_idle', true)
    self:addState('bring', Tamer.st_bring, 'i_idle', true)

	self:addState('active', Tamer.st_active, 'skill_1', true)
	self:addState('passive', Tamer.st_passive, 'skill_2', true)

    self:addState('wait', Tamer.st_wait, 'i_idle', true)
    self:addState('move', PARENT.st_move, 'i_idle', true)

    self:addState('success_pose', Tamer.st_success_pose, 'i_idle', true)
    self:addState('success_move', Tamer.st_success_move, 'i_idle', true)

    self:addState('dying', Tamer.st_dying, 'i_dying', false, PRIORITY.DYING)
    self:addState('dead', PARENT.st_dead, nil, nil, PRIORITY.DEAD)

    self:addState('comeback', PARENT.st_comeback, 'i_idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function Tamer:update(dt)
    if self.m_bUseSelfAfterImage then
        self:updateAfterImage(dt)
    end

    if (not self.m_bDead and self.m_world:isPossibleControl()) then
        if (self.m_lSkillCoolTimer[TAMER_SKILL_PASSIVE] > 0) then
            self.m_lSkillCoolTimer[TAMER_SKILL_PASSIVE] = math_max(self.m_lSkillCoolTimer[TAMER_SKILL_PASSIVE] - dt, 0)
	    else
		    self:changeState('passive')
		    self.m_lSkillCoolTimer[TAMER_SKILL_PASSIVE] = self.m_lSkill[TAMER_SKILL_PASSIVE]['cooldown']
        end
    end

    self:syncAniAndPhys()
        
    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_appear
-- @brief 테이머 배회
-------------------------------------
function Tamer.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_bLeftFormation) then
            owner:setPosition(-300, 0)
            owner:setMove(CRITERIA_RESOLUTION_X / 2 - 80, 0, 700)
        end
    end
end

-------------------------------------
-- function st_roam
-- @brief 테이머 배회
-------------------------------------
function Tamer.st_roam(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_roamTimer = 0

        owner:setAfterImage(false)
    end

    if (owner.m_roamTimer <= 0) then
        -- 현재 위치가 몇사분면인지 계산
        local quadrant = getQuadrant(
            CRITERIA_RESOLUTION_X / 4,
            0,
            owner.pos.x,
            owner.pos.y
        )

        -- 다음 분면을 목표 지점으로 함
        quadrant = quadrant + 1
        if (quadrant > 4) then
            quadrant = quadrant - 4
        end
        
        local tar_x, tar_y, tar_z
        
        if (quadrant == 1) then
            tar_x = math_random(CRITERIA_RESOLUTION_X / 4, CRITERIA_RESOLUTION_X / 2)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2 - 100)
        elseif (quadrant == 2) then
            tar_x = math_random(CRITERIA_RESOLUTION_X / 4, CRITERIA_RESOLUTION_X / 2)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2) - (CRITERIA_RESOLUTION_Y / 2 - 150)
        elseif (quadrant == 3) then
            tar_x = math_random(100, CRITERIA_RESOLUTION_X / 4)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2) - (CRITERIA_RESOLUTION_Y / 2 - 150)
        elseif (quadrant == 4) then
            tar_x = math_random(100, CRITERIA_RESOLUTION_X / 4)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2 - 100)
        end
        tar_z = TAMER_Z_POS
        
        local cameraHomePosX, cameraHomePosY = owner.m_world.m_gameCamera:getHomePos()
        tar_x = (tar_x + cameraHomePosX)
        tar_y = (tar_y + cameraHomePosY)

        local course = math_random(-1, 1)
        local time = math_random(15, 30) / 10
        local bezier = getBezier(tar_x, tar_y, owner.pos.x, owner.pos.y, course)
        local move_action = cc.BezierBy:create(time, bezier)
                
        owner.m_rootNode:stopAllActions()
        owner.m_rootNode:runAction(move_action)

        owner:runAction_MoveZ(time, tar_z)
                        
        owner.m_roamTimer = time + (math_random(0, 10) * 0.1)    -- 0 ~ 1초 사이로 잠시 멈추도록
    end

    owner.m_roamTimer = owner.m_roamTimer - dt
end

-------------------------------------
-- function st_bring
-- @brief 드랍아이템을 가져오는 연출
-------------------------------------
function Tamer.st_bring(owner, dt)
    if (owner.m_stateTimer == 0) then
        local prevPosX = owner.pos.x
        local prevPosY = owner.pos.y
        local prevScale = owner.m_rootNode:getScale()
        
        local time1 = 0.1
        local move_action1 = cc.MoveTo:create(time1, cc.p(owner.m_targetItem.pos.x, owner.m_targetItem.pos.y))
        local callFunc_action1 = cc.CallFunc:create(function()
            owner:runAction_MoveZ(time1, 0)
        end)

        local time2 = 0.2
        local move_action2 = cc.MoveTo:create(time2, cc.p(prevPosX, prevPosY))
        local callFunc_action2 = cc.CallFunc:create(function()
            owner:runAction_MoveZ(time2, TAMER_Z_POS)
        end)
        
        owner.m_rootNode:stopAllActions()
        owner.m_rootNode:runAction(cc.Sequence:create(
            cc.Spawn:create(move_action1, callFunc_action1),
            cc.DelayTime:create(0.5),
            cc.Spawn:create(move_action2, callFunc_action2),
            cc.CallFunc:create(function()
                owner:changeState('roam')
                owner:setAfterImage(false)
            end)
        ))

        owner.m_animator:changeAni('i_summon', false)
        owner.m_animator:addAniHandler(function()
            owner.m_animator:changeAni('i_idle', true)
        end)

        owner.m_afterimageMove = 0
        owner:setAfterImage(true)
            
    else
        owner:updateAfterImage(dt)
    end
end

-------------------------------------
-- function st_active
-------------------------------------
function Tamer.st_active(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 화면 위치 찾기 위함
		local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
		-- 연출 세팅
		owner:setTamerSkillDirecting(CRITERIA_RESOLUTION_X/2, cameraHomePosY + 200, TAMER_SKILL_ACTIVE)
	
		-- 스킬 동작
		owner:doSkillActive()     
    end
end

-------------------------------------
-- function st_passive
-------------------------------------
function Tamer.st_passive(owner, dt)
    if (owner.m_stateTimer == 0) then
		local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
		-- 연출 세팅
		owner:setTamerSkillDirecting(CRITERIA_RESOLUTION_X/4, cameraHomePosY + 200, TAMER_SKILL_PASSIVE)

		-- 패시브 발동
		owner:doSkillPassive()
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function Tamer.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_bDead == false) then
            owner:setDead()
        end
        owner.m_rootNode:stopAllActions()

		owner.m_barrier:changeAni('disappear', false)
        owner.m_barrier:addAniHandler(function()
            owner.m_barrier:setVisible(false)

            local action = cc.Sequence:create(
                cc.MoveBy:create(3, cc.p(0, -2000)),
                cc.CallFunc:create(function()
                    owner:changeState('dead')
                end)
            )
            owner:runAction(action)            
        end)
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function Tamer.st_wait(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_rootNode:stopAllActions()
    end
end

-------------------------------------
-- function st_success_pose
-- @brief success 세레머니
-------------------------------------
function Tamer.st_success_pose(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner.m_animator:changeAni('i_idle', true)
        end)

    elseif (owner.m_stateTimer >= 2.5) then
        owner:changeState('success_move')
    end
end

-------------------------------------
-- function st_success_move
-- @brief success 세레머니 후 오른쪽으로 퇴장
-------------------------------------
function Tamer.st_success_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        --local add_speed = (owner.pos['y'] / -100) * 100
        local add_speed = math_random(-2, 2) * 100
        owner:setMove(owner.pos.x + 2000, owner.pos.y, 1500 + add_speed)

        owner.m_afterimageMove = 0

        owner:setAfterImage(true)
    end
end

-------------------------------------
-- function setTamerSkillDirecting
-------------------------------------
function Tamer:setTamerSkillDirecting(move_pos_x, move_pos_y, skill_idx)
	local world = self.m_world
	local game_highlight = world.m_gameHighlight

	-- 하이라이트 활성화
    game_highlight:setMode(GAME_HIGHLIGHT_MODE_DRAGON_SKILL)

	-- 하이라이트 대상 추가 (테이머 + 드래곤)
    game_highlight:addChar(self)
	for _, dragon in pairs(world:getDragonList()) do
		game_highlight:addChar(dragon)
	end

    -- 암전
	game_highlight:changeDarkLayerColor(254, 0.5)

	-- 스킬 이름 말풍선
	local skill_name = Str(self.m_lSkill[skill_idx]['t_name'])
	SkillHelper:makePassiveSkillSpeech(self, skill_name)

	-- 연출 이동
    self:setHomePos(self.pos.x, self.pos.y)
    self:setMove(move_pos_x, move_pos_y, 2000)
	self:runAction_MoveZ(0.1, 0)

	-- 애프터 이미지
    self.m_afterimageMove = 0
    self:setAfterImage(true)
		
	-- 애니메이션 종료시
	self:addAniHandler(function()
		-- roam상태로 변경
        self:changeStateWithCheckHomePos('roam')
		-- 하이라이트 비활성화
        game_highlight:setMode(GAME_HIGHLIGHT_MODE_HIDE)
        game_highlight:clear()
        -- 암전 해제 -> @TODO 암전 해제 연출 살짝 어긋나는건...
		game_highlight:changeDarkLayerColor(0, 0.2)
		-- 애프터 이미지 해제
		self:setAfterImage(false)
    end)
end

-------------------------------------
-- function setWaitState
-------------------------------------
function Tamer:setWaitState(is_wait_state)
    self.m_bWaitState = is_wait_state

    if is_wait_state then
        if isExistValue(self.m_state, 'idle', 'roam') then
            self:changeState('wait')
        end
    else
        if (self.m_state == 'wait') then
            self:changeState('roam')
        end
    end
end

-------------------------------------
-- function runAction_Floating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function Tamer:runAction_Floating()
end

-------------------------------------
-- function runAction_MoveZ
-- @brief 테이머 z축 이동
-------------------------------------
function Tamer:runAction_MoveZ(time, tar_z)
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    local tar_z = tar_z or TAMER_Z_POS

    local scale_action = cc.ScaleTo:create(time, self.m_baseAnimatorScale * (1 - (0.003 * tar_z)))
    local tint_action = cc.TintTo:create(time, 255 - tar_z, 255 - tar_z, 255 - tar_z)
    local action = cc.Spawn:create(scale_action, tint_action)

    cca.runAction(target_node, action, TAMER_ACTION_TAG__MOVE_Z)
end

-------------------------------------
-- function setAnimatorScale
-------------------------------------
function Tamer:setAnimatorScale(scale)
    self.m_animator:setScale(scale)

    self.m_baseAnimatorScale = scale
end

-------------------------------------
-- function setAfterImage
-------------------------------------
function Tamer:setAfterImage(b)
    Dragon.setAfterImage(self, b)
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function Tamer:updateAfterImage(dt)
    Dragon.updateAfterImage(self, dt)
end

-------------------------------------
-- function changeHomePosByTime
-------------------------------------
function Tamer:changeHomePosByTime(x, y, time)
    PARENT.changeHomePosByTime(self, x, y, time)

    --self:runAction_MoveZ(time, 0)
end

-------------------------------------
-- function doSkill
-------------------------------------
function Tamer:doSkill(skill_idx)
	local t_skill = self.m_lSkill[skill_idx]
	
	PARENT.doSkillBySkillTable(self, t_skill, nil)
	
	--[[
	if (t_skill['skill_form'] == 'status_effect') then 
		-- 1. skill의 타겟룰로 상태효과의 대상 리스트를 얻어옴
		local l_target = self:getTargetListByTable(t_skill)
        if (not l_target) then return end

		-- 2. 상태효과 문자열(;로 구분)
		local status_effect_str = {t_skill['status_effect_1'], t_skill['status_effect_2']}

		-- 3. 타겟에 상태효과생성
		StatusEffectHelper:doStatusEffectByStr(self, l_target, status_effect_str)

	else
		cclog('미구현 테이머 스킬 : ' .. t_skill['sid'] .. ' / ' .. t_skill['t_name'])
		return false
	end
	]]
    self.m_lSkillCoolTimer[skill_idx] = t_skill['cooldown'] 

	return true
end

-------------------------------------
-- function doSkillActive
-------------------------------------
function Tamer:doSkillActive()
    --[[
    self.m_world:dispatch('tamer_skill', {}, function()
        self:showToolTipActive()
        self:doSkill(TAMER_SKILL_ACTIVE)
    end, idx)
    ]]--

    self.m_world:dispatch('tamer_skill')
    return self:doSkill(TAMER_SKILL_ACTIVE)
end

-------------------------------------
-- function doSkillPassive
-------------------------------------
function Tamer:doSkillPassive()
    return self:doSkill(TAMER_SKILL_PASSIVE)
end

-------------------------------------
-- function doSkillFixedPassive
-------------------------------------
function Tamer:doSkillFixedPassive()
    return self:doSkill(3)
end

-------------------------------------
-- function showToolTipActive
-------------------------------------
function Tamer:showToolTipActive()
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]
    local str = UI_Tooltip_Skill:getSkillDescStr('tamer', t_skill['sid'])

    local tool_tip = UI_Tooltip_Skill(320, -220, str, true)
    tool_tip:autoRelease()
end

-------------------------------------
-- function resetActiveSkillCool
-------------------------------------
function Tamer:resetActiveSkillCool()
    self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = 0
end

-------------------------------------
-- function isEndActiveSkillCool
-------------------------------------
function Tamer:isEndActiveSkillCool()
    return (self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] == 0)
end

-------------------------------------
-- function isPossibleSkill
-------------------------------------
function Tamer:isPossibleSkill()
    if (not self:isEndActiveSkillCool()) then
		return false
	end

    return true
end

-------------------------------------
-- function getActiveSkillTable
-------------------------------------
function Tamer:getActiveSkillTable()
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]
    return t_skill
end

-------------------------------------
-- function doBringItem
-------------------------------------
function Tamer:doBringItem(item)
    self.m_targetItem = item

    self:changeState('bring')
end