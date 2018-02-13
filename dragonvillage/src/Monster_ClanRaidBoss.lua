local PARENT = Monster

-------------------------------------
-- class Monster_ClanRaidBoss
-------------------------------------
Monster_ClanRaidBoss = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_ClanRaidBoss:init(file_name, body, ...)
    self.m_bUseCastingEffect = false
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

        if (owner.m_cbDead) then
            owner.m_cbDead(owner)
        end

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

    -- formationMgr에서의 위치 정보 갱신
    if (self.m_cbChangePos) then
        self.m_cbChangePos(self)
    end

    -- 본 위치가 이동하면 physworld의 위치정보도 갱신시켜야함
    self.m_dirtyPos = true
end

-------------------------------------
-- function setStatusCalc
-------------------------------------
function Monster_ClanRaidBoss:setStatusCalc(status_calc)
    self.m_statusCalc = status_calc

    if (not self.m_statusCalc) then return end

    -- hp 설정
    do
        -- 외부로부터 현재체력과 최대체력 정보를 얻어서 세팅
        local game_state = self.m_world.m_gameState

        self.m_maxHp = game_state.m_bossMaxHp:get()
        self.m_hp = game_state.m_bossHp:get()
        self.m_hp = math_min(self.m_hp, self.m_maxHp)
        
        self.m_hpRatio = self.m_hp / self.m_maxHp

        local indivisual_status = self.m_statusCalc.m_lStatusList['hp']
        indivisual_status:setBasicStat(self.m_maxHp, 0, 0, 0, 0)
    end
    
    -- 공속 설정
    self:calcAttackPeriod(true)
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
            self:unsetSkillID(skill_id)
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
-- function setSilence
-- @brief 특정 상태효과 면역 체크
-------------------------------------
function Monster_ClanRaidBoss:checkSpecialImmune(t_status_effect)
    if (self.m_charTable['type'] == 'clanraid_boss') then
        return PARENT.checkSpecialImmune(self, t_status_effect)
    end
    
    return false
end

-------------------------------------
-- function getPosForFormation
-------------------------------------
function Monster_ClanRaidBoss:getPosForFormation()
    return self:getCenterPos()
end