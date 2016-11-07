-------------------------------------
-- class DropHelper
-------------------------------------
DropHelper = class({
        m_stageID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function DropHelper:init(stage_id)
    self.m_stageID = stage_id
end

-------------------------------------
-- function validDropField
-------------------------------------
function DropHelper:validDropField(t_drop, item_type, item_grade)
    -- 확률 확인
    local rate_key = item_type .. '_rate_' .. item_grade
    if (t_drop[rate_key] == 0) then
        return false
    end

    -- 볼륨 확인
    local volume_key = item_type .. '_volume_' .. item_grade
    if (t_drop[volume_key] == 0) then
        return false
    end

    return true
end

-------------------------------------
-- function getDisplayItemList
-------------------------------------
function DropHelper:getDisplayItemList()
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[self.m_stageID]

    local l_ret = {}
    for i=0, 10 do
        local key = 'drop_display_' .. i
        local item_id = t_drop[key]
        if (item_id ~= 0) then
            table.insert(l_ret, item_id)
        end
    end

    return l_ret
end

-------------------------------------
-- function getDisplayItemIconList
-------------------------------------
function DropHelper:getDisplayItemIconList()
    local l_item_list = self:getDisplayItemList()

    local l_ret = {}
    for i,item_id in ipairs(l_item_list) do
        --local icon = self:getItemIconFromIID(item_id)
        local item_card = UI_ItemCard(item_id, 0)

        -- 첫 번째 드롭 아이템은 강조
        if (i == 1) then
            item_card:setHighlight(true)
        end

        local icon = item_card.root
        table.insert(l_ret, icon)
    end

    return l_ret
end

-------------------------------------
-- function getItemIconFromIID
-------------------------------------
function DropHelper:getItemIconFromIID(item_id)
    return IconHelper:getItemIcon(item_id)
end


-------------------------------------
-- function dropItem
-- @brief 해당 stage_id의 아이템을 모두 드랍
-------------------------------------
function DropHelper:dropItem()
    local l_drop_item = {}

    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[self.m_stageID]

    local sum_random = SumRandom()
    sum_random:addItem(t_drop['rate_s'], 's')
    sum_random:addItem(t_drop['rate_a'], 'a')
    sum_random:addItem(t_drop['rate_b'], 'b')
    sum_random:addItem(t_drop['rate_c'], 'c')

    local value1 = sum_random:getRandomValue()
    local value2 = sum_random:getRandomValue()
    local value3 = sum_random:getRandomValue()

    -- 세개 모두 c등급일 경우 하나를 b등급으로 상향
    if (value1 == 'c') and (value2 == 'c') and (value3 == 'c') then
        value3 = 'b'
    end

    local item1 = self:dropItemIndependent(value1)
    local item2 = self:dropItemIndependent(value2)
    local item3 = self:dropItemIndependent(value3)

    l_drop_item[1] = item1
    l_drop_item[2] = item2
    l_drop_item[3] = item3

    return l_drop_item
end

-------------------------------------
-- function getFirstRewardItemList
-- @brief 해당 stage_id의 최초보상 아이템 항목 리턴
-------------------------------------
function DropHelper:getFirstRewardItemList(stage_id)
    local table_first_reward = TABLE:get('first_reward')
    local t_first_reward = table_first_reward[stage_id]

    local l_reward_item = {}

    -- 보상 지급
    for i=1, 10 do
        local item_id = t_first_reward['reward_' .. i] or 0
        local item_cnt = t_first_reward['value_' .. i] or 0

        if (item_id ~= 0) then
            table.insert(l_reward_item, {item_id, item_cnt})
        end
    end

    return l_reward_item
end


-------------------------------------
-- function dropItemIndependent
-- @brief
-------------------------------------
function DropHelper:dropItemIndependent(grade)
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[self.m_stageID]

    local sum_random = SumRandom()

    for i=1, 10 do
        local key_rate = 'rate_' .. grade .. i
        local key_id = 'id_' .. grade .. i
        local key_value = 'value_' .. grade .. i

        sum_random:addItem(t_drop[key_rate], {t_drop[key_id], t_drop[key_value]})
    end

    local item = sum_random:getRandomValue()
    return item
end


-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 start
-------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function getDisplayItemIconList_firstReward
-------------------------------------
function DropHelper:getDisplayItemIconList_firstReward()
    local stage_id = self.m_stageID
    local table_first_reward = TABLE:get('first_reward')
    local t_first_reward = table_first_reward[stage_id]

    local l_ret = {}
    for i=1,10 do
        local item_id = t_first_reward['reward_' .. i] or 0
        local item_cnt = t_first_reward['value_' .. i] or 0

        if (item_id ~= 0) then
            local item_card = UI_ItemCard(item_id, item_cnt)

            local icon = item_card.root
            table.insert(l_ret, icon)
        end
    end

    return l_ret
end

-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 end
-------------------------------------------------------------------------------------------------------------------