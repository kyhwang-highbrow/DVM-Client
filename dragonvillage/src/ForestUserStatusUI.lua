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
    local vars = self.vars
    self.m_rootNode:setLocalZOrder(FOREST_ZORDER['STAT_UI'])
end

-------------------------------------
-- function onEvent
-------------------------------------
function ForestUserStatusUI:onEvent(event_name, struct_event)
    if (event_name == 'forest_character_move') then
        local Forest_char = struct_event:getObject()
        local x, y = struct_event:getPosition()
        self.m_rootNode:setPosition(x, y)
    end
end

-------------------------------------
-- function addTierIcon
-------------------------------------
function ForestUserStatusUI:addTierIcon(struct_user_info)
    local vars = self.vars
    local tier_icon = g_arenaNewData.m_playerUserInfo:makeTierIcon(g_arenaNewData:getMyLastTier())
    tier_icon:setScale(1.4)

    if (vars['tierNode']) then
        vars['tierNode']:removeAllChildren()

        if (tier_icon) then
            vars['tierNode']:addChild(tier_icon)
        end
    end
end