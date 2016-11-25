local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillLaser
-------------------------------------
SkillLaser = class(PARENT, {
        m_linkEffect = '',  -- 레이저의 그래픽 리소스
        m_laserDir = '',

        m_limitTime = '',

        m_multiHitTime = '',
        m_multiHitTimer = '',

        m_clearCount = '',
        m_maxClearCount = '',

        m_startPosX = '',
        m_startPosY = '',

        m_laserEndPosX = '',
        m_laserEndPosY = '',

        m_physGroup = '',

		m_thickness = '',
        m_laserThickness = 'number', -- 레이저 굵기
     })

-------------------------------------
-- function initc
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser:init_skill(missile_res, hit, thickness)
	PARENT.init_skill(self)

    -- 캐릭터 유형별 변수 정리(dragon or enemy)
    if (self.m_owner.phys_key == 'hero') then
        is_hero = true
        self.m_physGroup = 'missile_h'
    else
        is_hero = false
        self.m_physGroup = 'missile_e'
    end

    local duration = (self.m_owner.m_statusCalc.m_attackTick / 2)
    local hit = math_max(hit, 1)
	self.m_thickness = thickness

	    -- 쿨타임 지정
    self.m_limitTime = duration
    self.m_multiHitTime = self.m_limitTime / hit
    self.m_multiHitTimer = 0
	
    self.m_clearCount = 0
	self.m_maxClearCount = hit - 1
	
    self.m_laserDir = 180

    self.m_startPosX = 0
    self.m_startPosY = 0
	
    do
        -- 스케일 지정
        if	   (thickness == 1) then self.m_laserThickness = 30
        elseif (thickness == 2) then self.m_laserThickness = 60
        elseif (thickness == 3) then self.m_laserThickness = 120
        else                    error('레이저 두께는 1~3 이어야 합니다. 현재 thickness : ' .. thickness)
        end
    end

    -- 레이저 링크 이펙트 생성
    self:makeLaserLinkEffect(missile_res, thickness)
	
	-- 상태효과 (고대신룡 힐)
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, {}, self.m_lStatusEffectStr)
end

-------------------------------------
-- function makeLaserLinkEffect
-------------------------------------
function SkillLaser:makeLaserLinkEffect(file_name, thickness)
    local link_effect = EffectLink(file_name)

    link_effect.m_bRotateEndEffect = false

    -- 저사양모드 ignore
    link_effect:setIgnoreLowEndMode(true)

    -- 'appear' -> 'idle' 에니메이션으로 자동 변경
    link_effect:registCommonAppearAniHandler()

    do -- 이펙트 스케일 지정
        local scale = 1

        -- 스케일 지정
        if     (thickness == 1) then scale = 0.5
        elseif (thickness == 2) then scale = 1
        elseif (thickness == 3) then scale = 2
        else                    error('레이저 두께는 1~3 이어야 합니다. 현재 thickness : ' .. thickness)
        end

        link_effect.m_startPointNode:setScale(scale)
        link_effect.m_effectNode:setScale(scale, 1)
        link_effect.m_endPointNode:setScale(scale)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    self.m_linkEffect = link_effect
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaser:initState()
	self:setCommonState(self)
    self:addState('start', SkillLaser.st_idle, 'idle', true)
    self:addState('disappear', SkillLaser.st_disappear, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLaser.st_idle(owner, dt)
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount) then
        
		owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_clearCount = owner.m_clearCount + 1
    end

    owner:refresh()

    if ((not owner.m_owner) or owner.m_owner.m_bDead) or (owner.m_stateTimer >= owner.m_limitTime) then
        owner:changeState('disappear')
        return
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillLaser.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            owner:changeState('dying')
        end
        owner.m_linkEffect:changeCommonAni('disappear', false, ani_handler)
    end
end


-------------------------------------
-- function refresh
-------------------------------------
function SkillLaser:refresh(force)
    local change_start = false
	
    if self.m_owner then
        if (self.m_owner.pos.x ~= self.m_startPosX) or (self.m_owner.pos.y ~= self.m_startPosY) then
            change_start = true
            self.m_startPosX = self.m_owner.pos.x + (self.m_attackPosOffsetX * math.max(self.m_thickness/2, 1))
            self.m_startPosY = self.m_owner.pos.y + self.m_attackPosOffsetY
            self:setPosition(self.m_startPosX, self.m_startPosY)
        end
    end

    if force or change_start then
        local dir = getDegree(self.m_startPosX, self.m_startPosY, self.m_targetPos.x, self.m_targetPos.y)

        if (self.m_laserDir ~= dir) then
            self.m_laserDir = dir
            local pos = getPointFromAngleAndDistance(dir, 2560)    
            EffectLink_refresh(self.m_linkEffect, 0, 0, pos['x'], pos['y'])

            self.m_laserEndPosX = self.m_startPosX + pos['x']
            self.m_laserEndPosY = self.m_startPosY + pos['y']
        end
    end

    if (not force) then
        self:checkCollision()
    end
end

-------------------------------------
-- function checkCollision
-------------------------------------
function SkillLaser:checkCollision()

    local radius = (self.m_laserThickness / 2)

    -- 레이저에 충돌된 모든 객체 리턴
    local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(self.m_startPosX, self.m_startPosY,
        self.m_laserEndPosX, self.m_laserEndPosY, radius, self.m_physGroup)
    
	-- 모든 객체에 공격
    for i,v in ipairs(t_collision_obj) do
        self:collisionAttack(v['obj'])
    end
end

-------------------------------------
-- function collisionAttack
-------------------------------------
function SkillLaser:collisionAttack(target_char)
    if (not self.t_collision) then
        return
    end

    -- 이미 충돌된 객체라면 리턴
    if (self.t_collision[target_char.phys_idx]) then
        return
    end

    -- 충돌, 공격 처리
    self.t_collision[target_char.phys_idx] = true
	
	self:attack(target_char)
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local hit = t_skill['hit']
	local thickness = t_skill['val_1']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, hit, thickness)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    skill:refresh(true)
end
