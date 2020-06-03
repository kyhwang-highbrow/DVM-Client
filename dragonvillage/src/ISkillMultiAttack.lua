-------------------------------------
-- interface ISkillMultiAttack
-- @breif Skill class 와 결합하여 반복공격 구조를 지원한다.
-------------------------------------
ISkillMultiAttack = {
		m_attackCount = 'number',
		m_maxAttackCount = 'number',
		
		m_hitInterval = 'number',
		m_multiAtkTimer = 'dt',
        m_multiAtkDelay = 'number',
     }

-------------------------------------
-- function init
-------------------------------------
function ISkillMultiAttack:init()
    self.m_attackCount = 0
    self.m_maxAttackCount = 0
    self.m_hitInterval = 0
    self.m_multiAtkTimer = 0
    self.m_multiAtkDelay = 0
end

-------------------------------------
-- function st_appear
-------------------------------------
function ISkillMultiAttack.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
		if (not owner.m_targetChar) then 
			owner:changeState('dying')
		else
			owner:onAppear()
			owner.m_animator:addAniHandler(function()
				owner:changeState('attack')
			end)
		end
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function ISkillMultiAttack.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:enterAttack()
    end
	
    owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt

	-- 반복 공격
    if (owner.m_multiAtkTimer > owner.m_hitInterval + owner.m_multiAtkDelay) then
		-- 공격 횟수 초과시 탈출
		if (owner.m_attackCount >= owner.m_maxAttackCount) then
			owner:escapeAttack()
		else
			owner:runAttack()
			owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
			owner.m_attackCount = owner.m_attackCount + 1
		end
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function ISkillMultiAttack.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:onDisappear()
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function setAttackInterval
-- @brief 공격 인터벌 설정
-------------------------------------
function ISkillMultiAttack:setAttackInterval()
end

-------------------------------------
-- function onAppear
-- @brief appear state에서 실행
-------------------------------------
function ISkillMultiAttack:onAppear()
end

-------------------------------------
-- function enterAttack
-- @brief 공격이 시작되는 시점에 실행
-------------------------------------
function ISkillMultiAttack:enterAttack()
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function ISkillMultiAttack:escapeAttack()
end

-------------------------------------
-- function onDisappear
-- @brief disappear state에서 실행
-------------------------------------
function ISkillMultiAttack:onDisappear()
end



-------------------------------------
-- function getCloneTable
-------------------------------------
function ISkillMultiAttack:getCloneTable()
	return clone(ISkillMultiAttack)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function ISkillMultiAttack:getCloneClass()
	return class(clone(ISkillMultiAttack))
end