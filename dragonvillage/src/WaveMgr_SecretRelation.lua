local PARENT = WaveMgr

-------------------------------------
-- class WaveMgr_SecretRelation
-------------------------------------
WaveMgr_SecretRelation = class(PARENT, {
        m_enemyDid = 'number',   -- 지정된 적드래곤 아이디
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr_SecretRelation:init(world, stage_name, develop_mode)
    -- 해당 스테이지에서 가능한 적드래곤을 하나 지정
    local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()

    self.m_enemyDid = t_dungeon_info['dragon']

    -- RandomDragon으로 들어간 enemy_id값들을 지정된 드래곤 아이디로 치환
    if (self.m_scriptData and self.m_scriptData['wave']) then
        for wave, t_data in pairs(self.m_scriptData['wave']) do
            for _, v in pairs(t_data['wave']) do
                for i, data in ipairs(v) do
                    v[i] = string.gsub(data, 'RandomDragon', self.m_enemyDid)
                end
            end
        end
    end
end

-------------------------------------
-- function spawnEnemy_dynamic
-------------------------------------
function WaveMgr_SecretRelation:spawnEnemy_dynamic(enemy_id, level, appear_type, value1, value2, value3, movement)
    
    local enemy

    -- Enemy 생성
    if (isMonster(enemy_id)) then
        enemy = self.m_world:makeMonsterNew(enemy_id, level + self.m_addLevel)

    else
        local evolution = enemy_id % 10
        local enemy_id = math_floor(enemy_id / 10)
        local rarity = self:getRarity(enemy_id, level)
        local isBoss = (rarity == self.m_highestRarity and self:isFinalWave())

        enemy = self.m_world:makeDragonNew(StructDragonObject({
            did = enemy_id,
            lv = level + self.m_addLevel,
            grade = 1,
            evolution = evolution,
            skill_0 = self.m_currWave,
            skill_1 = self.m_currWave,
            skill_2 = self.m_currWave,
            skill_3 = isBoss and 1 or 0,
        }), true)

        if (isBoss) then
            self.m_boss = enemy

            enemy.m_animator:setScale(0.6)

            -- 스테이지별 boss_hp_ratio 적용.
            local boss_hp_ratio = TableStageData():getValue(self.m_world.m_stageID, 'boss_hp_ratio') or 1
            enemy.m_statusCalc:appendHpRatio(boss_hp_ratio)
            enemy:setStatusCalc(enemy.m_statusCalc)
            
            Monster.makeHPGauge(enemy, {0, -80}, true)
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

-------------------------------------
-- function getBossId
-------------------------------------
function WaveMgr_SecretRelation:getBossId()
    if (isMonster(self.m_bossId)) then
        return self.m_bossId
    end

    local boss_id = math_floor(self.m_bossId / 10)
    local evolution = self.m_bossId % 10
    return boss_id, evolution
end