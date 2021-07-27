local PARENT = DropItemMgr

-------------------------------------
-- class DropItemMgr_EventGold
-------------------------------------
DropItemMgr_EventGold = class(PARENT, {
    m_remainFinalItemCnt = 'number',

    m_obtainedGold = 'number',  -- 획득한 골드량
})

-------------------------------------
-- function init
-------------------------------------
function DropItemMgr_EventGold:init(world)
    self.m_obtainedGold = SecurityNumberClass(0, false)
end

-------------------------------------
-- function designateDropMonster
-- @brief 드랍 몬스터 지정
-------------------------------------
function DropItemMgr_EventGold:designateDropMonster()
    self.m_lDropItemStack = {}

    -- 전투 중 100개까지만 드랍
    self.m_remainItemCnt = 100

    -- 전투 종료시 120개까지만 드랍
    self.m_remainFinalItemCnt = 120

    local total_count = self.m_remainItemCnt + self.m_remainFinalItemCnt

    for i = 1, total_count do
        local t_item = {
            type = 'gold',
            value = math_random(250, 650)
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

    self:obtainItem(item)
    item:changeState('appear_auto_obtain')

    return item
end

-------------------------------------
-- function onEvent
-------------------------------------
function DropItemMgr_EventGold:onEvent(event_name, t_event, ...)
    local arg = {...}
    local enemy = arg[1]

    if (event_name == 'drop_gold') then
        -- 전투 중 드랍 갯수 체크
        if (0 < self.m_remainItemCnt) then
            local pos_x = enemy.pos.x
            local pos_y = enemy.pos.y

            self:dropItem(pos_x, pos_y)
            self.m_remainItemCnt = (self.m_remainItemCnt - 1)
        end

    elseif (event_name == 'drop_gold_final') then
        -- 전투 종료 시드랍 갯수 체크
        if (0 < self.m_remainFinalItemCnt) then
            local pos_x = enemy.pos.x
            local pos_y = enemy.pos.y

            self:dropItem(pos_x, pos_y)
            self.m_remainFinalItemCnt = (self.m_remainFinalItemCnt - 1)
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

    --
    if (type == 'gold') then
        local obtained_gold = self.m_obtainedGold:get() + value
        self.m_obtainedGold:set(obtained_gold)
    end
end

-------------------------------------
-- function getObtainedGold
-------------------------------------
function DropItemMgr_EventGold:getObtainedGold()
    return self.m_obtainedGold:get()
end