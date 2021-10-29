local PARENT = UI

-------------------------------------
-- class UI_EventRuneFestival
-------------------------------------
UI_EventRuneFestival = class(PARENT,{
    })


-------------------------------------
-- function init
-------------------------------------
function UI_EventRuneFestival:init()
    local vars = self:load('event_rune_festival.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventRuneFestival:initUI()
    local vars = self.vars
    
    local drop_table = TableDrop()
    local item_table = TableItem()

    local stage_id_list = g_eventRuneFestival:getEventStageIdList()

    for index, stage_id in ipairs(stage_id_list) do
        local stage_data = drop_table:get(stage_id)
        local item_index = 1

        while(stage_data['item_' .. item_index .. '_id']) do
            local item_id = stage_data['item_' .. item_index .. '_id']

            if (item_id == nil) or (item_id == '') then
                break 
            end

            local item_data = item_table:get(item_id)
            local item_type = item_data['type']
     
            if item_type and (item_type == 'event_token') then
                local item_min = stage_data['item_' .. item_index .. '_min']
                local item_max = stage_data['item_' .. item_index .. '_max']

                if (item_min == item_max) then
                    vars['rewardLabel' .. index]:setString(Str('{1}개', item_min))
                else
                    vars['rewardLabel' .. index]:setString(Str('{1}~{2}개', item_min, item_max))
                end

                break;
            end

            item_index = item_index + 1
        end

        if (stage_data['cost_type'] == 'st') and vars['stageCostLabel' .. index] then
            vars['stageCostLabel' .. index]:setString(stage_data['cost_value'])
        end
    end

    vars['numberLabel']:setString(Str('{1}개', g_userData:get('event_token') or 0))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventRuneFestival:initButton()
    local vars = self.vars
    
    -- 스테이지 진입 버튼 (난이도별)
    vars['normalStartBtn']:registerScriptTapHandler(function() self:click_stageStartBtn(1119801) end)
    vars['hardlStartBtn']:registerScriptTapHandler(function() self:click_stageStartBtn(1129801) end)
    vars['helllStartBtn']:registerScriptTapHandler(function() self:click_stageStartBtn(1139801) end)
    vars['hellfireStartBtn']:registerScriptTapHandler(function() self:click_stageStartBtn(1149801) end)


    vars['shopBtn']:registerScriptTapHandler(function() UINavigator:goTo('shop') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventRuneFestival:refresh()
    local vars = self.vars
    
    -- 이벤트 종료까지 {1} 남음
    if vars['timeLabel'] then
        local remain_time_text = g_eventRuneFestival:getStatusText()
        vars['timeLabel']:setString(remain_time_text)
    end

    -- 일일 최대 {1}/{2}개 사용 가능
    if vars['obtainLabel'] then
        local str = g_eventRuneFestival:getRuneFestivalStaminaText()
        vars['obtainLabel']:setString(str)
    end 
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventRuneFestival:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function click_stageStartBtn
-------------------------------------
function UI_EventRuneFestival:click_stageStartBtn(stage_id)
    UI_AdventureStageInfo(stage_id)
end