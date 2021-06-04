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

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
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
-- function update
-------------------------------------
function ForestUserStatusUI:update(dt)
    local uid = g_userData:get('uid')
    if (not uid) then return end

    local tier = g_arenaNewData:getUserLastTier(uid)
    if (not tier) then return end

    self:addTierIcon(tier)
end
