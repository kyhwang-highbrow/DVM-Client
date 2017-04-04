local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Width
-------------------------------------
SkillAoESquare_Width = class(PARENT, {
        m_missileStartPosX = 'number',
        m_missileDir = 'number'        
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare_Width:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare_Width:init_skill()
    PARENT.init_skill(self)

    local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    if (self.m_owner.m_bLeftFormation) then
        self.m_missileStartPosX = cameraHomePosX
        self.m_missileDir = 0
    else
        self.m_missileStartPosX = cameraHomePosX + CRITERIA_RESOLUTION_X
        self.m_missileDir = 180
    end
	    
    if (not self.m_owner.m_bLeftFormation) then
        self.m_animator:setFlip(true)
    end

	-- X좌표값은 화면의 중심으로 세팅
	self:setPosition(cameraHomePosX + (CRITERIA_RESOLUTION_X / 2), self.m_targetPos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoESquare_Width:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_width', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_skillHeight = t_data['size']
	end
end

-------------------------------------
-- function adjustAnimator
-------------------------------------
function SkillAoESquare_Width:adjustAnimator()    
	if (not self.m_animator) then return end
	
	-- delay state 종료시 켜준다.
	self.m_animator:setVisible(false) 

	self.m_animator:setScaleY(self.m_resScale)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoESquare_Width:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoESquare_Width.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAoESquare_Width.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:fireMissile()

        owner.m_animator.m_node:setRepeat(false)
        owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillAoESquare_Width:fireMissile()
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
	
	t_option['scale'] = tonumber(self.m_resScale)
    t_option['speed'] = 1400

    -- 하이라이트
    t_option['highlight'] = self.m_bHighlight

    t_option['cbFunction'] = function(attacker, defender, x, y)
        self:onAttack(defender)

        -- 나에게로부터 상대에게 가는 버프 이펙트 생성
        local allyList = char:getFellowList()
        for i, ally in ipairs(allyList) do
            if (not ally.m_bDead) then
                EffectMotionStreak(world, x, y, ally.pos.x, ally.pos.y, RES_SE_MS)
            end
        end
	end

    local missile = world.m_missileFactory:makeMissile(t_option)

end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Width:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Width(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        --world.m_gameHighlight:addMissile(skill)
    end
end
