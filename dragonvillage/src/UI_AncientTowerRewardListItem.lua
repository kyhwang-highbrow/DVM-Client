local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerRewardListItem
-------------------------------------
UI_AncientTowerRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('tower_user_rank_reward_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerRewardListItem:initUI()
    local vars = self.vars
    local t_reward_info = self.m_rewardInfo
    vars['rankLabel']:setString(Str(t_reward_info['t_name']))

    local l_reward = TableClass:seperate(t_reward_info['reward'], ',', true)
    for i = 1, #l_reward do
        local l_str = seperate(l_reward[i], ';')
        local item_type = l_str[1]
        local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)

        local icon = IconHelper:getItemIcon(id)
        
        local table_item = TABLE:get('item')
        local t_item = table_item[id]

        local scale = 0.4
        if (t_item and t_item['type'] == 'relation_point') then
            scale = 0.3
        end
        
        icon:setScale(scale)
        vars['rewardNode'..i]:addChild(icon)

        local name = TableItem:getItemName(id)
        local cnt = l_str[2]
        vars['rewardLabel'..i]:setString(Str('{1}', cnt))
    end


    -- 받을 수 있는 포상에 하이라이트
    local my_rank = g_ancientTowerData.m_nTotalRank
    local my_rank_rate = g_ancientTowerData.m_nTotalRate
    local rank_type = nil
    local rank_value = 1
        
    local rank_min = tonumber(t_reward_info['rank_min'])
    local rank_max = tonumber(t_reward_info['rank_max'])

    local ratio_min = tonumber(t_reward_info['ratio_min'])
    local ratio_max = tonumber(t_reward_info['ratio_max'])

    -- 순위 필터
    if (rank_min and rank_max) then
        if (rank_min <= my_rank) and (my_rank <= rank_max) then
            vars['meSprite']:setVisible(true)
            return
        end
    end

    if (my_rank_rate < 5) then
        return
    end

    -- 비율 필터
    if (ratio_min and ratio_max) then
        if (ratio_min < my_rank_rate) and (my_rank_rate <= ratio_max) then
            vars['meSprite']:setVisible(true)
            return
        end
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerRewardListItem:refresh()
end
