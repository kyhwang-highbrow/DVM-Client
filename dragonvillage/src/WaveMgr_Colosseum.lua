-------------------------------------
-- class WaveMgr_Colosseum
-------------------------------------
WaveMgr_Colosseum = class(WaveMgr, {
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr_Colosseum:init(world, stage_name, develop_mode)
    self.m_maxWave = 1
end

-------------------------------------
-- function isFinalWave
-------------------------------------
function WaveMgr:isFinalWave()
	return true
end