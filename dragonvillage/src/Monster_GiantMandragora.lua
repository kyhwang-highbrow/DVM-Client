local PARENT = Monster

local DAMAGE_UNIT = 100000

-------------------------------------
-- class Monster_GiantMandragora
-------------------------------------
Monster_GiantMandragora = class(PARENT, {
        m_orgAnimatorScale = 'number',
        m_curAnimatorScale = 'number',

        m_dropInterval = 'number',
        m_dropTimer = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_GiantMandragora:init_monster(t_monster, monster_id, level)
    PARENT.init_monster(self, t_monster, monster_id, level)

    if (self.m_animator and self.m_animator.m_node) then
        self.m_orgAnimatorScale = self.m_animator:getScale()
    else
        self.m_orgAnimatorScale = 1
    end

    self.m_curAnimatorScale = self.m_orgAnimatorScale
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_GiantMandragora:initState()
    PARENT.initState(self)

    self:addState('dying', Monster_GiantMandragora.st_dying, 'dying_1', false, PRIORITY.DYING)
    self:addState('dead', Monster_GiantMandragora.st_dead, nil, nil, PRIORITY.DEAD)
end

-------------------------------------
-- function st_dying
-------------------------------------
function Monster_GiantMandragora.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:setSpeed(0)

        -- 사망 처리 시 StateDelegate Kill!
        owner:killStateDelegate()

        if (owner.m_cbDead) then
            owner.m_cbDead(owner)
        end

        SoundMgr:playEffect('EFX', 'efx_midboss_die')

        if (owner.m_hpNode) then
            owner.m_hpNode:setVisible(false)
        end

        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end

        owner:addAniHandler(function()
            owner.m_animator:changeAni('dying_2', false)
            owner:addAniHandler(function()
                owner:changeState('dead')
            end)
        end)

        local accum_damage = owner.m_world.m_gameState.m_accumDamage:get()
        local drop_count = math_floor(accum_damage / DAMAGE_UNIT)

        owner.m_dropInterval = owner.m_animator:getDuration() / drop_count
        owner.m_dropTimer = 0
    end

    while (owner.m_dropInterval <= owner.m_dropTimer) do
        owner:dispatch('drop_gold', {}, owner)
        owner.m_dropTimer = owner.m_dropTimer - owner.m_dropInterval
    end

    owner.m_dropTimer = owner.m_dropTimer + dt
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Monster_GiantMandragora:makeHPGauge(hp_ui_offset, force)
end

-------------------------------------
-- function setHp
-- @brief 체력은 변경 할 수 없도록 처리
-------------------------------------
function Monster_GiantMandragora:setHp(hp, bFixed)
    local dv = hp - self.m_hp

    -- 데미지가 아닌 경우
    if (dv >= 0) then return end

    local damage = -dv

    local t_event = {}
    t_event['damage'] = damage

    -- 리스너에 전달
	self:dispatch('character_set_damage', t_event, self)

    -- 누적 데미지량에 따라 키움
    self:growByAccumDamage(t_event['accum_damage'])
end

-------------------------------------
-- function growByAccumDamage
-------------------------------------
function Monster_GiantMandragora:growByAccumDamage(accum_damage)
    if (not accum_damage) then return end

    -- 5만 데미지를 받을 때마다 1%씩 크기를 키움
    local grow_count = math_floor(accum_damage / 50000)
    local new_scale = 0.01 * grow_count + self.m_orgAnimatorScale

    -- 최대 300%
    new_scale = math_min(new_scale, 3)

    if (self.m_curAnimatorScale ~= new_scale) then
        self:runAction_Grow(new_scale)

        -- TODO: body 크기도 키워야함...

        self.m_curAnimatorScale = new_scale
    end
end

-------------------------------------
-- function runAction_Grow
-------------------------------------
function Monster_GiantMandragora:runAction_Grow(new_scale)
    if (not self.m_animator) then return end
    
    local target_node = self.m_animator.m_node
    if (not target_node) then return end
    
    local action = cc.ScaleTo:create(0.5, -new_scale, new_scale),

    cca.stopAction(target_node, CHARACTER_ACTION_TAG__SCALE)
    cca.runAction(target_node, action, CHARACTER_ACTION_TAG__SCALE)
end