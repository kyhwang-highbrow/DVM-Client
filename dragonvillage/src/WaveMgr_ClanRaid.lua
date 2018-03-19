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

-------------------------------------
-- function applyBossStatus
-- @brief 특수한 보스 스텟을 적용
-------------------------------------
function WaveMgr_ClanRaid:applyBossStatus(boss)
    -- 체력 설정
    do
        -- 던전 정보로부터 보스 체력을 가져옴
        -- (!!던전 정보가 없을 경우 테스트 모드에서만 임시 체력을 사용)
        local max_hp
        local hp

        local struct_raid = g_clanRaidData:getClanRaidStruct()
        if (struct_raid) then
            max_hp = struct_raid:getMaxHp()
            hp = struct_raid:getHp()
        else
            if (IS_TEST_MODE()) then
                max_hp = 10000000000
                hp = 500000
            else
                error('clan raid data is not exist!')
            end
        end

        hp = math_min(hp, max_hp)

        boss.m_maxHp = max_hp
        boss.m_hp = hp
        boss.m_hpRatio = hp / max_hp

        local indivisual_status = boss.m_statusCalc.m_lStatusList['hp']
        indivisual_status:setBasicStat(boss.m_maxHp, 0, 0, 0, 0)
    end
end