local PARENT = MonsterLua_Boss

-------------------------------------
-- class Monster_GoldDragon
-------------------------------------
Monster_GoldDragon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_GoldDragon:init(file_name, body, ...)
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_GoldDragon:initState()
    PARENT.initState(self)

    self:addState('dying', Monster_GoldDragon.st_dying, 'boss_die', false, PRIORITY.DYING)
end


-------------------------------------
-- function st_dying
-------------------------------------
function Monster_GoldDragon.st_dying(owner, dt)
    if (owner:isBeginningStep()) then
        if owner.m_hpNode then
            owner.m_hpNode:setVisible(false)
        end

        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end

        -- 효과음
        if owner.m_tEffectSound['die'] then
            local category = 'EFFECT'
            if startsWith(owner.m_tEffectSound['die'], 'vo_') then
                category = 'VOICE'
            end
            SoundMgr:playEffect(category, owner.m_tEffectSound['die'])
        end

        -- 화면 쉐이킹
        owner.m_world.m_shakeMgr:doShakeUpDown(25, 10)

        owner.m_animator:addAniHandler(function()
            
            -- 화면 쉐이킹 멈춤
            owner.m_world.m_shakeMgr:stopShake()

            owner:changeState('dead')
        end)
    end
end

-------------------------------------
-- function setDamage
-------------------------------------
function Monster_GoldDragon:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)

    -- TODO: 데미지에 따른 금화 획득
    do
        local base_gold, gold_per_damage = TableSecretDungeon():getGoldInfo(self.m_world.m_stageID)
        local gold = base_gold + math_floor(damage / gold_per_damage)
        self.m_world:obtainGold(gold)
    end

    -- TODO: 금화 떨어지는 이펙트
    do
        local res = 'res/effect/effect_hit_gold/effect_hit_gold.vrp'
        local idx = math_random(1, 3)
        self.m_world:addInstantEffect(res, 'hit_' .. idx, i_x, i_y)
    end
end

-------------------------------------
-- function setHp
-------------------------------------
function Monster_GoldDragon:setHp(hp)
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Monster_GoldDragon:makeHPGauge(hp_ui_offset, force)
    self.m_unitInfoOffset = hp_ui_offset

    self.m_statusNode = cc.Node:create()
    self.m_rootNode:addChild(self.m_statusNode)
end