-------------------------------------
-- class WaveMgr_Colosseum
-------------------------------------
WaveMgr_Colosseum = class(WaveMgr, {
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr_Colosseum:init(world, stage_name, stage_id, develop_mode)
    self.m_maxWave = 1
end

-------------------------------------
-- function isFinalWave
-------------------------------------
function WaveMgr_Colosseum:isFinalWave()
	return true
end