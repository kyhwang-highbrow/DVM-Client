local PARENT = class(MonsterLua_Boss, ICharacterBinding:getCloneTable())

-------------------------------------
-- class Monster_AncientRuinDragon
-------------------------------------
Monster_AncientRuinDragon = class(PARENT, {
    m_cbAppearEnd   = 'function',       -- appear 상태가 끝났을때 호출될 콜백 함수

    m_bCreateParts  = 'boolean',
    m_bExistDron    = 'boolean',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_AncientRuinDragon:init(file_name, body, ...)
    self.m_bUseCastingEffect = false

    self.m_bCreateParts = false
    self.m_bExistDron = false
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
-- function update
-------------------------------------
function Monster_AncientRuinDragon:update(dt)
    self.m_bExistDron = false

    -- 드론이 존재하는지 여부 저장
    local list

    if (self.m_bLeftFormation) then 
        list = self.m_world:getDragonList()
    else
        list = self.m_world:getEnemyList()
    end

    for _, v in ipairs(list) do
        if (not v:isDead()) then
            local t_char = v:getCharTable()
            if (t_char and t_char['type'] == 'ancient_ruin_dragon_drone') then
                self.m_bExistDron = true
                break
            end
        end
    end

    return PARENT.update(self, dt)
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

-------------------------------------
-- function release
-------------------------------------
function Monster_AncientRuinDragon:release()
    self:removeAllChildCharacter()

    PARENT.release(self)
end

-------------------------------------
-- function checkAttributeCounter
-- @brief 속성 상성
-------------------------------------
function Monster_AncientRuinDragon:checkAttributeCounter(attacker_char)
    local t_attr_effect, attr_synastry = PARENT.checkAttributeCounter(self, attacker_char)

    -- 드론이 존재할 경우 특수 효과
    if (self.m_bExistDron) then
        -- 자신의 약점이 아닌 속성의 공격을 받았을 시 데미지 감소 처리
        if (attr_synastry ~= 1) then
            local value = g_constant:get('INGAME', 'ANCIENT_RUIN_BOSS_DRON_DAMAGE_REDUCE') or 0
            t_attr_effect['damage'] = t_attr_effect['damage'] - value
        end
    end

    return t_attr_effect, attr_synastry
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