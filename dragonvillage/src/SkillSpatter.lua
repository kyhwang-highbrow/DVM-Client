local PARENT = Skill

-------------------------------------
-- class SkillSpatter
-------------------------------------
SkillSpatter = class(PARENT, {
        m_owner = 'Character',
        m_spatterRange = 'number',
        m_spatterCount = 'number',
        m_spatterMaxCount = 'number',
        m_spatterHealRate = 'number',

        m_stdPosX = 'number',
        m_stdPosY = 'number',

        m_prevPosX = 'number',
        m_prevPosY = 'number',

        m_lTargetedIdx = 'list',
        m_targetChar = 'character',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSpatter:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillSpatter:init_skill(motionstreak_res, range_res, range, count, std_pos_x, std_pos_y)
	-- 멤버 변수
    self.m_spatterRange = range
    self.m_spatterCount = 0
    self.m_spatterMaxCount = count
    self.m_spatterHealRate = self.m_powerRate / 100

    self.m_stdPosX = std_pos_x
    self.m_stdPosY = std_pos_y

    self.m_prevPosX = std_pos_x
    self.m_prevPosY = std_pos_y

    self.m_lTargetedIdx = {}
    self.m_lTargetedIdx[self.m_owner['phys_idx']] = true -- 시전자는 대상에서 제외

	-- 스킬 효과 시작
    self:spatterHeal(self.m_owner) -- 시전자는 회복을 하고 시작
    self:trySpatter()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSpatter:initState()
    self:addState('idle', SkillSpatter.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillSpatter.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- JumpTo액션 실행
        local target_pos = cc.p(owner.m_targetChar.pos.x, owner.m_targetChar.pos.y)
        local action = cc.JumpTo:create(0.5, target_pos, 100, 1)

        -- 액션 종료 후 타겟을 회복, 튀기기 시도
        local function end_func()
            owner:spatterHeal(owner.m_targetChar)
            owner:trySpatter()
        end

        local sequence = cc.Sequence:create(action, cc.CallFunc:create(end_func))
        owner.m_rootNode:runAction(sequence)
    end

    -- m_rootNode의 위치로 클래스위 위치 동기화, 각도 지정
    local x, y = owner.m_rootNode:getPosition()
    local degree = getDegree(owner.m_prevPosX, owner.m_prevPosY, x, y)
    owner:setRotation(degree)
    owner:setPosition(x, y)
    owner.m_prevPosX, owner.m_prevPosY = x, y
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillSpatter:findTarget()
    local world = self.m_owner.m_world
    local t_ret = world:getTargetList(self.m_owner, self.m_stdPosX, self.m_stdPosY, 'ally', 'x', 'distance_line')
    
    local t_target = {}

    for i,dragon in ipairs(t_ret) do
        local phys_idx = dragon['phys_idx']
        if (not self.m_lTargetedIdx[phys_idx]) then
            local distance = getDistance(self.m_stdPosX, self.m_stdPosY, dragon.pos.x, dragon.pos.y)
            if (self.m_spatterRange <= 0) or (distance <= self.m_spatterRange) then
                table.insert(t_target, dragon)
            end
        end
    end

    -- 체력 비율이 낮은 순으로 정렬
    local l_last_target = TargetRule_getTargetList_hp_low(t_target)
    local target = l_last_target[1]

    if target then
        local phys_idx = target['phys_idx']
        self.m_lTargetedIdx[phys_idx] = true
    end

    return target
end

-------------------------------------
-- function spatterHeal
-------------------------------------
function SkillSpatter:spatterHeal(target_char)
    if (target_char.m_bDead) then
        return
    end

    -- 시전자의 최대 체력에 비례한 회복
    local heal = (self.m_owner.m_maxHp * self.m_spatterHealRate)
    target_char:healAbs(heal)
end

-------------------------------------
-- function trySpatter
-------------------------------------
function SkillSpatter:trySpatter()
    if (self.m_spatterCount >= self.m_spatterMaxCount) then
        self:changeState('dying')
        return false
    end

    self.m_targetChar = self:findTarget()
    if (not self.m_targetChar) then
        self:changeState('dying')
        return false
    end

    self.m_spatterCount = self.m_spatterCount + 1
    self:changeState('idle')
    return true
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res       'res/missile/missile_water/missile_water.vrp'
-- @param motionstreak_res  'res/missile/motion_streak/motion_streak_water.png'
-- @param range_res         'res/effect/effect_aoe_water/effect_aoe_water.vrp'
-------------------------------------
function SkillSpatter:makeSkillInstance(owner, t_skill)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute()) -- 'res/missile/missile_water/missile_water.vrp'
    local motionstreak_res = t_skill['res_2'] -- 'res/missile/motion_streak/motion_streak_water.png'
    local range_res = t_skill['res_3'] -- 삭제되어있음 
    local range = t_skill['val_1']
    local count = t_skill['val_2']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillSpatter(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(motionstreak_res, range_res, range, count, owner.pos.x, owner.pos.y)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('idle')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)

	-- 위치 지정 및 모션스트릭	
	skill:setPosition(owner.pos.x, owner.pos.y)
    skill:setMotionStreak(world.m_missiledNode, motionstreak_res)

    -- 영역 이펙트 생성 .. 사용 안함
    if (range > 0) and (range_res and (range_res ~= 'x')) then
        local suffix, scale = AreaOfEffectHelper:getAOEData(range)
        local animation_name = 'idle_' .. suffix
        local effect = world:addInstantEffectWorld(range_res, animation_name, owner.pos.x, owner.pos.y)
        effect:setScale(scale)
    end
end