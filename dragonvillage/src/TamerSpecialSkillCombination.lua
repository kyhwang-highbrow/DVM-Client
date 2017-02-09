local PARENT = Entity

 -- # 스페셜 스킬 상수
 local PENTAGON_POS = {
	{x = 0, y = 100},
	{x = 100, y = 50},
	{x = 80, y = -100},
	{x = -80, y = -100},
	{x = -100, y = 50}
}
local STD_X = 900
local STD_Y = 45
local SPEED = 2500
local ATTACK_INTERVAL = 0.2
local MAX_HIT = 10

-------------------------------------
-- class TamerSpecialSkillCombination
-- @brief 고니가 사용하는 테이머 궁극기
-------------------------------------
TamerSpecialSkillCombination = class(PARENT, {
		m_activityCarrier = 'ActivityCarrier',
		m_world = 'Game World',
		m_mainEffect = 'effect',
		m_lDragonEffect = 'effect',
		m_res = 'resource path',

		m_lDragon = 'list[dragon]',
		m_tTarget = 'all enemy',
		m_powerMultiply = 'num',

		m_hitCnt = 'num',
		m_maxHitCnt = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function TamerSpecialSkillCombination:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function TamerSpecialSkillCombination:init_skill(res, world, power_multiply)
	self.m_res = res
	self.m_world = world
	self.m_lDragon = world:getDragonList()
	self.m_tTarget = world:getEnemyList()
	self.m_powerMultiply = power_multiply

	self.m_hitCnt = 0
	self.m_maxHitCnt = MAX_HIT

	self.m_lDragonEffect = {}

	self:setActivityCarrier()
end

-------------------------------------
-- function setActivityCarrier
-------------------------------------
function TamerSpecialSkillCombination:setActivityCarrier()
	for _, dragon in pairs(self.m_lDragon) do
		if (not self.m_activityCarrier) then
			self.m_activityCarrier = dragon:makeAttackDamageInstance()
			self.m_activityCarrier.m_skillCoefficient = self.m_powerMultiply/MAX_HIT
		else
			local activity_carrier = dragon:makeAttackDamageInstance()
			self.m_activityCarrier:mergeStat(activity_carrier)
		end
	end

    self.m_activityCarrier.m_attackType = 'special'
end

-------------------------------------
-- function initState
-------------------------------------
function TamerSpecialSkillCombination:initState()
    self:addState('start', TamerSpecialSkillCombination.st_start, nil, false) 
	self:addState('phase_1', TamerSpecialSkillCombination.st_phase_1, nil, false)
	self:addState('phase_2', TamerSpecialSkillCombination.st_phase_2, nil, false)
    self:addState('phase_3', TamerSpecialSkillCombination.st_phase_3, nil, false)
	self:addState('dying', TamerSpecialSkillCombination.st_end, nil, false)
end

-------------------------------------
-- function st_start
-------------------------------------
function TamerSpecialSkillCombination.st_start(owner, dt)
	if (owner.m_stateTimer == 0) then
		-- 1. 모든 드래곤에게 벼락 이벤트 시전 후 idle_dragon으로 상태 변경
		local thunder_effect = nil
		for _, dragon in pairs(owner.m_lDragon) do 
			thunder_effect = MakeAnimator(owner.m_res)
			thunder_effect:changeAni('start', false)
			thunder_effect:setPosition(cc.p(0, 0))

			dragon.m_rootNode:addChild(thunder_effect.m_node)
			
			-- 리스트에 이펙트 저장
			owner.m_lDragonEffect[dragon] = thunder_effect
			
			-- dragon 정지
			dragon:changeState('delegate')

            -- dragon 무적상태 부여
            dragon:setInvincibility(true)
		end
		
		-- 타겟도 정지
		for _, target in pairs(owner.m_tTarget) do 
            if (not target.m_bDead and not isInstanceOf(target, MonsterLua_Boss)) then
			    target:changeState('delegate')
            end
		end

        -- 게임 조작 막음
        owner.m_world.m_bPreventControl = true

	elseif (owner.m_stateTimer >= 0.5) then
		for _, dragon in pairs(owner.m_lDragon) do 
			owner.m_lDragonEffect[dragon]:changeAni('idle_dragon', true)
		end

		-- 2. 적당한 시간 후 다음 페이즈로 이동
		owner:changeState('phase_1')
	end
end

-------------------------------------
-- function st_phase_1
-------------------------------------
function TamerSpecialSkillCombination.st_phase_1(owner, dt)
	-- 1. 모든 드래곤을 순회하며 지정된 위치로 이동 시킴
	if (owner.m_stateTimer == 0) then
        local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()

		local x, y, idx = 0, 0, 1
		for i, dragon in pairs(owner.m_lDragon) do 
			x = STD_X + PENTAGON_POS[idx].x + cameraHomePosX
			y = STD_Y + PENTAGON_POS[idx].y + cameraHomePosY
			dragon:setMove(x, y, SPEED)
			idx = idx + 1
		end

	-- 2. 적당한 시간 후 다음 페이즈로 이동
	elseif (owner.m_stateTimer >= 0.5) then
		owner:changeState('phase_2')
	end
end

-------------------------------------
-- function st_phase_2
-------------------------------------
function TamerSpecialSkillCombination.st_phase_2(owner, dt)
	-- 1. 에너지 구체 이펙트 생성 (m_mainEffect)
	if (owner.m_stateTimer == 0) then
        local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()

		owner.m_mainEffect = MakeAnimator(owner.m_res)
		owner.m_mainEffect:changeAni('appear', false)
		owner.m_mainEffect:setPosition(cc.p(STD_X + cameraHomePosX, STD_Y + cameraHomePosY))
		owner.m_world.m_missiledNode:addChild(owner.m_mainEffect.m_node)
		owner.m_mainEffect:addAniHandler(function()
			owner.m_mainEffect:changeAni('idle', true)
		end)

        SoundMgr:playEffect('EFFECT', 'skill_tamer_special_2')
        		
	-- 2. 적당한 시간 후 다음 페이즈로 이동
	elseif (owner.m_stateTimer >= 0.5) then
		owner:changeState('phase_3')
	end
end

-------------------------------------
-- function st_phase_3
-------------------------------------
function TamerSpecialSkillCombination.st_phase_3(owner, dt)
	-- 1. 공격 실행 .. ATTACK_INTERVAL초 마다 한번
	if (owner.m_stateTimer >= ATTACK_INTERVAL * (owner.m_hitCnt)) then
		owner:runAttack()
		owner.m_hitCnt = owner.m_hitCnt + 1
	end

	-- 2. 적당한 시간 후 다음 페이즈로 이동
	if (owner.m_hitCnt >= owner.m_maxHitCnt) then
		owner:changeState('dying')
	end
end

-------------------------------------
-- function st_end
-------------------------------------
function TamerSpecialSkillCombination.st_end(owner, dt)
	if (owner.m_stateTimer == 0) then
		-- 1. 이펙트 disappear
        if owner.m_mainEffect then
		    owner.m_mainEffect:changeAni('disappear', false)
        end
		-- 2. 드래곤 제자리 및 스테이트 attackDelay, 무적 해제
		for _, dragon in pairs(owner.m_lDragon) do 
			dragon:setMoveHomePos(SPEED)
			dragon:changeState('attackDelay')
            dragon:setInvincibility(false)
			owner.m_lDragonEffect[dragon]:release()
		end
		-- 3. 타겟 스테이트 attackDelay
		for _, target in pairs(owner.m_tTarget) do 
			if (not target.m_bDead and not isInstanceOf(target, MonsterLua_Boss)) then
				target:changeState('attackDelay')
			end
		end

	-- 4. 적당한 시간 후 종료
	elseif (owner.m_stateTimer >= 1) then
        -- 게임 조작 막음 해제
        owner.m_world.m_bPreventControl = false

		return true
	end
end

-------------------------------------
-- function runAttack
-------------------------------------
function TamerSpecialSkillCombination:runAttack()
	self.m_world.m_shakeMgr:shakeBySpeed(math_random(300, 500), math_random(500, 1500))
    for i,target_char in ipairs(self.m_tTarget) do
        -- 공격
		self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
		target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
    end

	-- 스킬이 제거할 수 있는 미사일 제거
	for i, v in pairs(self.m_world.m_lSpecailMissileList) do
		v:release()
	end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function TamerSpecialSkillCombination:makeSkillInstance(res, world, power_multiply)
	-- 1. 스킬 생성
    local skill = TamerSpecialSkillCombination(nil)

	-- 2. 초기화 관련 함수
    skill:init_skill(res, world, power_multiply)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('start')

    -- 4. Physics, Node, GameMgr에 등록
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end