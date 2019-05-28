local PARENT = UI

-------------------------------------
-- class UI_IllusionRewardPopup
-------------------------------------
UI_IllusionRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionRewardPopup:init(t_info, reward_data)
    local vars = self:load('event_dungeon_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_IllusionRewardPopup')

    self:initUI(t_info, reward_data)
    self:initButton()
    self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionRewardPopup:initUI(t_info, reward_data)
    local vars = self.vars
    
    local reward_info = t_info
    
    -- 플레이어 정보 받아옴
    local rank_ui = UI_IllusionRankListItem(t_info, true)
    
    -- 지난 시즌 랭킹 정보
    vars['rankNode']:addChild(rank_ui.root)

    if (reward_info) then
    end

    local dungeon_name = Str('환상 던전')
    vars['descLabel']:setString(Str('{1}이 종료되었습니다.', dungeon_name))
    vars['rankLabel']:setString(Str('{1} 개인 랭킹', dungeon_name))

    -- 보상 카드
    local interval = 95
    local count = #reward_data
    local l_pos = getSortPosList(interval, count)

    for i, data in ipairs(reward_data) do
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
function UI_IllusionRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IllusionRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_IllusionRewardPopup)
