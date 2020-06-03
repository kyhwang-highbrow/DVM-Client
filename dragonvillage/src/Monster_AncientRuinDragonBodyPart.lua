local PARENT = class(Monster, ICharacterBinding:getCloneTable())

-------------------------------------
-- class Monster_AncientRuinDragonBodyPart
-------------------------------------
Monster_AncientRuinDragonBodyPart = class(PARENT, {})


-------------------------------------
-- function init_monster
-------------------------------------
function Monster_AncientRuinDragonBodyPart:init_monster(t_monster, monster_id, level)
    -- 각종 init 함수 실행
	do
        self:initDragonSkillManager('monster', monster_id, 6, true)
        self:initStatus(t_monster, level, 0, 0, 0)

        -- 하이라이트 노드 설정
        if (self.m_parentChar) then
            self:addHighlightNode(self.m_parentChar.m_animator.m_node)
        end
    end

    -- 피격 처리
    self:addDefCallback(function(attacker, defender, i_x, i_y, k, b)
        self:undergoAttack(attacker, defender, i_x, i_y, k or 0, b)
    end)
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Monster_AncientRuinDragonBodyPart:makeHPGauge(hp_ui_offset, force)
end

-------------------------------------
-- function undergoAttack
-------------------------------------
function Monster_AncientRuinDragonBodyPart:undergoAttack(attacker, defender, i_x, i_y, body_key, no_event, is_guard)
    if (self.m_parentChar) then
        self.m_parentChar:undergoAttack(attacker, self.m_parentChar, i_x, i_y, self.m_bodyKey, no_event, is_guard)
    end
end

-------------------------------------
-- function setDamage
-------------------------------------
function Monster_AncientRuinDragonBodyPart:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    if (self.m_parentChar) then
        PARENT.setDamage(self.m_parentChar, attacker, self.m_parentChar, i_x, i_y, damage, t_info)
    end
end

-------------------------------------
-- function release
-------------------------------------
function Monster_AncientRuinDragonBodyPart:release()
    if (self.m_parentChar) then
        self.m_parentChar:removeChildCharacter(self)
    end

    PARENT.release(self)
end

-------------------------------------
-- function setHighlight
-------------------------------------
function Monster_AncientRuinDragonBodyPart:setHighlight(highlightLevel)
    if (self.m_parentChar) then
        self.m_parentChar:setHighlight(highlightLevel)
    end
end

-------------------------------------
-- function isExistTargetEffect
-------------------------------------
function Monster_AncientRuinDragonBodyPart:isExistTargetEffect(k)
    local unit = self
    local key = k

    if (self.m_parentChar) then
        unit = self.m_parentChar
        key = self.m_bodyKey
    end

    return PARENT.isExistTargetEffect(unit, key)
end

-------------------------------------
-- function setTargetEffect
-------------------------------------
function Monster_AncientRuinDragonBodyPart:setTargetEffect(animator, k)
    local unit = self
    local key = k

    if (self.m_parentChar) then
        unit = self.m_parentChar
        key = self.m_bodyKey
    end

    PARENT.setTargetEffect(unit, animator, key)
end

-------------------------------------
-- function removeTargetEffect
-------------------------------------
function Monster_AncientRuinDragonBodyPart:removeTargetEffect(k)
    local unit = self
    local key = k

    if (self.m_parentChar) then
        unit = self.m_parentChar
        key = self.m_bodyKey
    end

    PARENT.removeTargetEffect(unit, key)
end

-------------------------------------
-- function isExistNonTargetEffect
-------------------------------------
function Monster_AncientRuinDragonBodyPart:isExistNonTargetEffect(k)
    local unit = self
    local key = k

    if (self.m_parentChar) then
        unit = self.m_parentChar
        key = self.m_bodyKey
    end

    return PARENT.isExistNonTargetEffect(unit, key)
end

-------------------------------------
-- function setNonTargetEffect
-------------------------------------
function Monster_AncientRuinDragonBodyPart:setNonTargetEffect(animator, k)
    local unit = self
    local key = k

    if (self.m_parentChar) then
        unit = self.m_parentChar
        key = self.m_bodyKey
    end

    PARENT.setNonTargetEffect(unit, animator, key)
end

-------------------------------------
-- function removeNonTargetEffect
-------------------------------------
function Monster_AncientRuinDragonBodyPart:removeNonTargetEffect(k)
    local unit = self
    local key = k

    if (self.m_parentChar) then
        unit = self.m_parentChar
        key = self.m_bodyKey
    end

    PARENT.removeNonTargetEffect(unit, key)
end

-------------------------------------
-- function getZOrder
-------------------------------------
function Monster_AncientRuinDragonBodyPart:getZOrder()
    local zOrder = WORLD_Z_ORDER.BOSS + 1
    return zOrder
end