local PARENT = UI

-------------------------------------
-- class UI_ArenaNewDailyReward
-- @brief 
-------------------------------------
UI_ArenaNewDailyReward = class(PARENT,{
    m_remainNextScore = 'number',

    m_myTierRewardItem = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewDailyReward:init(remain_score)
	self.m_uiName = 'UI_ArenaNewDailyReward'
    self.m_remainNextScore = remain_score

    local vars = self:load('arena_new_scene_popup_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewDailyReward')

    vars['rewardBtn']:registerScriptTapHandler(function() self:click_dailyRewardBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewDailyReward:initUI()
    local vars = self.vars
    local struct_rankReward = StructArenaNewRankReward()
    local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
    local l_rank_reward = struct_rankReward:getRankRewardList()
    local rewardable_tier_item
    local finalList = {}

    for i, v in ipairs(l_rank_reward) do
        -- 입문자는 버리기
        if (v['tier_id'] ~= 99) then
            table.insert(finalList, v)
        end

        if (struct_user_info.m_tier == v['tier']) then
            rewardable_tier_item = v
            self.m_myTierRewardItem = rewardable_tier_item
            index = i
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

    local idx
    for i, data in ipairs(table_view.m_itemList) do
        if (data['data']) then
            if (data['data']['tier'] == struct_user_info.m_tier) then
                idx = i
                break
            end
        end
    end

    table_view:relocateContainerFromIndex(idx)
    
    -- 현재 티어아이콘
    vars['tierIconNode']:removeAllChildren()
    local icon = struct_user_info:makeTierIcon(nil, 'big')
    vars['tierIconNode']:addChild(icon)

    -- 티어 이름
    local tier_name = struct_user_info:getTierName()
    vars['tierLabel']:setString(tier_name)

    vars['infoLabel']:setString(Str('{1}점을 더 획득하면 다음 티어 보상을 획득 할 수 있어요!', self.m_remainNextScore))
    
    if (rewardable_tier_item) then
        if (rewardable_tier_item['tier'] == 'legend') then
            self:setRewardItem(rewardable_tier_item)

        elseif (rewardable_tier_item['tier'] == 'beginner') then
            vars['infoMenu']:setVisible(true)
            vars['rewardMenu']:setVisible(false)
            
        else
            self:setRewardItem(rewardable_tier_item, struct_user_info)

        end
    end
end

-------------------------------------
-- function setRewardItem
-------------------------------------
function UI_ArenaNewDailyReward:setRewardItem(rewardable_tier_item, struct_user_info)
    -- 획득 가능 보상 계산
    local total_gold = 0
    local custom_item_id
    local custom_item_count
    local vars = self.vars

    if not isNullOrEmpty(rewardable_tier_item['daily_gold_rate']) then
        total_gold = tonumber(rewardable_tier_item['daily_gold_rate']) * struct_user_info:getRP()
    end

    local l_reward = g_itemData:parsePackageItemStr(rewardable_tier_item['daily_reward'])

    if (l_reward and #l_reward > 0) then
        custom_item_id = l_reward[1]['item_id']
        custom_item_count = comma_value(l_reward[1]['count'])
    end

    -- 획득 가능 보상
    -- 골드 비율 x 승점
    local icon = UI_ItemCard(700002, total_gold)
    vars['itemNode1']:addChild(icon.root)

    -- 연마석
    icon = UI_ItemCard(custom_item_id, custom_item_count)
    vars['itemNode2']:addChild(icon.root)


    if (g_arenaNewData.m_dailyRewardReceived) then
        --vars['rewardBtn']:setEnabled(false)
    else
        vars['rewardBtn']:setEnabled(true)
    end
end

-------------------------------------
-- function setRewardItem
-------------------------------------
function UI_ArenaNewDailyReward:click_dailyRewardBtn()
    function finish_cb(ret)
        self:close()
        ret["reward_info"] = {{count=1, item_id=704900}, {count=1200, item_id=700002}}
        UI_ArenaNewDailyRewardConfirm(ret['reward_info'], self.m_myTierRewardItem)
        --UI_ArenaNewDailyRewardToast(ret['reward_info'])
    end

    g_arenaNewData:request_dailyReward(finish_cb)
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

    local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
    local is_on_range = struct_user_info.m_tier == tierInfo['tier']

    vars['meSprite']:setVisible(is_on_range)
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




-------------------------------------
-- class UI_ArenaNewDailyRewardListItem
-------------------------------------
UI_ArenaNewDailyRewardConfirm = class(UI, {
    m_rewardData = 'table',

    m_rankInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewDailyRewardConfirm:init(data, rank_info)
    local vars = self:load('arena_new_scene_popup_reward_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_rewardData = data
    self.m_rankInfo = rank_info

    self:initUI()

    self:setCurrntReward()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewDailyRewardConfirm:initUI()
    local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)


    local my_rank_item = UI_ArenaNewDailyRewardListItem(self.m_rankInfo)
    vars['meNode']:addChild(my_rank_item.root)
end


-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ArenaNewDailyRewardConfirm:click_okBtn()
    UI_ArenaNewDailyRewardToast(self.m_rewardData)
    self:close()
end

-------------------------------------
-- function showCurrntReward
-------------------------------------
function UI_ArenaNewDailyRewardConfirm:setCurrntReward()
    --if (not item_list) then return end
    -- 현재 보상 정보 파싱
    local vars = self.vars
    local start_posX
    local place_distance
    local item_list = self.m_rewardData
    local item_count = #item_list

    
    for idx, t_item in ipairs(item_list) do
        -- 정보 입력
        local item_id = t_item['item_id']
        local itemIcon = UI_ItemCard(item_id, t_item['count'])
        vars['itemNode' .. idx]:removeAllChildren(true)
        vars['itemNode' .. idx]:addChild(itemIcon.root)
    end
end





-------------------------------------
-- class UI_ArenaNewDailyRewardListItem
-------------------------------------
UI_ArenaNewDailyRewardToast = class(UI, {
    m_rewardData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewDailyRewardToast:init(data)
    local vars = self:load('popup_toast_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_rewardData = data

    self.root:setPositionY(100)

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewDailyRewardToast:initUI()
	-- body    
    local vars = self.vars
    self.root:stopAllActions()
    self:setOpacityChildren(true)
    self:setCurrntReward()

    -- 등장 연출
	doAllChildren(self.root, function(child) child:setCascadeOpacityEnabled(true) end)

    self.root:setOpacity(0)
    local fadein = cc.FadeIn:create(0.1) 
    local delay = cc.DelayTime:create(0.5)
	local fadeout = cc.FadeOut:create(0.3)
    cca.runAction(self.root, cc.Sequence:create(fadein, delay, fadeout, cc.CallFunc:create(function() self:close() end)))
end

-------------------------------------
-- function showCurrntReward
-------------------------------------
function UI_ArenaNewDailyRewardToast:setCurrntReward()
    --if (not item_list) then return end
    -- 현재 보상 정보 파싱
    local vars = self.vars
    local start_posX
    local place_distance
    local item_list = self.m_rewardData
    local item_count = #item_list

    vars['rewardNode']:removeAllChildren(true)

    for _, t_item in ipairs(item_list) do
        -- 정보 입력
        local item_id = t_item['item_id']
        local itemIcon = UI_ItemCard(item_id, t_item['count'])
        vars['rewardNode']:addChild(itemIcon.root)

        if (not start_posX) then
            local width = itemIcon.root:getContentSize()['width']
            place_distance = width / 2 + 5
            
            start_posX = - place_distance

        else
            start_posX = place_distance  

        end

        itemIcon.root:setPositionX(start_posX)
    end
end
