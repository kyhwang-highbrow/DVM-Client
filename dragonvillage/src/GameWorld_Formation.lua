-------------------------------------
-- function init_formation
-- @brief
-------------------------------------
function GameWorld:init_formation()
    -- 왼쪽 지형
    self.m_leftFormationMgr = FormationMgr(true)
    self.m_leftFormationMgr:setSplitPos(20, 200)

    -- 오른쪽 지형
    self.m_rightFormationMgr = FormationMgr(false)
    self.m_rightFormationMgr:setSplitPos(1280-20, 200)
end