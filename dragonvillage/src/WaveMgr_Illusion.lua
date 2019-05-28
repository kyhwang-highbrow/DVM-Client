-------------------------------------
-- class WaveMgr_ClanRaid
-------------------------------------
WaveMgr_Illusion = class(WaveMgr, {
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr_Illusion:init(world, stage_name, stage_id, develop_mode)
    self.m_maxWave = 1
end

-------------------------------------
-- function isFirstWave
-------------------------------------
function WaveMgr_Illusion:isFirstWave()
	return true
end

-------------------------------------
-- function isFinalWave
-------------------------------------
function WaveMgr_Illusion:isFinalWave()
	return true
end

-------------------------------------
-- function applyBossStatus
-- @brief 특수한 보스 스텟을 적용
-------------------------------------
function WaveMgr_Illusion:applyBossStatus(boss)
    -- 체력 설정
    do
        local max_hp
        local hp

        max_hp = g_illusionDungeonData:getCurBossMaxHp()
        hp = g_illusionDungeonData:getCurBossMaxHp()
        hp = math_min(hp, max_hp)

        boss.m_maxHp = max_hp
        boss.m_hp = hp
        boss.m_hpRatio = hp / max_hp

        local indivisual_status = boss.m_statusCalc.m_lStatusList['hp']
        indivisual_status:setBasicStat(boss.m_maxHp, 0, 0, 0, 0)
    end
end