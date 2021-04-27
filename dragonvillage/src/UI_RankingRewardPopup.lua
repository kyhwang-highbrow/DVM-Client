local PARENT = UI

----------------------------------------------------------------------
-- class UI_EventRankingRewardPopup
-- 이벤트 랭킹 보상 팝업
----------------------------------------------------------------------
UI_EventRankingRewardPopup = class(PARENT, {
    m_intervalBtwItem = 'number',
})


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRankingRewardPopup:init(is_daily, ui_eventListItem, user_info, reward_info)
    local vars = self:load('event_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRankingRewardPopup')

    self.m_intervalBtwItem = 95

    self:initUI(is_daily, ui_eventListItem, user_info, reward_info)
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRankingRewardPopup:initUI(is_daily, ui_eventListItem, user_info, reward_info)
    local vars = self.vars

    -- 시즌 랭킹 정보
    local rank_ui = ui_eventListItem(user_info)
    vars['rankNode']:addChild(rank_ui.root)

    -- 텍스트
    if is_daily then -- 일일 보상
        vars['descLabel']:setString(Str('일일 랭킹 보상이 지급되었습니다.'))
        vars['rankLabel']:setString(Str('일일 랭킹'))
    else -- 종합 보상
        vars['descLabel']:setString(Str('이벤트가 종료되었습니다.'))
        vars['rankLabel']:setString(Str('종합 랭킹'))
    end

    local function make_func(data)
        local ui = UI_ItemCard(data['item_id'], data['count'])
        return ui
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.65)
    end


    local tableview = UIC_TableView(vars['rewardNode'])
    tableview:setCellUIClass(make_func, create_func)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableview:setCellSizeToNodeSize()
    tableview:setAlignCenter(true)
    tableview:setItemList(reward_info, true)

    tableview:setScrollLock(true)




    -- -- 보상
    -- local reward_num = table.count(reward_info)
    -- local pos_list = getSortPosList(self.m_intervalBtwItem, reward_num)

    -- for i, data in ipairs(reward_info) do
    --     local item_card = UI_ItemCard(data.item_id, data.count)
    --     item_card:setRarityVisibled(true)
        
    --     item_card.root:setPositionX(pos_list[i])
        
    --     vars['rewardNode']:addChild(item_card.root)
    -- end        
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_EventRankingRewardPopup:initButton()
    self.vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRankingRewardPopup:refresh()
end



