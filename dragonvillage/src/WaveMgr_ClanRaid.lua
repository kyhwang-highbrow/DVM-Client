-------------------------------------
-- class WaveMgr_ClanRaid
-------------------------------------
WaveMgr_ClanRaid = class(WaveMgr, {
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr_ClanRaid:init(world, stage_name, stage_id, develop_mode)
    self.m_maxWave = 1
end

-------------------------------------
-- function newScenario
-------------------------------------
function WaveMgr_ClanRaid:newScenario()
    self.m_currWave = 1
    self.m_waveTimer = -1

    self.m_lDynamicWave = {}
    self.m_highestRarity = -1
    self.m_bDeadHighestRarity = false
    self.m_lBossInfo = {}
    self.m_lBoss = nil

    -- 1웨이브는 상반신, 2웨이브는 하반신으로 처리하여 2개의 웨이브 정보를 모두 가져옴
	for idx = 1, 2 do
        local t_data = self.m_scriptData['wave'][idx]
        if (t_data) then
	        self:newScenario_dynamicWave(t_data, idx)
        end
    end

    self:dispatch('change_wave', {}, self.m_currWave)
end

-------------------------------------
-- function newScenario_dynamicWave
-------------------------------------
function WaveMgr_ClanRaid:newScenario_dynamicWave(t_data, wave_idx)
    if (not t_data['wave']) then return end

    local phys_group_key

    if (wave_idx == 1) then
        phys_group_key = PHYS.ENEMY_TOP
    else
        phys_group_key = PHYS.ENEMY_BOTTOM
    end
    
    -- wave 정보를 읽어 dynamic wave 세팅
	self:setDynamicWave(self.m_lDynamicWave, t_data['wave'], {phys_group_key = phys_group_key})
    
    -- regen에 정보가 있다면 해당 몹을 지속적으로 소환하도록 세팅.
	if (t_data['regen']) then
		self.m_isRegenWave = true
        self.m_mRegenGroup = {}

        for idx, v in ipairs(t_data['regen']) do
            -- 웨이브 인덱스 정보를 포함한 리젠 그룹 키값을 생성
            local regen_group_key = idx + (wave_idx * 10)

            self.m_mRegenGroup[regen_group_key] = StructWaveRegenGroup(regen_group_key, v, g_constant:get('INGAME', 'REGEN_APPEAR'), phys_group_key)
        end
	end
end

-------------------------------------
-- function spawnEnemy_dynamic
-------------------------------------
function WaveMgr_ClanRaid:spawnEnemy_dynamic(enemy_id, level, appear_type, value1, value2, value3, movement, phys_group)
    local rarity = self:getRarity(enemy_id, level)
    local isBoss = (rarity == self.m_highestRarity and self:isFinalWave())
    local enemy = self.m_world:makeMonsterNew(enemy_id, level)
    local phys_group = phys_group or PHYS.ENEMY_TOP
    
    enemy.m_isBoss = true

    if (not self.m_lBoss) then
        self.m_lBoss = {}
    end
    table.insert(self.m_lBoss, enemy)

    -- 스테이지별 boss_hp_ratio 적용
    local boss_hp_ratio = TableStageData():getValue(self.m_world.m_stageID, 'boss_hp_ratio') or 1
    enemy.m_statusCalc:appendHpRatio(boss_hp_ratio)
    enemy:setStatusCalc(enemy.m_statusCalc)

    -- 레이어 처리
    if (phys_group == PHYS.ENEMY_TOP) then
        self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.BOSS)
    elseif (enemy_id == 151071) then
        self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.BOSS - 1)
    else
        self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
    end
    
    if (phys_group == self.m_world:getOpponentPCGroup()) then
        self.m_world.m_rightFormationMgr:setChangePosCallback(enemy)
    else
        self.m_world.m_subRightFormationMgr:setChangePosCallback(enemy)
    end
    
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
        if (movement == 'roam') then
            enemy.m_bRoam = true
        elseif (self.m_world.m_enemyMovementMgr) then
            self.m_world.m_enemyMovementMgr:addEnemy(movement, enemy)
        end
    end
    
	return enemy
end

-------------------------------------
-- function isFirstWave
-------------------------------------
function WaveMgr_ClanRaid:isFirstWave()
	return true
end

-------------------------------------
-- function isFinalWave
-------------------------------------
function WaveMgr_ClanRaid:isFinalWave()
	return true
end