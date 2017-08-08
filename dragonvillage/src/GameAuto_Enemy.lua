local PARENT = GameAuto

-------------------------------------
-- class GameAuto_Enemy
-------------------------------------
GameAuto_Enemy = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Enemy:init(world)
    self:onStart()
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameAuto_Enemy:onEvent(event_name, t_event, ...)
    if (event_name == 'enemy_active_skill') then
        self:setWorkTimer()
    end
end