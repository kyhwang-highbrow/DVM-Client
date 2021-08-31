local PARENT = UI

-------------------------------------
-- class UI_EventLFBagRankingRewardPopup
-------------------------------------
UI_EventLFBagRankingRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBagRankingRewardPopup:init(user_info, reward_info, isDaily)
    local vars = self:load('event_lucky_bag_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventLFBagRankingRewardPopup')

    self:initUI(user_info, reward_info, isDaily)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBagRankingRewardPopup:initUI(user_info, reward_info, isDaily)
    local vars = self.vars
    
    -- 플레이어 정보 받아옴
    local rank_ui = UI_EventLFBagRankingListItem(user_info, reward_info)
    
    -- 지난 시즌 랭킹 정보
    vars['rankNode']:addChild(rank_ui.root)

    if (isDaily) then
        vars['descLabel']:setString(Str('일일 랭킹 보상이 지급되었습니다.'))
        vars['rankLabel']:setString(Str('일일 랭킹'))
    else
        vars['descLabel']:setString(Str('이벤트가 종료되었습니다.'))
        vars['rankLabel']:setString(Str('종합 랭킹'))
    end

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
function UI_EventLFBagRankingRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBagRankingRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventLFBagRankingRewardPopup)
