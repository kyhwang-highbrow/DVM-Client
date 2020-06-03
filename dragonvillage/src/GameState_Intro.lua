local PARENT = GameState

-------------------------------------
-- class GameState_Intro
-------------------------------------
GameState_Intro = class(PARENT, {
    })

-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_Intro:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
end


