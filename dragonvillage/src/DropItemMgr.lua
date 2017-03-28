local PARENT = IEventListener:getCloneClass()

-------------------------------------
-- class DropItemMgr
-------------------------------------
DropItemMgr = class(PARENT, {
	m_world = 'GameWorld',

    m_touchNode = 'cc.Node',
    m_selectItem = 'DropItem',
    m_lItemlist = 'table',

    m_chapterID = 'number',
    m_tableDropIngame = 'TableDropIngame',
    m_remainItemCnt = 'number',
    m_dropCount = 'number',
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
    self.m_dropCount = 0

    -- 아이템을 드랍할 몬스터 지정
    self:designateDropMonster(wave_script)
end

-------------------------------------
-- function designateDropMonster
-- @brief 드랍 몬스터 지정
-------------------------------------
function DropItemMgr:designateDropMonster()
    local stage_id = self.m_world.m_stageID
    self.m_chapterID = TableDropIngame:makeChapterIDFromStageID(stage_id)
    

    self.m_tableDropIngame = TableDropIngame()
    local t_drop_ingame = self.m_tableDropIngame:getDropIngameTable(self.m_chapterID)
    if (not t_drop_ingame) then
        return
    end

    -- 총 드랍할 개수를 지정
    local drop_item_count = self.m_tableDropIngame:getDropItemCount(self.m_chapterID)
    self.m_remainItemCnt = drop_item_count

    -- 웨이브 갯수 얻어옴
    local wave_script = self.m_world.m_waveMgr.m_scriptData
    local wave_list = wave_script['wave']
    local wave_cnt = #wave_list

    -- 웨이브 별 아이템 리턴 갯수
    local l_drop_count = {}
    do
        local remain_count = drop_item_count
        if (wave_cnt <= drop_item_count) then
            local cnt = math_floor(drop_item_count / wave_cnt)
            for i=1, wave_cnt do
                l_drop_count[i] = cnt
                remain_count = (remain_count - cnt)
            end
        end

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

    -- 몬스터에 드랍 여부를 지정    
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
    item:setPosition(x + math_random(-50, 50), y + math_random(-50, 50))

    self:addItem(item)

    self.m_dropCount = (self.m_dropCount + 1)
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

    return nil
end

-------------------------------------
-- function onEvent
-------------------------------------
function DropItemMgr:onEvent(event_name, t_event, ...)
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
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    local select_item = self:getItemFromPos(node_pos['x'], node_pos['y'])

    if (select_item and not select_item:isObtained()) then
        -- 테이머 드랍 아이템 획득 연출
        self.m_world.m_tamer:doBringItem(select_item)
        self:obtainItem(select_item)

        --self.m_selectItem = select_item
        return true
    end

    return false
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function DropItemMgr:onTouchEnded(touch, event)
    --[[
    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    if (self.m_selectItem) then
        if (self.m_selectItem == self:getItemFromPos(node_pos['x'], node_pos['y'])) then
            -- 테이머 드랍 아이템 획득 연출
            self.m_world.m_tamer:doBringItem(self.m_selectItem)

            self:obtainItem(self.m_selectItem)
        end
    end

    self.m_selectItem = nil
    --]]
end

-------------------------------------
-- function obtainItem
-------------------------------------
function DropItemMgr:obtainItem(item)
    if (item:isObtained()) then return end

    item:setObtained()

    -- TODO: 드랍 아이템 획득 처리
    local t_temp = { 'cash', 'gold', 'lactea' }
    t_temp = randomShuffle(t_temp)

    local type = t_temp[1]
    local res = 'res/ui/icon/inbox/inbox_' .. type .. '.png'
    if (res) then
        local node = cc.Node:create()
        node:setPosition(item.pos.x, item.pos.y)
        self.m_world:addChild3(node, DEPTH_ITEM_GOLD)

        local icon = cc.Sprite:create(res)
        if (icon) then
            icon:setPositionX(-15)
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            node:addChild(icon)
        end

        local label = cc.Label:createWithBMFont('res/font/normal.fnt', '+1')
        if (label) then
            local string_width = label:getStringWidth()
            local offset_x = (string_width / 2)
            label:setPositionX(offset_x)
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setColor(cc.c3b(255, 255, 255))
            node:addChild(label)
        end

        node:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.EaseIn:create(cc.MoveBy:create(1, cc.p(0, 80)), 1))
    end
end