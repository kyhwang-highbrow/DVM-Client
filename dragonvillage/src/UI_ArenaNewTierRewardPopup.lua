local PARENT = UI

-------------------------------------
-- class UI_ArenaNewTierRewardPopup
-------------------------------------
UI_ArenaNewTierRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewTierRewardPopup:init()
    self.m_uiName = 'UI_ArenaNewTierRewardPopup'
    local vars = self:load('arena_new_tier_attain_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewTierRewardPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewTierRewardPopup:initUI()
    local vars = self.vars
    local table_arena_rank = TABLE:get('table_arena_new_rank')
    local struct_rank = StructArenaNewRankReward()
    local l_rank = struct_rank:getRankRewardList()
    local titleStr = Str('입문자')
    local highestTierRewardId = 99

    for i = 1, #l_rank do
        local item = l_rank[i]
        if (item['tier_id'] and tonumber(item['tier_id']) and not g_arenaNewData:hasArchiveReward(item['tier_id'])) then
            highestTierRewardId = math.min(highestTierRewardId, tonumber(item['tier_id']))
            titleStr = item['t_name']
        end
    end

    if (highestTierRewardId > 0) then
        titleStr = Str(titleStr)
    end

    if (vars['tierLabel']) then vars['tierLabel']:setString(titleStr) end

    local itemsList = g_arenaNewData.m_tierRewardInfo
    local finalList = self:combineItems(itemsList)
    local total_cnt = table.count(finalList)

	if (total_cnt == 1) then
		-- 보상 아이템 표기
		local t_item = itemsList[1]
		local icon = IconHelper:getItemIcon(t_item['item_id'])
		vars['rewardNode']:addChild(icon)
		local count = comma_value(t_item['count'])
		vars['rewardLabel']:setString(count)

	-- 패치후 최초 업데이트 시점을 위한 분기 처리 (나중에 정리)
	else
		for idx, t_item in ipairs(finalList) do
			local item_id = t_item['item_id']
			local item_cnt = t_item['count']
			local card = UI_ItemCard(tonumber(item_id), item_cnt)
			vars['rewardTempNode']:addChild(card.root)

			local pos_x = UIHelper:getCardPosX(total_cnt, idx)
			card.root:setPositionX(pos_x)
		end
        vars['rewardFrameNode']:setVisible(false)
	end

    -- 티어아이콘
    local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
    if (struct_user_info) then
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewTierRewardPopup:combineItems(itemsList)
    local finalList = {}
	for idx, t_item in ipairs(itemsList) do
        local item_id = t_item['item_id']
        local count = t_item['count']
        local hasAttached = false

	    for i, v in ipairs(finalList) do
            if (v['item_id'] == t_item['item_id']) then
                v['count'] = v['count'] + tonumber(count)
                hasAttached = true
            end
        end

        if (not hasAttached) then
            table.insert(finalList, t_item)
        end
    end

    return finalList
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewTierRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewTierRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ArenaNewTierRewardPopup)
