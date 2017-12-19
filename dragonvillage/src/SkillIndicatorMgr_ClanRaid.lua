local PARENT = SkillIndicatorMgr

-------------------------------------
-- class SkillIndicatorMgr_ClanRaid
-------------------------------------
SkillIndicatorMgr_ClanRaid = class(PARENT, {})

-------------------------------------
-- function update
-------------------------------------
function SkillIndicatorMgr_ClanRaid:update(dt)
    --[[
    if (not self.m_world:isPossibleControl()) then
        self:clear()
        self:closeSkillToolTip()
        return 
    end
    ]]--

    if (self:isControlling()) then
        if (self.m_selectHero:isDead()) then
            self:clear()
            self:closeSkillToolTip()
            return                
        end
    end
end

-------------------------------------
-- function setPauseMode
-------------------------------------
function SkillIndicatorMgr_ClanRaid:setPauseMode(b, hero)
    --self.m_world:setTemporaryPause(b, hero)
    --self.m_bPauseMode = b
end
