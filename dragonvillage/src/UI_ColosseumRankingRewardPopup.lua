local PARENT = UI

-------------------------------------
-- class UI_ColosseumRankingRewardPopup
-------------------------------------
UI_ColosseumRankingRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRankingRewardPopup:init(t_info, is_clan)
    local vars = self:load('colosseum_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ColosseumRankingRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(t_info, is_clan)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRankingRewardPopup:initUI(struct_user_info_colosseum)
    local vars = self.vars
    
    local struct_data = t_info['rank']
    local reward_info = t_info['reward_info']

    -- 데이터 구성
    local rank_ui, str_1, str_2
    if (is_clan) then
        rank_ui = UI_ColosseumClanRankListItem(struct_data)
        str_1 = Str('지난 시즌 클랜 랭킹')
        str_2 = Str('지난 시즌 클랜 랭킹 보상')

    else
        rank_ui = UI_ColosseumRankListItem(struct_data)
        str_1 = Str('지난 시즌 개인 랭킹')
        str_2 = Str('지난 시즌 개인 랭킹 보상')

    end
    
    -- 지난 시즌 랭킹 정보
    vars['rankNode']:addChild(rank_ui.root)
    vars['rankLabel']:setString(str_1)
    vars['rankRewardLabel']:setString(str_2)

    -- 보상 정보 (UI상 1개의 자리만 배정되어있다 변경시 고탑 참고)
    if (reward_info) then
        local reward_cnt = #reward_info
        for i = 1, reward_cnt do
            local item_data = reward_info[i]
            local item_id = item_data['item_id']
            local item_cnt = item_data['count']

            local icon = IconHelper:getItemIcon(item_id, item_cnt)
            vars['rewardNode']:addChild(icon)
            vars['rewardLabel']:setString(comma_value(item_cnt))

            local item_type = TableItem:getItemType(item_id)
            if (item_type == 'relation_point') then
                vars['rewardLabel']:setString('')
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRankingRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRankingRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ColosseumRankingRewardPopup)
