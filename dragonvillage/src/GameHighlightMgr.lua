-------------------------------------
-- class GameHighlightMgr
-------------------------------------
GameHighlightMgr = class({
        m_world = 'GameWorld',

        m_darkLayer = '',
        m_darkLevel = 'number',     -- 어둡기 정도(0~255)

        m_bForced = 'boolean',
        m_forcedHighlightList = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function GameHighlightMgr:init(world, darkLayer)
    self.m_world = world

    self.m_darkLevel = 0

    self.m_darkLayer = darkLayer
    self.m_darkLayer:setOpacity(self.m_darkLevel)
    self.m_darkLayer:setVisible(true)

    self.m_bForced = false
    self.m_forcedHighlightList = {}
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
            mHighlightList[v] = true
        end
    end

    -- 인디케이터 조작 중
    if (not bPass and world.m_skillIndicatorMgr:isControlling()) then
        bPass = true
        darkLevel = math_max(darkLevel, g_constant:get('INGAME', 'HIGHLIGHT_LEVEL_FOR_INDICATOR') or 200)

        -- 더블 팀 모드의 경우 암전을 약하게 처리
        if (isInstanceOf(world, GameWorldForDoubleTeam)) then
            darkLevel = darkLevel / 2
        end

        local dragon = world.m_skillIndicatorMgr.m_selectHero
        local enemys = dragon:getSkillIndicator():getIndicatorTargetForHighlight()

        Add({dragon})
        Add(enemys)
    end

    -- 드래곤 드래그 스킬 연출 중
    if (not bPass and world.m_gameDragonSkill:isPlayingActiveSkill()) then
        bPass = true
        darkLevel = math_max(darkLevel, g_constant:get('INGAME', 'HIGHLIGHT_LEVEL_FOR_DRAG_SKILL') or 255)

        -- 드래그 스킬일 경우, 맞는 대상을 제외한 적들에게 부분 암전을 건다
        local dragon = world.m_gameDragonSkill:getFocusingUnit()
        local dragons = dragon:getFellowList()
        local enemys = dragon:getSkillIndicator():getTargetForHighlight()
        
        Add(dragons)
        Add(enemys)
    end

    -- 강제 설정된 상태
    if (not bPass and self.m_bForced) then
        bPass = true
        darkLevel = math_max(darkLevel, 200)

        Add(self.m_forcedHighlightList)
    end

    -- 테이머 스킬 연출 중
    if (not bPass and world.m_gameDragonSkill:isPlayingTamerSkill()) then
        darkLevel = math_max(darkLevel, 170)

        local dragons = self.m_world:getDragonList()
        local enemys = self.m_world:getEnemyList()

        Add(dragons)
        Add(enemys)
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
-- function setToForced
-- @breif 하이라이트를 강제로 설정
-------------------------------------
function GameHighlightMgr:setToForced(b)
    self.m_bForced = b
    self.m_forcedHighlightList = {}
end

-------------------------------------
-- function addForcedHighLightList
-------------------------------------
function GameHighlightMgr:addForcedHighLightList(entity)
    table.insert(self.m_forcedHighlightList, entity)
end