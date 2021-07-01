local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewTierInfoListItem
-------------------------------------
UI_ArenaNewTierInfoListItem = class(PARENT, {
        m_tierInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewTierInfoListItem:init(t_tier_info)
    self.m_tierInfo = t_tier_info
    local vars = self:load('arena_new_popup_tier_reward_item.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewTierInfoListItem:initUI()
    local vars = self.vars
    
    local tierInfo = self.m_tierInfo
    local activeRewardInfo = tierInfo['achieve_reward']

    -- 보상
    local l_reward = g_itemData:parsePackageItemStr(activeRewardInfo)
    if (l_reward and #l_reward > 0) then
        -- 보상은 오직 다이아 뿐임
        local itemCount = comma_value(l_reward[1]['count'])

        vars['rewardLabel']:setString(itemCount)
    else    
        vars['rewardLabel']:setString('-')
    end

    -- 달성 조건
    local scoreMin = comma_value(tierInfo['score_min'])
    vars['scoreLabel']:setString(scoreMin)
    
    -- 티어이름
    vars['tierLabel']:setString(StructUserInfoArenaNew:getTierName(tierInfo['tier']))

    -- 순위나 백분위 제한 있을 때 출력
    local strRankRange = ''
    if (tierInfo['rank_min'] and tierInfo['rank_max'] and tierInfo['rank_min'] ~= '' and tierInfo['rank_max'] ~= '') then
        local isSameRank = tierInfo['rank_min'] == tierInfo['rank_max']

        if (isSameRank) then
            strRankRange = Str('{1}위', tierInfo['rank_min'])
        else
            strRankRange = Str('{1}위', tierInfo['rank_min']) .. " ~ " .. Str('{1}위', tierInfo['rank_max'])
        end
    end

    if (tierInfo['ratio_max'] and tierInfo['ratio_max'] ~= '') then
        strRankRange = Str('상위 {1}%', tierInfo['ratio_max'])
    end

    if (not strRankRange or strRankRange == '') then
        if (not tierInfo['score_min'] or tierInfo['score_min'] == '' or tierInfo['score_min'] <= 0) then
            strRankRange = '-'
        else
            strRankRange = Str('{1}점 이상', tierInfo['score_min'])
        end 
    end

    vars['rankLabel']:setString(strRankRange)

    -- 티어아이콘
    local pure_tier, tier_grade = self:perseTier(tierInfo['tier'])
    if (not pure_tier) then return end
    res = string.format('res/ui/icons/pvp_tier/pvp_tier_s_%s.png', pure_tier)

    local icon = cc.Sprite:create(res)
    if (icon) then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setScale(0.7)
        vars['tierNode']:addChild(icon)
    end

    if (g_arenaNewData:isAchieveRewarded(tierInfo['tier_id'])) then
        vars['clearNode']:setVisible(true)
    else
        vars['clearNode']:setVisible(false)
    end

end

-------------------------------------
-- function perseTier
-- @brief 티어 구분 (bronze_3 -> bronze, 3)
-------------------------------------
function UI_ArenaNewTierInfoListItem:perseTier(tier_str)
    if (not tier_str) then
        return
    end

    local str_list = pl.stringx.split(tier_str, '_')
    local pure_tier = str_list[1]
    local tier_grade = tonumber(str_list[2]) or 0
    return pure_tier, tier_grade
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewTierInfoListItem:initButton()
    local vars = self.vars 
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewTierInfoListItem:refresh()
end