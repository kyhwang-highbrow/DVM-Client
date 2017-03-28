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
    m_optainedItemList = 'list',
})

-------------------------------------
-- function init
-------------------------------------
function DropItemMgr:init(world)
	self.m_world = world

    self.m_touchNode = cc.Node:create()
    world:addChild2(self.m_touchNode)
    self:makeTouchLayer(self.m_touchNode)

    self.m_selectItem = nil
    self.m_lItemlist = {}
    self.m_dropCount = 0
    self.m_optainedItemList = {}

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
    local node_pos = self.m_touchNode:getParent():convertToNodeSpace(location)

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
-- function decideDropItem
-------------------------------------
function DropItemMgr:decideDropItem()
end

-------------------------------------
-- function obtainItem
-------------------------------------
function DropItemMgr:obtainItem(item)
    if (item:isObtained()) then return end

    item:setObtained()

    -- 인터미션 때 이동하는 것 멈춤
    local action_tag = 1000
    cca.stopAction(item.m_rootNode, action_tag)

    local type, count = self.m_tableDropIngame:decideDropItem(self.m_chapterID)
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

        local label = cc.Label:createWithBMFont('res/font/normal.fnt', '+' .. count)
        if (label) then
            local string_width = label:getStringWidth()
            local offset_x = (string_width / 2)
            label:setPositionX(offset_x)
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setColor(cc.c3b(255, 255, 255))
            node:addChild(label)
        end

        local delay_time = 0.2
        node:setVisible(false)
        node:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time), cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time), cc.EaseIn:create(cc.MoveBy:create(1, cc.p(0, 80)), 1)))
        node:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time), cc.Show:create()))
    end

    -- 정보 저장
    table.insert(self.m_optainedItemList, {type, count})
end




-------------------------------------
-- function intermission
-- @brief 드랍 아이템 인터미션
-------------------------------------
function DropItemMgr:intermission()

    -- 아이템들 이동
    for i,v in pairs(self.m_lItemlist) do
        self:applyInterMissionAction(v.m_rootNode)
    end

    -- 터치 레이어 이동
    self:applyInterMissionAction(self.m_touchNode)
end

-------------------------------------
-- function applyIntermissionAction
-- @breif 인터미션 액션 지정
-------------------------------------
function DropItemMgr:applyInterMissionAction(node)
    -- 카메라 이동 거리 얻어옴
    local gap_x, gap_y = self.m_world.m_gameCamera:getIntermissionOffset()

    -- 인터미션 시간 얻어옴
    local move_time = getInGameConstant(WAVE_INTERMISSION_TIME)

    local x, y = node:getPosition()
    local action = cc.MoveTo:create(move_time, cc.p(x + gap_x, y + gap_y))
    local action_tag = 1000
    cca.runAction(node, action, action_tag)
end

-------------------------------------
-- function makeOptainedDropItemStr
-- @breif
-------------------------------------
function DropItemMgr:makeOptainedDropItemStr()
    local str = nil

    for i,v in ipairs(self.m_optainedItemList) do
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