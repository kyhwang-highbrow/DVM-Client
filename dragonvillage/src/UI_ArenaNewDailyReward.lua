local PARENT = UI

-------------------------------------
-- class UI_ArenaNewDailyReward
-- @brief 
-------------------------------------
UI_ArenaNewDailyReward = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewDailyReward:init()
	self.m_uiName = 'UI_ArenaNewDailyReward'
    
    local vars = self:load('arena_new_scene_popup_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewDailyReward')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewDailyReward:initUI()
    local vars = self.vars
    local struct_rankReward = StructArenaNewRankReward()

    local l_rank_reward = struct_rankReward:getRankRewardList()
    local finalList = {}

    for i, v in ipairs(l_rank_reward) do
        -- 입문자는 버리기
        if (v['tier_id'] ~= 99) then
            table.insert(finalList, v)
        end
    end

    table.sort(finalList, function(a,b) return a['tier_id'] < b['tier_id'] end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['userRewardNode'])
    table_view:setCellSizeToNodeSize(true)
    table_view:setGapBtwCells(5)

    --table_view.m_defaultCellSize = cc.size(720, 50)
    table_view:setCellUIClass(UI_ArenaNewDailyRewardListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(finalList, true)
end







-------------------------------------
-- class UI_ArenaNewDailyRewardListItem
-------------------------------------
UI_ArenaNewDailyRewardListItem = class(UI, IRankListItem:getCloneTable(), {
        m_tierInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewDailyRewardListItem:init(t_tier_info)
    self.m_tierInfo = t_tier_info
    local vars = self:load('arena_new_scene_popup_reward_item.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewDailyRewardListItem:initUI()
    local vars = self.vars
    
    local tierInfo = self.m_tierInfo
    local activeRewardInfo = tierInfo['daily_reward']
    ccdump(tierInfo)
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

    local l_reward = g_itemData:parsePackageItemStr(activeRewardInfo)
    if (l_reward and #l_reward > 0) then
        -- 보상은 오직 연마석 뿐임
        local item_id = l_reward[1]['item_id']
        local itemCount = comma_value(l_reward[1]['count'])

        vars['rewardLabel2']:setString(itemCount)

        local icon = IconHelper:getItemIcon(item_id)
        icon:setScale(0.4)
        vars['rewardNode2']:addChild(icon)
    else    
        vars['rewardLabel2']:setString('-')
    end

    -- 골드 획득량 배율
    vars['rewardLabel1']:setString(Str('승점') .. 'x' .. tierInfo['daily_gold_rate'])
    local icon = IconHelper:getItemIcon('gold')
    icon:setScale(0.4)
    vars['rewardNode1']:addChild(icon)

    --[[
    
    -- 달성 조건
    local scoreMin = comma_value(tierInfo['score_min'])
    vars['scoreLabel']:setString(scoreMin)

    if (g_arenaNewData:isAchieveRewarded(tierInfo['tier_id'])) then
        vars['clearNode']:setVisible(true)
    else
        vars['clearNode']:setVisible(false)
    end
    ]]
end

-------------------------------------
-- function perseTier
-- @brief 티어 구분 (bronze_3 -> bronze, 3)
-------------------------------------
function UI_ArenaNewDailyRewardListItem:perseTier(tier_str)
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
function UI_ArenaNewDailyRewardListItem:initButton()
    local vars = self.vars 
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewDailyRewardListItem:refresh()
end