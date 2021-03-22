local PARENT = GameState

-------------------------------------
-- class GameState_DimensionGate
-------------------------------------
GameState_DimensionGate = class(PARENT, {

})


-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_DimensionGate:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
end

-------------------------------------
-- function makeResultUI
-------------------------------------
-- function GameState_DimensionGate:makeResultUI(isSuccess)
-- end