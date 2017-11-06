local PARENT = UI

-------------------------------------
-- class UI_AncientTowerRankingRewardPopup
-------------------------------------
UI_AncientTowerRankingRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRankingRewardPopup:init(struct_user_info_ancient, t_ret)
    local vars = self:load('tower_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AncientTowerRankingRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(struct_user_info_ancient)
    self:initButton()
    self:refresh()

    ItemObtainResult(t_ret)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerRankingRewardPopup:initUI(struct_user_info_ancient)
    local vars = self.vars

    -- 여기서 클랜인지 아닌지 구분하여 처리
    do
        local info = struct_user_info_ancient
    
        -- 지난 시즌 랭킹 정보
        local rank_ui = UI_AncientTowerRankListItem(info)
        vars['rankNode']:addChild(rank_ui.root)

        -- 지난 시즌 랭킹 / 지난 시즌 보상 텍스트
        -- vars['rankLabel']:setString()
        -- vars['rankRewardLabel']:setString()
    end

    -- 보상 정보
    local item_info = info.m_userData
    if (item_info) then
        local reward_cnt = #item_info
        for i = 1, reward_cnt do
            local item_data = item_info[i]
            local item_id = item_data['item_id']
            local item_cnt = item_data['count']

            local icon = IconHelper:getItemIcon(item_id, item_cnt)
            vars['rewardNode'..i]:addChild(icon)
            vars['rewardLabel'..i]:setString(comma_value(item_cnt))

            local item_type = TableItem:getItemType(item_id)
            if (item_type == 'relation_point') then
                vars['rewardLabel'..i]:setString('')
            end
        end

        -- 노드 보상 갯수에 따른 위치 변경
        local max_cnt = 3
        for i = 1, max_cnt do
            if (i > reward_cnt) then
                vars['rewardSprite'..i]:setVisible(false)
            end
        end

        if (reward_cnt == 1) then
            vars['rewardSprite1']:setPositionX(0)

        elseif (reward_cnt == 2) then
            vars['rewardSprite1']:setPositionX(-68)
            vars['rewardSprite2']:setPositionX(68)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerRankingRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerRankingRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_AncientTowerRankingRewardPopup)
