local PARENT = GameWorld

-------------------------------------
-- class GameWorldTrial
-------------------------------------
GameWorldTrial = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldTrial:init(world)
end


-------------------------------------
-- function createComponents
-------------------------------------
function GameWorldTrial:createComponents()
    PARENT.createComponents(self)

    self.m_gameState = GameState(self)
end
