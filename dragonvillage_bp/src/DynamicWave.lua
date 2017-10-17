-- 한줄로 정의된 dynamic 웨이브 정보를 읽어들여 처리하는 클래스

-------------------------------------
-- class DynamicWave
-------------------------------------
DynamicWave = class({
        m_waveMgr = '',
        m_dynamicTimer = '',

        m_lScheduledSpawn = '',

        m_enemyID = '',
        m_appearType = '',
        m_movement = '',

        m_luaValue1 = '',
        m_luaValue2 = '',
        m_luaValue3 = '',
        
        m_enemyLevel = '',
        m_hasItem = 'boolean',

		m_regenInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function DynamicWave:init(wave_mgr, data, delay)
    self.m_waveMgr = wave_mgr
    self.m_dynamicTimer = -1
	self.m_regenInfo = nil
    self.m_hasItem = false

    
    local l_data = seperate(data, '@')
    local data_
    if l_data then
		-- data ex : "300202;1;test;T7;R5@item"
        data_ = l_data[1]

        -- 두 번째 값이 item으로 설정되었을 경우 아이템을 
        if (l_data[2] == 'item') then
            self.m_hasItem = true
        end
    else
        data_ = data
    end

    -- data_ ex : "300202;1;test;T7;R5"
    local l_str = seperate(data_, ';')

    local enemy_id = l_str[1]   -- 적군 ID
    local level = l_str[2]   -- 적군 레벨
    local appearType = l_str[3]   -- 등장 타입

    self.m_enemyID = tonumber(enemy_id)
    self.m_appearType = appearType
    self.m_enemyLevel = tonumber(level)

    -- 추가 값
    self.m_luaValue1 = l_str[4]
    self.m_luaValue2 = l_str[5]
    self.m_luaValue3 = l_str[6]
    self.m_movement = l_str[7]
    
    self.m_lScheduledSpawn = {}
    self.m_lScheduledSpawn[1] = tonumber(delay)
end

-------------------------------------
-- function setRegenInfo
-------------------------------------
function DynamicWave:setRegenInfo(table)
	self.m_regenInfo = table
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

        local monster = self.m_waveMgr:spawnEnemy_dynamic(self.m_enemyID, self.m_enemyLevel, self.m_appearType,
            self.m_luaValue1,
            self.m_luaValue2,
            self.m_luaValue3,
            self.m_movement
            )

		-- regen 정보가 있다면 (regen된 몬스터라면)
		if (self.m_regenInfo) then
			-- 리젠 정보를 저장
			monster:setRegenInfo(self.m_regenInfo)
			-- 강제로 패시브 동작
			monster:doSkill_passive()
            -- HP 즉시 표시
            if(monster.m_hpNode) then
                monster.m_hpNode:setVisible(true)
            end
		end

        -- 아이템을 드랍하는 몬스터라면
        if self.m_hasItem then
            monster.m_hasItem = true
        end
    end
end