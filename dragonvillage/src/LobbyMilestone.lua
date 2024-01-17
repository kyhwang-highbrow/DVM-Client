local PARENT = class(UI, IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyMilestone
-------------------------------------
LobbyMilestone = class(PARENT, {
    m_rootNode = 'cc.Node',
    m_lobbyMap = 'm_lobbyMap',
    m_arrowAnimator = '',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyMilestone:init(lobby_map)
    self:load('world_raid_ranking_board_milestone.ui')
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
    self.m_rootNode:addChild(self.root)
    self.m_lobbyMap = lobby_map
    self.m_arrowAnimator = self.vars['arrowVisual']
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyMilestone:onEvent(event_name, t_event, ...)
    if (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        self.m_rootNode:setPosition(x, y)
        self:refresh(cc.p(x, y))
        self:dispatch('lobby_user_status_ui_move', {}, self, x, y)
    end
end

-------------------------------------
--- @function refresh
-------------------------------------
function LobbyMilestone:refresh(tamer_world_pos)
    local vars = self.vars
    local lobby_map = self.m_lobbyMap
    if lobby_map == nil then
        return
    end

    local board_world_pos = lobby_map.m_groudNode:convertToWorldSpaceAR(cc.p(650, 200))
    --local tamer_world_pos = convertToWorldSpace(tamer_pos)    

    local diff_x = board_world_pos.x - tamer_world_pos.x
    local diff = diff_x < 0 and -1 or 1
    local x = 150 * diff

    if self.root:getPositionX() ~= x  then
        local str = diff_x < 0 and 'arrow_left' or 'arrow_right'
        self.root:setPosition(cc.p(x, 100))
        self.m_arrowAnimator:changeAni(str, true)
    end
end

-------------------------------------
-- function release
-------------------------------------
function LobbyMilestone:release()
    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
        self.m_rootNode = nil
    end

    PARENT.release_EventDispatcher(self)
    PARENT.release_EventListener(self)
end