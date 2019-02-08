local PARENT = Monster

-------------------------------------
-- class Monster_ClanRaidBoss
-------------------------------------
Monster_ClanRaidBoss = class(PARENT, {
    m_isProtectedForTimeOut = 'boolean',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_ClanRaidBoss:init(file_name, body, ...)
    self.m_bUseCastingEffect = false
    self.m_isProtectedForTimeOut = false
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_ClanRaidBoss:initState()
    PARENT.initState(self)

    if (self.m_charTable['type'] == 'clanraid_boss') then
        self:addState('dying', Monster_ClanRaidBoss.st_dying, 'dying', false, PRIORITY.DYING)
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function Monster_ClanRaidBoss.st_dying(owner, dt)
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
function Monster_ClanRaidBoss:updateBonePos(dt)
    PARENT.updateBonePos(self, dt)

    -- 충돌영역 위치로 게이지를 표시하기 위함
    if (self.m_hpNode and not self.m_bFixedPosHpNode) then
        local body_list = self:getBodyList()
        local body = body_list[1]

        local offset_x = self.m_unitInfoOffset[1] + body['x']
        local offset_y = self.m_unitInfoOffset[2] + body['y']

        if (self.m_hpNode) then
            self.m_hpNode:setPosition(offset_x, offset_y)
        end

        if (self.m_castingNode) then
            self.m_castingNode:setPosition(offset_x, offset_y)
        end

        self:setPositionStatusIcons(offset_x, offset_y)
    end

    -- 본 위치가 이동하면 physworld의 위치정보도 갱신시켜야함
    self.m_dirtyPos = true
end

-------------------------------------
-- function undergoAttack
-------------------------------------
function Monster_ClanRaidBoss:undergoAttack(attacker, defender, i_x, i_y, body_key, no_event, is_guard)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == i_x and self.pos['y'] == i_y) then
        i_x, i_y = self:getCenterPos()
    end

    PARENT.undergoAttack(self, attacker, defender, i_x, i_y, body_key, no_event, is_guard)
end

-------------------------------------
-- function setDamage
-------------------------------------
function Monster_ClanRaidBoss:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == i_x and self.pos['y'] == i_y) then
        i_x, i_y = self:getCenterPos()
    end

    -- 타임 아웃시 무적 처리
    if (self.m_isProtectedForTimeOut) then
        damage = 0
    end

    local prev_hp = self.m_hp
    local bApplyDamage = PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)

    -- 막타 시 데미지 저장(일시 정지 상태일 경우는 모두 합산)
    if (bApplyDamage and t_info and not t_info['is_definite_death']) then
        if (self:isZeroHp()) then
            if (prev_hp > 0 or self.m_temporaryPause) then
                self:dispatch('clan_boss_final_damage', { damage = damage, skill_id = t_info['skill_id'] })
            end
        end
    end
end

-------------------------------------
-- function onChangedAttackableGroup
-- @brief 공격할 수 있는 대상 그룹 정보가 변경되었을 경우
-------------------------------------
function Monster_ClanRaidBoss:onChangedAttackableGroup()
    -- 클랜 보스 본체의 경우 특정 스킬을 사용하지 못하도록 처리...
    if (self.m_charTable['type'] == 'clanraid_boss') then
        local l_remove_skill_id = { 250011, 250012, 250013, 250014, 250015 }

        for _, skill_id in ipairs(l_remove_skill_id) do
            --self:unsetSkillID(skill_id)

            local skill_indivisual_info = self:findSkillInfoByID(skill_id)
            if (skill_indivisual_info) then
                skill_indivisual_info:setEnabled(false)
            end
        end
    end
end

-------------------------------------
-- function makeMissFont
-------------------------------------
function Monster_ClanRaidBoss:makeMissFont(x, y)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeMissFont(self, x, y)
end

-------------------------------------
-- function makeShieldFont
-------------------------------------
function Monster_ClanRaidBoss:makeShieldFont(x, y)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeShieldFont(self, x, y)
end

-------------------------------------
-- function makeImmuneFont
-------------------------------------
function Monster_ClanRaidBoss:makeImmuneFont(x, y, scale)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeImmuneFont(self, x, y, scale)
end

-------------------------------------
-- function makeResistanceFont
-------------------------------------
function Monster_ClanRaidBoss:makeResistanceFont(x, y, scale)
    -- 충돌영역 위치로 변경
    if (self.pos['x'] == x and self.pos['y'] == y) then
        x, y = self:getCenterPos()
    end

    PARENT.makeResistanceFont(self, x, y, scale)
end

-------------------------------------
-- function syncHp
-------------------------------------
function Monster_ClanRaidBoss:syncHp(hp)
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
function Monster_ClanRaidBoss:makeHPGauge(hp_ui_offset, force)
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
function Monster_ClanRaidBoss:runAction_Floating()
    if (not self.m_animator) then return end
    
    local target_node = self.m_animator.m_node
    if (not target_node) then return end
    
    -- 행동 불가 상태일 경우
    if (self:hasStatusEffectToDisableBehavior()) then
        return
    end
    
    target_node:setPosition(0, 0)

	local floating_x_max = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MAX_X_SCOPE')
	local floating_y_max = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MAX_Y_SCOPE')
	local floating_x_min = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MIN_X_SCOPE')
	local floating_y_min = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MIN_Y_SCOPE')
	local floating_time = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_TIME') * 2

    local function getTime()
        return math_random(5, 15) * 0.1 * floating_time / 2
    end

    local sequence = cc.Sequence:create(
        cc.MoveTo:create(getTime(), cc.p(math_random(-floating_x_max, -floating_x_min), math_random(-floating_y_max, -floating_y_min))),
        cc.MoveTo:create(getTime(), cc.p(math_random(floating_x_min, floating_x_max), math_random(floating_y_min, floating_y_max)))
    )

    local action = cc.RepeatForever:create(sequence)
    cca.runAction(target_node, action, CHARACTER_ACTION_TAG__FLOATING)
end

-------------------------------------
-- function setPosition
-------------------------------------
function Monster_ClanRaidBoss:setPosition(x, y)
	PARENT.setPosition(self, x, y)

    -- 충돌영역 위치로 게이지를 표시하기 위함
    if (self.m_hpNode and not self.m_bFixedPosHpNode) then
        local body_list = self:getBodyList()
        local body = body_list[1]

        local offset_x = self.m_unitInfoOffset[1] + body['x']
        local offset_y = self.m_unitInfoOffset[2] + body['y']

        self.m_hpNode:setPosition(offset_x, offset_y)

        if (self.m_castingNode) then
            self.m_castingNode:setPosition(offset_x, offset_y)
        end
    end
end

-------------------------------------
-- function setTimeScale
-------------------------------------
function Monster_ClanRaidBoss:setTimeScale(time_scale)
    local time_scale = time_scale or self.m_aspdRatio

    -- 쫄들만 속도를 조정
    if (self.m_charTable['type'] ~= 'clanraid_boss') then
        time_scale = time_scale * 0.3
    end
    
    PARENT.setTimeScale(self, time_scale)
end

-------------------------------------
-- function updateDebugingInfo
-- @brief 인게임 정보 출력용 업데이트
-------------------------------------
function Monster_ClanRaidBoss:updateDebugingInfo()
	-- 화면에 체력 표시
	if g_constant:get('DEBUG', 'DISPLAY_UNIT_HP') then 
		--self.m_infoUI.m_label:setString(string.format('%d/%d\n%d/%d\n(%d%%)',self.m_hp, self.m_maxHp, self.m_hpCount, self.m_maxHpCount, self:getHpRate() * 100))
        self.m_infoUI.m_label:setString(self.m_hp .. '/' .. self.m_maxHp .. '\n' .. '(' .. self:getHpRate() * 100 .. '%)')
    else
        PARENT.updateDebugingInfo(self)
    end
end

-------------------------------------
-- function insertStatusEffect
-------------------------------------
function Monster_ClanRaidBoss:insertStatusEffect(status_effect)
    PARENT.insertStatusEffect(self, status_effect)

    local body_list = self:getBodyList()
    local body = body_list[1]

    status_effect:setOffsetPos(body)
end

-------------------------------------
-- function checkSpecialImmune
-- @brief 특정 상태효과 면역 체크
-------------------------------------
function Monster_ClanRaidBoss:checkSpecialImmune(t_status_effect)
    -- 타임 아웃시 상태효과 면역 처리
    if (self.m_isProtectedForTimeOut) then
        return true
    end

    if (self.m_charTable['type'] == 'clanraid_boss') then
        return PARENT.checkSpecialImmune(self, t_status_effect)
    end
    
    return false
end

-------------------------------------
-- function getInterceptableSkillID
-- @return	skill_id
-------------------------------------
function Monster_ClanRaidBoss:getInterceptableSkillID(tParam)
    local skill_id = nil
    
    -- time_out류 스킬 처리를 위한 하드코딩
    if (g_gameScene) then
        local ramain_time = g_gameScene:getRemainTimer()
        local delay_time = 3

        if (ramain_time < delay_time) then
            skill_id = self:getTimeOutSkillID()
        end
    end

    if (not skill_id) then
        skill_id = PARENT.getInterceptableSkillID(self, tParam)
    end

    return skill_id
end

-------------------------------------
-- function getPosForFormation
-------------------------------------
function Monster_ClanRaidBoss:getPosForFormation()
    return self:getCenterPos()
end

-------------------------------------
-- function getZOrder
-------------------------------------
function Monster_ClanRaidBoss:getZOrder()
    local zOrder = WORLD_Z_ORDER.BOSS
    local enemy_id = self:getCharId()
    local idx = getDigit(enemy_id, 1000, 1)
    local sub_idx = getDigit(enemy_id, 10, 1)

    if (idx == 0) then
        zOrder = WORLD_Z_ORDER.BOSS + 1    
    elseif (sub_idx == 7) then
        zOrder = WORLD_Z_ORDER.BOSS
    else
        zOrder = WORLD_Z_ORDER.BOSS + 1 + 7 - sub_idx
    end

    return zOrder
end

-------------------------------------
-- function onTimeOut
-- @brief 타임 아웃 되었을 때 호출
-------------------------------------
function Monster_ClanRaidBoss:onTimeOut()
    -- 모든 디버프 해제
    StatusEffectHelper:releaseStatusEffectDebuff(self)

    -- 무적 처리
    self.m_isProtectedForTimeOut = true
end