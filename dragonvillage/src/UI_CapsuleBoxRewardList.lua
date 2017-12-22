local PARENT = UI

-------------------------------------
-- class UI_CapsuleBoxRewardList
-------------------------------------
UI_CapsuleBoxRewardList = class(PARENT,{
		m_capsuleBoxData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxRewardList:init(struct_capsule_box)
	local vars = self:load('capsule_box_reward.ui')
	UIManager:open(self, UIManager.POPUP)
	
	self.m_capsuleBoxData = g_capsuleBoxData:getCapsuleBoxInfo()

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CapsuleBoxRewardList')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxRewardList:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxRewardList:initButton()
	local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxRewardList:refresh()
	local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_CapsuleBoxRewardList:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_CapsuleBoxRewardList.makeRewardCell(box_key, struct_reward)
	local ui = UI()
	ui:load('capsule_box_reward_item.ui')

	local vars = ui.vars

	local item_id = struct_reward['item_id']
	local item_cnt = struct_reward['item_cnt']

	local item_card = UI_ItemCard(item_id, item_cnt)
	vars['itemNode']:addChild(item_card.root)

	-- 보상 이름
	local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
	vars['rewardLabel']:setString(name)
	vars['quantityLabel']:setString('n개')

	-- 가능 여부
	local state = struct_reward:getState()
	vars['stateLabel']:setString(state)
	vars['stateLabel']:setTextColor(cc.c4b(45, 255, 107, 255))
	-- cc.c4b(255, 70, 70, 255)

	-- 획득 확률
	local rate = struct_reward['rate']
	vars['chanceLabel']:setString(string.format('%.3f%%', rate))

	return ui
end

--@CHECK
UI:checkCompileError(UI_CapsuleBoxRewardList)
