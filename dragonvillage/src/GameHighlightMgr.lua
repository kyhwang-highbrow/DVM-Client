-------------------------------------
-- class GameHighlightMgr
-------------------------------------
GameHighlightMgr = class({
        m_world = 'GameWorld',

        m_skipLevel = 'number',

        m_darkLayer = '',
        m_darkLevel = 'number',     -- 어둡기 정도(0~255)
     })

-------------------------------------
-- function init
-------------------------------------
function GameHighlightMgr:init(world, darkLayer)
    self.m_world = world

    self.m_skipLevel = g_autoPlaySetting:get('skip_level') or 0

    self.m_darkLevel = 0

    self.m_darkLayer = darkLayer
    self.m_darkLayer:setOpacity(self.m_darkLevel)
    self.m_darkLayer:setVisible(true)
end

-------------------------------------
-- function update
-------------------------------------
function GameHighlightMgr:update(dt)
    local world = self.m_world

    local bPass = false
    local darkLevel = 0
    local mHighlightList = {}

    local function Add(list)
        for _, v in pairs(list) do
            if (not v.m_bDead) then
                mHighlightList[v] = true
            end
        end
    end

    -- 인디케이터 조작 중
    if (world.m_skillIndicatorMgr:isControlling()) then
        bPass = true
        darkLevel = math_max(darkLevel, 200)

        local dragon = world.m_skillIndicatorMgr.m_selectHero
        local enemys = dragon.m_skillIndicator:getTargetForHighlight()

        Add({dragon})
        Add(enemys)
    end

    -- 드래곤 드래그 스킬 연출 중
    if (not bPass and world.m_gameDragonSkill:isPlayingActiveSkill()) then
        bPass = true
        darkLevel = math_max(darkLevel, 255)

        -- 드래그 스킬일 경우, 맞는 대상을 제외한 적들에게 부분 암전을 건다
        local dragon = world.m_gameDragonSkill:getFocusingDragon()
        local dragons = dragon:getFellowList()
        local enemys = dragon.m_skillIndicator:getTargetForHighlight()
        
        Add(dragons)
        Add(enemys)
    end

    if (self.m_skipLevel < 2) then

        -- 드래곤 타임 스킬 연출 중
        if (not bPass and world.m_gameDragonSkill:isPlayingTimeSkill()) then
            darkLevel = math_max(darkLevel, 170)

            -- 쿨타임 스킬일 경우, 사용자가 아닌, 다른 드래곤들에겐 부분 암전을 건다
            local dragon = world.m_gameDragonSkill:getFocusingDragon()
            local enemys = dragon:getOpponentList()

            Add({dragon})
            Add(enemys)
        end

        -- 테이머 스킬 연출 중
        if (not bPass and world.m_tamer and world.m_tamer:isRequiredHighLight()) then
            darkLevel = math_max(darkLevel, 170)

            local dragons = self.m_world:getDragonList()
            local enemys = self.m_world:getEnemyList()

            Add(dragons)
            Add(enemys)
        end
    end

    self:setDarkLayer(darkLevel)
    self:setUnits(mHighlightList)
end

-------------------------------------
-- function setDarkLayer
-------------------------------------
function GameHighlightMgr:setDarkLayer(darkLevel)
    if (self.m_darkLevel == darkLevel) then return end
    
    self.m_darkLevel = darkLevel

    local dark_layer = self.m_darkLayer
    local duration = duration or 0

    -- 현재 카메라에 따른 위치 변경
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    dark_layer:setPosition(cameraHomePosX, cameraHomePosY)
    
    dark_layer:stopAllActions()
    dark_layer:runAction( cc.FadeTo:create(0.2, self.m_darkLevel) )
end

-------------------------------------
-- function setUnits
-------------------------------------
function GameHighlightMgr:setUnits(mHighlightList)
    local temp = 255 - self.m_darkLevel

    for _, list in pairs({self.m_world:getDragonList(), self.m_world:getEnemyList()}) do
        for i, v in ipairs(list) do
            if (mHighlightList[v]) then
                v:setHighlight(255)
            else
                v:setHighlight(temp)
            end
        end
    end
end

-------------------------------------
-- function setSkipLevel
-------------------------------------
function GameHighlightMgr:setSkipLevel(skip_level)
    self.m_skipLevel = skip_level
end