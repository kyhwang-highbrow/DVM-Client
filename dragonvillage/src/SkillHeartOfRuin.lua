local PARENT = Skill

-------------------------------------
-- class SkillHeartOfRuin
-------------------------------------
SkillHeartOfRuin = class(PARENT, {
        m_statusEffectType = 'string',  -- 중첩별 연출을 위해 참조될 스테이터스 이펙트 타입
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHeartOfRuin:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHeartOfRuin:init_skill()
	PARENT.init_skill(self)

    -- 멤버 변수
    local statusEffectStr = self.m_lStatusEffectStr[1]
    if statusEffectStr then
        local t_effect = StatusEffectHelper:parsingStr(statusEffectStr)
        
        self.m_statusEffectType = t_effect.type

        cclog('self.m_statusEffectType = ' .. self.m_statusEffectType)
    end

    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHeartOfRuin:initState()
	self:setCommonState(self)
    self:addState('start', SkillHeartOfRuin.st_idle, 'idle', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHeartOfRuin.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 버프 적용
        owner:doStatusEffect({
            STATUS_EFFECT_CON__SKILL_HIT,
            STATUS_EFFECT_CON__SKILL_HIT_CRI
        }, {})

        -- 배경 연출
        if owner.m_statusEffectType then
            local list = owner.m_owner:getStatusEffectList()
            local statusEffect = list[owner.m_statusEffectType]
            if statusEffect then
                local world = owner.m_world
                local level = 1
                
                if statusEffect.m_overlabCnt <= 3 then      level = 1
                elseif statusEffect.m_overlabCnt <= 6 then  level = 2
                else                                        level = 3
                end

                cclog('level = ' .. level)

                world.m_mapManager.m_node:stopAllActions()
                world.m_mapManager:setDirecting('ripple' .. level)
            end
        end

        owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
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
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end