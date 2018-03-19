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
-- @brief Ư���� ���� ������ ����
-------------------------------------
function WaveMgr_ClanRaid:applyBossStatus(boss)
    -- ü�� ����
    do
        -- ���� �����κ��� ���� ü���� ������
        -- (!!���� ������ ���� ��� �׽�Ʈ ��忡���� �ӽ� ü���� ���)
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