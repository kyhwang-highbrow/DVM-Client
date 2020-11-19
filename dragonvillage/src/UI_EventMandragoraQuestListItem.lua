local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventMandragoraQuestListItem
-------------------------------------
UI_EventMandragoraQuestListItem = class(PARENT, {
        m_questInfo = '',
        m_refreshFunc = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMandragoraQuestListItem:init(quest_info)
    local vars = self:load('event_mandragora_item.ui')
    if (not quest_info) then
        return
    end

    self.m_questInfo = quest_info

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventMandragoraQuestListItem:initUI()
    local vars = self.vars
    vars['swallowTouchMenu']:setSwallowTouch(false)

    local struct_quest = self.m_questInfo

    -- 일차
    local day_text = struct_quest:getQuestDayText()
    vars['dayLabel']:setString(day_text)

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMandragoraQuestListItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMandragoraQuestListItem:refresh()
    local vars = self.vars
    local struct_quest = self.m_questInfo

    -- 퀘스트 설명
    local quest_text = struct_quest:getQuestStateText()
    vars['missionLabel']:setString(quest_text)

    -- 클리어
    local is_clear = (struct_quest['reward'] == 1)
    vars['completeSprite']:setVisible(is_clear)
    vars['clearNode']:setVisible(is_clear)

    -- 닫힘
    local is_open = (struct_quest['open'] == 1)
    vars['lockNode']:setVisible(not is_open)

    -- 진행 단계
    local is_current = struct_quest:getCurrentQuestID()
    vars['selectSprite']:setVisible(is_current)

    -- 보상 받기
    local is_reward = (struct_quest['clear'] == 1 and struct_quest['reward'] == 0)
    vars['readySprite']:setVisible(not is_reward)
    vars['rewardBtn']:setVisible(is_reward)
    vars['rewardBtn']:setEnabled(is_reward)
    
    -- 보상 목록
    local card = struct_quest:getRewardItemCard()
    if (card) then
        vars['rewardNode']:addChild(card.root)
        card:setEnabledClickBtn(not is_reward)
    end
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_EventMandragoraQuestListItem:click_rewardBtn()
    local function refresh_cb()
        if (self.m_refreshFunc) then
            self.m_refreshFunc()
        end
    end
    
    local struct_quest = self.m_questInfo
    local qid = struct_quest['qid']

    g_mandragoraQuest:request_clearReward(qid, refresh_cb)
end