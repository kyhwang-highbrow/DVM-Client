local PARENT = UI

-------------------------------------
-- class UI_RewardListPopup
-- @brief
-- @waring 직접 인스턴스를 생성해서 사용하지 말 것!
-------------------------------------
UI_RewardListPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_RewardListPopup:init()
    local vars = self:load('adventure_first_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    

    --[[
    local drop_helper = DropHelper(stage_id)
    local l_icon = drop_helper:getDisplayItemIconList_firstReward()
    local l_pos = getSortPosList(150, #l_icon)

    for i,icon in ipairs(l_icon) do
        vars['itemNode']:addChild(icon)
        icon:setPositionX(l_pos[i])
    end

    self:refreshUI()
    --]]

    -- 백키 지정
    --g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_RewardListPopup')

    --self:initButton()
    --self:refresh()

    --self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RewardListPopup:initButton()
    local vars = self.vars
    vars['receiveLabel']:setString(Str('닫기'))
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RewardListPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RewardListPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_RewardListPopup:click_okBtn()
    self:close()
end

-------------------------------------
-- function setTitleText
-------------------------------------
function UI_RewardListPopup:setTitleText(text)
    local vars = self.vars
    vars['titleLabel']:setString(text)
end

-------------------------------------
-- function setDescText
-------------------------------------
function UI_RewardListPopup:setDescText(text)
    local vars = self.vars
    vars['descLabel']:setString(text)
end

-------------------------------------
-- function setRewardItemList
-------------------------------------
function UI_RewardListPopup:setRewardItemList(l_item_list)
    local l_item_card_list = {}

    for i,v in ipairs(l_item_list) do
        local item_id = v['item_id']
        local count = v['count']
        local item_card = UI_ItemCard(item_id, count)
        table.insert(l_item_card_list, item_card)
    end

    self:addRewardItemCardList(l_item_card_list)
end

-------------------------------------
-- function addRewardItemCardList
-------------------------------------
function UI_RewardListPopup:addRewardItemCardList(l_item_card_list)
    local vars = self.vars
    vars['itemNode']:removeAllChildren()

    local l_pos = getSortPosList(150, #l_item_card_list)
    for i,item_card in ipairs(l_item_card_list) do
        vars['itemNode']:addChild(item_card.root)
        item_card.root:setPositionX(l_pos[i])
    end
end

-------------------------------------
-- function setRewardItemCardList_byItemPackageStr
-------------------------------------
function UI_RewardListPopup:setRewardItemCardList_byItemPackageStr(item_package_str)
    local l_item_list = g_itemData:parsePackageItemStr(item_package_str)
    self:setRewardItemList(l_item_list)
end