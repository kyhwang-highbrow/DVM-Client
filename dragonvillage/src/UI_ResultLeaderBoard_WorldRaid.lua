local PARENT = UI_ResultLeaderBoard_IncarnationOfSins
-------------------------------------
-- class UI_ResultLeaderBoard_WorldRaid
-------------------------------------
UI_ResultLeaderBoard_WorldRaid = class(PARENT, {
    })

    
-------------------------------------
-- function setCurrentInfo
-------------------------------------
function UI_ResultLeaderBoard_WorldRaid:setCurrentInfo()
    local vars = self.vars
    local type = self.m_type

    vars['gaugeSprite']:setVisible(false)

    -- 현재 점수
    vars['scoreLabel']:setString(Str('{1}점', comma_value(self.m_cur_score)))     -- 점수
    
    -- 현재 랭킹
    vars['rankLabel']:setString(Str('{1}위', comma_value(self.m_cur_rank)))       -- 랭킹

    -- 보상 아이템
    vars['rewardMenu']:removeAllChildren()

    local cur_reward_data = g_worldRaidData:getPossibleReward(self.m_cur_rank, self.m_cur_ratio)    
    local l_reward_data = g_itemData:parsePackageItemStr(cur_reward_data['sh_reward'])

    -- 소환권 일반 보상은 제거해버림
    if #l_reward_data > 0  then
        table.remove(l_reward_data, #l_reward_data)
    end

    local reward_size = table.count(l_reward_data)
    local icon_size = 150
    local icon_scale = 0.666
    local icon_interval = 5
    local l_ui_pos_list = getSortPosList((icon_size * icon_scale) + icon_interval, reward_size)

    for idx, item_info in ipairs(l_reward_data) do
        local item_id = item_info['item_id']
        local count = item_info['count']
        --local ui = UI_ItemCard(item_id, count)
        local node = IconHelper:getItemIcon(item_id)
        node:setScale(icon_scale)            
        vars['rewardMenu']:addChild(node)
        node:setPositionX(l_ui_pos_list[idx])
    end

    local remain_str, _ = g_worldRaidData:getRemainTimeString()
    vars['remainTimeLabel']:setString(remain_str)
    vars['rewardMenuMenu']:setVisible(#l_reward_data > 0)
    require('UI_ResultLeaderBoard_IncarnationOfSinsListItem')
    if (self.m_tUpperRank) then
        -- 앞 순위 유저
        local ui_upper = UI_ResultLeaderBoard_IncarnationOfSinsListItem(type, self.m_tUpperRank, false)
        if (ui_upper) then            
            vars['upperNode']:addChild(ui_upper.root)
        end
    end

    if (self.m_tLowerRank) then
        -- 뒤 순위 유저
        local ui_lower = UI_ResultLeaderBoard_IncarnationOfSinsListItem(type, self.m_tLowerRank, false) -- type, t_data, is_me,
        if (ui_lower) then            
            vars['lowerNode']:addChild(ui_lower.root)
        end
    end

    if (self.m_tMeRank) then
        -- 자기 자신
        local ui_me = UI_ResultLeaderBoard_IncarnationOfSinsListItem(type, self.m_tMeRank, true)
        if (ui_me) then            
            vars['meNode']:addChild(ui_me.root)
        end
    end

    vars['meNode']:setLocalZOrder(1)
end


-------------------------------------
-- function setChangeInfo
-------------------------------------
function UI_ResultLeaderBoard_WorldRaid:setChangeInfo()
    local vars = self.vars
    local type = self.m_type

    vars['gaugeSprite']:setVisible(false)

    -- 콤마 라벨
    local score_tween_cb = function(number, label)
        local number = math.floor(number)
        label:setString(Str('{1}점', comma_value(number)))
    end
    
    -- 현재 점수
    local score_label = NumberLabel(vars['scoreLabel'], 0, 2)
    score_label:setTweenCallback(score_tween_cb)
    score_label:setNumber(self.m_before_score, true)
    score_label:setNumber(self.m_cur_score, false)


    local rank_tween_cb = function(number, label)
        local number = math.floor(number)
        label:setString(Str('{1}위', number))
    end

    -- 현재 랭킹
    local rank_label = NumberLabel(vars['rankLabel'], 0, 2)
    rank_label:setTweenCallback(rank_tween_cb)
    rank_label:setNumber(self.m_before_rank, true)
    rank_label:setNumber(self.m_cur_rank, false)

     -- + 콤마 라벨
    local diff_tween_cb = function(number, label)
        local number = math.floor(number)
        if (number > 0) then
            label:setString(string.format('+'..comma_value(number)))
        else
            label:setString(string.format(comma_value(number)))
        end
    end
    
    -- 점수 없을 때
    if (self.m_before_score == -1) then
        self.m_before_score = 0    
    end


    -- 랭킹 없을 때
    if (self.m_before_rank == -1) then
        self.m_before_rank = self.m_cur_rank
    end
end


--@CHECK
UI:checkCompileError(UI_ResultLeaderBoard_WorldRaid)
