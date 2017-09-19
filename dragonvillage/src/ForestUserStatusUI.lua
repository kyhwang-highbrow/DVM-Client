local PARENT = LobbyUserStatusUI

-------------------------------------
-- class ForestUserStatusUI
-------------------------------------
ForestUserStatusUI = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function ForestUserStatusUI:init(t_user_info)
    self.m_rootNode:setLocalZOrder(FOREST_ZORDER['STAT_UI'])
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyUserStatusUI:onEvent(event_name, struct_event)
    if (event_name == 'forest_character_move') then
        local Forest_char = struct_event:getObject()
        local x, y = struct_event:getPosition()
        self.m_rootNode:setPosition(x, y)
    end
end