local PARENT = UI

-------------------------------------
-- class UI_EventIncarnationOfSinsRewardPopup
-------------------------------------
UI_EventIncarnationOfSinsRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRewardPopup:init(user_info, reward_info)
    local vars = self:load('event_incarnation_of_sins_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventIncarnationOfSinsRewardPopup')

    self:initUI(user_info, reward_info)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRewardPopup:initUI(user_info, reward_info)
    local vars = self.vars
    
    -- 플레이어 정보 받아 그림
    require('UI_EventIncarnationOfSinsRankingTotalTab')
    local rank_ui = UI_EventIncarnationOfSinsRankingTotalTabRankingListItem(user_info)
    
    -- 랭킹 정보
    vars['rankNode']:addChild(rank_ui.root)

    vars['descLabel']:setString(Str('이벤트가 종료되었습니다.'))
    vars['rankLabel']:setString(Str('랭킹'))

    -- 보상 카드
    local interval = 95
    local count = table.count(reward_info)
    local l_pos = getSortPosList(interval, count)

    for i, data in ipairs(reward_info) do
        local item_id = data['item_id']
        local count = data['count']

        local item_card = UI_ItemCard(item_id, count, t_sub_data)
        item_card:setRarityVisibled(true)
        item_card.root:setScale(0.6)
        vars['rewardNode']:addChild(item_card.root)

        local pos_x = l_pos[i]
        item_card.root:setPositionX(pos_x)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventIncarnationOfSinsRewardPopup)
