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

    local cash = 0
    if info.m_userData then
        cash = info.m_userData['cash']
    end

    -- 보상쪽 UI 수정해야함
    --vars['rewardLabel']:setString(comma_value(cash))
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
