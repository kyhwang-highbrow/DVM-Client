--local PARENT = MonsterLua_Boss
local PARENT = Monster_AncientRuinDragon

-------------------------------------
-- class Monster_WorldRaidBoss
-------------------------------------
Monster_WorldRaidBossAncientRuinDragon = class(PARENT, {
     })

-------------------------------------
-- function setDamage
-------------------------------------
function Monster_WorldRaidBossAncientRuinDragon:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == i_x and self.pos['y'] == i_y) then
        i_x, i_y = self:getCenterPos()
    end

    -- 타임 아웃시 무적 처리
    self:dispatch('acc_damage', { damage = damage,}, self)
    PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)    
end