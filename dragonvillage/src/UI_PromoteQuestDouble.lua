local PARENT = UI

-------------------------------------
-- class UI_PromoteQuestDouble
-------------------------------------
UI_PromoteQuestDouble = class(PARENT,{
        m_buyCb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PromoteQuestDouble:init(buy_cb)
    self.m_uiName = 'UI_PromoteQuestDouble'
    local vars = self:load('promote_quest_double.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_buyCb = buy_cb

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_PromoteAutoPick')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @brief 2018-11-21 퀘스트 보상 보여주는 그림 6개만 만들어 놓은 상태(골드, 다이아, 날개, 우정포인트, 자수정, 클랜코인)
-- @brief 데이터로 퀘스트 보상 아이템 종류 추가나 삭제 시 추가 UI작업 필요
-------------------------------------
function UI_PromoteQuestDouble:initUI()
    local vars = self.vars
    -- 일일 퀘스트 보상 개수(아이템별) 합산한 맵 
    local t_quest_max_map = self:addAllReward_dailyQuest()

    local table_item = TableItem()
    for id, value in pairs(t_quest_max_map) do
        local item_type = table_item:getItemTypeFromItemID(id)
        if (item_type) then
            local label_name = item_type .. 'Label' -- lua_name : 아이템타입+Label  ex) goldLabel, cashLabel

            -- 최대 보상 개수 : 일일 보상 합산 x 상품 지속 기간
            -- 2018-11-21 상품 지속 기간 14일
            local max_value = tonumber(value) * 14

            -- 라벨에 들어갈 문구 조합  -- ex) 골드\n10000개
            if (vars[label_name]) then
                local item_name = Str(table_item:getItemName(id))
                local value_str = comma_value(Str('{1}개', max_value))
                local full_str = item_name .. '\n' .. value_str
                vars[label_name]:setString(full_str)
            end
        end 
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PromoteQuestDouble:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_okay() end)
    vars['cancleBtn']:registerScriptTapHandler(function() self:click_cancle() end)
end

-------------------------------------
-- function addAllReward_dailyQuest
-- @return  일일 퀘스트 보상에서 아이템별로 보상 갯수를 합산하여 [item_id] = count 형태의 맵 반환   
-------------------------------------
function UI_PromoteQuestDouble:addAllReward_dailyQuest()
    local table_quest = TableQuest:getQuestTable()
    local max_count_map = {}
    for qid, v in pairs(table_quest) do
        -- 퀘스트 중 type이 일일 보상인 경우
        if (v['type'] == 'daily') then
            -- reward = '700001;1,700002;1'
            local reward = v['reward']
            local comma_split_list = plSplit(reward, ',') -- 아이템별로 리스트 생성
            for i, each_reward_str in pairs(comma_split_list) do
                local semi_split_list = plSplit(each_reward_str, ';') -- 아이템 id와 count 분리한 리스트 생성
                local reward_id = tonumber(semi_split_list[1])
                local reward_count = semi_split_list[2]
                -- 아이템 개수 초기화 
                if (not max_count_map[reward_id]) then
                    max_count_map[reward_id] = tonumber(reward_count)
                -- 아이템 개수 합산
                else
                    max_count_map[reward_id] = max_count_map[reward_id] + tonumber(reward_count)
                end
            end
        end
    end

    return max_count_map
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PromoteQuestDouble:refresh()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_PromoteQuestDouble:click_okay()
    self.m_buyCb()
    self:close()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_PromoteQuestDouble:click_cancle()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_PromoteQuestDouble)
