local PARENT = UI

-------------------------------------
-- class UI_ColosseumRankingRewardPopup
-------------------------------------
UI_ColosseumRankingRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRankingRewardPopup:init(struct_user_info_colosseum, t_ret)
    local vars = self:load('colosseum_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ColosseumRankingRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(struct_user_info_colosseum)
    self:initButton()
    self:refresh()

    ItemObtainResult(t_ret)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRankingRewardPopup:initUI(struct_user_info_colosseum)
    local vars = self.vars

    local info = struct_user_info_colosseum

    do -- 티어 아이콘
        local icon = info:makeTierIcon(nil, 'big')
        vars['tierNode']:addChild(icon)

        vars['tierLabel']:setString(info:getTierName())
    end

    -- 순위 표시
    vars['rankingLabel']:setString(info:getRankText(true))


    local cash = 0
    if info.m_userData then
        cash = info.m_userData['cash'] or 0
    end
    vars['rewardLabel']:setString(comma_value(cash))
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
