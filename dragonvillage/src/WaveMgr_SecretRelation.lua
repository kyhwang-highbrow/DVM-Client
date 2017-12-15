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
function WaveMgr_SecretRelation:init(world, stage_name, stage_id, develop_mode)
    -- 해당 스테이지에서 가능한 적드래곤을 하나 지정
    local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()

    if t_dungeon_info then
        self.m_enemyDid = t_dungeon_info['dragon']
    else
        -- 벤치마크를 할 때에 사용하기 위함
        self.m_enemyDid = 120564
    end

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
-- function setDynamicWave
-- @brief script를 읽어 dynamic wave를 저장
-------------------------------------
function WaveMgr_SecretRelation:setDynamicWave(l_wave, l_data, t_param)
    PARENT.setDynamicWave(self, l_wave, l_data, t_param)

    -- 웨이브 정보에서 드래곤의 경우는 did + evolution형식으로 아이디를 사용함
    for i, v in ipairs(self.m_lBossInfo) do
        local id = v['cid']
        local cid
        local evolution

        if (isMonster(id)) then
            cid = id
        else
            cid = math_floor(id / 10)
            evolution = id % 10
        end

        self.m_lBossInfo[i]['cid'] = cid
        self.m_lBossInfo[i]['evolution'] = evolution
    end
end

-------------------------------------
-- function spawnEnemy_dynamic
-------------------------------------
function WaveMgr_SecretRelation:spawnEnemy_dynamic(enemy_id, level, appear_type, value1, value2, value3, movement, phys_group)
    local enemy
    local phys_group = phys_group or PHYS.ENEMY

    -- Enemy 생성
    if (isMonster(enemy_id)) then
        enemy = self.m_world:makeMonsterNew(enemy_id, level)

    else
        local evolution = enemy_id % 10
        local enemy_id = math_floor(enemy_id / 10)
        local rarity = self:getRarity(enemy_id, level)
        local isBoss = (rarity == self.m_highestRarity and self:isFinalWave())

        enemy = self.m_world:makeDragonNew(StructDragonObject({
            did = enemy_id,
            lv = level,
            grade = 1,
            evolution = evolution,
            skill_0 = self.m_currWave,
            skill_1 = self.m_currWave,
            skill_2 = self.m_currWave,
            skill_3 = isBoss and 1 or 0,
        }), true)

        if (isBoss) then
            enemy.m_isBoss = true

            if (not self.m_lBoss) then
                self.m_lBoss = {}
            end
            table.insert(self.m_lBoss, enemy)

            enemy.m_animator:setScale(0.6)

            -- 스테이지별 boss_hp_ratio 적용.
            local boss_hp_ratio = TableStageData():getValue(self.m_world.m_stageID, 'boss_hp_ratio') or 1
            enemy.m_statusCalc:appendHpRatio(boss_hp_ratio)
            enemy:setStatusCalc(enemy.m_statusCalc)
            
            Monster.makeHPGauge(enemy, {0, -80}, true)
        end
    end

    self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
    self.m_world.m_physWorld:addObject(phys_group, enemy)
    self.m_world:bindEnemy(enemy)
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