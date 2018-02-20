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
-- function onEvent
-------------------------------------
function DropItemMgr_EventGold:onEvent(event_name, t_event, ...)
    if (event_name == 'drop_gold') then
        local arg = {...}
        local enemy = arg[1]
        local pos_x = enemy.pos.x - 600
        local pos_y = enemy.pos.y

        if (0 < self.m_remainItemCnt) then
            local offset_x = math_random(-300, 300)
            local offset_y = math_random(-300, 300)

            self:dropItem(pos_x + offset_x, pos_y + offset_y)
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