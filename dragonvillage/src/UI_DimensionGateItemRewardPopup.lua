PARENT = UI

UI_DimensionGateItemRewardPopup = class(PARENT, {
    m_parentData = '',
    m_closeBtn = '',
    m_itemNodes = '',
    m_itemMenus = '',
})

function UI_DimensionGateItemRewardPopup:init(data)
    local vars = self:load('dmgate_scene_item_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DimensionGateItemRewardPopup')

    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end


function UI_DimensionGateItemRewardPopup:initMember(data)
    local vars = self.vars

    self.m_parentData = data
    self.m_closeBtn = vars['closeBtn']
    
    self.m_itemNodes = {}
    self.m_itemMenus = {}

    local itemNum = 1
    while(vars['itemNode' .. tostring(itemNum)]) do
        self.m_itemNodes[itemNum] = vars['itemNode' .. tostring(itemNum)]
        itemNum = itemNum + 1
    end
    
    itemNum = 1
    while(vars['itemMenu' .. tostring(itemNum)]) do
        self.m_itemMenus[itemNum] = vars['itemMenu' .. tostring(itemNum)]
        itemNum = itemNum + 1
    end
end


function UI_DimensionGateItemRewardPopup:initUI()
end


function UI_DimensionGateItemRewardPopup:initButton()
    self.m_closeBtn:registerScriptTapHandler(function() self:click_closeBtn() end)
end


function UI_DimensionGateItemRewardPopup:refresh()
    local itemCount = #self.m_parentData

    if(itemCount > 0) then
        for i = 1, itemCount do
            self:create_itemCard(self.m_parentData[i]['item'], i)            
        end
    else
        self:create_itemCard(self.m_parentData['item'], 1)
        
        for i = 2, #self.m_itemMenus do
            self.m_itemMenus[i]:setVisible(false)
        end
    end

end

function UI_DimensionGateItemRewardPopup:click_closeBtn()
    self:close()
end

function UI_DimensionGateItemRewardPopup:create_itemCard(str, index)
    local ITEM_ID = 1
    local ITEM_NUM = 2
    local itemString = seperate(str, ';')
    local item_id = tonumber(itemString[ITEM_ID])
    local item_num = tonumber(itemString[ITEM_NUM])

    local card = UI_ItemCard(item_id, item_num)
    self.m_itemNodes[index]:addChild(card.root)
end