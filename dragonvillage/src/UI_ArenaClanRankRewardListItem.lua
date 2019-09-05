local PARENT = class(UI, ITableViewCell:getCloneTable())


--[[
        ['t_name']='181위~200위';
        ['ratio_min']='';
        ['rank_min']=181;
        ['ratio_max']='';
        ['rank_id']=24;
        ['score_min']=190000;
        ['week']=1;
        ['rank_max']=200;
        ['reward']='gold;400000,cash;4000,ancient;230';
--]]

-------------------------------------
-- class UI_ArenaRankClanRewardListItem
-------------------------------------
UI_ArenaRankClanRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRankClanRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('arena_rank_popup_item_clan_reward.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankClanRewardListItem:initUI()
    local vars = self.vars
    local t_reward_info = self.m_rewardInfo
    
    local rank_name = self.getNameStr(t_reward_info)
    self.vars['rankLabel']:setString(rank_name)

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
        vars['rewardLabel'..i]:setString(Str('{1}', comma_value(cnt)))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankClanRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRankClanRewardListItem:refresh()
end

-------------------------------------
-- function getNameStr
-------------------------------------
function UI_ArenaRankClanRewardListItem.getNameStr(t_reward_info)
    local rank_name = t_reward_info['t_name']
    
    local rank_min = t_reward_info['rank_min']
    local rank_max = t_reward_info['rank_max']

    local rank_str = ''
    if (rank_min == '' and rank_max == '') then
        return Str(t_reward_info['t_name'])
    end

    -- 랭크 타입이 {1}위
    if (rank_min == rank_max) then
        rank_str = Str('{1}위', comma_value(rank_min))
        return rank_str
    end
    
    -- 랭크 타입이 {1}~{2}위
    if (rank_min ~= rank_max) then
        rank_str = Str('{1}~{2}위 ', comma_value(rank_min), comma_value(rank_max))
        return rank_str
    end
    
    return Str(rank_name)
end

