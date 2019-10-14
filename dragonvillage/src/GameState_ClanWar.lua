local PARENT = GameState_Arena

-------------------------------------
-- class GameState_ClanWar
-------------------------------------
GameState_ClanWar = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_ClanWar:init(world)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_ClanWar:makeResultUI(is_win)
    UI_GameResult_ClanWar()
end