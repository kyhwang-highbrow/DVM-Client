local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumRankRewardItem
-------------------------------------
UI_ColosseumRankRewardItem = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRankRewardItem:init(t_data)
    local tier = t_data['tier']

    if (tier == 'legend') then
        self:load('colosseum_rank_reward_legend.ui')
        self:init_legend(t_data)

    elseif (tier == 'master') then
        self:load('colosseum_rank_reward_master.ui')
        self:init_master(t_data)

    elseif (tier == 'beginner') then
        self:load('colosseum_rank_reward_beginner.ui')
        self:init_beginner(t_data)

    else
        self:load('colosseum_rank_reward_common.ui')
        self:init_common(t_data)
    end
end

-------------------------------------
-- function init_legend
-- @brief 레전드 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_legend(t_data)
    local vars = self.vars
    local t_first = t_data['list'][1]
    local cash = self:getCashCount(t_first)
    vars['legendRewardLabel']:setString(Str('{1}개', comma_value(cash)))
    vars['legendScoreLabel']:setString(Str('{1}점 +', comma_value(t_first['cutline'])))
end

-------------------------------------
-- function init_master
-- @brief 마스터 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_master(t_data)
    local vars = self.vars
    for i,v in ipairs(t_data['list']) do
        local cash = self:getCashCount(v)
        vars['masterRewardLabel' .. i]:setString(Str('{1}개', comma_value(cash)))
        vars['masterGradeLabel' .. i]:setString(Str('{1}위 이상', v['rank']))
        vars['masterScoreLabel' .. i]:setString(Str('{1}점 +', comma_value(v['cutline'])))
    end
end

-------------------------------------
-- function init_common
-- @brief 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_common(t_data)
    local vars = self.vars
    for i,v in ipairs(t_data['list']) do
        local cash = self:getCashCount(v)
        vars['rewardLabel' .. i]:setString(Str('{1}개', comma_value(cash)))
        vars['gradeLabel' .. i]:setString(Str('{1}등급', i))
        vars['scoreLabel' .. i]:setString(Str('{1}점 +', comma_value(v['cutline'])))
    end

    -- 티어 아이콘
    local tier = t_data['tier']
    local tier_icon = StructUserInfoColosseum:makeTierIcon(tier, 'big')
    vars['tierNode']:addChild(tier_icon)

    -- 티어 이름
    local tier_name = StructUserInfoColosseum:getTierName(tier)
    vars['tierLabel']:setString(tier_name)
end

-------------------------------------
-- function init_beginner
-- @brief 입문자 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_beginner(t_data)
    local vars = self.vars
    local t_first = t_data['list'][1]
    local cash = self:getCashCount(t_first)
    vars['beginnerRewardLabel']:setString(Str('{1}개', comma_value(cash)))
    vars['beginnerScoreLabel']:setString(Str('{1}점 +', comma_value(t_first['cutline'])))
end

-------------------------------------
-- function getCashCount
-------------------------------------
function UI_ColosseumRankRewardItem:getCashCount(t_data)
    local package_item_str = t_data['weekly_reward']

    local l_item_list = ServerData_Item:parsePackageItemStr(package_item_str)
    local cash = 0

    local cash_item_id = TableItem:getItemIDFromItemType('cash')
    for i,v in pairs(l_item_list) do
        if (cash_item_id == v['item_id']) then
            cash = (cash + v['count'])
        end
    end

    return cash
end
