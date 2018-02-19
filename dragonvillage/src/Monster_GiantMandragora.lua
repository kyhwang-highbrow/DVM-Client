local PARENT = Monster

-------------------------------------
-- class Monster_GiantMandragora
-------------------------------------
Monster_GiantMandragora = class(PARENT, {
        m_orgAnimatorScale = 'number',
        m_curAnimatorScale = 'number',
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

    self:addState('dying', Monster_GiantMandragora.st_dying, 'boss_die', false, PRIORITY.DYING)
end

-------------------------------------
-- function st_dying
-------------------------------------
function Monster_GiantMandragora.st_dying(owner, dt)
    PARENT.st_dying(owner, dt)
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

    -- 10만 데미지를 받을 때마다 5%씩 크기를 키움
    --local grow_count = math_floor(accum_damage / 100000)
    local grow_count = math_floor(accum_damage / 10000)
    local new_scale = 0.05 * grow_count + self.m_orgAnimatorScale

    -- 최대 500%
    new_scale = math_min(new_scale, 5)

    if (self.m_curAnimatorScale ~= new_scale) then
        self:runAction_Grow(new_scale)

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

    --[[
    local temp_scale = new_scale * 1.2

    local action = cc.Sequence:create(
        cc.ScaleTo:create(0.25, -temp_scale, temp_scale),
        cc.ScaleTo:create(0.25, -new_scale, new_scale)
    )
    ]]--

    local action = cc.ScaleTo:create(0.5, -new_scale, new_scale),

    cca.stopAction(target_node, CHARACTER_ACTION_TAG__SCALE)
    cca.runAction(target_node, action, CHARACTER_ACTION_TAG__SCALE)
end