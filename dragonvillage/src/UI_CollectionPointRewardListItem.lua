local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CollectionPointRewardListItem
-------------------------------------
UI_CollectionPointRewardListItem = class(PARENT, {
        m_collectionPointID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionPointRewardListItem:init(data)
    self.m_collectionPointID = data['req_point']

    local vars = self:load('collection_point_popup_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionPointRewardListItem:initUI()
    local vars = self.vars

    local data = g_collectionData:getCollectionPointInfo(self.m_collectionPointID)

    local icon = cc.Sprite:create('res/ui/icon/item/cash.png')
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    vars['rewardNode']:addChild(icon)

    vars['rewardLabel']:setString(comma_value(data['cash_reward']))

    vars['nameLabel']:setString(Str(data['t_desc']))

    vars['pointLabel']:setString(comma_value(data['req_point']))


end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionPointRewardListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionPointRewardListItem:refresh()
    local vars = self.vars

    local data = g_collectionData:getCollectionPointInfo(self.m_collectionPointID)

    if data['received'] then
        vars['completeSprite']:setVisible(true)
    else
        vars['completeSprite']:setVisible(false)
    end

    vars['rewardBtn']:setEnabled(g_collectionData:canGerCollectionPointReward(self.m_collectionPointID))
end