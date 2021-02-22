local PARENT = UI

-------------------------------------
-- class UI_ArenaNewRankingRewardPopup
-------------------------------------
UI_ArenaNewRankingRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRankingRewardPopup:init(t_info, is_clan)
    local vars = self:load('arena_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ArenaNewRankingRewardPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewRankingRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)


    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(t_info, is_clan)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewRankingRewardPopup:initUI(t_info, is_clan)
    local vars = self.vars
    
    local struct_data = t_info['rank']
    local reward_info = t_info['reward_info']

    -- 데이터 구성
    local rank_ui, str_1, str_2
    if (is_clan) then
        rank_ui = UI_ArenaNewRankListItem(struct_data)
        str_1 = Str('지난 시즌 클랜 랭킹')
        str_2 = Str('지난 시즌 클랜 랭킹 보상')

    else
        rank_ui = UI_ArenaNewRankListItem(struct_data)
        str_1 = Str('지난 시즌 개인 랭킹')
        str_2 = Str('지난 시즌 개인 랭킹 보상')
    end

    -- 지난 시즌 랭킹 정보
    vars['rankNode']:addChild(rank_ui.root)
    vars['rankLabel']:setString(str_1)
    vars['rankRewardLabel']:setString(str_2)

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
function UI_ArenaNewRankingRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRankingRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ArenaNewRankingRewardPopup)
