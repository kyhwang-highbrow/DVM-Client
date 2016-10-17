-- 한줄로 정의된 dynamic 웨이브 정보를 읽어들여 처리하는 클래스

-------------------------------------
-- class DynamicWave
-------------------------------------
DynamicWave = class({
        m_waveMgr = '',
        m_dynamicTimer = '',

        m_lScheduledSpawn = '',

        m_enemyID = '',
        m_movement = '',

        m_luaValue1 = '',
        m_luaValue2 = '',
        m_luaValue3 = '',
        m_luaValue4 = '',
        m_luaValue5 = '',

        m_enemyLevel = '',
    })

-------------------------------------
-- function init
-------------------------------------
function DynamicWave:init(wave_mgr, data, delay)
    self.m_waveMgr = wave_mgr
    self.m_dynamicTimer = -1

    -- data ex : "300202;1;test;T7;R5"
    local l_str = seperate(data, ';')

    local enemy_id = l_str[1]   -- 적군 ID
    local level = l_str[2]   -- 적군 레벨
    local movement = l_str[3]   -- 이동 타입

    self.m_enemyID = tonumber(enemy_id)
    self.m_movement = movement
    self.m_enemyLevel = level

    -- 추가 값
    self.m_luaValue1 = l_str[4]
    self.m_luaValue2 = l_str[5]
    self.m_luaValue3 = l_str[6]
    self.m_luaValue4 = l_str[7]
    self.m_luaValue5 = l_str[8]

    self.m_lScheduledSpawn = {}
    self.m_lScheduledSpawn[1] = tonumber(delay)

    --[[
    -- data ex : "300202;0;1;test;T7;R5"
    local l_str = seperate(data, ';')

    local enemy_id = l_str[1]   -- 적군 ID
    local interval = l_str[2]   -- 적군이 등장하는 간격
    local count = l_str[3]      -- 적군의 개체수
    local movement = l_str[4]   -- 이동 타입

    self.m_enemyID = tonumber(enemy_id)
    self.m_movement = movement

    -- 추가 값
    self.m_luaValue1 = l_str[5]
    self.m_luaValue2 = l_str[6]
    self.m_luaValue3 = l_str[7]
    self.m_luaValue4 = l_str[8]
    self.m_luaValue5 = l_str[9]

    self.m_lScheduledSpawn = {}
    for i=1, count do
        local time = delay + ((i-1) * interval)
        table.insert(self.m_lScheduledSpawn, time)
    end
    --]]
end

-------------------------------------
-- function update
-------------------------------------
function DynamicWave:update(dt)
    -- 예약된 소환이 없을 경우 종료
    if (#self.m_lScheduledSpawn <= 0) then
        return true
    end

    -- 타이머 업데이트
    if (self.m_dynamicTimer == -1) then
        self.m_dynamicTimer = 0
    else
        self.m_dynamicTimer = self.m_dynamicTimer + dt
    end

    -- 동적 Enemy 소환
    if (self.m_lScheduledSpawn[1] <= self.m_dynamicTimer) then
        table.remove(self.m_lScheduledSpawn, 1)

        self.m_waveMgr:spawnEnemy_dynamic(self.m_enemyID, self.m_enemyLevel, self.m_movement,
            self.m_luaValue1,
            self.m_luaValue2,
            self.m_luaValue3,
            self.m_luaValue4,
            self.m_luaValue5)
    end

end