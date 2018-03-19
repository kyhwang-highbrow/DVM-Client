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
-- function getRarity
-------------------------------------
function WaveMgr_SecretRelation:getRarity(enemy_id, enemy_lv)
    return 10 + enemy_lv
end

-------------------------------------
-- function getEnemyDragonData
-- @brief 적군으로 등장하는 드래곤 정보를 리턴
-------------------------------------
function WaveMgr_SecretRelation:getEnemyDragonData(enemy_id, level, is_boss)
    local evolution = enemy_id % 10
    
    return StructDragonObject({
            did = self.m_enemyDid,
            lv = level,
            grade = 1,
            evolution = evolution,
            skill_0 = self.m_currWave,
            skill_1 = self.m_currWave,
            skill_2 = self.m_currWave,
            skill_3 = is_boss and 1 or 0,
        })
end

-------------------------------------
-- function applyBossStatus
-- @brief 특수한 보스 스텟을 적용
-------------------------------------
function WaveMgr_SecretRelation:applyBossStatus(boss)
    PARENT.applyBossStatus(self, boss)

    -- 크기 조정
    boss.m_animator:setScale(0.6)

    -- 체력 게이지
    Monster.makeHPGauge(boss, {0, -80}, true)
end