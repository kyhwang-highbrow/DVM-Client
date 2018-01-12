local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumClanRankRewardItem
-------------------------------------
UI_ColosseumClanRankRewardItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumClanRankRewardItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('colosseum_reward_item_clan.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumClanRankRewardItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumClanRankRewardItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumClanRankRewardItem:refresh()
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
