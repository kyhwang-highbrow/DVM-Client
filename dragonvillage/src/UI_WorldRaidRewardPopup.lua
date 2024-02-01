local PARENT = UI

-------------------------------------
-- class UI_WorldRaidRewardPopup
-------------------------------------
UI_WorldRaidRewardPopup = class(PARENT,{
    m_profileFrameId = '',
    m_profileFrameAnimator = 'animator',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidRewardPopup:init(t_info, profile_frame_id)
    self.m_profileFrameId = profile_frame_id or 0

    cclog('self.m_profileFrameId', self.m_profileFrameId)
    self.m_profileFrameAnimator = nil

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
            
            vars['rewardLabel'..i]:setString('')
            if item_type ~= 'profile_frame' then
                vars['rewardLabel'..i]:setString(comma_value(item_cnt))
                vars['rewardNode'..i]:addChild(icon)
            else
                local leader_dragon = g_dragonsData:getLeaderDragon()
                local card = UI_DragonCard(leader_dragon, nil, nil, nil, true)
                vars['rewardNode'..i]:addChild(card.root)
                vars['rewardNode'..i]:addChild(icon)
                self.m_profileFrameAnimator = icon
            end

            item_type = TableItem:getItemType(item_id)
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

-- function initButton
-------------------------------------
-------------------------------------
function UI_WorldRaidRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
end

-------------------------------------
-- function click_equipBtn
-------------------------------------
function UI_WorldRaidRewardPopup:click_equipBtn()
    local vars = self.vars

    -- 소유 중인 프로필 테두리냐?
    if g_profileFrameData:isOwnedProfileFrame(self.m_profileFrameId) == false then
        UIManager:toastNotificationRed(Str('현재 보유 중인 테두리가 아닙니다.'))
        return
    end

    local success_cb = function(ret)
        local origin_scale = self.m_profileFrameAnimator:getScale()
        local scale_up_value = origin_scale * 1.2

        local rotate_to = cc.EaseElasticOut:create(cc.RotateTo:create(0.2, 720), 0.1)
        local scale_up = cc.EaseElasticOut:create(cc.ScaleTo:create(0.2, scale_up_value), 0.1)
        local scale_down = cc.EaseElasticIn:create(cc.ScaleTo:create(0.2, origin_scale), 0.1)
        local call_func = cc.CallFunc:create(function () 
            UIManager:toastNotificationGreen(Str('테두리를 착용하였습니다.'))
        end)
    
        local delay = cc.DelayTime:create(0.1)
        local seq = cc.Sequence:create(rotate_to, delay, scale_up, scale_down, call_func)
    
        --self.m_profileFrameAnimator:stopAllActions()
        self.m_profileFrameAnimator:runAction(seq)

        self.m_profileFrameId = 0
        self:refresh()
    end

    vars['selectEffect1Visual']:setVisible(true)
    vars['selectEffect1Visual']:changeAni('yellow_05', false)
    vars['selectEffect1Visual']:addAniHandler(function() vars['selectEffect1Visual']:setVisible(false) end)

    vars['selectEffect2Visual']:setVisible(true)
    vars['selectEffect2Visual']:changeAni('pack_idle_03', false)
    vars['selectEffect2Visual']:addAniHandler(function() vars['selectEffect2Visual']:setVisible(false) end)

    --g_profileFrameData:request_equip(self.m_profileFrameId, success_cb)
    success_cb()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidRewardPopup:refresh()
    local vars = self.vars

    vars['equipBtn']:setVisible(self.m_profileFrameId > 0)
    vars['okBtn']:setVisible(self.m_profileFrameId == 0)
end

--@CHECK
UI:checkCompileError(UI_WorldRaidRewardPopup)
