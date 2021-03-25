local PARENT = SkillScript

local WEAK_POINT_BONE = 'bone79'

-------------------------------------
-- class SkillScript_AncientDragon
-------------------------------------
SkillScript_AncientDragon = class(PARENT, {
    m_hitCount = 'number',
    m_hitCountForCancel = 'number',

    m_effectRootNode = '',
    m_effectWeakPoint = '',

    m_hpGaugeFrame = '',
    m_hpGauge = '',
})

-------------------------------------
-- function init
-------------------------------------
function SkillScript_AncientDragon:init()
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
function SkillScript_AncientDragon:init_skill(script_name, duration)
    PARENT.init_skill(self, script_name, duration)

    -- 스킬 캔슬에 필요한 히트수 저장
    local value = TableStageData():getValue(self.m_world.m_stageID, 'val_1')
    if (value and value ~= '') then
        self.m_hitCountForCancel = tonumber(value)
    end

    -- 약점 이펙트 생성
    if (not self.m_effectRootNode) then
        self.m_effectRootNode = cc.Node:create()
        self.m_effectRootNode:setVisible(false)
        self.m_world:getMissileNode():addChild(self.m_effectRootNode)
    end

    --[[
    if (not self.m_effectWeakPoint) then
        self.m_effectWeakPoint = MakeAnimator('res/effect/effect_weak_point/effect_weak_point.vrp')
        self.m_effectWeakPoint:changeAni('idle', true)
        self.m_effectWeakPoint:setVisible(false)
        self.m_effectRootNode:addChild(self.m_effectWeakPoint.m_node, 1)
    end
    ]]--

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
function SkillScript_AncientDragon:initEventListener()
    PARENT.initEventListener(self)

    -- 스킬 사용자 피격시 이벤트 등록
    self.m_owner:addListener('under_atk', self)
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillScript_AncientDragon:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_lTargetChar = self.m_world:getDragonList()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript_AncientDragon:initState()
    self:setCommonState(self)
	
    self:addState('start', SkillScript_AncientDragon.st_charge, nil, false)
    self:addState('attack', SkillScript_AncientDragon.st_attack, nil, false)
    self:addState('cancel', SkillScript_AncientDragon.st_cancel, nil, false)
    self:addState('end', SkillScript_AncientDragon.st_disappear, nil, false)
end

-------------------------------------
-- function st_charge
-------------------------------------
function SkillScript_AncientDragon.st_charge(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 주체 유닛 애니 설정
        local unit = owner.m_owner
        unit.m_animator:changeAni('skill_1_appear', false)

        -- 여기서 충전중 정보 설정
        owner.m_reactingInfo = {  }


        -- 약점 이펙트 표시
        if (owner.m_effectRootNode) then
            owner.m_effectRootNode:setVisible(true)
        end
    end

    owner:updateEffectPos()
    owner:updateGauge()
    
    if (owner.m_hitCount >= owner.m_hitCountForCancel) then
        owner:changeState('cancel')
    elseif (owner.m_stateTimer > 15) then
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillScript_AncientDragon.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        -- 주체 유닛 애니 설정
        local unit = owner.m_owner
        unit.m_animator:changeAni('skill_1_idle', true)

        -- 미사일 발사
        owner:runAttack()
	end

    if (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_cancel
-------------------------------------
function SkillScript_AncientDragon.st_cancel(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        -- 주체 유닛 애니 설정
        local unit = owner.m_owner
        unit.m_animator:changeAni('skill_1_cancel', false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillScript_AncientDragon.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 이펙트 삭제
        owner:removeEffect()

        -- 주체 유닛 애니 설정
        local unit = owner.m_owner
        unit.m_animator:changeAni('skill_1_disappear', false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function onDying
-------------------------------------
function SkillScript_AncientDragon:onDying()
    PARENT.onDying(self)

    -- 이펙트 삭제
    self:removeEffect()
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillScript_AncientDragon:runAttack()
    -- attack pos 가져옴
    local pos = self:getOwnerAttackPos('skill_1_idle')
    if (not pos) then
        pos = { x = 0, y = 0 }
    end

    self:do_script_shot(pos['x'], pos['y'], PHYS.MISSILE.ENEMY)
end

-------------------------------------
-- function onEvent
-------------------------------------
function SkillScript_AncientDragon:onEvent(event_name, t_event, ...)
    local t_event = t_event or {}

	if (string.find(event_name, 'under_atk')) then
        local body_key = t_event['body_key']
        if (body_key) then
            local body = self.m_owner:getBody(body_key)

            if (not body) then
            elseif (body['bone'] == WEAK_POINT_BONE) then
                --self.m_hitCount = self.m_hitCount + 1
                self.m_hitCount = self.m_hitCount + t_event['damage']
                --cclog('self.m_hitCount : ' .. self.m_hitCount)

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
function SkillScript_AncientDragon:updateEffectPos()
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
function SkillScript_AncientDragon:updateGauge()
    if (self.m_hpGauge) then
        local hitCount = math_min(self.m_hitCount, self.m_hitCountForCancel)
        local ratio = (self.m_hitCountForCancel - hitCount) / self.m_hitCountForCancel

        self.m_hpGauge:setScaleX(ratio)
    end
end

-------------------------------------
-- function removeEffect
-------------------------------------
function SkillScript_AncientDragon:removeEffect()
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
function SkillScript_AncientDragon:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
    local script_name = t_skill['val_1']
    local duration = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript_AncientDragon(res)

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