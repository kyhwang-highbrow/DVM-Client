local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumMatchRewardItem
-------------------------------------
UI_ColosseumMatchRewardItem = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumMatchRewardItem:init(t_data)
    local tier = t_data['tier']

    local vars = self:load('colosseum_match_reward_item.ui')


    -- 티어 아이콘
    local tier = t_data['tier']
    local tier_icon = StructUserInfoColosseum:makeTierIcon(tier, 'big')
    vars['tierNode']:addChild(tier_icon)

    -- 티어 이름
    local tier_name = StructUserInfoColosseum:getTierName(tier)
    vars['tierLabel']:setString(tier_name)

    local t_first = t_data['list'][1]

    local win_honor = self:getCashCount(t_first['win_reward'])
    vars['rewardLabel1']:setString(Str('+{1} 명예', comma_value(win_honor)))

    local lose_honor = self:getCashCount(t_first['lose_reward'])
    vars['rewardLabel2']:setString(Str('+{1} 명예', comma_value(lose_honor)))
end

-------------------------------------
-- function getCashCount
-------------------------------------
function UI_ColosseumMatchRewardItem:getCashCount(package_item_str)
    local l_item_list = ServerData_Item:parsePackageItemStr(package_item_str)
    local honor = 0

    local honor_item_id = TableItem:getItemIDFromItemType('honor')
    for i,v in pairs(l_item_list) do
        if (honor_item_id == v['item_id']) then
            honor = (honor + v['count'])
        end
    end

    return honor
end
