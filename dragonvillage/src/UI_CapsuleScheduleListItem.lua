local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CapsuleScheduleListItem
-------------------------------------
UI_CapsuleScheduleListItem = class(PARENT, {
        m_scheduleData = 'Data'
        --[[
               "second_3":770203,
               "badge_first_3":"",
               "badge_first":"",
               "badge_second":"",
               "badge_first_2":"",
               "chance_up_1":121053,
               "second_2":770212,
               "first_3":770784,
               "chance_up_2":"",
               "t_first_name":"",
               "badge_second_1":"",
               "second_1":770112,
               "t_second_name":"",
               "badge_first_1":"",
               "day":20181125,
               "badge_second_2":"",
               "badge_second_3":"",
               "first_2":770433,
               "first_1":770725
        --]]
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleScheduleListItem:init(data)
    local vars = self:load('capsule_box_schedule_list_item.ui')
    self.m_scheduleData = data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleScheduleListItem:initUI()
    local vars = self.vars
    
    self.vars['titleHeroLabel']:setString(self:getCapsuleBoxTitle('hero'))
    self.vars['titleLegendLabel']:setString(self:getCapsuleBoxTitle('legend'))
    
    -- yyyy년 mm월 dd일    
    local date_str = self:getScheduleTime()
    self.vars['timeLabel']:setString(date_str)

    local is_check_new_dragon = false
    local cur_date = tonumber(g_capsuleBoxData.m_todaySchedule['day'])
    local capsule_date = tonumber(self.m_scheduleData['day'])
    if (cur_date == capsule_date) then                              -- 판매 중인 상품은 하이라이트 표시
        self.vars['todaySprite']:setVisible(true)
    elseif (cur_date > capsule_date) then                           -- 판매 끝난 상품은 lock 표시 
        self.vars['lockSprite']:setVisible(true)
    -- 판매 예정인 상품은 출시 안된 드래곤 체크해야함
    else
        is_check_new_dragon = true
    end
    
    -- item_key_list 항목 뜻 
    -- ex)  first_1 : 전설 캡슐 첫 번째 아이템, second_2 : 영웅 캡슐  두 번째 아이템
    local item_key_list = {'first_1', 'first_2', 'first_3','second_1', 'second_2', 'second_3'}

    local table_item = TableItem()

    -- 아이템 카드 세팅
    for i, reward_name in ipairs(item_key_list) do
        local node_name
        if (string.match(reward_name,'first')) then
            node_name = 'legendDragonNode'
        elseif(string.find(reward_name, 'second')) then
            node_name = 'heroDragonNode'
        end

        if (node_name) then
            -- first_1의 숫자를 추출
            local node_number = string.match(reward_name, '%d')

            -- ex) legendDragonNode + 1
            node_name = node_name ..  node_number

            -- 노드에 아이템 카드 매달기
            local reward_card
            local capsule_item_id
            if (vars[node_name]) then
                capsule_item_id = self:getCapsuleBoxItemId(reward_name)
                -- 아이템이 드래곤이라면 출시 여부 판단 
                if (table_item:isDragonByItemId(capsule_item_id)) then
                    local did = table_item:getDidByItemId()
                    -- 출시 되지 않은 드래곤이면 출력 안함
                    if (not g_dragonsData:isReleasedDragon(did)) then
                        return
                    end
                end

                -- table_item에 있는 id인지 확인
                if (not table_item:getItemName()) then
                    return
                end
                
                if (capsule_item_id) then
                    reward_card = UI_ItemCard(capsule_item_id, 1).root
                    reward_card:setScale(0.66)
                    vars[node_name]:addChild(reward_card)
                end
            end
        end
    end

end

-------------------------------------
-- function initItemCard
-------------------------------------
function UI_CapsuleScheduleListItem:initButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleScheduleListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleScheduleListItem:refresh()
end

-------------------------------------
-- function getScheduleData
-------------------------------------
function UI_CapsuleScheduleListItem:getScheduleData()
    return self.m_scheduleData or {}
end

-------------------------------------
-- function getScheduleTime
-------------------------------------
function UI_CapsuleScheduleListItem:getScheduleTime()
    local schedule_data = self:getScheduleData()
    local schedule_time = self.m_scheduleData['day']

    if (not schedule_time) then
        return 0
    end

    local year = string.sub(schedule_time, 0, 4)
    local month = string.sub(schedule_time, 5, 6)
    local day = string.sub(schedule_time, 7, 8)
    
    local date_format = 'yyyymmdd'
    local parser = pl.Date.Format(date_format)

    local schedule_date = parser:parse(tostring(schedule_time))
    local schedule_time = schedule_date['time'] 

    --월화수목금 번역?
    -- local week_name = pl.Date():weekday_name(schedule_time)
    local date_str = string.format('%d년 %d월 %d일', tonumber(year), tonumber(month),tonumber(day))
    return Str(date_str)
end

-------------------------------------
-- function getCapsuleBoxItemId
-------------------------------------
function UI_CapsuleScheduleListItem:getCapsuleBoxItemId(item_key)
    local schedule_data = self:getScheduleData()
    return self.m_scheduleData[item_key] or nil 
end

-------------------------------------
-- function getCapsuleBoxTitle
-------------------------------------
function UI_CapsuleScheduleListItem:getCapsuleBoxTitle(type)
    local schedule_data = self:getScheduleData()

    if (type == 'legend') then
        return Str(self.m_scheduleData['t_first_name']) or ''
    else
        return Str(self.m_scheduleData['t_second_name']) or ''
    end
end


