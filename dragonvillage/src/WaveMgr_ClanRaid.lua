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

    -- 1���̺�� ��ݽ�, 2���̺�� �Ϲݽ����� ó���Ͽ� 2���� ���̺� ������ ��� ������
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
    
    -- wave ������ �о� dynamic wave ����
	self:setDynamicWave(self.m_lDynamicWave, t_data['wave'], {phys_group_key = phys_group_key})
    
    -- regen�� ������ �ִٸ� �ش� ���� ���������� ��ȯ�ϵ��� ����.
	if (t_data['regen']) then
		self.m_isRegenWave = true
        self.m_mRegenGroup = {}

        for idx, v in ipairs(t_data['regen']) do
            -- ���̺� �ε��� ������ ������ ���� �׷� Ű���� ����
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

    -- ���������� boss_hp_ratio ����
    local boss_hp_ratio = TableStageData():getValue(self.m_world.m_stageID, 'boss_hp_ratio') or 1
    enemy.m_statusCalc:appendHpRatio(boss_hp_ratio)
    enemy:setStatusCalc(enemy.m_statusCalc)

    -- ���̾� ó��
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

    -- ���� ������ ����
    if (EnemyAppear[appear_type]) then
        EnemyAppear[appear_type](enemy, value1, value2, value3)
    end

    -- �̵� ���� ����
    do
        if (not movement) then
            movement = self.m_currWave
        end

        -- �ι� �ӽ� ó��
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