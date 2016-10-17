-------------------------------------
-- class DataStamina
-------------------------------------
DataStamina = class({
        m_type = 'string',              -- 스테미너의 종류

        -- 특정 수치를 저장하는 변수들
        m_stamina = 'number',           -- 현재 스태미나
        m_maxStamina = 'number',        -- 최대 스태미나
        m_staminaChargeTime = 'number', -- 충전 쿨타임
        m_lastChargeTime = 'number',    -- 마지막 충전 시간

        -- 업데이트에서 사용되는 변수들
        m_timer = 'number',

        m_changeCBList = 'table',
        m_tData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function DataStamina:init(type, stamina, max_stamina, stamina_charge_time, last_charge_time, t_data)
    self.m_tData = t_data
    self.m_type = type

    self.m_stamina = stamina or 0
    self.m_maxStamina = max_stamina or 5
    self.m_staminaChargeTime = stamina_charge_time or 120 -- 120초(2분)
    self.m_lastChargeTime = last_charge_time or os.time()

    self.m_timer = (self.m_lastChargeTime + self.m_staminaChargeTime) - os.time()

    self.m_changeCBList = {}

    self:adjust()
end

-------------------------------------
-- function update
-------------------------------------
function DataStamina:update(dt)
    -- 스태미나가 가득 차있는 경우 skip
    if (self.m_stamina >= self.m_maxStamina) then
        return
    end

    -- 충전까지 남은 timer 시간 감소
    self.m_timer = self.m_timer - dt

    -- 충전이 될경우
    if (self.m_timer <= 0) then
        self.m_stamina = self.m_stamina + 1
        self.m_timer = self.m_timer + self.m_staminaChargeTime
        self.m_lastChargeTime = self.m_lastChargeTime + self.m_staminaChargeTime
        
        -- 데이터 변경 후 저장하도록
        self.m_tData[2] = self.m_lastChargeTime
        g_userData:setDirtyLocalSaveData()

        -- 1개 충전
        self:changeStamina(self.m_stamina - 1, self.m_stamina, 'charge')
    else
        local str = self:getRemainText()
        for i,v in ipairs(self.m_changeCBList) do
            v(str)
        end
    end
end

-------------------------------------
-- function adjust
-------------------------------------
function DataStamina:adjust()

    -- 이미 최대일 경우
    if (self.m_stamina > self.m_maxStamina) then
        self.m_lastChargeTime = os.time()
        self.m_timer = 0
    else
        local time = os.time() - self.m_lastChargeTime
        local charge_stamina = math_floor(time / self.m_staminaChargeTime)

        -- 충전될 스태미나가 있을 경우
        if charge_stamina > 0 then
            -- 최대치는 넘지 않도록 보정
            if (self.m_stamina + charge_stamina) > self.m_maxStamina then
                charge_stamina = (self.m_maxStamina - self.m_stamina)
            end

            self.m_stamina = self.m_stamina + charge_stamina

            -- 최종 충전 시간과 남은 시간 갱신
            self.m_lastChargeTime = self.m_lastChargeTime + (charge_stamina * self.m_staminaChargeTime)
            self.m_timer = (self.m_lastChargeTime + self.m_staminaChargeTime) - os.time()
        end
    end

    -- 데이터 변경 후 저장하도록
    self.m_tData[2] = self.m_lastChargeTime
    g_userData:setDirtyLocalSaveData()
end

-------------------------------------
-- function changeStamina
-------------------------------------
function DataStamina:changeStamina(before, after, where)
    local str = self:getRemainText()
    for i,v in ipairs(self.m_changeCBList) do
        v(str)
    end

    -- 데이터 변경 후 저장하도록
    self.m_tData[1] = after
    g_userData:setDirtyLocalSaveData()

    --self:print(where)
end

-------------------------------------
-- function print
-------------------------------------
function DataStamina:print(where)
    local str = '## [' .. self.m_type .. '] ' .. self.m_stamina .. '/' .. self.m_maxStamina

    if where then
        str = str .. ' [' .. where .. ']'
    end
    cclog(str)
end

-------------------------------------
-- function useStamina
-------------------------------------
function DataStamina:useStamina(cnt)
    if (self.m_stamina < cnt) then
        return false
    end

    local before = self.m_stamina
    local after = self.m_stamina - cnt

    if (before >= self.m_maxStamina) then
        self.m_lastChargeTime = os.time()
        self.m_timer = self.m_staminaChargeTime

        -- 데이터 변경 후 저장하도록
        self.m_tData[2] = self.m_lastChargeTime
        g_userData:setDirtyLocalSaveData()
    end

    self.m_stamina = self.m_stamina - cnt
    self:changeStamina(self.m_stamina + cnt, self.m_stamina, 'use')
    return true
end

-------------------------------------
-- function addStamina
-------------------------------------
function DataStamina:addStamina(cnt)
    local before = self.m_stamina
    local after = self.m_stamina + cnt
    self.m_stamina = self.m_stamina + cnt
    self:changeStamina(before, after, 'add')
end

-------------------------------------
-- function getRemainText
-------------------------------------
function DataStamina:getRemainText()
    if (self.m_stamina >= self.m_maxStamina) then
        return 'MAX'
    else
        local timer = math_ceil(self.m_timer)
        return datetime.makeTimeDesc(timer, true, false)
    end
end

-------------------------------------
-- function setMaxStamina
-------------------------------------
function DataStamina:setMaxStamina(max_stamina)
    
    -- 변경 전 max상태인지 저장
    local is_max = (self.m_maxStamina <= self.m_stamina)

    -- 변경
    self.m_maxStamina = max_stamina

    -- 변경 전 max상태였고, 현재 max상태가 아닌 경우 마지막 충전 시간 초기화
    if is_max and (self.m_stamina < self.m_maxStamina) then
        self.m_lastChargeTime = os.time()

        -- 데이터 변경 후 저장하도록
        self.m_tData[2] = self.m_lastChargeTime
        g_userData:setDirtyLocalSaveData()
    end
end


-------------------------------------
-- function addChangeCB
-------------------------------------
function DataStamina:addChangeCB(change_cb)
    table.insert(self.m_changeCBList, change_cb)
    
    local str = self:getRemainText()
    change_cb(str)
end
