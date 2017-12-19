local PARENT = SkillIndicatorMgr

-------------------------------------
-- class SkillIndicatorMgr_ClanRaid
-------------------------------------
SkillIndicatorMgr_ClanRaid = class(PARENT, {})

--[[
-------------------------------------
-- function setPauseMode
-------------------------------------
function SkillIndicatorMgr_ClanRaid:setPauseMode(b, hero)
    self.m_world:setTemporaryPause(b, hero)
    self.m_bPauseMode = b
end
]]--