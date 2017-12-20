local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillLaserBomb
-------------------------------------
SkillLaserBomb = class(PARENT, {
        m_linkEffect = 'list',  -- 레이저의 그래픽 리소스
        
        m_laserDir1 = '',
        m_laserDir2 = '',

        m_limitTime = '',

        m_multiHitTime = '',
        m_multiHitTimer = '',

        m_clearCount = '',
        m_maxClearCount = '',

        m_startPosX1 = '',
        m_startPosY1 = '',

        m_startPosX2 = '',
        m_startPosY2 = '',

        m_physGroup = '',

        m_refresh = 'table',
        m_explosionRes = '',

        m_laserThickness = 'number', -- 레이저 굵기
     })

-------------------------------------
-- function initc
-- @param file_name
-- @param body
-------------------------------------
function SkillLaserBomb:init(file_name, body, ...)
    self.m_linkEffect = {}
    self.m_refresh= {}
    self.m_refresh[1] = false
    self.m_refresh[2] = false

end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaserBomb:init_skill(start_res, missile_res, explosion_res, hit, thickness)
	PARENT.init_skill(self)
    self.m_explosionRes = explosion_res
    self.m_physGroup = self.m_owner:getMissilePhysGroup()

    local duration = (self.m_owner.m_statusCalc.m_attackTick / 2)
    local hit = math_max(hit, 1)

	    -- 쿨타임 지정
    self.m_limitTime = duration
    self.m_multiHitTime = self.m_limitTime / hit
    self.m_multiHitTimer = 0
	
    self.m_clearCount = 0
	self.m_maxClearCount = hit
	
    self.m_laserDir1 = 180
    self.m_laserDir2 = 180
    self.m_startPosX1 = 0
    self.m_startPosY1 = 0
	self.m_startPosX2 = 0
    self.m_startPosY2 = 0

    local function cb_func() 
		self:changeState('start')

	end
    local camera_x, camera_y = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    local anim = self:makeEffect(start_res, camera_x, camera_y, 'idle', cb_func)
    if (not self.m_owner.m_bLeftFormation) then
        anim:setPositionX(CRITERIA_RESOLUTION_X)
        anim:setFlip(true)
    end
    anim:setEventHandler(function(event)
            if event then
                local string_value = event['eventData']['stringValue']           
                if string_value and (string_value ~= '') then
                    local l_str = seperate(string_value, ',')
                    if l_str then
                        local scale = anim:getScale()
                        local flip = anim.m_bFlip
                        
                        x = l_str[1] * scale
                        y = l_str[2] * scale

                        if flip then
                            x = -x
                        end
                        local anim_x, anim_y = anim:getPosition()
                        if (event['eventData']['name'] == 'attack1') then
                            self.m_startPosX1 = x + anim_x
                            self.m_startPosY1 = y + anim_y
                            self:makeLaserLinkEffect(missile_res, 1)
                            self.m_refresh[1] = true
                        else
                            self.m_startPosX2 = x + anim_x
                            self.m_startPosY2 = y + anim_y
                            self:makeLaserLinkEffect(missile_res, 2)
                            self.m_refresh[2] = true
                        end
                    end
                end
            end
        end)

    -- 레이저 링크 이펙트 생성    

end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillLaserBomb:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('bar', self.m_skillSize)  

		self.m_resScale = 1 --t_data['scale']
		self.m_laserThickness = t_data['size']
	end
end

-------------------------------------
-- function makeLaserLinkEffect
-------------------------------------
function SkillLaserBomb:makeLaserLinkEffect(file_name, idx)
    local link_effect = EffectLink(file_name)

    link_effect.m_bRotateEndEffect = false

    -- 저사양모드 ignore
    link_effect:setIgnoreLowEndMode(true)
    -- 'appear' -> 'idle' 에니메이션으로 자동 변경
    link_effect:registCommonAppearAniHandler()
	-- 이펙트 스케일 지정

    self.m_rootNode:addChild(link_effect.m_node)
    self.m_linkEffect[idx] = link_effect
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaserBomb:initState()
	self:setCommonState(self)
    self:addState('start', SkillLaserBomb.st_idle, 'idle', true)
    self:addState('disappear', SkillLaserBomb.st_disappear, nil, true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLaserBomb.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_owner.m_animator:changeAni('skill_disappear', false)
    end
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount) then
		owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_clearCount = owner.m_clearCount + 1

        owner:runAttack()
    end

    owner:refresh()

    if ((not owner.m_owner) or owner.m_owner:isDead() or (owner.m_clearCount >= owner.m_maxClearCount)) then
        owner:changeState('disappear')
        return
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillLaserBomb.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            owner:makeEffect(owner.m_explosionRes, owner.m_targetPos.x, owner.m_targetPos.y, 'idle')
            owner:changeState('dying')
        end
		--owner.m_linkEffect:setVisible(false)
        owner.m_linkEffect[1]:changeCommonAni('disappear', false, ani_handler)
        owner.m_linkEffect[2]:changeCommonAni('disappear', false, ani_handler)

    end
end


-------------------------------------
-- function refresh
-------------------------------------
function SkillLaserBomb:refresh()
    if(self.m_refresh[1]) then
        local distance1 = math_distance(self.m_startPosX1, self.m_startPosY1, self.m_targetPos.x, self.m_targetPos.y)
        local dir1 = getDegree(self.m_startPosX1, self.m_startPosY1, self.m_targetPos.x, self.m_targetPos.y)

        if (force or self.m_laserDir1 ~= dir1) then
            self.m_laserDir1 = dir1
            local pos = getPointFromAngleAndDistance(dir1, distance1)
            EffectLink_refresh(self.m_linkEffect[1], self.m_startPosX1, self.m_startPosY1, pos['x'] + self.m_startPosX1, pos['y'] + self.m_startPosY1)

        end
    end
    if (self.m_refresh[2]) then
        local distance2 = math_distance(self.m_startPosX2, self.m_startPosY2, self.m_targetPos.x, self.m_targetPos.y)
        local dir2 = getDegree(self.m_startPosX2, self.m_startPosY2, self.m_targetPos.x, self.m_targetPos.y)

        if (force or self.m_laserDir2 ~= dir2) then
            self.m_laserDir2 = dir2
            local pos = getPointFromAngleAndDistance(dir2, distance2)
            EffectLink_refresh(self.m_linkEffect[2], self.m_startPosX2, self.m_startPosY2, pos['x'] + self.m_startPosX2, pos['y'] + self.m_startPosY2)

        end
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillLaserBomb:findCollision()
    if (self.m_lTargetCollision) then
        return self.m_lTargetCollision
    end

end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillLaserBomb:runAttack(t_collision_obj, t_collision_bodys)
	if (not self.t_collision) then
		return
	end

    local collisions = self:findCollision()

    for _, collision in ipairs(collisions) do
        local target = collision:getTarget()
        local body_key = collision:getBodyKey()

        if (not self.t_collision[target.phys_idx]) then
			self.t_collision[target.phys_idx] = {}
		end

        if (not self.t_collision[target.phys_idx][body_key]) then
		    -- 충돌, 공격 처리
		    self.t_collision[target.phys_idx][body_key] = true
            
            self:attack(collision)
        end
    end
    
	self:doCommonAttackEffect()
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaserBomb:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local start_res = t_skill['res_1']
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
    local explosion_res = SkillHelper:getAttributeRes(t_skill['res_3'], owner)
	local hit = t_skill['hit']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaserBomb(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(start_res, missile_res, explosion_res, hit)
	skill:initState()
	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

end
