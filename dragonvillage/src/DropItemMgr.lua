local PARENT = IEventListener:getCloneClass()

-------------------------------------
-- class DropItemMgr
-------------------------------------
DropItemMgr = class(PARENT, {
	m_world = 'GameWorld',

    m_touchNode = 'cc.Node',
    m_selectItem = 'DropItem',
    m_lItemlist = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function DropItemMgr:init(world)
	self.m_world = world

    self.m_touchNode = cc.Node:create()
    world.m_worldLayer:addChild(self.m_touchNode)
    self:makeTouchLayer(self.m_touchNode)

    self.m_selectItem = nil
    self.m_lItemlist = {}
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function DropItemMgr:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
                    
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function update
-------------------------------------
function DropItemMgr:update(dt)
    local t_remove = {}
    for i, v in ipairs(self.m_lItemlist) do

        -- 일시 정지 상태가 아닌 경우에만 업데이트
        if (not v.m_temporaryPause) then

            -- update 리턴값이 true이면 객체 삭제
            if (v:update(dt) == true) then
                table.insert(t_remove, 1, i)
                v:release()
            end
        end
    end

    for i,v in ipairs(t_remove) do
        table.remove(self.m_lItemlist, v)
    end
end

-------------------------------------
-- function doDrop
-------------------------------------
function DropItemMgr:dropItem(x, y)
    local item = DropItem(nil, {0, 0, 15})
    item:init_item('item_marbl')
    item:initState()
    item:setPosition(x, y)

    self:addItem(item)
end

-------------------------------------
-- function addItem
-------------------------------------
function DropItemMgr:addItem(item)
    table.insert(self.m_lItemlist, item)
    item:initWorld(self.m_world)

    self.m_world:addChild2(item.m_rootNode, DEPTH_ITEM_GOLD)
end

-------------------------------------
-- function cleanupItem
-------------------------------------
function DropItemMgr:cleanupItem()
    for i, v in ipairs(self.m_lItemlist) do
        v:changeState('dying')
    end

    self.m_selectItem = nil
end

-------------------------------------
-- function getItemFromPos
-------------------------------------
function DropItemMgr:getItemFromPos(pos_x, pos_y)
    for i, v in ipairs(self.m_lItemlist) do
        local x, y = v:getCenterPos()
		local distance = math_distance(x, y, pos_x, pos_y)

        if (distance <= 100) then
            return v
        end
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function DropItemMgr:onEvent(event_name, t_event, ...)
    if (event_name == 'character_dead') then
        local arg = {...}
        local enemy = arg[1]

        -- TODO: 적에 따른 드랍처리
        self:dropItem(enemy.pos.x, enemy.pos.y)
    end
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function DropItemMgr:onTouchBegan(touch, event)
    -- 조작 가능 상태일 때에만
    if (not self.m_world:isPossibleControl()) then
        return false
    end

    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    local select_item = self:getItemFromPos(node_pos['x'], node_pos['y'])

    if (select_item) then
        self.m_selectItem = select_item
        return true
    end

    return false
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function DropItemMgr:onTouchEnded(touch, event)
    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    if (self.m_selectItem) then
        if (self.m_selectItem == self:getItemFromPos(node_pos['x'], node_pos['y'])) then
            self.m_selectItem:changeState('dying')

            self.m_world.m_tamer:setTargetItem(self.m_selectItem)
        end
    end

    self.m_selectItem = nil
end