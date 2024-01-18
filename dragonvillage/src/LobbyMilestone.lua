local PARENT = class(UI, IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyMilestone
-------------------------------------
LobbyMilestone = class(PARENT, {
    m_rootNode = 'cc.Node',
    m_lobbyMap = 'm_lobbyMap',
    m_milestoneList = 'List<StructMilestone>',
    m_milstone = 'StructMilestone',
    m_arrowAnimator = '',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyMilestone:init(lobby_map, struct_milestone_list)
    self:load('world_raid_ranking_board_milestone.ui')
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
    self.m_rootNode:addChild(self.root)
    self.m_lobbyMap = lobby_map
    self.m_milestoneList = struct_milestone_list
    self.m_milstone = self:getActiveMilstone()
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
--- @function getActiveMilstone
-------------------------------------
function LobbyMilestone:getActiveMilstone()
    for _, v in ipairs(self.m_milestoneList) do
        if v:isActivate() == true then
            return v
        end
    end

    return nil
end

-------------------------------------
--- @function refresh
-------------------------------------
function LobbyMilestone:refresh(tamer_world_pos)
    local vars = self.vars
    local lobby_map = self.m_lobbyMap
    self.m_rootNode:setVisible(false)

    if lobby_map == nil then
        return
    end

    if self.m_milstone == nil then
        return
    end

    if self.m_milstone:isActivate() == false then        
        return
    end

    if g_lobbyChangeMgr:getLobbyEntering() == true then
        return
    end

    self.m_rootNode:setVisible(true)
    local object_pos = self.m_milstone:getObjectPos()
    local lobby_direction = self.m_milstone:getObjectLobbyDirection()
    local board_world_pos = lobby_map.m_groudNode:convertToWorldSpaceAR(object_pos)    
    local diff_x = board_world_pos.x - tamer_world_pos.x
    local diff = diff_x < 0 and -1 or 1

    if lobby_direction ~= 0 then
        diff = lobby_direction
    end

    local x = 150 * diff
    if self.root:getPositionX() ~= x  then
        local str = diff < 0 and 'arrow_left' or 'arrow_right'
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