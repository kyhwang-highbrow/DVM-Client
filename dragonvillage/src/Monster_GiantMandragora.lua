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

        self.m_animator.m_node:setMix('idle', 'damage', 0.2)
        self.m_animator.m_node:setMix('damage', 'damage', 0.2)
        self.m_animator.m_node:setMix('damage', 'idle', 0.2)
        self.m_animator.m_node:setMix('damage', 'attack', 0.1)
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

        -- ��� ó�� �� StateDelegate Kill!
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
        local drop_count = math_floor(accum_damage / DAMAGE_UNIT) + 20
        drop_count = math_min(drop_count, 110)

        owner.m_dropInterval = owner.m_animator:getDuration() / drop_count
        owner.m_dropTimer = 0
    end

    while (owner.m_dropInterval <= owner.m_dropTimer) do
        owner:dispatch('drop_gold_final', {}, owner)
        owner.m_dropTimer = owner.m_dropTimer - owner.m_dropInterval
    end

    owner.m_dropTimer = owner.m_dropTimer + dt
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Monster_GiantMandragora:makeHPGauge(hp_ui_offset, force)
    PARENT.makeHPGauge(self, hp_ui_offset, false)

    -- ���ֺ� ü�� ������ ��� ����
    self.m_hpGauge = nil
    self.m_hpGauge2 = nil

    local childs = self.m_hpNode:getChildren()
    for _, v in pairs(childs) do
        doAllChildren(v, function(node) node:setVisible(false) end)
    end
    
    -- ü�� ������ ��� �̸� ǥ��
    local font_scale_x, font_scale_y = Translate:getFontScaleRate()
    local label = cc.Label:createWithTTF(self:getName(), Translate:getFontPath(), 24, 2, cc.size(250, 100), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setColor(cc.c3b(255,87,87))
    label:setScale(font_scale_x, font_scale_y)
    self.m_hpNode:addChild(label)
end

-------------------------------------
-- function setHp
-- @brief ü���� ���� �� �� ������ ó��
-------------------------------------
function Monster_GiantMandragora:setHp(hp, bFixed)
    -- �׾����� Ż��
    if (not bFixed) then
	    if (self:isDead()) then return end
        if (self:isZeroHp()) then return end
    end

    local dv = hp - self.m_hp

    -- �������� �ƴ� ���
    if (dv >= 0) then return end

    local damage = -dv

    local t_event = {}
    t_event['damage'] = damage

    -- �����ʿ� ����
	self:dispatch('character_set_damage', t_event, self)

    local accum_damage = t_event['accum_damage']

    -- ���� ���������� ���� Ű��
    self:growByAccumDamage(accum_damage)

    -- ���� ���������� ���� ������ ���
    local prev_accum_damage = accum_damage - damage
    prev_accum_damage = math_max(prev_accum_damage, 0)
    self:dropItemByAccumDamage(accum_damage, prev_accum_damage)
end

-------------------------------------
-- function growByAccumDamage
-------------------------------------
function Monster_GiantMandragora:growByAccumDamage(accum_damage)
    if (not accum_damage) then return end

    -- 5�� �������� ���� ������ 1%�� ũ�⸦ Ű��
    local grow_count = math_floor(accum_damage / (DAMAGE_UNIT / 2))
    local new_scale = 0.01 * grow_count + self.m_orgAnimatorScale

    -- �ִ� 300%
    new_scale = math_min(new_scale, 3 * self.m_orgAnimatorScale)

    if (self.m_curAnimatorScale ~= new_scale) then
        self:runAction_Grow(new_scale)

        self.m_curAnimatorScale = new_scale
    end
end

-------------------------------------
-- function dropItemByAccumDamage
-------------------------------------
function Monster_GiantMandragora:dropItemByAccumDamage(accum_damage, prev_accum_damage)
    if (not accum_damage or not prev_accum_damage) then return end

    -- ���� ������ ���� ���� ���
    local value1 = math_floor(accum_damage / (DAMAGE_UNIT * 2))
    local value2 = math_floor(prev_accum_damage / (DAMAGE_UNIT * 2))
    if (value1 <= value2) then return end

    -- �ǰ� �ִϸ��̼�
    if (self.m_state == 'attackDelay') then
        self.m_animator:changeAni('damage', false)

        self:addAniHandler(function()
            self.m_animator:changeAni('idle', true)
        end)
    end

    -- ������ ���
    self:dispatch('drop_gold', {}, self)
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