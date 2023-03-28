local PARENT = UI_Product

-------------------------------------
-- class UI_ProductSmall
-------------------------------------
UI_StoryDungeonEventShopItem = class(PARENT, {
    m_structProduct = 'StructProduct',
    m_cbBuy = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_StoryDungeonEventShopItem:init(struct_product)
    local vars = self:load('story_dungeon_shop_item.ui')
    self.m_structProduct = struct_product
    self:initItemNodePos()
    self:initUI()
	--self:initButton()
	--self:refresh()
end
