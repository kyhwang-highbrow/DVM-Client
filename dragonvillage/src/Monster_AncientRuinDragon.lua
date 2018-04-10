local PARENT = class(MonsterLua_Boss, ICharacterBinding:getCloneTable())

-------------------------------------
-- class Monster_AncientRuinDragon
-------------------------------------
Monster_AncientRuinDragon = class(PARENT, {
    m_cbAppearEnd   = 'function',       -- appear 상태가 끝났을때 호출될 콜백 함수

    m_bCreateParts  = 'boolean',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_AncientRuinDragon:init(file_name, body, ...)
    self.m_bUseCastingEffect = false

    self.m_bCreateParts = false
end

-------------------------------------
-- function initPhys
-- @param body
-------------------------------------
function Monster_AncientRuinDragon:initPhys(body)
    PARENT.initPhys(self, body)

    if (self.m_animator and self.m_animator.m_type == ANIMATOR_TYPE_SPINE) then
        if (not self.m_bCreateParts) then
            local t_monster = self:getCharTable()
            local body_size = self:getBodySize(t_monster['size_type'])

            for idx, body in ipairs(self.m_lBodyToUseBone) do
                local body_part = Monster_AncientRuinDragonBodyPart()
                self:addChildCharacter(body_part)
                      
                self.m_world:addToUnitList(body_part)

                local monster_id = attributeStrToNum(self.m_attributeOrg) + 152020

                body_part:init_monster(t_monster, monster_id, self:getTotalLevel())
                body_part:initState()
	            body_part:initFormation(body_size)
                body_part:initPhys({0, 0, 25})

                -- 스텟 정보는 본체와 공유
                do
                    body_part.m_bodyKey = body['key']
                    body_part.m_isBoss = true
                    body_part.m_statusCalc = self.m_statusCalc
                    body_part.m_mStatusEffect = self.m_mStatusEffect
                    body_part.m_mHiddenStatusEffect = self.m_mHiddenStatusEffect
                    body_part.m_lStatusIcon = self.m_lStatusIcon
                    body_part.m_mStatusIcon = self.m_mStatusIcon
                    body_part.m_mStatusEffectGroggy = self.m_mStatusEffectGroggy
                end

                self.m_world.m_worldNode:addChild(body_part.m_rootNode, self:getZOrder() + 1)

                if (idx > 2) then
                    self.m_world.m_physWorld:addObject(PHYS.ENEMY_BOTTOM, body_part)
                else
                    self.m_world.m_physWorld:addObject(PHYS.ENEMY_TOP, body_part)
                end
                self.m_world:bindEnemy(body_part)
                self.m_world:addEnemy(body_part)
            
                body_part:dispatch('enemy_appear_done', {}, body_part)
            end

            self.m_bCreateParts = true
        end
    end
end

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
        self.m_animator.m_node:setMix('idle', 'skill_1_appear', 0.2)
        self.m_animator.m_node:setMix('skill_1_appear', 'skill_1_cancel', 0.2)
        self.m_animator.m_node:setMix('skill_1_appear', 'skill_1_idle', 0.2)
        self.m_animator.m_node:setMix('idle', 'skill_2', 0.2)
        self.m_animator.m_node:setMix('idle', 'skill_3', 0.2)
        self.m_animator.m_node:setMix('idle', 'skill_5', 0.2)
        self.m_animator.m_node:setMix('idle', 'skill_6', 0.2)
        self.m_animator.m_node:setMix('idle', 'skill_7', 0.2)
        self.m_animator.m_node:setMix('idle', 'skill_8', 0.2)
        self.m_animator.m_node:setMix('idle', 'boss_die', 0.2)
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
    self:addState('dying', Monster_AncientRuinDragon.st_dying, 'boss_die', false, PRIORITY.DYING)
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
-- function st_dying
-------------------------------------
function Monster_AncientRuinDragon.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 사망 처리 시 StateDelegate Kill!
        owner:killStateDelegate()

        owner:dispatch('character_dying', {}, owner)

        local duration = owner.m_animator:getDuration()
        owner.m_animator:runAction(cc.FadeTo:create(duration, 0))

        -- 에니메이션 종료 시
        owner:addAniHandler(function()
            owner:changeState('dead')
        end)

        if (owner.m_hpNode) then
            owner.m_hpNode:setVisible(false)
        end

        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end
    end
end

-------------------------------------
-- function updateBonePos
-- @breif Spine Bone 정보로 갱신이 필요한 처리를 수행
-------------------------------------
function Monster_AncientRuinDragon:updateBonePos(dt)
    PARENT.updateBonePos(self, dt)

    if (self.m_animator and self.m_animator.m_node) then
        -- 충돌 영역 파츠들의 위치 갱신
        for i, child in ipairs(self.m_lChildChar) do
            local body = self.m_lBodyToUseBone[i]
            local pos_x = body['x'] + self.pos.x
            local pos_y = body['y'] + self.pos.y
        
            child:setPosition(pos_x, pos_y)
        end
    end
end

--[[
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
]]--

-------------------------------------
-- function release
-------------------------------------
function Monster_AncientRuinDragon:release()
    self:removeAllChildCharacter()

    PARENT.release(self)
end

-------------------------------------
-- function runAction_Floating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function Monster_AncientRuinDragon:runAction_Floating()
end

-------------------------------------
-- function setEnableBody
-- @param enabled
-- @param release_appended
-------------------------------------
function Monster_AncientRuinDragon:setEnableBody(enabled)
    self.enable_body = false
end

-------------------------------------
-- function doAppear
-------------------------------------
function Monster_AncientRuinDragon:doAppear(cb)
    self.m_cbAppearEnd = cb

    self:changeState('appear')
end