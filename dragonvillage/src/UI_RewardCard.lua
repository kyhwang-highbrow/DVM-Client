local PARENT = UI_ItemCard

-------------------------------------
-- class UI_RewardCard
-------------------------------------
UI_RewardCard = class(PARENT, {
		m_itemType = 'str',
     })

-------------------------------------
-- function init
-- @param1 type : item type -> 스트링으로 받고 setItemData 에서 item_id 로 바꿔준다
-------------------------------------
function UI_RewardCard:init(type, count)
	self.m_itemType = type

	-- ItemCard도 항상 swallowTouch 하지 않는게 좋을거 같은데... 고려중
	self.root:setSwallowTouch(false)
end

-------------------------------------
-- function setItemData
-------------------------------------
function UI_RewardCard:setItemData()
	self:findRewardItemId()

	PARENT.setItemData(self)
end

-------------------------------------
-- function findRewardItemId
-------------------------------------
function UI_RewardCard:findRewardItemId()
	local reward_type = self.m_itemID
	local reward_item = TableItem():getRewardItem(reward_type)
	
	self.m_itemID = reward_item['item']
end