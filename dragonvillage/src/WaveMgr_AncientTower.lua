local PARENT = WaveMgr

-------------------------------------
-- class WaveMgr_AncientTower
-------------------------------------
WaveMgr_AncientTower = class(PARENT, {})

-------------------------------------
-- function spawnEnemy_dynamic
-------------------------------------
function WaveMgr_AncientTower:spawnEnemy_dynamic(enemy_id, level, appear_type, value1, value2, value3, movement, phys_group)
    local rarity = self:getRarity(enemy_id, level)
    local isBoss = (rarity == self.m_highestRarity and self:isFinalWave())
    local enemy
    local phys_group = phys_group or PHYS.ENEMY

    -- Enemy 생성
    if isMonster(enemy_id) then
        enemy = self.m_world:makeMonsterNew(enemy_id, level)

    else
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

        enemy.m_animator:setScale(0.45)

        if (isBoss) then
            enemy.m_isBoss = true

            if (not self.m_lBoss) then
                self.m_lBoss = {}
            end
            table.insert(self.m_lBoss, enemy)

            -- 스테이지별 boss_hp_ratio 적용.
            local boss_hp_ratio = TableStageData():getValue(self.m_world.m_stageID, 'boss_hp_ratio') or 1
            enemy.m_statusCalc:appendHpRatio(boss_hp_ratio)
            enemy:setStatusCalc(enemy.m_statusCalc)

            -- 광폭화 스킬 적용
            do
                local skill_id = 200009
                local skill_type = TableDragonSkill():getSkillType(skill_id)

                enemy:setSkillID(skill_type, skill_id, 1)

                -- 초기 발동 시간 조정
                do
                    local skill_indivisual_info = enemy:findSkillInfoByID(skill_id)
                    skill_indivisual_info.m_timer = 300
                end
            end
        end
    end

    self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
    self.m_world.m_physWorld:addObject(phys_group, enemy)
    self.m_world:bindEnemy(enemy)
    self.m_world:addEnemy(enemy)
    
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