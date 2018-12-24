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
    
    -- 캡슐 타이틀 설정
    vars['titleHeroLabel']:setString(self:getCapsuleBoxTitle('hero'))
    vars['titleLegendLabel']:setString(self:getCapsuleBoxTitle('legend'))
    
    -- 캡슐 일정 설정  
    if (self.m_scheduleData['advance_notice']) then
        vars['timeLabel']:setString(self.m_scheduleData['advance_notice'])
    else
        local date_str = self:getScheduleTime()
        vars['timeLabel']:setString(date_str)-- yyyy년 mm월 dd일
    end

    -- 캡슐 상품 일정 체크
    local cur_date = tonumber(g_capsuleBoxData.m_todaySchedule['day'])
    if (self.m_scheduleData['day']) then
        local capsule_date = tonumber(self.m_scheduleData['day'])
        if (cur_date == capsule_date) then                              -- 오늘 상품은 하이라이트 표시
            vars['todaySprite']:setVisible(true)
        elseif (cur_date > capsule_date) then                           -- 판매 끝난 상품은 lock 표시 
            vars['lockSprite']:setVisible(true)
        end
    end

    -- 캡슐 아이템 세팅
    -- 공통적으로 사용하는 first_1, second_1 이용해서 노드 이름, 아이템 정보 알아냄 
    local item_key_list = {'first_1', 'first_2', 'first_3','second_1', 'second_2', 'second_3'}
    for i, reward_name in ipairs(item_key_list) do   
        local node_name
        do -- 노드 이름 만드는 과정 : ex) first_1 -> legendDragonNode1
            if (string.match(reward_name,'first')) then
                node_name = 'legendDragonNode'
            elseif(string.find(reward_name, 'second')) then
                node_name = 'heroDragonNode'
            end
            
            local node_number = string.match(reward_name, '%d')
            node_name = node_name ..  node_number
        end
        if (vars[node_name]) then         
            -- 아이템 카드 세팅
            local item_card = self:makeItemCard(reward_name, node_name)
            -- 아이템 카드 해당 노드에 추가       
            if (item_card) then
                vars[node_name]:addChild(item_card.root)
                item_card.root:setScale(0.66)
            end        
        end

    end

end

-------------------------------------
-- function isValidItem
-- @brief 출시 예정 드래곤 or 적합하지 않은 id의 경우 false 
-------------------------------------
function UI_CapsuleScheduleListItem:isValidItem(reward_name, capsule_item_id)
    
    local table_item = TableItem()
    local reward_card

    if (not capsule_item_id) then
        return false
    end

    -- 아이템이 드래곤이라면 출시 여부 판단 
    if (table_item:isDragonByItemId(capsule_item_id)) then
        local did = table_item:getDidByItemId()
        -- 출시 되지 않은 드래곤이면 출력 안함
        if (not g_dragonsData:isReleasedDragon(did)) then
            return false
        end
    end

    -- table_item에 있는 id인지 확인
    if (not table_item:getItemName()) then
        return false
    end
    
    return true
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

    -- 20181212을 년월일로 분리하는 과정
    local year = string.sub(schedule_time, 0, 4)
    local month = string.sub(schedule_time, 5, 6)
    local day = string.sub(schedule_time, 7, 8)

    -- Date 인스턴스 타겟 날짜로 생성
    local date = pl.Date()
	date:year(tonumber(year))
    date:month(tonumber(month))
    date:day(tonumber(day))
    
    -- 요일 구하는 함수
    local week_day_eng = date:weekday_name()
    local week_day_kr
    if ('Mon' == week_day_eng) then week_day_kr = Str('월')
    elseif ('Tue' == week_day_eng) then week_day_kr = Str('화')
    elseif ('Wed' == week_day_eng) then week_day_kr = Str('수')
    elseif ('Thu' == week_day_eng) then week_day_kr = Str('목')
    elseif ('Fri' == week_day_eng) then week_day_kr = Str('금')
    elseif ('Sat' == week_day_eng) then week_day_kr = Str('토')
    elseif ('Sun' == week_day_eng) then week_day_kr = Str('일')
    end

    local year_kr = Str('년')
    local month_kr = Str('월')
    local day_kr = Str('일')
    local date_form = '%d' .. year_kr .. ' ' .. '%d' .. month_kr .. ' ' .. '%d' .. day_kr .. ' ' .. '(%s)'
    local date_str = string.format(date_form, tonumber(year), tonumber(month),tonumber(day), week_day_kr)
    return date_str
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

    if (not self.m_scheduleData['t_first_name']) then
        return ''
    end

    if (type == 'legend') then
        return Str(self.m_scheduleData['t_first_name']) .. ' ' .. Str('캡슐') or ''
    else
        return Str(self.m_scheduleData['t_second_name']) .. ' ' .. Str('캡슐') or ''
    end

end

-------------------------------------
-- function makeItemCard
-------------------------------------
function UI_CapsuleScheduleListItem:makeItemCard(reward_name, node_name)
    local vars = self.vars
    local capsule_item_id = self:getCapsuleBoxItemId(reward_name)

    -- 출시 예정 드래곤 or 잘못된 id의 경우 아이템 카드는 적합하지 않음 (물음표 표시)
    local is_valid_item = self:isValidItem(reward_name, capsule_item_id)
    
    -- 마지막에 추가되는 일정 예고 아이템 (물음표 표시)
    if (self.m_scheduleData['advance_notice']) then
        is_valid_item = false
    end


    local item_card
    -- 아이템 정상 출력
    if (is_valid_item) then
        local table_item = TableItem()
        -- 드래곤의 경우 드래곤 카드 클래스로 생성
        if (table_item:isDragonByItemId(capsule_item_id)) then
            local t_dragon_data = {}
            local t_item = table_item:get(capsule_item_id)
            t_dragon_data['did'] = t_item['did']
            t_dragon_data['evolution'] = t_item['evolution']
            t_dragon_data['grade'] = t_item['grade']
            t_dragon_data['skill_0'] = 1
            t_dragon_data['skill_1'] = 0
            t_dragon_data['skill_2'] = 0
            t_dragon_data['skill_3'] = 0
        
            item_card = UI_DragonCard(StructDragonObject(t_dragon_data))
        else
            item_card = UI_ItemCard(capsule_item_id, 1)
        end
        -- 뱃지 생성
        local badge_ui = g_capsuleBoxData:makeBadge(self.m_scheduleData, reward_name)
        if (badge_ui) then
            item_card.root:addChild(badge_ui.root)
        end
    -- 아이템을 물음표로 출력
    else
        local empty_ui = UI()
        empty_ui:load('icon_item_item.ui')              -- 물음표만 활성화 하면 되기 때문에 ItemCard 생성하지 않고(init함수들 사용x) vars만 긁어옴
        empty_ui.vars['lockSprite']:setVisible(true)
        item_card = empty_ui
    
        -- 카드 중 한개라도 빈 카드면 타이틀을 숨김
        if (string.match(node_name, 'hero')) then
            vars['titleHeroLabel']:setVisible(false)
        else
            vars['titleLegendLabel']:setVisible(false)
        end
    end

    return item_card
end
