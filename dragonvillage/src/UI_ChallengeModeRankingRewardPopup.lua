local PARENT = UI

-------------------------------------
-- class UI_ChallengeModeRankingRewardPopup
-------------------------------------
UI_ChallengeModeRankingRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeRankingRewardPopup:init(t_info, t_last_data)
    local vars = self:load('challenge_mode_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChallengeModeRankingRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(t_info, t_last_data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModeRankingRewardPopup:initUI(t_info, t_last_data)
    local vars = self.vars
    
    local reward_info = t_info
    
    -- 플레이어 정보 받아옴
    local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
    local rank_ui = UI_ChallengeModeRankingListItem(struct_user_info, t_last_data)
    
    -- 지난 시즌 랭킹 정보
    vars['rankNode']:addChild(rank_ui.root)

    -- 보상 정보 (최대 2개로 가정)
    if (reward_info) then
        local reward_cnt = #reward_info
        -- 보상 없는 경우 생김 (10판 미만인 유저들)
        if (reward_cnt == 0) then
            vars['rankRewardLabel']:setVisible(false)
            vars['rewardNode1']:setVisible(false)
            vars['rewardNode2']:setVisible(false)
            return
        end

        for i = 1, reward_cnt do
            local item_data = reward_info[i]
            local item_id = item_data['item_id']
            local item_cnt = item_data['count']

            local icon = IconHelper:getItemIcon(item_id, item_cnt)
            vars['rewardIconNode'..i]:addChild(icon)
            vars['rewardLabel'..i]:setString(comma_value(item_cnt))

            local item_type = TableItem:getItemType(item_id)
            if (item_type == 'relation_point') then
                vars['rewardLabel'..i]:setString('')
            end
        end

        -- 노드 보상 갯수에 따른 위치 변경
        if (reward_cnt == 2) then
            vars['rewardNode1']:setPositionX(-55)
            vars['rewardNode2']:setPositionX(55)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeRankingRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeRankingRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ChallengeModeRankingRewardPopup)
