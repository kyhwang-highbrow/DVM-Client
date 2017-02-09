local PARENT = WaveMgr

-------------------------------------
-- class WaveMgr_SecretRelation
-------------------------------------
WaveMgr_SecretRelation = class(PARENT, {
        m_enemyDid = 'number'   -- 지정된 적드래곤 아이디
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr_SecretRelation:init(world, stage_name, develop_mode)
    -- 해당 스테이지에서 가능한 적드래곤을 하나 지정
    -- TODO: 스테이지 정보로부터 결정되도록 차후 수정
    local l_did = TableSecretDungeon():getRandomDragonList()
    l_did = randomShuffle(l_did)

    self.m_enemyDid = l_did[1]

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
-- function newScenario_dynamicWave
-------------------------------------
function WaveMgr:newScenario_dynamicWave(t_data)
    if (not t_data['wave']) then return end

    -- 5웨이브부터 보스 등장
    local isExistBoss = false
    if (self:isFinalWave()) then
        isExistBoss = true
    end

    self.m_lDynamicWave = {}
    self.m_highestRarity = 0

    for i, v in pairs(t_data['wave']) do
        for _, data in pairs(v) do
            local dynamic_wave = DynamicWave(self, data, i)
            table.insert(self.m_lDynamicWave, dynamic_wave)

            -- 특정 웨이브에서는 최대 레벨을 가진 적(드래곤)을 찾음
            if (isExistBoss) then
                local level = dynamic_wave.m_enemyLevel
                
                if level > self.m_highestRarity then
                    self.m_highestRarity = level
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
    if isMonster(enemy_id) then
        enemy = self.m_world:makeMonsterNew(enemy_id, level)

    else
        local evolution = enemy_id % 10
        local enemy_id = math_floor(enemy_id / 10)
        local isBoss = (evolution == 3 and level == self.m_highestRarity)
        
        enemy = self.m_world:makeDragonNew({
            did = enemy_id,
            lv = level,
            evolution = evolution,
            skill_0 = self.m_currWave,
            skill_1 = self.m_currWave,
            skill_2 = self.m_currWave,
            skill_3 = self.m_currWave,
        }, true)

        if (isBoss) then
            enemy.m_animator:setScale(0.6)
            
            MonsterLua_Boss.makeHPGauge(enemy, {0, -80}, true)
        end
    end
	                        
    self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
    self.m_world.m_physWorld:addObject(PHYS.ENEMY, enemy)
    self.m_world:addEnemy(enemy)

	enemy:setAddPhysObject()

    self.m_world.m_rightFormationMgr:setChangePosCallback(enemy)

	-- 패시브 실행
	local l_passive = enemy.m_lSkillIndivisualInfo['passive']
    for i,skill_info in pairs(l_passive) do
        local skill_id = skill_info.m_skillID
        enemy:doSkill(skill_id, 0, 0)
    end

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