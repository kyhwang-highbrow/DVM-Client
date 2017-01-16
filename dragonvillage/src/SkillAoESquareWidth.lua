local PARENT = Skill

-------------------------------------
-- class SkillAoESquareWidth
-------------------------------------
SkillAoESquareWidth = class(PARENT, {
        m_skillHeight = 'number',

        m_missileStartPosX = 'number',
        m_missileDir = 'number'        
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquareWidth:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquareWidth:init_skill(skill_height)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_skillHeight = skill_height

    local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    if (self.m_owner.m_bLeftFormation) then
        self.m_missileStartPosX = cameraHomePosX
        self.m_missileDir = 0
    else
        self.m_missileStartPosX = cameraHomePosX + CRITERIA_RESOLUTION_X
        self.m_missileDir = 180
    end
	    
	self:setPosition(cameraHomePosX + (CRITERIA_RESOLUTION_X / 2), self.m_targetPos.y) -- X좌표값은 화면의 중심으로 세팅

    if (not self.m_owner.m_bLeftFormation) then
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoESquareWidth:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoESquareWidth.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAoESquareWidth.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:fireMissile()

        owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillAoESquareWidth:fireMissile()
    local targetPos = self.m_targetPos
    if (not targetPos) then
        return 
    end

    local char = self.m_owner
    local world = self.m_world

    local t_option = {}

    t_option['owner'] = char

    t_option['pos_x'] = self.m_missileStartPosX
    t_option['pos_y'] = targetPos.y

    t_option['physics_body'] = {0, 0, self.m_skillHeight / 2}
    t_option['attack_damage'] = self.m_activityCarrier

    t_option['object_key'] = char:getAttackPhysGroup()

    t_option['missile_res_name'] = nil
	t_option['attr_name'] = self.m_owner:getAttribute()

    t_option['movement'] ='normal'
	t_option['missile_type'] = 'PASS'

    t_option['dir'] = self.m_missileDir
	
	t_option['scale'] = self.m_resScale
    t_option['speed'] = 1400

    t_option['cbFunction'] = function(attacker, defender, x, y)
        self.m_skillHitEffctDirector:doWork()

        -- 나에게로부터 상대에게 가는 버프 이펙트 생성
        if (char.m_bLeftFormation) then
            for i, hero in ipairs(world:getDragonList()) do
                if (not hero.m_bDead) then
                    EffectMotionStreak(world, x, y, hero.pos.x, hero.pos.y, 'res/effect/motion_streak/motion_streak_fire.png')
                end
            end
        end
	end

    local missile = world.m_missileFactory:makeMissile(t_option)

end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquareWidth:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
    local skill_height = t_skill['val_1']   -- 공격 반경
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquareWidth(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(skill_height)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
