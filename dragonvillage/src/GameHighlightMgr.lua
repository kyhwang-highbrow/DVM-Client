-------------------------------------
-- class GameHighlightMgr
-------------------------------------
GameHighlightMgr = class({
        m_world = 'GameWorld',

        m_bActive = 'boolean',

        m_darkLayer = '',
     })

-------------------------------------
-- function init
-------------------------------------
function GameHighlightMgr:init(world, darkLayer)
    self.m_world = world

    self.m_bActive = false
   
    self.m_darkLayer = darkLayer
    self.m_darkLayer:setOpacity(0)
    self.m_darkLayer:setVisible(true)
end

-------------------------------------
-- function update
-------------------------------------
function GameHighlightMgr:update(dt)
    local world = self.m_world

    local b = false

    -- 드래곤 스킬 연출 중
    if (world.m_gameDragonSkill:isPlaying()) then
        b = true

    -- 인디케이터 조작 중
    elseif (world.m_skillIndicatorMgr:isControlling()) then
        b = true

    -- 테이머 스킬 연출 중
    elseif (world.m_tamer:isRequiredHighLight()) then
        b = true

    end

    self:setActive(b)
end

-------------------------------------
-- function setActive
-------------------------------------
function GameHighlightMgr:setActive(bActive)
    if (self.m_bActive == bActive) then return end
       
    self.m_bActive = bActive
    
    if (self.m_bActive) then
        self:changeDarkLayerColor(255, 0.2)
    else
        self:changeDarkLayerColor(0, 0.2)
    end
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