local PARENT = UI

-------------------------------------
-- class UI_ObtainToastPopup
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
    UIManager:open(self, UIManager.NORMAL)
	self.m_uiName = 'UI_ObtainToastPopup'

    -- 등장 액션 지정
    self.root:setOpacity(0)
    self.root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255), cc.DelayTime:create(0.6), cc.FadeTo:create(0.5, 0)))

    self:setObtainList(l_item)
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

	local l_pos = getSortPosList(170, table.count(l_item))
	for i, v in ipairs(l_item) do
		local item_id = v['item_id']
		local item_cnt = v['count']
		local ui_item = UI_ItemCard(item_id, item_cnt)
		ui_item.root:setPositionX(l_pos[i])

		vars['rewardNode']:addChild(ui_item.root)
        ui_item.root:setScale(0)
        ui_item.root:runAction(cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1, 1), 0.3))
	end

	-- 보상 아이콘도 투명도가 적용되기 위한 코드
	doAllChildren(vars['rewardNode'], function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ObtainToastPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ObtainToastPopup:refresh()
	local vars = self.vars
end
