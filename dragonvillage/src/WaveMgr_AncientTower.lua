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
    if (isMonster(enemy_id)) then
        enemy = self.m_world:makeMonsterNew(enemy_id, level)
    else
        local enemy_dragon_data = self:getEnemyDragonData(enemy_id, level, isBoss)
        enemy = self.m_world:makeDragonNew(enemy_dragon_data, true)
    end

    local z_order = enemy:getZOrder()
    
    if (isBoss) then
        enemy.m_isBoss = true

        if (not self.m_lBoss) then
            self.m_lBoss = {}
        end
        table.insert(self.m_lBoss, enemy)

        -- 보스 특수 스텟 적용
        self:applyBossStatus(enemy)
    end
    
    self.m_world.m_worldNode:addChild(enemy.m_rootNode, z_order)
    self.m_world.m_physWorld:addObject(phys_group, enemy)
    self.m_world:bindEnemy(enemy)
    self.m_world:addEnemy(enemy)
    
	-- 등장 움직임 설정
    if (EnemyAppear[appear_type]) then
        EnemyAppear[appear_type](enemy, value1, value2, value3)
    end

    -- 이동 패턴 설정
    do
        if (not movement) then
            movement = self.m_currWave
        end

        -- 로밍 임시 처리
        if (self.m_world.m_enemyMovementMgr) then
            self.m_world.m_enemyMovementMgr:addEnemy(movement, enemy)
        end
    end
    
	return enemy
end

-------------------------------------
-- function getEnemyDragonData
-- @brief 적군으로 등장하는 드래곤 정보를 리턴
-------------------------------------
function WaveMgr_AncientTower:getEnemyDragonData(enemy_id, level, is_boss)
    return StructDragonObject({
            did = enemy_id,
            lv = level,
            grade = 1,
            evolution = 3,
            skill_0 = 1,
            skill_1 = 1,
            skill_2 = 1,
            skill_3 = is_boss and 1 or 0,
        })
end

-------------------------------------
-- function applyBossStatus
-- @brief 특수한 보스 스텟을 적용
-------------------------------------
function WaveMgr_AncientTower:applyBossStatus(boss)
    PARENT.applyBossStatus(self, boss)

    -- 크기 조정
    boss.m_animator:setScale(0.45)

    -- 광폭화 스킬 적용
    do
        local skill_id = 200009
        local skill_type = TableDragonSkill():getSkillType(skill_id)

        boss:setSkillID(skill_type, skill_id, 1)

        -- 초기 발동 시간 조정
        do
            local skill_indivisual_info = boss:findSkillInfoByID(skill_id)
            skill_indivisual_info.m_curChanceValue = 300
        end
    end
end