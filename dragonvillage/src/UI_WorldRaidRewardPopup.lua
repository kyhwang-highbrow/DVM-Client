local PARENT = UI

-------------------------------------
-- class UI_WorldRaidRewardPopup
-------------------------------------
UI_WorldRaidRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidRewardPopup:init(t_info)
    local vars = self:load('world_raid_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_WorldRaidRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(t_info)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidRewardPopup:initUI(t_info)
    local vars = self.vars
        
    local struct_data = t_info['rank']
    local reward_info = t_info['reward_info']

    if reward_info == nil then
        return
    end

    -- 데이터 구성
    local rank_ui = UI_AncientTowerRankListItem(struct_data)
    local str_1 = Str('지난 시즌 개인 랭킹')
    local str_2 = Str('지난 시즌 개인 랭킹 보상')
    
    -- 지난 시즌 랭킹 정보
    vars['rankNode']:addChild(rank_ui.root)
    --vars['rankLabel']:setString(str_1)
    --vars['rankRewardLabel']:setString(str_2)

    -- 보상 정보 (최대 3개로 가정 .. 나중에 테이블뷰로 하자)
    if (reward_info) then
        local reward_cnt = #reward_info
        for i = 1, reward_cnt do
            local item_data = reward_info[i]
            local item_id = item_data['item_id']
            local item_cnt = item_data['count']
            local item_type = TableItem:getItemType(item_id)

            local icon = IconHelper:getItemIcon(item_id, item_cnt)
            vars['rewardNode'..i]:addChild(icon)
            vars['rewardLabel'..i]:setString('')
            if item_type ~= 'profile_frame' then
                vars['rewardLabel'..i]:setString(comma_value(item_cnt))       
            end

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

    -- 내 최종 순위
    local user_info = t_info['user_info']
    if user_info == nil then
        return
    end

    local ui = UI_ClanRaidRankListItem(user_info)
    vars['myRankNode']:addChild(ui.root)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_WorldRaidRewardPopup)
