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
    if (self.m_world.m_bDevelopMode) then
        UI_GameResult_ClanWar(is_win)
        return
    end


    local finish_cb = function(ret)
		UI_GameResult_ClanWar(is_win)
	end

	-- 1. 네트워크 통신
    local func_network_game_finish = function()
        g_clanWarData:request_clanWarFinish(is_win, self.m_fightTimer, finish_cb)
    end
	func_network_game_finish()
end