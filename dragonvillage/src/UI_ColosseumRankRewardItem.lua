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
    local user_info = g_colosseumData.m_playerUserInfo
    local pure_tier, tier_grade = user_info:perseTier()


    if (tier == 'legend') then
        self:load('colosseum_rank_reward_legend.ui')
        self:init_legend(t_data, pure_tier, tier_grade)

    elseif (tier == 'master') then
        self:load('colosseum_rank_reward_master.ui')
        self:init_master(t_data, pure_tier, tier_grade)

    elseif (tier == 'beginner') then
        self:load('colosseum_rank_reward_beginner.ui')
        self:init_beginner(t_data, pure_tier, tier_grade)

    else
        self:load('colosseum_rank_reward_common.ui')
        self:init_common(t_data, pure_tier, tier_grade)
    end
end

-------------------------------------
-- function init_legend
-- @brief 레전드 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_legend(t_data, pure_tier, tier_grade)
    local vars = self.vars
    local t_first = t_data['list'][1]
    local cash = self:getCashCount(t_first)
    vars['legendRewardLabel']:setString(Str('{1}개', comma_value(cash)))
    vars['legendScoreLabel']:setString(Str('{1}점 +', comma_value(t_first['cutline'])))

    -- 본인 등급 표시
    vars['legendRewardSprite']:setVisible(pure_tier == 'legend')
end

-------------------------------------
-- function init_master
-- @brief 마스터 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_master(t_data, pure_tier, tier_grade)
    local vars = self.vars
    for i,v in ipairs(t_data['list']) do
        local cash = self:getCashCount(v)
        vars['masterRewardLabel' .. i]:setString(Str('{1}개', comma_value(cash)))
        vars['masterGradeLabel' .. i]:setString(Str('{1}위 이상', v['rank']))
        vars['masterScoreLabel' .. i]:setString(Str('{1}점 +', comma_value(v['cutline'])))
    end

    -- 본인 등급 표시
    if (pure_tier == 'master') then
        vars['masterRewardSprite']:setVisible(true)
        local pos_y = vars['node' .. tier_grade]:getPositionY()
        vars['masterRewardSprite']:setPositionY(pos_y)
    else
        vars['masterRewardSprite']:setVisible(false)
    end
end

-------------------------------------
-- function init_common
-- @brief 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_common(t_data, pure_tier, tier_grade)
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

    -- 본인 등급 표시
    if (pure_tier == tier) then
        vars['rewardSprite']:setVisible(true)
        local pos_y = vars['node' .. tier_grade]:getPositionY()
        vars['rewardSprite']:setPositionY(pos_y)
    else
        vars['rewardSprite']:setVisible(false)
    end
end

-------------------------------------
-- function init_beginner
-- @brief 입문자 티어 보상
-------------------------------------
function UI_ColosseumRankRewardItem:init_beginner(t_data, pure_tier, tier_grade)
    local vars = self.vars
    local t_first = t_data['list'][1]
    local cash = self:getCashCount(t_first)
    vars['beginnerRewardLabel']:setString(Str('{1}개', comma_value(cash)))
    vars['beginnerScoreLabel']:setString(Str('{1}점 +', comma_value(t_first['cutline'])))

    -- 본인 등급 표시
    vars['beginnerRewardSprite']:setVisible(pure_tier == 'beginner')
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
