-------------------------------------
-- class EnemyMovement
-------------------------------------
EnemyMovement = class(IEventListener:getCloneClass(), {
    m_key = 'string',
    m_tPattern = 'table',

    m_curIdx = 'number',
    m_curType = 'string',
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
        self.m_curType = nil
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
            self:applyNextPattern()
        end
    end

    -------------------------------------
    -- function addEnemy
    -------------------------------------
    function EnemyMovement:addEnemy(enemy)
        enemy.m_movement = self

        table.insert(self.m_lEnemyList, enemy)

        -- 콜백 등록
        enemy:addListener('character_comeback', self)
        enemy:addListener('character_dead', self)
        
        self.m_bSorted = false
    end

    -------------------------------------
    -- function removeEnemy
    -------------------------------------
    function EnemyMovement:removeEnemy(enemy)
        enemy.m_movement = nil

        local idx = table.find(self.m_lEnemyList, enemy)
        table.remove(self.m_lEnemyList, idx)
        
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
    -- function reset
    -------------------------------------
    function EnemyMovement:reset()
        self.m_curIdx = 1
        self.m_remainTime = 0

        self.m_bSorted = false
    end

    -------------------------------------
    -- function doMove
    -------------------------------------
    function EnemyMovement:doMove(enemy)
        if (not enemy:isPossibleMove()) then return end

        local posIdx = enemy:getPosIdx()
        local key = TableEnemyMove():getMovePosKey(self.m_curType, posIdx)
        if (key) then
            local pos = getWorldEnemyPos(enemy, key)

            enemy:changeHomePosByTime(pos.x, pos.y, self.m_remainTime, -1)
        end
    end

    -------------------------------------
    -- function applyNextPattern
    -------------------------------------
    function EnemyMovement:applyNextPattern()
        if (not self.m_bSorted) then
            self:sortEnemyList()
        end

        if (not self.m_tPattern[self.m_curIdx]) then
            self.m_curIdx = 1
        end

        -- 패턴 정보 예("wait:0", "move_1:2", "move_2:1")
        local pattern = self.m_tPattern[self.m_curIdx]
        local l_data = plSplit(pattern, ';')

        -- 현재 패턴 정보를 세팅
        self.m_curType = l_data[1]
        self.m_remainTime = tonumber(l_data[2] or 1)
        
        -- 리스트내의 모든 적군을 이동시킴
        for i, enemy in pairs(self.m_mEnemyList) do
            self:doMove(enemy)
        end

        self.m_curIdx = self.m_curIdx + 1
    end

    -------------------------------------
    -- function onEvent
    -------------------------------------
    function EnemyMovement:onEvent(event_name, t_event, ...)
        local arg = {...}
        local enemy = arg[1]

        if (event_name == 'character_comeback') then
            self:doMove(enemy)
            
        elseif (event_name == 'character_dead') then
            self:removeEnemy(enemy)

        end
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

        for k, list in pairs(t_movement) do
            local rand = math_random(#list)
            self:addMovement(k, list[rand])
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

    -------------------------------------
    -- function reset
    -------------------------------------
    function EnemyMovementMgr:reset()
        for k, v in pairs(self.m_mMovementList) do
            v:reset()
        end
    end