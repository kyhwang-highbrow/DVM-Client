local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerClanRewardListItem
-------------------------------------
UI_AncientTowerClanRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerClanRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('tower_clan_rank_reward_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerClanRewardListItem:initUI()
    local t_reward_info = self.m_rewardInfo
    local vars = self.vars

    local my_data = g_clanRankData:getMyRankData(CLAN_RANK['ANCT'])
    if (not my_data) then
        return
    end

    local my_rank = my_data['rank'] 
    
    if (my_rank == -1) then
        return
    end

    -- 받을 수 있는 포상에 하이라이트
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

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerClanRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerClanRewardListItem:refresh()
    local vars = self.vars
    local t_reward_info = self.m_rewardInfo    
    if (vars['rankLabel']) then
        vars['rankLabel']:setString(Str(t_reward_info['t_name']))
    end

    do
        local l_str = plSplit(t_reward_info['reward'], ';')
        local item_type = l_str[1]
        local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
        local name = TableItem:getItemName(id)
        local cnt = l_str[2]
        if (vars['rewardLabel1']) then
            vars['rewardLabel1']:setString(Str('{1}', comma_value(cnt)))
        end
    end
end
