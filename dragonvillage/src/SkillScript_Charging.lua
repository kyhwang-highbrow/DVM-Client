local PARENT = SkillScript

local WEAK_POINT_BONE = 'bone79'

-------------------------------------
-- class SkillScript_Charging
-------------------------------------
SkillScript_Charging = class(PARENT, {
    -- 받은 데미지
    m_totalDamage = 'number',
    m_totalDamageForCancel = 'number',

    m_appearAniName = 'str',
    m_chargeAniName = 'str', 
    m_failAniName = 'str', 
    m_returnAniName = 'str',

    -- val_1 성공발동스킬
    m_attackSkillId = 'number', -- 스크립트 파일일 수도 있음
    m_failSkillId = 'number',

    -- val_2 캐스팅시간;취소에 필요한 데미지 퍼센트(0~100)
    m_castingTime = 'number',
    m_abortDamageRate = 'number',

    -- val_3 예상 : 타겟 위치정보
    m_weakBoneName = 'string',

    -- 약점이펙트
    m_effectRootNode = '',
    m_effectWeakPoint = '',

    -- 캐스팅 캔슬 가능시 노출할 체력바
    m_hpGaugeFrame = '',
    m_hpGauge = '',
})

-------------------------------------
-- function init
-------------------------------------
function SkillScript_Charging:init()
    self.m_totalDamage = 0
    self.m_totalDamageForCancel = 65535

    -- animation
    self.m_appearAniName = 'idle'
    self.m_chargeAniName = 'attack'
    self.m_failAniName = ''
    self.m_returnAniName = ''

    -- val_1
    self.m_attackSkillId = -1
    self.m_failSkillId = -1

    -- val_2
    self.m_castingTime = 15
    self.m_abortDamageRate = 1

    -- val_3
    self.m_weakBoneName = nil


    self.m_effectRootNode = nil
    self.m_effectWeakPoint = nil

    self.m_hpGaugeFrame = nil
    self.m_hpGauge = nil
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillScript_Charging:init_skill(script_name, duration)
    local durataion_value = duration and duration or 0
    local script_name_value = script_name and script_name or ''

    PARENT.init_skill(self, script_name_value, durataion_value)

    -- 약점 이펙트 생성
    if (not self.m_effectRootNode) then
        self.m_effectRootNode = cc.Node:create()
        self.m_effectRootNode:setVisible(false)
        self.m_world:getMissileNode():addChild(self.m_effectRootNode)
    end

    -- 캐시에 체력게이지 스프라이트 로드
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_cha_info/ingame_cha_info.plist')

    -- 게이지 생성
    if (not self.m_hpGaugeFrame) then
        self.m_hpGaugeFrame = cc.Sprite:createWithSpriteFrameName('ingame_cha_info_hp_gg_0101.png')

        if (not self.m_hpGaugeFrame) then
            cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_cha_info/ingame_cha_info.plist')
            self.m_hpGaugeFrame = cc.Sprite:createWithSpriteFrameName('ingame_cha_info_hp_gg_0101.png')
        end

        self.m_hpGaugeFrame:setPosition(-35, -25)
        self.m_hpGaugeFrame:setAnchorPoint(cc.p(0, 0.5))
        self.m_hpGaugeFrame:setDockPoint(cc.p(0, 0.5))
        self.m_effectRootNode:addChild(self.m_hpGaugeFrame, 2)
    end

    if (not self.m_hpGauge) then
        self.m_hpGauge = cc.Sprite:createWithSpriteFrameName('ingame_cha_info_hp_gg_0104.png')

        if (not self.m_hpGaugeFrame) then
            cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_cha_info/ingame_cha_info.plist')
            self.m_hpGauge = cc.Sprite:createWithSpriteFrameName('ingame_cha_info_hp_gg_0104.png')
        end

        self.m_hpGauge:setPosition(-32, -25)
        self.m_hpGauge:setAnchorPoint(cc.p(0, 0.5))
        self.m_hpGauge:setDockPoint(cc.p(0, 0.5))
        self.m_effectRootNode:addChild(self.m_hpGauge, 3)
    end
end

-------------------------------------
-- function initEventListener
-- @breif 이벤트 처리..
-------------------------------------
function SkillScript_Charging:initEventListener()
    PARENT.initEventListener(self)

    -- 스킬 사용자 피격시 이벤트 등록
    self.m_owner:addListener('under_atk', self)
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillScript_Charging:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_owner = owner
    self.m_lTargetChar = self.m_world:getDragonList()
    self.m_duration = 0

    -- 애니메이션 설정
    -- skill 테이블의 animation 에 정보가 여러개 들어가 있을 수도 있다.
    -- {animation_name};{animation_name}
    local l_animation = pl.stringx.split(t_skill['animation'], ';')

    if (l_animation) then
        if (#l_animation >= 4) then
            self.m_appearAniName = l_animation[1]
	        self.m_chargeAniName = l_animation[2]
            self.m_failAniName = l_animation[3]
            self.m_returnAniName = l_animation[4]

        elseif (#l_animation >= 3) then
            self.m_appearAniName = l_animation[1]
	        self.m_chargeAniName = l_animation[2]
            self.m_failAniName = l_animation[3]

        elseif (#l_animation >= 2) then
            self.m_appearAniName = l_animation[1]
	        self.m_chargeAniName = l_animation[2]

        elseif (#l_animation >= 1) then
            self.m_chargeAniName = l_animation[1]

        end
    end

    -- 스킬설정
    -- 인덱스 1 성공스킬
    -- 인덱스 2 실패스킬
    local l_skill = pl.stringx.split(t_skill['val_1'], ';')

    if (l_skill) then
        if (#l_skill >= 2) then
            self.m_attackSkillId = tonumber(l_skill[1])
	        self.m_failSkillId = tonumber(l_skill[2])

        elseif (#l_skill >= 1) then
            self.m_attackSkillId = tonumber(l_skill[1])

        end
    end

    -- 캐스팅 정보
    -- {캐스팅 시간(초)};{캐스팅 중단에 필요한 데미지}
    local l_customValue = pl.stringx.split(t_skill['val_2'], ';')

    if (l_customValue) then
        if (#l_customValue >= 2) then
            self.m_castingTime = tonumber(l_customValue[1])
	        self.m_abortDamageRate = tonumber(l_customValue[2])

        elseif (#l_customValue >= 1) then
            self.m_castingTime = tonumber(l_customValue[1])

        end
    end

    self.m_totalDamageForCancel = self.m_abortDamageRate / 100 * self.m_owner.m_maxHp

end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript_Charging:initState()
    self:setCommonState(self)
    self:addState('start', SkillScript_Charging.st_start, nil, false)
    self:addState('charge', SkillScript_Charging.st_charge, nil, false)
    self:addState('attack', SkillScript_Charging.st_attack, nil, false)
    self:addState('cancel', SkillScript_Charging.st_cancel, nil, false)
    self:addState('end', SkillScript_Charging.st_disappear, nil, false)
end

-------------------------------------
-- function st_charge
-------------------------------------
function SkillScript_Charging.st_start(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 약점 이펙트 표시
        if (owner.m_effectRootNode) then
            owner.m_effectRootNode:setVisible(true)
        end

        owner:updateEffectPos()
        owner:updateGauge()

        owner.m_owner.m_animator:changeAni(owner.m_appearAniName, false)
        owner.m_owner.m_animator:addAniHandler(function()
            owner:changeState('charge')
        end)
		
    end
end

-------------------------------------
-- function st_charge
-------------------------------------
function SkillScript_Charging.st_charge(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner.m_owner.m_animator:changeAni(owner.m_chargeAniName, false)
    end

    owner:updateEffectPos()
    owner:updateGauge()

    if (owner.m_totalDamage >= owner.m_totalDamageForCancel) then
        owner:changeState('cancel')
    elseif (owner.m_stateTimer > owner.m_castingTime) then
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillScript_Charging.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        -- 공격 찍
        owner:runAttack()
		owner:changeState('end')
	end

    -- 공격상태 유지시간
    --[[
    if (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('end')
    end
    ]]
end

-------------------------------------
-- function st_cancel
-------------------------------------
function SkillScript_Charging.st_cancel(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        if (isNullOrEmpty(owner.m_failAniName)) then
            owner:changeState('dying')
            return
        end

		owner.m_owner.m_animator:changeAni(owner.m_failAniName, false) 
        owner.m_owner.m_animator:addAniHandler(function()
            owner:changeState('dying')

            -- 캐스팅 실패 스킬
            if (owner.m_failSkillId and owner.m_failSkillId > 0) then
                owner.m_owner:doSkill(owner.m_failSkillId)
            end  
        end)
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillScript_Charging.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        if (isNullOrEmpty(owner.m_returnAniName)) then
            owner:changeState('dying')
            return
        end

        -- 주체 유닛 애니 설정
        local unit = owner.m_owner
        unit.m_animator:changeAni(owner.m_returnAniName, false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function onDying
-------------------------------------
function SkillScript_Charging:onDying()
    PARENT.onDying(self)

    -- 이펙트 삭제
    self:removeEffect()
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillScript_Charging:runAttack()
    -- attack pos 가져옴
    local pos = self:getOwnerAttackPos('attack')
    if (not pos) then
        pos = { x = 0, y = 0 }
    end

    if (self:isScriptSkill()) then
        self:do_script_shot(pos['x'], pos['y'], PHYS.MISSILE.ENEMY)
    else
        self.m_owner:doSkill(tonumber(self.m_attackSkillId), pos['x'], pos['y'])
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function SkillScript_Charging:onEvent(event_name, t_event, ...)
    local t_event = t_event or {}

	if (string.find(event_name, 'under_atk')) then
        local body_key = t_event['body_key']
        if (body_key) then
            local body = self.m_owner:getBody(body_key)

            if (not body) then
            
            --[[    
            elseif (body['bone'] == WEAK_POINT_BONE) then
                self.m_totalDamage = self.m_totalDamage + t_event['damage']

                -- 게이지 갱신
                self:updateGauge()
                ]]

            -- 전신맛사지중이면? 어디에 맞든 데미지 계산
            elseif (self:isFullBodyAttack()) then
                self.m_totalDamage = self.m_totalDamage + t_event['damage']

                -- 게이지 갱신
                self:updateGauge()

            end
        end
    else
        PARENT.onEvent(self, event_name, t_event, ...)
    end
end


-------------------------------------
-- function updateEffectPos
-------------------------------------
function SkillScript_Charging:updateEffectPos()
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
-- function updateGauge
-------------------------------------
function SkillScript_Charging:updateGauge()
    if (self.m_hpGauge) then
        local hitCount = math_min(self.m_totalDamage, self.m_totalDamageForCancel)
        local ratio = (self.m_totalDamageForCancel - hitCount) / self.m_totalDamageForCancel

        self.m_hpGauge:setScaleX(ratio)
    end
end

-------------------------------------
-- function removeEffect
-------------------------------------
function SkillScript_Charging:removeEffect()
    if (self.m_effectRootNode) then
        self.m_effectRootNode:removeFromParent(true)
        self.m_effectRootNode = nil
    end

    self.m_effectWeakPoint = nil
    self.m_hpGaugeFrame = nil
    self.m_hpGauge = nil
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillScript_Charging:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local res = t_skill['res_1']
    --local duration = t_skill['val_2']
    --local script_name = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript_Charging(res)

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
function SkillScript_Charging:isFullBodyAttack()
    return isNullOrEmpty(self.m_weakBoneName)
end

-------------------------------------
-- function isScriptSkill
-------------------------------------
function SkillScript_Charging:isScriptSkill()
    return not tonumber(self.m_attackSkillId)
end