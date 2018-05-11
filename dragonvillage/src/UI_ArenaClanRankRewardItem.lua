local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ArenaClanRankRewardItem
-------------------------------------
UI_ArenaClanRankRewardItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaClanRankRewardItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('colosseum_reward_item_clan.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaClanRankRewardItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaClanRankRewardItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaClanRankRewardItem:refresh()
    local vars = self.vars
    local t_reward_info = self.m_rewardInfo

    vars['rankLabel']:setString(Str(t_reward_info['t_name']))
    
    -- 보상
    do
        local l_str = plSplit(t_reward_info['reward'], ';')
        local item_type = l_str[1]
        local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
        local name = TableItem:getItemName(id)
        local cnt = l_str[2]
        vars['rewardLabel']:setString(Str('{1} x{2}', name, cnt))
    end
end
