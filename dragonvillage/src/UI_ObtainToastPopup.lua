local PARENT = UI

-------------------------------------
-- class UI_ObtainPopup
-------------------------------------
UI_ObtainToastPopup = class(PARENT, {
        m_lOtainItem = 'list',
    })

-------------------------------------
-- function createObtainToastPopup
-------------------------------------
function UI_ObtainToastPopup.createObtainToastPopup(l_item)
    local ui_obtain_toast_popup = UI_ObtainToastPopup(l_item)

    return ui_obtain_toast_popup
end

-------------------------------------
-- function init
-------------------------------------
function UI_ObtainToastPopup:init(l_item)
    local vars = self:load('popup_toast_reward.ui')
	self:setObtainList(l_item)
	self.m_uiName = 'UI_ObtainToastPopup'

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function setReward
-------------------------------------
function UI_ObtainToastPopup:setObtainList(l_item)
    self.m_lOtainItem = l_item
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ObtainToastPopup:initUI()
	local vars = self.vars
	local l_item = self.m_lOtainItem
	if (not l_item) then
		return
	end

	local l_pos = getSortPosList(150, table.count(l_item))--getPosXForCenterSortting(300, -100, #l_item, 150) -- background_width, start_pos, count, list_item_width
	for i, v in ipairs(l_item) do
		local item_id = v['item_id']
		local item_cnt = v['count']
		local ui_item = UI_ItemCard(item_id, item_cnt)
		ui_item.root:setPositionX(l_pos[i])
		--ui_item:setPositionY()

		vars['rewardNode3']:addChild(ui_item.root)
	end

	-- 보상 아이콘도 투명도가 적용되기 위한 코드
	doAllChildren(vars['rewardNode3'], function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ObtainToastPopup:initButton()
    local vars = self.vars

    --vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ObtainToastPopup:refresh()
	local vars = self.vars
end
