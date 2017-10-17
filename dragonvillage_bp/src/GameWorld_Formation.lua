-------------------------------------
-- function init_formation
-- @brief
-------------------------------------
function GameWorld:init_formation()
    -- 왼쪽 지형
    self.m_leftFormationMgr = FormationMgr(true)
    self.m_leftFormationMgr:setSplitPos(20, 122)

    self.m_gameCamera:addListener('camera_set_home', self.m_leftFormationMgr)

    -- 오른쪽 지형
    self.m_rightFormationMgr = FormationMgr(false)
    self.m_rightFormationMgr:setSplitPos(1280-20, 200)

    self.m_gameCamera:addListener('camera_set_home', self.m_rightFormationMgr)
end