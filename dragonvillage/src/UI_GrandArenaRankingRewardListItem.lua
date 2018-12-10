local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_GrandArenaRankingRewardListItem
-------------------------------------
UI_GrandArenaRankingRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GrandArenaRankingRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('grand_arena_ranking_popup_reward_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GrandArenaRankingRewardListItem:initUI()
    local vars = self.vars

    local t_reward_info = self.m_rewardInfo
    --{
    --    ['tier_id']=16;
    --    ['t_name']='11위~20위';
    --    ['ratio_min']='';
    --    ['rank_min']=11;
    --    ['ratio_max']='';
    --    ['rank_max']=20;
    --    ['week']=1;
    --    ['rank_id']=6;
    --    ['reward']='cash;4200,valor;60';
    --}
    --
    -- rank_id로 정렬

    -- 순위
    vars['rankingLabel']:setString(Str(t_reward_info['t_name']))

    local str = t_reward_info['reward']
    local l_item_str = pl.stringx.split(str, ',')
    local l_item = {}

    local cash = 0
    local valor = 0

    for i,v in pairs(l_item_str) do
        local l_str = pl.stringx.split(v, ';')
        local key = l_str[1]
        local value = l_str[2]

        if (key == 'cash') then
            cash = value
        elseif (key == 'valor') then
            valor = value
        end
    end

    vars['rewardLabel1']:setString(comma_value(cash))
    vars['rewardLabel2']:setString(comma_value(valor))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GrandArenaRankingRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GrandArenaRankingRewardListItem:refresh()
end
