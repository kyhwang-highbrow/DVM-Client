-------------------------------------
-- class EnemyMovement
-------------------------------------
EnemyMovement = class({
    m_key = 'string',
    m_tPattern = 'table',

    m_curIdx = 'number',
    m_remainTime = 'number',    -- 다음 패턴까지 남은시간

    m_lEnemyList = 'table',     -- 해당 패턴을 사용하는 적군 리스트
    m_mEnemyList = 'table',

    m_bSorted = 'table',        -- 소팅 여부
})

    -------------------------------------
    -- function init
    -------------------------------------
    function EnemyMovement:init(key, t_pattern)
        self.m_key = key
        self.m_tPattern = t_pattern

        self.m_curIdx = 1
        self.m_remainTime = 0
        
        self.m_lEnemyList = {}
        self.m_mEnemyList = {}

        self.m_bSorted = false
    end

    -------------------------------------
    -- function update
    -------------------------------------
    function EnemyMovement:update(dt)
        if (self.m_remainTime > 0) then
            self.m_remainTime = self.m_remainTime - dt
        end

        if (self.m_remainTime <= 0) then
            self:doPattern()
        end
    end

    -------------------------------------
    -- function addEnemy
    -------------------------------------
    function EnemyMovement:addEnemy(enemy)
        table.insert(self.m_lEnemyList, enemy)

        self.m_bSorted = false
    end

    -------------------------------------
    -- function sortEnemyList
    -- @brief 특정 기준값으로 소팅된 리스트를 순서대로 맵으로 저장
    -------------------------------------
    function EnemyMovement:sortEnemyList()
        self.m_mEnemyList = {}
        
        -- TODO: TableEnemyMove에 리스트별로 소팅 방식 설정이 필요
        for i, enemy in ipairs(self.m_lEnemyList) do
            enemy:setPosIdx(i)

            self.m_mEnemyList[i] = enemy
        end

        self.m_bSorted = true
    end

    -------------------------------------
    -- function doPattern
    -------------------------------------
    function EnemyMovement:doPattern(x, y, time)
        if (not self.m_bSorted) then
            self:sortEnemyList()
        end

        if (not self.m_tPattern[self.m_curIdx]) then
            self.m_curIdx = 1
        end

        -- 패턴 정보 예("wait:0", "move_1:2", "move_2:1")
        local data = seperate(self.m_tPattern[self.m_curIdx], ';')
        local type = data[1]
        local time = tonumber(data[2]) or 1
        
        for i, enemy in pairs(self.m_mEnemyList) do
            local key = TableEnemyMove():getMovePosKey(type, i)
            if (key) then
                local pos = getWorldEnemyPos(enemy, key)

                enemy:changeHomePosByTime(pos.x, pos.y, time)
            end
        end

        self.m_remainTime = time

        self.m_curIdx = self.m_curIdx + 1
    end
    

-------------------------------------
-- class EnemyMovementMgr
-------------------------------------
EnemyMovementMgr = class({
    m_world = 'GameWorld',

    m_mMovementList = 'table',
})

    -------------------------------------
    -- function init
    -------------------------------------
    function EnemyMovementMgr:init(world, t_movement)
        self.m_world = world

        self.m_mMovementList = {}

        for k, v in pairs(t_movement) do
            self:addMovement(k, v)
        end
    end

    -------------------------------------
    -- function update
    -------------------------------------
    function EnemyMovementMgr:update(dt)
        for k, v in pairs(self.m_mMovementList) do
            v:update(dt)
        end
    end

    -------------------------------------
    -- function addEnemy
    -------------------------------------
    function EnemyMovementMgr:addEnemy(key, enemy)
        if (not self.m_mMovementList[key]) then return end

        self.m_mMovementList[key]:addEnemy(enemy)
    end

    -------------------------------------
    -- function addMovement
    -------------------------------------
    function EnemyMovementMgr:addMovement(key, t_pattern)
        if (not self.m_mMovementList[key]) then
            self.m_mMovementList[key] = EnemyMovement(key, t_pattern)
        end
    end