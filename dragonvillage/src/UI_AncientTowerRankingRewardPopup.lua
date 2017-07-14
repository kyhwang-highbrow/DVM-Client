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

    local info = struct_user_info_ancient
    
    -- 점수 표시
    vars['scoreLabel']:setString(info:getScoreText())

    -- 순위 표시
    vars['rankingLabel']:setString(info:getRankText(true))

    local item_info = info.m_userData
    local reward_cnt = 3
    if (item_info) then
        for i = 1, reward_cnt do
            local item_data = item_info[i]
            local item_id = item_data['item_id']
            local item_cnt = item_data['count']

            local icon = IconHelper:getItemIcon(item_id)
            vars['rewardNode'..i]:addChild(icon)

            vars['rewardLabel'..i]:setString(comma_value(item_cnt))
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
