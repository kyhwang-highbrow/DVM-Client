local PARENT = SkillScript

local WEAK_POINT_BONE = 'bone79'

-------------------------------------
-- class SkillScript_Groggy
-------------------------------------
SkillScript_Groggy = class(PARENT, {
    -- 받은 데미지
    m_totalDamage = 'number',
    m_totalDamageForCancel = 'number',

    -- 그로기 집입 전, 그로기 중, 그로기 후 애니메이션
    m_disappearAniName = 'str',
    m_groggyAniName = 'str', 
    m_wakeAniName = 'str', 

    -- val_3 예상 : 타겟 위치정보
    m_weakBoneName = 'string',

    -- 약점이펙트
    m_effectRootNode = '',
    m_effectWeakPoint = '',
})

-------------------------------------
-- function init
-------------------------------------
function SkillScript_Groggy:init()
    -- animation
    self.m_disappearAniName = 'idle'
    self.m_groggyAniName = 'idle'
    self.m_wakeAniName = 'idle'

    -- val_1
    self.m_attackSkillId = -1
    self.m_failSkillId = -1

    -- val_3
    self.m_weakBoneName = nil


    self.m_effectRootNode = nil
    self.m_effectWeakPoint = nil
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillScript_Groggy:init_skill(script_name, duration)
    local durataion_value = duration and duration or 0
    local script_name_value = script_name and script_name or ''

    PARENT.init_skill(self, script_name_value, durataion_value)

    -- 약점 이펙트 생성
    if (not self.m_effectRootNode) then
        self.m_effectRootNode = cc.Node:create()
        self.m_effectRootNode:setVisible(false)
        self.m_world:getMissileNode():addChild(self.m_effectRootNode)
    end
end

-------------------------------------
-- function initEventListener
-- @breif 이벤트 처리..
-------------------------------------
function SkillScript_Groggy:initEventListener()
    PARENT.initEventListener(self)

    -- 스킬 사용자 피격시 이벤트 등록
    self.m_owner:addListener('under_atk', self)
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillScript_Groggy:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_owner = owner
    self.m_lTargetChar = self.m_world:getDragonList()
    self.m_duration = 0

    -- 애니메이션 설정
    -- skill 테이블의 animation 에 정보가 여러개 들어가 있을 수도 있다.
    -- {animation_name};{animation_name}
    local l_animation = pl.stringx.split(t_skill['animation'], ';')

    if (l_animation) then

        if (#l_animation >= 3) then
            self.m_disappearAniName = l_animation[1]
	        self.m_groggyAniName = l_animation[2]
            self.m_wakeAniName = l_animation[3]

        elseif (#l_animation >= 2) then
            self.m_disappearAniName = l_animation[1]
	        self.m_groggyAniName = l_animation[2]

        elseif (#l_animation >= 1) then
            self.m_disappearAniName = l_animation[1]

        end
    end

end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript_Groggy:initState()
    self:setCommonState(self)
    self:addState('start', SkillScript_Groggy.st_start, nil, false)
    self:addState('end', SkillScript_Groggy.st_disappear, nil, false)
end

-------------------------------------
-- function st_charge
-------------------------------------
function SkillScript_Groggy.st_start(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 약점 이펙트 표시
        if (owner.m_effectRootNode) then
            owner.m_effectRootNode:setVisible(true)
        end

        owner:updateEffectPos()

        owner.m_owner.m_animator:changeAni(owner.m_disappearAniName, false)
        owner.m_owner.m_animator:addAniHandler(function()
            owner.m_owner.m_animator:changeAni(owner.m_groggyAniName, false)
            owner.m_owner.m_animator:addAniHandler(function()
                owner:changeState('end')
            end)
        end)
    end
end


-------------------------------------
-- function st_disappear
-------------------------------------
function SkillScript_Groggy.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        -- 주체 유닛 애니 설정
        local unit = owner.m_owner
        unit.m_animator:changeAni(owner.m_wakeAniName, false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function onDying
-------------------------------------
function SkillScript_Groggy:onDying()
    PARENT.onDying(self)

    -- 이펙트 삭제
    self:removeEffect()
end

-------------------------------------
-- function updateEffectPos
-------------------------------------
function SkillScript_Groggy:updateEffectPos()
    if (self.m_effectRootNode) then
        local unit = self.m_owner

        --[[
        local bone_pos = unit.m_animator.m_node:getBonePosition(WEAK_POINT_BONE)
        local x = unit.pos['x'] + bone_pos['x'] * unit.m_animator.m_node:getScaleX()
        local y = unit.pos['y'] + bone_pos['y'] * unit.m_animator.m_node:getScaleY()
        
        self.m_effectRootNode:setPosition(x, y)
        ]]

        self.m_effectRootNode:setPosition(unit.pos['x'], unit.pos['y'])
    end
end

-------------------------------------
-- function removeEffect
-------------------------------------
function SkillScript_Groggy:removeEffect()
    if (self.m_effectRootNode) then
        self.m_effectRootNode:removeFromParent(true)
        self.m_effectRootNode = nil
    end

    self.m_effectWeakPoint = nil
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillScript_Groggy:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local res = t_skill['res_1']
    --local duration = t_skill['val_2']
    --local script_name = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript_Groggy(res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(script_name, duration)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode('bottom')
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end

-------------------------------------
-- function isFullBodyAttack
-------------------------------------
function SkillScript_Groggy:isFullBodyAttack()
    return isNullOrEmpty(self.m_weakBoneName)
end
