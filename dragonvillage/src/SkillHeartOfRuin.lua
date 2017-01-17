local PARENT = Skill

-------------------------------------
-- class SkillHeartOfRuin
-------------------------------------
SkillHeartOfRuin = class(PARENT, {
        m_resFileName = 'string',
        
        m_statusEffectType = 'string',  -- 중첩별 연출을 위해 참조될 스테이터스 이펙트 타입
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHeartOfRuin:init(file_name, body, ...)
    self.m_resFileName = file_name
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHeartOfRuin:init_skill()
	PARENT.init_skill(self)

    -- 위치 조정
    if (self.m_owner.m_bLeftFormation) then
        self.m_attackPosOffsetX = -100
    else
        self.m_attackPosOffsetX = 100
    end
    self.m_attackPosOffsetY = 0

    -- 스테이터스 이펙트 타입명 저장
    local statusEffectStr = self.m_lStatusEffectStr[1]
    if statusEffectStr then
        local t_effect = StatusEffectHelper:parsingStr(statusEffectStr)
        
        self.m_statusEffectType = t_effect.type
    end

    self:setPosition(self.m_owner.pos.x + self.m_attackPosOffsetX, self.m_owner.pos.y + self.m_attackPosOffsetY)    
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHeartOfRuin:initState()
	self:setCommonState(self)
    self:addState('start', SkillHeartOfRuin.st_idle, 'back', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHeartOfRuin.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 연출 이펙트
        owner:makeEffect()

        -- 버프 적용
        owner:doStatusEffect({
            STATUS_EFFECT_CON__SKILL_HIT,
            STATUS_EFFECT_CON__SKILL_HIT_CRI
        }, {})

        local world = owner.m_world

        -- 배경 연출
        if owner.m_statusEffectType then
            local level = 1
            local list = owner.m_owner:getStatusEffectList()
            local statusEffect = list[owner.m_statusEffectType]

            if statusEffect then
                if statusEffect.m_overlabCnt > 6 then       level = 3
                elseif statusEffect.m_overlabCnt > 3 then   level = 2
                else                                        level = 1
                end
            end

            world.m_mapManager.m_node:stopAllActions()
            world.m_mapManager:setDirecting('darknix_shaky' .. level)
        end

		-- shake 연출
		world.m_shakeMgr:doShakeGrowling(0.05, 10, 35)

		-- 포효 연출
		--[[
		@ 필요 조건 -> 
			grid action 들어가는 경우에만 rootNode = cc.NodeGrid:create() 처리
			ripple 후 원복 처리, 
			ripple 위치는 화면상에서의 character 위치로 하는 처리

		owner.m_owner.m_rootNode:runAction(cc.Sequence:create(
			cca.getRipple3D(3, 1)
        ))
		]]

        owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
	end
end

-------------------------------------
-- function makeEffect
-------------------------------------
function SkillHeartOfRuin:makeEffect()
    local world = self.m_owner.m_world
    -- 연출 배경 생성
    do
        local effect = AnimatorVrp('res/effect/effect_scene_effect_01/effect_scene_effect_01.vrp')
        effect:changeAni('idle', false)
        effect:addAniHandler(function() effect:runAction(cc.RemoveSelf:create()) end)
        world.m_bgNode:addChild(effect.m_node)

        local cameraHomePosX, cameraHomePosY = world.m_gameCamera:getHomePos()
        effect:setPosition(cameraHomePosX + (CRITERIA_RESOLUTION_X / 2), cameraHomePosY)
        effect:setScale(0.6)
    end
    
    -- 연출 이펙트 생성
    do
        local effect = AnimatorVrp(self.m_resFileName)
        effect:changeAni('front', false)
        effect:addAniHandler(function() effect:runAction(cc.RemoveSelf:create()) end)
        effect:setPosition(self.m_owner.pos.x + self.m_attackPosOffsetX, self.m_owner.pos.y + self.m_attackPosOffsetY)
    
        world.m_worldNode:addChild(effect.m_node, 3)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHeartOfRuin:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHeartOfRuin(res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_worldNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end