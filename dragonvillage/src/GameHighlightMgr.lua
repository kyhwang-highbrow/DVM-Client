-------------------------------------
-- class GameHighlightMgr
-------------------------------------
GameHighlightMgr = class({
        m_world = 'GameWorld',

        m_level = 'number',     -- 어둡기 정도(0~255)

        m_darkLayer = '',
     })

-------------------------------------
-- function init
-------------------------------------
function GameHighlightMgr:init(world, darkLayer)
    self.m_world = world

    self.m_level = 0
   
    self.m_darkLayer = darkLayer
    self.m_darkLayer:setOpacity(self.m_level)
    self.m_darkLayer:setVisible(true)
end

-------------------------------------
-- function update
-------------------------------------
function GameHighlightMgr:update(dt)
    local world = self.m_world

    local level = 0

    -- 드래곤 드래그 스킬 연출 중
    if (world.m_gameDragonSkill:isPlayingActiveSkill()) then
        level = math_max(level, 255)
    end

    -- 드래곤 타임 스킬 연출 중
    if (world.m_gameDragonSkill:isPlayingTimeSkill()) then
        level = math_max(level, 170)
    end

    -- 인디케이터 조작 중
    if (world.m_skillIndicatorMgr:isControlling()) then
        level = math_max(level, 200)
    end

    -- 테이머 스킬 연출 중
    if (world.m_tamer and world.m_tamer:isRequiredHighLight()) then
        level = math_max(level, 170)
    end

    self:setLevel(level)
end

-------------------------------------
-- function setLevel
-------------------------------------
function GameHighlightMgr:setLevel(level)
    if (self.m_level == level) then return end
       
    self.m_level = level
    
    self:changeDarkLayerColor(self.m_level, 0.2)
end

-------------------------------------
-- function changeDarkLayerColor
-------------------------------------
function GameHighlightMgr:changeDarkLayerColor(opacity, duration)
    local dark_layer = self.m_darkLayer
    local duration = duration or 0

    dark_layer:stopAllActions()

    -- 현재 카메라에 따른 위치 변경
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    dark_layer:setPosition(cameraHomePosX, cameraHomePosY)
    
    dark_layer:runAction( cc.FadeTo:create(duration, opacity) )
end