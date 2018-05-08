-------------------------------------
-- class WaveMgr_Arena
-------------------------------------
WaveMgr_Arena = class(WaveMgr, {
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr_Arena:init(world, stage_name, stage_id, develop_mode)
    self.m_maxWave = 1
end

-------------------------------------
-- function isFinalWave
-------------------------------------
function WaveMgr_Arena:isFinalWave()
	return true
end