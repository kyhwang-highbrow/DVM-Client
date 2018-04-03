local PARENT = class(MonsterLua_Boss, ICharacterBinding:getCloneTable())

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
--[[
-------------------------------------
-- function initPhys
-- @param body
-------------------------------------
function Monster_AncientRuinDragon:initPhys(body)
    PARENT.initPhys(self, { 0, 0, 0 })
end
]]--
-------------------------------------
-- function initCharacterBinding
-- @brief 바인딩 관련 초기값 지정(m_classDef은 반드시 설정되어야함)
-- @override
-------------------------------------
function Monster_AncientRuinDragon:initCharacterBinding()
    self.m_classDef = MonsterLua_Boss
end

-------------------------------------
-- function init_monster
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