local PARENT = SkillScript

local WEAK_POINT_BONE = 'bone79'

-------------------------------------
-- class SkillScript_Charging
-------------------------------------
SkillScript_Charging = class(PARENT, {
    m_hitCount = 'number',
    m_hitCountForCancel = 'number',

    m_chargeAniName = 'str', 
    m_castingTime = 'number',

    m_attackSkillId = 'number', -- 스크립트 파일일 수도 있음
    m_failSkillId = 'number',

    m_effectRootNode = '',
    m_effectWeakPoint = '',

    m_hpGaugeFrame = '',
    m_hpGauge = '',
})

-------------------------------------
-- function init
-------------------------------------
function SkillScript_Charging:init()
    self.m_hitCount = 0
    self.m_hitCountForCancel = 10

    self.m_effectRootNode = nil
    self.m_effectWeakPoint = nil

    self.m_hpGaugeFrame = nil
    self.m_hpGauge = nil
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillScript_Charging:init_skill(script_name, duration)
    PARENT.init_skill(self, script_name, duration)

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

    -- skill 테이블의 animation 은 사전 연출 animation이기 때문에
    -- 다른 컬럼을 사용해야 한다.
	self.m_chargeAniName = t_skill['animation']

	local l_casting_info = pl.stringx.split(t_skill['val_3'], ';')

    -- 1 충전 시 어떤 애니메이션 사용?
    -- 2 캐스팅 시간
    -- 3 중단에 필요한 데미지 체력 % 수?
    -- 4 실패시 발동될 스킬
    if (l_casting_info) then
        if (#l_casting_info >= 4) then
            self.m_chargeAniName = l_casting_info[1]
            self.m_castingTime = tonumber(l_casting_info[2])
            self.m_hitCountForCancel = tonumber(l_casting_info[3]) * self.m_owner.m_maxHp
            self.m_failSkillId = tonumber(l_casting_info[4])
        end
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript_Charging:initState()
    self:setCommonState(self)
    self:addState('start', SkillScript_Charging.st_start, nil, false)
    self:addState('charge', SkillScript_Charging.st_charge, self.m_chargeAniName, false)
    self:addState('attack', SkillScript_Charging.st_attack, nil, false)
    self:addState('cancel', SkillScript_Charging.st_cancel, nil, false)
    self:addState('end', SkillScript_Charging.st_disappear, nil, false)
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function SkillScript_Charging:changeState(state)
    local char = self.m_owner
    local ani_name = self.m_tStateAni[state] and self.m_tStateAni[state]

    if (char and not isNullOrEmpty(ani_name)) then
        -- 주체 유닛 애니 설정
        char.m_animator:changeAni(ani_name, false)
    end

    if (state == 'cancel') then
        char:doSkill(self.m_failSkillId)
    end

    return PARENT.changeState(self, state)
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

        owner:changeState('charge')
    end
end

-------------------------------------
-- function st_charge
-------------------------------------
function SkillScript_Charging.st_charge(owner, dt)
	if (owner.m_stateTimer == 0) then

    end

    owner:updateEffectPos()
    owner:updateGauge()

    if (owner.m_hitCount >= owner.m_hitCountForCancel) then
        owner:changeState('cancel')
    elseif (owner.m_stateTimer > 3) then
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

        -- 미사일 발사
        owner:runAttack()

        cclog(owner.m_hitCountForCancel)

        owner:changeState('end')
	end

    if (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_cancel
-------------------------------------
function SkillScript_Charging.st_cancel(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()
        owner:changeState('dying')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillScript_Charging.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        -- 주체 유닛 애니 설정
        local unit = owner.m_owner
        --[[
        unit.m_animator:changeAni('skill_1_disappear', false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)]]

        owner:changeState('dying')
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
        self.m_owner:doSkill(tonumber(self.m_attackSkillId))
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
            elseif (body['bone'] == WEAK_POINT_BONE) then
                self.m_hitCount = self.m_hitCount + t_event['damage']

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
        local bone_pos = unit.m_animator.m_node:getBonePosition(WEAK_POINT_BONE)
        local x = unit.pos['x'] + bone_pos['x'] * unit.m_animator.m_node:getScaleX()
        local y = unit.pos['y'] + bone_pos['y'] * unit.m_animator.m_node:getScaleY()
        
        self.m_effectRootNode:setPosition(x, y)
    end
end

-------------------------------------
-- function updateGauge
-------------------------------------
function SkillScript_Charging:updateGauge()
    if (self.m_hpGauge) then
        local hitCount = math_min(self.m_hitCount, self.m_hitCountForCancel)
        local ratio = (self.m_hitCountForCancel - hitCount) / self.m_hitCountForCancel

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
    local duration = t_skill['val_2']
    local script_name = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript_Charging(res)

    skill.m_attackSkillId = script_name

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
-- function isScriptSkill
-------------------------------------
function SkillScript_Charging:isScriptSkill()
    return not tonumber(self.m_attackSkillId)
end