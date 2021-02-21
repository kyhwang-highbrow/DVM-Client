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
    local struct_rank = StructArenaNewRankReward(table_arena_rank, true)
    local l_rank = struct_rank:getRankRewardList()
    local titleStr = Str('입문자')
    local highestTierRewardId = -1

    for i = 1, #l_rank do
        local item = l_rank[i]
        if (item['tier_id'] and g_arenaNewData:hasArchiveReward(item['tier_id'])) then
            highestRewardTierId = math.min(highestRewardTierId, item['tier_id'])
            titleStr = item['t_name']
        end
    end

    if (highestTierRewardId > 0) then
        titleStr = Str(titleStr)
    end

    if (vars['tierLabel']) then vars['tierLabel']:setString(titleStr) end

    local itemsList = g_arenaNewData.m_tierRewardInfo
    local total_cnt = table.count(itemsList)
	if (total_cnt == 1) then
		-- 보상 아이템 표기
		local t_item = itemsList[1]
		local icon = IconHelper:getItemIcon(t_item['item_id'])
		vars['rewardNode']:addChild(icon)
		local count = comma_value(t_item['count'])
		vars['rewardLabel']:setString(count)

	-- 패치후 최초 업데이트 시점을 위한 분기 처리 (나중에 정리)
	else
		for idx, t_item in ipairs(itemsList) do
			local item_id = t_item['item_id']
			local item_cnt = t_item['count']
			local card = UI_ItemCard(item_id, item_cnt)
			vars['rewardTempNode']:addChild(card.root)

			local pos_x = UIHelper:getCardPosX(total_cnt, idx)
			card.root:setPositionX(pos_x)
		end
	end

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
