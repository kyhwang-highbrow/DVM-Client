local PARENT = UI

-------------------------------------
-- class UI_ArenaNewStepRewardPopup
-------------------------------------
UI_ArenaNewStepRewardPopup = class(PARENT,{
    m_stepNum = 'number',
    m_winCount = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewStepRewardPopup:init(stepNum, winCount)
    self.m_uiName = 'UI_ArenaNewStepRewardPopup'
    self.m_stepNum = stepNum
    self.m_winCount = winCount

    local vars = self:load('arena_new_popup_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewStepRewardPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewStepRewardPopup:initUI()
    local vars = self.vars
    local titleStr = Str('승리{1}회 달성 보상', tostring(self.m_stepNum))
    local subTitle = Str('현재 승리 {@yellow}{1}회{@default}', tostring(self.m_winCount))
    vars['titleLabel']:setString(titleStr)
    vars['winLabel']:setString(subTitle)
    

    -- 보상테이블 받기
    local table_arena_new = TABLE:get('table_arena_new')
    local rewardInfo

    for i = 1, #table_arena_new do
        if (table_arena_new[i] and table_arena_new[i]['id']) then
            if (tonumber(table_arena_new[i]['id']) == self.m_stepNum) then
                rewardInfo = table_arena_new[i]['break_reward']
                break
            end
        end
    end

    if (not rewardInfo) then return end

    local t_reward = plSplit(rewardInfo, ',')

    if (not t_reward or #t_reward <= 0) then return end
    if (#t_reward == 1) then
		-- 보상 아이템 표기
		local t_item = plSplit(t_reward[1], ';')
        if (t_item and #t_item == 2) then
            local icon = IconHelper:getItemIcon(tonumber(t_item[1]), tonumber(t_item[2]))
            vars['itemNode']:addChild(icon)
        end
	else
		for idx, t_item in ipairs(t_reward) do
            local l_item = plSplit(t_item, ';')

            if (l_item and #l_item == 2) then
			    local item_id = tonumber(l_item[1])
                if (not item_id) then
                    item_id = TableItem:getItemIDFromItemType(l_item[1])
                end 

			    local item_cnt = tonumber(l_item[2])
			    local card = UI_ItemCard(item_id, item_cnt)
			    vars['itemNode']:addChild(card.root)
                card.root:setScale(0.5)
			    local pos_x = UIHelper:getCardPosXWithScale(#t_reward, idx, 0.5)
			    card.root:setPositionX(pos_x)
            end
		end
	end

end

-------------------------------------
-- function combineItems
-------------------------------------
function UI_ArenaNewStepRewardPopup:combineItems(itemsList)
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
function UI_ArenaNewStepRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewStepRewardPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ArenaNewStepRewardPopup)
