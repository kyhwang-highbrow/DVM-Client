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
    self.vars['titleHeroLabel']:setString(self:getCapsuleBoxTitle('hero'))
    self.vars['titleLegendLabel']:setString(self:getCapsuleBoxTitle('legend'))
    
    -- 캡슐 일정 설정     
    local date_str = self:getScheduleTime()
    self.vars['timeLabel']:setString(date_str)-- yyyy년 mm월 dd일

    -- 캡슐 상품 일정 체크 
    local cur_date = tonumber(g_capsuleBoxData.m_todaySchedule['day'])
    local capsule_date = tonumber(self.m_scheduleData['day'])
    if (cur_date == capsule_date) then                              -- 오늘 상품은 하이라이트 표시
        self.vars['todaySprite']:setVisible(true)
    elseif (cur_date > capsule_date) then                           -- 판매 끝난 상품은 lock 표시 
        self.vars['lockSprite']:setVisible(true)
    end
    
    -- 캡슐 아이템 세팅
    local item_key_list = {'first_1', 'first_2', 'first_3','second_1', 'second_2', 'second_3'} -- ex)  first_1 : 전설 캡슐 첫 번째 아이템, second_2 : 영웅 캡슐  두 번째 아이템
    for i, reward_name in ipairs(item_key_list) do
        
        -- 전설, 영웅 판별해서 노드 이름 판단
        local node_name
        if (string.match(reward_name,'first')) then
            node_name = 'legendDragonNode'
        elseif(string.find(reward_name, 'second')) then
            node_name = 'heroDragonNode'
        end

        if (node_name) then
            -- ex) first_1 은 legendDragonNode1 와 대응
            local node_number = string.match(reward_name, '%d')
            node_name = node_name ..  node_number
            
            -- 아이템 카드 세팅
            if (vars[node_name]) then
                local capsule_item_id = self:getCapsuleBoxItemId(reward_name)
                local is_can_show = self:checkValidItem(reward_name, capsule_item_id)
                local item_card

                -- 보여줄 수 있는 카드는 아이템 카드 생성
                -- 보여줄 수 없는 카드는 물음표 카드 생성
                if (is_can_show and capsule_item_id) then
                    item_card = UI_ItemCard(capsule_item_id, 1)

                    -- 뱃지 생성
                    local badge_ui = self:makeBadge(reward_name)
                    item_card.root:addChild(badge_ui.root)

                else             
                    local empty_ui = UI()
                    empty_ui:load('icon_item_item.ui')
                    empty_ui.vars['lockSprite']:setVisible(true)
                    item_card = empty_ui
                end
                
                -- 아이템 카드 해당 노드에 추가       
                if (item_card) then
                    vars[node_name]:addChild(item_card.root)
                    item_card.root:setScale(0.66)
                end        
            end
        end
    end

end

-------------------------------------
-- function makeItemCard
-------------------------------------
function UI_CapsuleScheduleListItem:checkValidItem(reward_name, capsule_item_id)
    
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

-------------------------------------
-- function makeBadge
-------------------------------------
function UI_CapsuleScheduleListItem:makeBadge(reward_name)
    -- 뱃지용 UI 로드
    local badge_ui = UI()
    badge_ui:load('icon_badge.ui')
    badge_ui.vars['badgeNode']:setVisible(true)
    
    -- 뱃지 텍스쳐 설정 (event, hot, new)
    local badege_type = self.m_scheduleData['badge_' .. reward_name]
    local badge_res = self:getBadgeResource(badege_type)
    if (badge_res) then
        badge_ui.vars['badgeSprite']:setTexture(badge_res)
    end

    return badge_ui
end

-------------------------------------
-- function getBadgeResource
-------------------------------------
function UI_CapsuleScheduleListItem:getBadgeResource(type)
    local vars = self.vars
    local res = 'res/ui/frames/capsule_box_badge_%s.png'
    local res_number = ''

    if (not type) then
        return nil
    end

    if (type == '') then
        return nil
    end

    -- ex) res/ui/frames/capsule_box_badge_0301.png
    if (type == 'event') then
        res_number = '0301'
    elseif (type == 'hot') then
        res_number = '0302'
    elseif (type == 'new') then
        res_number = '0303'
    end

    local full_res = string.format(res, res_number)
    return full_res
end
