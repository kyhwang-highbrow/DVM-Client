local PARENT = GameState

-------------------------------------
-- class GameState_AncientRuin
-------------------------------------
GameState_AncientRuin = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function GameState_AncientRuin:init(world)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_AncientRuin:makeResultUI(is_success)
    UINavigator:goTo('ancient_ruin')
end