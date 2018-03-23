local PARENT = MonsterLua_Boss

-------------------------------------
-- class Monster_AncientRuinDragon
-------------------------------------
Monster_AncientRuinDragon = class(PARENT, {
    m_cbAppearEnd   = 'function',       -- appear 상태가 끝났을때 호출될 콜백 함수
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_AncientRuinDragon:init(file_name, body, ...)
    self.m_bUseCastingEffect = false
end

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_AncientRuinDragon:init_monster(t_monster, monster_id, level)
    PARENT.init_monster(self, t_monster, monster_id, level)

    if (self.m_animator and self.m_animator.m_node) then
        self.m_animator.m_node:setMix('boss_appear', 'idle', 1)
    end
end

-------------------------------------
-- function initFormation
-------------------------------------
function Monster_AncientRuinDragon:initFormation(body_size)
    PARENT.initFormation(self, body_size)

    -- 리소스가 좌우 반대로 제작되어서 여기서 반전처리...
    self.m_animator:setFlip(false)
end


-------------------------------------
-- function initState
-------------------------------------
function Monster_AncientRuinDragon:initState()
    PARENT.initState(self)

    self:addState('appear', Monster_AncientRuinDragon.st_appear, 'boss_appear', false)
end


-------------------------------------
-- function st_appear
-------------------------------------
function Monster_AncientRuinDragon.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_animator:addAniHandler(function()
            if (owner.m_cbAppearEnd) then
                owner.m_cbAppearEnd()
            end
        end)

        owner.m_animator.m_node:pause()
    end

    local map_manager = owner.m_world.m_mapManager
    local pos_x = owner.m_homePosX - (map_manager.m_addMoveDestDistance - map_manager.m_addMoveCurDistance)

    owner:setPosition(pos_x, owner.pos.y)

    if (pos_x == owner.m_homePosX) then
        owner.m_animator.m_node:resume()
    end
end

--[[
-------------------------------------
-- function undergoAttack
-------------------------------------
function Monster_AncientRuinDragon:undergoAttack(attacker, defender, i_x, i_y, body_key, no_event, is_guard)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == i_x and self.pos['y'] == i_y) then
        i_x, i_y = self:getCenterPos()
    end

    PARENT.undergoAttack(self, attacker, defender, i_x, i_y, body_key, no_event, is_guard)
end
]]--
-------------------------------------
-- function setDamage
-------------------------------------
function Monster_AncientRuinDragon:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == i_x and self.pos['y'] == i_y) then
        i_x, i_y = self:getCenterPos()
    end

    PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)
end
--[[
-------------------------------------
-- function onChangedAttackableGroup
-- @brief 공격할 수 있는 대상 그룹 정보가 변경되었을 경우
-------------------------------------
function Monster_AncientRuinDragon:onChangedAttackableGroup()
    -- 클랜 보스 본체의 경우 특정 스킬을 사용하지 못하도록 처리...
    if (self.m_charTable['type'] == 'clanraid_boss') then
        local l_remove_skill_id = { 250011, 250012, 250013, 250014, 250015 }

        for _, skill_id in ipairs(l_remove_skill_id) do
            self:unsetSkillID(skill_id)
        end
    end
end

-------------------------------------
-- function makeMissFont
-------------------------------------
function Monster_AncientRuinDragon:makeMissFont(x, y)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeMissFont(self, x, y)
end

-------------------------------------
-- function makeShieldFont
-------------------------------------
function Monster_AncientRuinDragon:makeShieldFont(x, y)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeShieldFont(self, x, y)
end

-------------------------------------
-- function makeImmuneFont
-------------------------------------
function Monster_AncientRuinDragon:makeImmuneFont(x, y, scale)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeImmuneFont(self, x, y, scale)
end

-------------------------------------
-- function makeResistanceFont
-------------------------------------
function Monster_AncientRuinDragon:makeResistanceFont(x, y, scale)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeResistanceFont(self, x, y, scale)
end
]]--
-------------------------------------
-- function syncHp
-------------------------------------
function Monster_AncientRuinDragon:syncHp(hp)
    if (self:isDead()) then return end

    self.m_hp = math_min(hp, self.m_maxHp)
    self.m_hpRatio = self.m_hp / self.m_maxHp

    if (self:isZeroHp()) then
        self:changeState('dying')
    end

    -- 체력바 가감 연출
    if (self.m_hpGauge) then
        self.m_hpGauge:setScaleX(self.m_hpRatio)
    end
	if (self.m_hpGauge2) then
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, self.m_hpRatio, 1))
        self.m_hpGauge2:runAction(cc.EaseIn:create(action, 2))
    end
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Monster_AncientRuinDragon:makeHPGauge(hp_ui_offset, force)
    PARENT.makeHPGauge(self, hp_ui_offset, false)

    -- 유닛별 체력 게이지 사용 안함
    self.m_hpGauge = nil
    self.m_hpGauge2 = nil

    local childs = self.m_hpNode:getChildren()
    for _, v in pairs(childs) do
        doAllChildren(v, function(node) node:setVisible(false) end)
    end
    
    -- 체력 게이지 대신 이름 표시
    local font_scale_x, font_scale_y = Translate:getFontScaleRate()
    local label = cc.Label:createWithTTF(self:getName(), Translate:getFontPath(), 24, 2, cc.size(250, 100), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setColor(cc.c3b(255,87,87))
    label:setScale(font_scale_x, font_scale_y)
    self.m_hpNode:addChild(label)
end

-------------------------------------
-- function runAction_Floating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function Monster_AncientRuinDragon:runAction_Floating()
end

-------------------------------------
-- function doAppear
-------------------------------------
function Monster_AncientRuinDragon:doAppear(cb)
    self.m_cbAppearEnd = cb

    self:changeState('appear')
end