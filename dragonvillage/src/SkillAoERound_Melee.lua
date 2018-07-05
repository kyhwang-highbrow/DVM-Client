local PARENT = SkillAoERound

-------------------------------------
-- class SkillAoERound_Melee
-------------------------------------
SkillAoERound_Melee = class(PARENT, {})

local MOVE_SPEED = 1500

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound_Melee:init(file_name, body, ...)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound_Melee:initState(attack_ani)
    self:setCommonState(self)
    self:addState('start', SkillAoERound_Melee.st_appear, nil, false)
    self:addState('attack', SkillAoERound_Melee.st_attack, 'idle', false)
    self:addState('disappear', SkillAoERound_Melee.st_disappear, nil, false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillAoERound_Melee.st_appear(owner, dt)
    local char = owner.m_owner

    if (owner:getStep() == 0) then
        if (owner:isBeginningStep()) then
            -- 캐릭터 이동 시작
            if (owner:isRightFormation()) then
                char:setMove(owner.m_targetPos.x + 100, owner.m_targetPos.y - 20, MOVE_SPEED)
            else
		        char:setMove(owner.m_targetPos.x - 100, owner.m_targetPos.y - 20, MOVE_SPEED)
            end

        elseif (char.m_isOnTheMove == false) then
            -- 캐릭터 공격 애니
            char.m_animator:changeAni('skill_disappear', false)
            char.m_animator:addAniHandler(function()
                char.m_animator:changeAni('idle', true)
            end)

            local function attack_cb(event)
                -- 공격 시작
                owner:changeState('attack')
            end
            char.m_animator:setEventHandler(attack_cb)

            owner:nextStep()
        end

    elseif (owner.m_stateTimer > 2) then
        -- 공격 시작
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoERound_Melee.st_attack(owner, dt)
    PARENT.st_attack(owner, dt)
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillAoERound_Melee.st_disappear(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        -- 캐릭터 원위치
        char:setMoveHomePos(MOVE_SPEED)

    elseif (char.m_isOnTheMove == false) then
        owner:changeState('dying')

    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound_Melee:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local attack_count = t_skill['hit']	  -- 공격 횟수
	local aoe_res_delay = tonumber(t_skill['val_1']) or 0
    
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스
    
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillAoERound_Melee(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(aoe_res, attack_count, aoe_res_delay)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end