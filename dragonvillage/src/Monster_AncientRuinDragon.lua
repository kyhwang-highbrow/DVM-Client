local PARENT = Monster

-------------------------------------
-- class Monster_AncientRuinDragon
-------------------------------------
Monster_AncientRuinDragon = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_AncientRuinDragon:init(file_name, body, ...)
    self.m_bUseCastingEffect = false
end

-------------------------------------
-- function initFormation
-------------------------------------
function Monster_AncientRuinDragon:initFormation(body_size)
    PARENT.initFormation(self, body_size)
    
    -- 리소스가 좌우 반대로 제작되어서 여기서 반전처리...
    self.m_animator:setFlip(false)
end
--[[
-------------------------------------
-- function setStatusCalc
-------------------------------------
function Monster_AncientRuinDragon:setStatusCalc(status_calc)
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

    -- 
    damage = 0

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
--[[
-------------------------------------
-- function runAction_Floating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function Monster_AncientRuinDragon:runAction_Floating()
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
function Monster_AncientRuinDragon:setPosition(x, y)
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
function Monster_AncientRuinDragon:setTimeScale(time_scale)
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
function Monster_AncientRuinDragon:updateDebugingInfo()
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
function Monster_AncientRuinDragon:insertStatusEffect(status_effect)
    PARENT.insertStatusEffect(self, status_effect)

    local body_list = self:getBodyList()
    local body = body_list[1]

    status_effect:setOffsetPos(body)
end

-------------------------------------
-- function checkSpecialImmune
-- @brief 특정 상태효과 면역 체크
-------------------------------------
function Monster_AncientRuinDragon:checkSpecialImmune(t_status_effect)
    if (self.m_charTable['type'] == 'clanraid_boss') then
        return PARENT.checkSpecialImmune(self, t_status_effect)
    end
    
    return false
end

-------------------------------------
-- function getPosForFormation
-------------------------------------
function Monster_AncientRuinDragon:getPosForFormation()
    return self:getCenterPos()
end
]]--