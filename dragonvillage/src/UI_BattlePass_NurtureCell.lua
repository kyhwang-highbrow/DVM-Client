local PARENT = class(UI, ITableViewCell:getCloneTable())

--------------------------------------------------------------------------
-- @classmod UI_BattlePass_NurtureCell
-- @brief 
--------------------------------------------------------------------------
UI_BattlePass_NurtureCell = class(PARENT, {
    m_data = '',


    -- Nodes in ui file
    m_levelSprite = '',
    m_levelLabel = '',

    m_normalRewardBtn = '',
    m_normalClearSprite = '',
    m_normalLockSprite = '',
    m_normalItemNode = '',
    m_normalItemLabel = '',

    m_passRewardBtn = '',
    m_passClearSprite = '',
    m_passLockSprite = '',
    m_passItemNode = '',
    m_passItemLabel = '',

    m_passPurchaseSprite = '',
})
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// pure virtual functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function init 
-- @brief 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:init(data)
    local vars = self:load('battle_pass_nurture_item.ui')
    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end


--------------------------------------------------------------------------
-- @function initUI 
-- @brief 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initUI()
    local vars = self.vars
    local data = self.m_data
    
    local normalItemId, normalItemNum = self:CreateItemCardToNode(self.m_normalItemNode, data['item_normal'])
    local passItemId, passItemNum = self:CreateItemCardToNode(self.m_passItemNode, data['item_pass'])

    -- self:SetItemCellName(vars['itemLabel1'], normalItemId)
    -- self:SetItemCellName(vars['itemLabel2'], passItemId)

    self:SetItemCellName(self.m_normalItemLabel, normalItemNum)
    self:SetItemCellName(self.m_passItemLabel, passItemNum)

    local label = self.m_levelLabel
    label:setString(Str(label:getString(), self.m_data['itemIndex']))
end


--------------------------------------------------------------------------
-- @function initButton 
-- @brief 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initButton()
    self.m_normalRewardBtn:registerScriptTapHandler(function() self:click_normalRewardBtn() end)
    self.m_passRewardBtn:registerScriptTapHandler(function() self:click_passRewardBtn() end)
end



--------------------------------------------------------------------------
-- @function refresh 
-- @brief 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:refresh()
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Init Helper Functions (Local)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function initMember 
-- @brief init function 내부에서 멤버 변수 정의
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initMember(data)
    local vars = self.vars
    self.m_data = data

    -- Node
    self.m_levelSprite = vars['levelSprite']
    self.m_levelLabel = vars['levelLabel']

    self.m_normalRewardBtn = vars['normalRewardBtn']
    self.m_normalClearSprite = vars['normalClearSprite']
    self.m_normalLockSprite = vars['normalLockSprite']
    self.m_normalItemNode = vars['normalItemNode']
    self.m_normalItemLabel = vars['normalItemLabel']

    self.m_passRewardBtn = vars['passRewardBtn']
    self.m_passClearSprite = vars['passClearSprite']
    self.m_passLockSprite = vars['passLockSprite']
    self.m_passItemNode = vars['passItemNode']
    self.m_passItemLabel = vars['passItemLabel']

    self.m_passPurchaseSprite = vars['passPurchaseSprite']
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Getter & Setter
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function SetItemCellName 
-- @brief 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:SetItemCellName(textLabel, item_id)
    textLabel:setString(Str(TableItem:getItemName(item_id)))
end

--------------------------------------------------------------------------
-- @function SetItemCellName 
-- @brief 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:SetItemCellName(textLabel, item_num)
    textLabel:setString(Str('x{1}', comma_value(item_num)))
    -- TODO (YOUNGJIN) : REMOVE IT
    textLabel:setFontSize(18)
end

--------------------------------------------------------------------------
-- @function SetReceivedMarkNormalReward 
-- @brief
-- @todo Check All the cases whether it is possible to twisted btw all these functions
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:SetReceivedMarkNormalReward(bool_value)
    self.m_normalClearSprite:setVisible(bool_value)
    self.m_normalRewardBtn:setEnabled(not bool_value)
    self.m_normalRewardBtn:setVisible(not bool_value)
end

--------------------------------------------------------------------------
-- @function SetReceivedMarkPassReward 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:SetReceivedMarkPassReward(bool_value)
    self.m_passClearSprite:setVisible(bool_value)
    self.m_passRewardBtn:setEnabled(not bool_value)
    self.m_passRewardBtn:setVisible(not bool_value)
end

--------------------------------------------------------------------------
-- @function SetPassLock
-- @param 배틀패스 구매여부 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:SetPassLock(bool_value)
    
--[[
배틀 패스 샀고 노멀 보상 안받음 : rewardBtn:visible true
true 노랑 on   = 
배틀 패스 샀고 노멀 보상 받음 : rewardBtn:visible false
true 노랑 off  =
배틀 패스 안샀고 노멀 보상 안받음 : rewardBtn:visible true
false 노랑 on   = 
배틀 패스 안샀고 노멀 보상 받음 : rewardBtn:visible false
false 노랑 off  = 
]]--
    self.m_passPurchaseSprite:setVisible(bool_value)
    self.m_passRewardBtn:setEnabled(not bool_value)
    
end

--------------------------------------------------------------------------
-- @function SetLevelSpritesVisible 
-- @param 레벨이 되냐 안되냐
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:SetLevelSpritesVisible(bool_value)
    --[[
        레벨 되고 노멀 보상 안받음 : rewardBtn:visible true
        true 노랑 on   = 
        레벨 되고 노멀 보상 받음 : rewardBtn:visible false
        true 노랑 off  =
        레벨 안되고 노멀 보상 안받음 : rewardBtn:visible false
        false 노랑 on   = 
        레벨 안되고 노멀 보상 받음 : rewardBtn:visible false
        false 노랑 off  = 
    ]]--
    self.m_normalLockSprite:setVisible(not bool_value)
    self.m_passLockSprite:setVisible(not bool_value)
    self.m_levelSprite:setVisible(bool_value)

    local isReceived = not self.m_normalClearSprite:isVisible()
    self.m_normalRewardBtn:setVisible(bool_value and isReceived)

    isReceived = not self.m_passClearSprite:isVisible()
    self.m_passRewardBtn:setVisible(bool_value and isReceived)
    

    -- TODO (YOUNGJIN) : Check right function btw setEnabled and setTouchEnabled
    -- TODO (YOUNGJIN) : Check these is required here or is it better to put out these as seperate function? 
    --self.m_passRewardBtn:setEnabled(bool_value)
    --self.m_normalRewardBtn:setEnabled(bool_value)
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Click Button Actions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function click_normalRewardBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:click_normalRewardBtn()
    
    local isLevelRecievable = self.m_levelSprite:isVisible()
    if(isLevelRecievable) then 
        self:SetReceivedMarkNormalReward(true)
    end
end

--------------------------------------------------------------------------
-- @function click_passRewardBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:click_passRewardBtn()
    
    local isLevelRecievable = self.m_levelSprite:isVisible()
    local isPassPurchased = not self.m_passPurchaseSprite:isVisible()
    if isLevelRecievable and isPassPurchased then
        self:SetReceivedMarkPassReward(true)
    end
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Local Functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function CreateItemCardToNode 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:CreateItemCardToNode(node, item_list)
    local ITEM_TYPE = 1
    local ITEM_NUM = 2

    itemStrList = seperate(item_list, ';')

    local itemType = itemStrList[ITEM_TYPE]
    local itemNum = itemStrList[ITEM_NUM]

    local itemId = TableItem:getItemIDFromItemType(itemType) or tonumber(itemType)

    local itemCard = UI_ItemCard(itemId)--, itemNum)
    itemCard:setEnabledClickBtn(false)

    -- TODO (YOUNGJIN) : 적절하지 못한 위치.
    itemCard:SetBackgroundVisible(false)

    node:addChild(itemCard.root)

    return itemId, itemNum
end