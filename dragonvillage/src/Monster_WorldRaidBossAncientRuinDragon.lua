--local PARENT = MonsterLua_Boss
local PARENT = Monster_AncientRuinDragon

-------------------------------------
-- class Monster_WorldRaidBoss
-------------------------------------
Monster_WorldRaidBossAncientRuinDragon = class(PARENT, {
    m_dmglist = '',
     })

     
-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_WorldRaidBossAncientRuinDragon:init(file_name, body, ...)
    self.m_bUseCastingEffect = false

    self.m_bCreateParts = false
    self.m_bExistDrone = false

    self.m_mEffectTimer = {}
    self.m_isRaidMonster = true
    --self.m_dmglist = {}
end


-------------------------------------
-- function setDamage
-------------------------------------
function Monster_WorldRaidBossAncientRuinDragon:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == i_x and self.pos['y'] == i_y) then
        i_x, i_y = self:getCenterPos()
    end

    -- 타임 아웃시 무적 처리
    -- self:dispatch('acc_damage', { damage = damage,}, self)
    self.m_world.m_gameState:onEvent('acc_damage', { damage = damage,})
    PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)    
end