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