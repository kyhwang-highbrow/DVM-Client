local PARENT = IEventListener:getCloneClass()

-------------------------------------
-- class DropItemMgr
-------------------------------------
DropItemMgr = class(PARENT, {
	m_world = 'GameWorld',

    m_touchNode = 'cc.Node',
    m_lItemlist = 'table',

    m_remainItemCnt = 'number',
    m_dropCount = 'number',
    m_obtainedItemList = 'list',
    m_bImmediatelyObtain = 'boolean',

    m_lDropItemStack = '',
})

-------------------------------------
-- function init
-------------------------------------
function DropItemMgr:init(world)
	self.m_world = world

    self.m_touchNode = self:makeTouchNode()
    self:makeTouchLayer(self.m_touchNode)

    self.m_lItemlist = {}

    self.m_remainItemCnt = 0
    self.m_dropCount = 0
    self.m_obtainedItemList = {}
    self.m_bImmediatelyObtain = false

    -- 아이템을 드랍할 몬스터 지정
    self:designateDropMonster()
end

-------------------------------------
-- function designateDropMonster
-- @brief 드랍 몬스터 지정
-------------------------------------
function DropItemMgr:designateDropMonster()
    if (self.m_world.m_bDevelopMode) then return end

    local stage_id = self.m_world.m_stageID

    local gamekey = self.m_world:getGameKey()
    local l_item_list =  g_stageData:getIngameDropInfo(gamekey) or {}
    self.m_lDropItemStack = l_item_list

    -- 총 드랍할 개수를 지정
    local drop_item_count = #l_item_list
    self.m_remainItemCnt = drop_item_count

    -- 웨이브 갯수 얻어옴
    local wave_script = self.m_world.m_waveMgr.m_scriptData
    local wave_list = wave_script['wave']
    if (not wave_list) then
        error('wave is nil. stage_id = ' .. stage_id)
    end

    local wave_cnt = #wave_list

    -- 웨이브 별 아이템 리턴 갯수
    local l_drop_count = {}
    for i=1, wave_cnt do
        l_drop_count[i] = 0
    end
    do
        local remain_count = drop_item_count

        -- 아이템 갯수가 웨이브보다 많은 경우 균등하게 배분
        if (wave_cnt <= drop_item_count) then
            local cnt = math_floor(drop_item_count / wave_cnt)
            for i=1, wave_cnt do
                l_drop_count[i] = cnt
                remain_count = (remain_count - cnt)
            end
        end

        -- 남은 아이템은 랜덤하게 배분
        if (0 < remain_count) then
            local sum_random = SumRandom()
            for i=1, wave_cnt do
                sum_random:addItem(1, i)
            end
            while (0 < remain_count) do
                local value = sum_random:getRandomValue(nil, true)
                l_drop_count[value] = (l_drop_count[value] + 1)
                remain_count = remain_count - 1
            end
        end
    end

    -- 웨이브별 몬스터에게 드랍 여부를 지정    
    for wave_idx,t_wave in ipairs(wave_list) do
        local time_list = t_wave['wave']
        local monster_cnt = 0
        for _,monster_list in pairs(time_list) do
            monster_cnt = (monster_cnt + #monster_list)
        end

        local sum_random = SumRandom()
        for k=1,monster_cnt do
            local has_item = (k <= l_drop_count[wave_idx])
            sum_random:addItem(1, has_item)
        end

        for _,monster_list in pairs(time_list) do
            for i,monster in ipairs(monster_list) do
                local has_item = sum_random:getRandomValue(nil, true)
                if has_item then
                    --cclog('has_item!!! ' .. monster)
                    monster_list[i] = monster_list[i] .. '@item'
                    self.m_remainItemCnt = (self.m_remainItemCnt - 1)
                end
            end
        end
    end
end

-------------------------------------
-- function makeTouchNode
-------------------------------------
function DropItemMgr:makeTouchNode()
    local touch_node = cc.Node:create()
    self.m_world.m_worldLayer:addChild(touch_node)

    return touch_node
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function DropItemMgr:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
                    
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
-- function dropItem
-------------------------------------
function DropItemMgr:dropItem(x, y)
    local item = DropItem(nil, {0, 0, 15})
    item.m_world = self.m_world
    item:init_item('item_marbl')
    item:initState()
    item:setPosition(x + math_random(-50, 50), y + math_random(-50, 50))

    self:addItem(item)

    self.m_dropCount = (self.m_dropCount + 1)

    self.m_world.m_logRecorder:recordLog('drop_item_cnt', 1)

    self:obtainItem(item)
    item:changeState('appear_auto_obtain')

    return item
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
        if (not v.m_bObtained) then
            v:changeState('dying')
        end
    end
end

-------------------------------------
-- function getItemList
-------------------------------------
function DropItemMgr:getItemList()
    return self.m_lItemlist
end

-------------------------------------
-- function getItemCount
-------------------------------------
function DropItemMgr:getItemCount()
    local item_count = table.count(self.m_lItemlist)
    return item_count
end

-------------------------------------
-- function setImmediatelyObtain
-------------------------------------
function DropItemMgr:setImmediatelyObtain()
    self.m_bImmediatelyObtain = true
end

-------------------------------------
-- function getItemFromPos
-------------------------------------
function DropItemMgr:getItemFromPos(pos_x, pos_y)
    local near_distance = nil
    local selected_item = nil

    for _,item in ipairs(self.m_lItemlist) do
        if (not item:isObtained()) then
            local x, y = item:getCenterPos()
		    local distance = math_distance(x, y, pos_x, pos_y)
            if (not near_distance) or (distance < near_distance) then
                near_distance = distance
                selected_item = item
            end
        end
    end

    if near_distance and (near_distance <= 200) then
        return selected_item
    end

    return nil
end

-------------------------------------
-- function onEvent
-------------------------------------
function DropItemMgr:onEvent(event_name, t_event, ...)
    if (self.m_world.m_bDevelopMode) then return end

    if (event_name == 'character_dead') then
        local arg = {...}
        local enemy = arg[1]

        -- TODO: 적에 따른 드랍처리
        if enemy.m_hasItem then
            self:dropItem(enemy.pos.x, enemy.pos.y)
            enemy.m_hasItem = false

        elseif (0 < self.m_remainItemCnt) then
            self:dropItem(enemy.pos.x, enemy.pos.y)
            self.m_remainItemCnt = (self.m_remainItemCnt - 1)
        end
    end
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function DropItemMgr:onTouchBegan(touch, event)

    --[[
    -- 조작 가능 상태일 때에만
    if (not self.m_world:isPossibleControl()) then
        return false
    end
    --]]

    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()

    -- item들은 game node 2에 위치함
    local node_pos = self.m_world.m_gameNode2:convertToNodeSpace(location)

    local select_item = self:getItemFromPos(node_pos['x'], node_pos['y'])

    if (select_item and not select_item:isObtained()) then
        self:obtainItem(select_item)

        -- 무조건 즉시 획득으로 임시 변경 sgkim 170411 (대표님 요구사항)
        select_item:makeObtainEffect()
        select_item:changeState('dying')

        --[[
        -- 즉시 획득
        if self.m_bImmediatelyObtain then
            select_item:makeObtainEffect()
            select_item:changeState('dying')
        -- 테이머 드랍 아이템 획득 연출
        else
            self.m_world.m_tamer:doBringItem(select_item)
        end
        --]]
        return true
    end

    return false
end

-------------------------------------
-- function decideDropItem
-------------------------------------
function DropItemMgr:decideDropItem()
end

-------------------------------------
-- function obtainItem
-------------------------------------
function DropItemMgr:obtainItem(item)
    if (item:isObtained()) then
        return
    end

    local t_data = self.m_lDropItemStack[1]
    table.remove(self.m_lDropItemStack, 1)

    local type = t_data['type']
    local value = t_data['value']

    local pTooltipUI = self.m_world.m_inGameUI.m_tooltip
    if pTooltipUI then
        pTooltipUI:refreshDropItems(type, value)
    end

    item:setObtained(type, value)
    table.insert(self.m_obtainedItemList, {type, value})
end

-------------------------------------
-- function makeObtainedDropItemStr
-- @breif
-------------------------------------
function DropItemMgr:makeObtainedDropItemStr()
    local str = nil

    for i,v in ipairs(self.m_obtainedItemList) do
        local item_type = v[1]
        local item_id = TableItem:getItemIDFromItemType(item_type)
        local item_count = v[2]

        if (not str) then
            str = ''
        else
            str = str .. ','
        end

        str = str .. item_id .. ';' .. item_count
    end

    return str or ''
end