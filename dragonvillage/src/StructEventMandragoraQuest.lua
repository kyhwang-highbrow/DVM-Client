local PARENT = Structure

-------------------------------------
-- class StructEventMandragoraQuest
-- @brief 이벤트 팝업에 등록된 탭
-------------------------------------
StructEventMandragoraQuest = class(PARENT, {
        qid = 'number',
        open = 'number',
        clear = 'number',
        reward = 'number',

        reward_info = 'string',
    })

local THIS = StructEventMandragoraQuest

-------------------------------------
-- function init
-------------------------------------
function StructEventMandragoraQuest:init(quest_data)
    self:apply(quest_data)
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructEventMandragoraQuest:getClassName()
    return 'StructEventMandragoraQuest'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructEventMandragoraQuest:getThis()
    return THIS
end

-------------------------------------
-- function apply
-------------------------------------
function StructEventMandragoraQuest:apply(t_data)
    for i, v in pairs(self) do
        if (t_data[i] ~= nil) then
            self[i] = t_data[i]
        end
    end
end

-------------------------------------
-- function getCurrentQuestID
-------------------------------------
function StructEventMandragoraQuest:getCurrentQuestID()
    local curr_quest_info = g_mandragoraQuest.m_currentQuestInfo
    return (self['qid'] == curr_quest_info['qid'])
end

-------------------------------------
-- function getRewardItemCard
-------------------------------------
function StructEventMandragoraQuest:getRewardItemCard()
    if (not self['reward_info']) then
        return nil
    end

    local l_str = seperate(self['reward_info'], ';')
    local item_id = tonumber(l_str[1])
    local item_cnt = tonumber(l_str[2])
    local card = UI_ItemCard(item_id, item_cnt)
    card.root:setSwallowTouch(false)
    return card
end

-------------------------------------
-- function getQuestDayText
-- @brief 해당 코드는 항상 퀘스트가 
-- 하루에 하나씩 열린다고 가정함
-------------------------------------
function StructEventMandragoraQuest:getQuestDayText()
    local event_start_time = g_hotTimeData:getEventBeginTime('event_mandraquest')
    local idx = self['qid']
    local time = event_start_time + (60 * 60 * 24 * (idx - 1))
    local date_format = os.date('%m.%d', time)
    return date_format
end

-------------------------------------
-- function getQuestStateText
-------------------------------------
function StructEventMandragoraQuest:getQuestStateText()
    local quest_table = TABLE:get('table_mandragora_quest_event')
    local t_info = quest_table[tonumber(self['qid'])]
    if (not t_info) then
        return ''
    end

    local t_desc = t_info['t_desc']
    local curr_quest_info = g_mandragoraQuest.m_currentQuestInfo
    local is_curr_qid = (curr_quest_info['qid'] == self['qid'])
    local curr_cnt = is_curr_qid and curr_quest_info['cur_value'] or 0
    local clear_cnt = t_info['clear_value_1']
    local main_str = Str(t_desc, clear_cnt) 

    -- 고대의 탑은 퀘스트 텍스트 표시 하드코딩
    -- curr_cnt가 플레이한 층 합계, 플레이한 층 수의 합이 클리어 층 수 이상일 때 (1/1) 표시되도록 함
    if (t_info['key'] == 'clr_tower') then
        if (tonumber(curr_cnt) >= tonumber(clear_cnt)) then
            curr_cnt = 1
            clear_cnt = 1
        else
            curr_cnt = 0
            clear_cnt = 1
        end
    end
    local sub_str = Str('({1}/{2})', curr_cnt, clear_cnt)

    return main_str .. ' ' .. sub_str
end