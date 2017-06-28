local PARENT = WaveMgr

-------------------------------------
-- class WaveMgr_AncientTower
-------------------------------------
WaveMgr_AncientTower = class(PARENT, {})

-------------------------------------
-- function spawnEnemy_dynamic
-------------------------------------
function WaveMgr_AncientTower:spawnEnemy_dynamic(enemy_id, level, appear_type, value1, value2, value3, movement)
    
    local enemy

    -- Enemy 생성
    if isMonster(enemy_id) then
        enemy = self.m_world:makeMonsterNew(enemy_id, level)

    else
        local isBoss = (level == self.m_highestRarity)

        enemy = self.m_world:makeDragonNew(StructDragonObject({
            did = enemy_id,
            lv = level,
            grade = 1,
            evolution = 3,
            skill_0 = 1,
            skill_1 = 1,
            skill_2 = 1,
            skill_3 = isBoss and 1 or 0,
        }), true)

        if (isBoss) then
            enemy.m_animator:setScale(0.6)
            
            -- 보스의 경우 체력 10배
            enemy.m_maxHp = enemy.m_maxHp * 10
            enemy.m_hp = enemy.m_hp * 10

            MonsterLua_Boss.makeHPGauge(enemy, {0, -80}, true)
        end
    end

    self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
    self.m_world.m_physWorld:addObject(PHYS.ENEMY, enemy)
    self.m_world:addEnemy(enemy)

	self.m_world.m_rightFormationMgr:setChangePosCallback(enemy)

	-- 등장 움직임 설정
    if (EnemyAppear[appear_type]) then
        EnemyAppear[appear_type](enemy, value1, value2, value3)
    end

    -- 이동 패턴 설정
    if (self.m_world.m_enemyMovementMgr) then
        if (not movement) then
            movement = self.m_currWave
        end

        self.m_world.m_enemyMovementMgr:addEnemy(movement, enemy)
    end

	return enemy
end