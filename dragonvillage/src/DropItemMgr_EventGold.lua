local PARENT = DropItemMgr

-------------------------------------
-- class DropItemMgr_EventGold
-------------------------------------
DropItemMgr_EventGold = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function DropItemMgr_EventGold:init(world)
end

-------------------------------------
-- function designateDropMonster
-- @brief 드랍 몬스터 지정
-------------------------------------
function DropItemMgr_EventGold:designateDropMonster()
    self.m_lDropItemStack = {}

    -- 최대 100개까지만 드랍
    self.m_remainItemCnt = 100

    for i = 1, self.m_remainItemCnt do
        local t_item = {
            type = 'gold',
            value = math_random(300, 700)
        }
        
        table.insert(self.m_lDropItemStack, t_item)
    end
end

-------------------------------------
-- function dropItem
-------------------------------------
function DropItemMgr_EventGold:dropItem(x, y)
    local item = DropItem(nil, {0, 0, 15})
    item.m_world = self.m_world
    item:init_item('item_marbl_gold')
    item:initState()
    item:setPosition(x + math_random(-300, 300), y + math_random(-300, 300))

    self:addItem(item)

    self.m_dropCount = (self.m_dropCount + 1)

    self.m_world.m_logRecorder:recordLog('drop_item_cnt', 1)

    -- 자동 획득 활성화일 경우 즉시 획득
    if (self.m_bActiveAutoItemPick == true) then
        self:obtainItem(item)
        item:changeState('appear_auto_obtain')
    end

    return item
end

-------------------------------------
-- function onEvent
-------------------------------------
function DropItemMgr_EventGold:onEvent(event_name, t_event, ...)
    if (event_name == 'drop_gold') then
        local arg = {...}
        local enemy = arg[1]
        
        if (0 < self.m_remainItemCnt) then
            local pos_x = enemy.pos.x
            local pos_y = enemy.pos.y

            self:dropItem(pos_x, pos_y)
            self.m_remainItemCnt = (self.m_remainItemCnt - 1)
        end
    end
end

-------------------------------------
-- function obtainItem
-------------------------------------
function DropItemMgr_EventGold:obtainItem(item)
    if (item:isObtained()) then
        return
    end

    local t_data = self.m_lDropItemStack[1]
    table.remove(self.m_lDropItemStack, 1)

    local type = t_data['type']
    local value = t_data['value']
    item:setObtained(type, value)
    table.insert(self.m_obtainedItemList, {type, value})
end