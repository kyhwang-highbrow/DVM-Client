local PARENT = WaveMgr

-------------------------------------
-- class WaveMgr_AncientTower
-------------------------------------
WaveMgr_AncientTower = class(PARENT, {})

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
            skill_indivisual_info.m_timer = 300
        end
    end
end