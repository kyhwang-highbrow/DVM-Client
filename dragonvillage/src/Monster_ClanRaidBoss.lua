local PARENT = Monster

-------------------------------------
-- class Monster_ClanRaidBoss
-------------------------------------
Monster_ClanRaidBoss = class(PARENT, {
        m_hpCount = '',
        m_maxHpCount = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_ClanRaidBoss:init(file_name, body, ...)
    self.m_hpCount = 0
    self.m_maxHpCount = 0
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

        self.m_hpCount = game_state.m_bossHpCount
        self.m_maxHpCount = game_state.m_bossMaxHpCount
        self.m_hpCount = math_min(self.m_hpCount, self.m_maxHpCount)

        self.m_hp = self.m_world.m_gameState.m_bossHp
        self.m_maxHp = self.m_world.m_gameState.m_bossMaxHp
        self.m_hp = math_min(self.m_hp, self.m_maxHp)
        
        self.m_hpRatio = self.m_hpCount / self.m_maxHpCount + self.m_hp / self.m_maxHp

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

    PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)
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
-- function setHp
-------------------------------------
function Monster_ClanRaidBoss:setHp(hp, bFixed)
	-- 죽었을시 탈출
    if (not bFixed) then
	    if (self:isDead()) then return end
        if (self:isZeroHp()) then return end
    end

    while (hp <= 0) do
        if (self.m_hpCount > 0) then
            hp = hp + self.m_maxHp
            self.m_hpCount = self.m_hpCount - 1
        else
            hp = 0
            self.m_hpCount = 0
            break
        end
    end

    self.m_hp = math_min(hp, self.m_maxHp)

    if (self.m_isImmortal) then
        self.m_hp = math_max(self.m_hp, 1)
    else
        self.m_hp = math_max(self.m_hp, 0)
    end
        
    self.m_hpRatio = self.m_hp / self.m_maxHp

    -- 리스너에 전달
	local t_event = clone(EVENT_CHANGE_HP_CARRIER)
	t_event['owner'] = self
	t_event['hp'] = self.m_hp
	t_event['max_hp'] = self.m_maxHp
    t_event['hp_rate'] = self.m_hpRatio

    self:dispatch('character_set_hp', t_event, self)

    -- 체력바 가감 연출
    if self.m_hpGauge then
        self.m_hpGauge:setScaleX(self.m_hpRatio)
    end
	if self.m_hpGauge2 then
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, self.m_hpRatio, 1))
        self.m_hpGauge2:runAction(cc.EaseIn:create(action, 2))
    end

    self.m_world.m_gameState:setBossHp(self.m_hpCount, self.m_hp)
end

-------------------------------------
-- function syncHp
-------------------------------------
function Monster_ClanRaidBoss:syncHp(hp_count, hp)
    if (self:isDead()) then return end

    self.m_hpCount = math_min(hp_count, self.m_maxHpCount)
    self.m_hp = math_min(hp, self.m_maxHp)
    self.m_hpRatio = self.m_hpCount / self.m_maxHpCount

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
    end
end

-------------------------------------
-- function updateDebugingInfo
-- @brief 인게임 정보 출력용 업데이트
-------------------------------------
function Monster_ClanRaidBoss:updateDebugingInfo()
	-- 화면에 체력 표시
	if g_constant:get('DEBUG', 'DISPLAY_UNIT_HP') then 
		self.m_infoUI.m_label:setString(string.format('%d/%d\n%d/%d\n(%d%%)',self.m_hp, self.m_maxHp, self.m_hpCount, self.m_maxHpCount, self:getHpRate() * 100))
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
    else
        --[[
        -- 보스 쫄의 경우 기절, 수면에만 면역 처리
        if (t_status_effect['name'] == 'stun' or t_status_effect['name'] == 'sleep') then
            return true
        end
        ]]--
    end
    
    return false
end