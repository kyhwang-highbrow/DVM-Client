local PARENT = Monster

-------------------------------------
-- class Monster_ClanRaidBoss
-------------------------------------
Monster_ClanRaidBoss = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_ClanRaidBoss:init(file_name, body, ...)
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
        self.m_maxHp = self.m_world.m_gameState.m_bossMaxHp
        self.m_hp = self.m_world.m_gameState.m_bossHp
        self.m_hpRatio = self.m_hp / self.m_maxHp

        local indivisual_status = self.m_statusCalc.m_lStatusList['hp']
        indivisual_status:setBasicStat(self.m_maxHp, 0, 0, 0, 0)
    end
    
    -- 공속 설정
    self:calcAttackPeriod(true)
end

-------------------------------------
-- function setHp
-------------------------------------
function Monster_ClanRaidBoss:setHp(hp, bFixed)
	PARENT.setHp(self, hp, bFixed)

    self.m_world.m_gameState:setBossHp(self.m_hp)
end

-------------------------------------
-- function syncHp
-------------------------------------
function Monster_ClanRaidBoss:syncHp(hp)
    if (self:isDead()) then return end

	self.m_hp = math_min(hp, self.m_maxHp)  
    self.m_hpRatio = self.m_hp / self.m_maxHp

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

    -- 충돌지점 위치로 게이지를 표시하기 위함
    if (self.m_hpNode and not self.m_bFixedPosHpNode) then
        local body_list = self:getBodyList()
        local body = body_list[1]

        local offset_x = self.m_unitInfoOffset[1] + body['x']
        local offset_y = self.m_unitInfoOffset[2] + body['y']

        self.m_hpNode:setPosition(offset_x, offset_y)
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