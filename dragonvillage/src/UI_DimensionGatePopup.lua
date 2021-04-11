local PARENT = UI

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
-------------------------------------
-- class UI_BattlePassInfoPopup
-- @brief 
-------------------------------------
UI_DimensionGateInfoPopup = class(PARENT,{
    })
 
-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateInfoPopup:init()
	self.m_uiName = 'UI_DimensionGateInfoPopup'

    local vars = self:load('dmgate_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DimensionGateInfoPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateInfoPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DimensionGateInfoPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DimensionGateInfoPopup:refresh()
end




--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- class UI_DimensionGateBlessPopup
-- @brief 
-------------------------------------
UI_DimensionGateBlessPopup = class(PARENT,{
    m_titleNode = '',

    m_scrollNode = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateBlessPopup:init()
    self.m_uiName = 'UI_DimensionGateBlessPopup'
    local vars = self:load('dmgate_bless_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_titleNode = vars['blessLabel']
    self.m_scrollNode = vars['scrollNode']

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DimensionGateBlessPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateBlessPopup:initUI()

    local buff_list = g_dimensionGateData:getBuffList(DIMENSION_GATE_ANGRA)
    self.m_titleNode:setString('시즌 효과')


    local function create_callback(ui, data)

    end

    -- -- 
    local tableview = UIC_TableView(self.m_scrollNode)
    tableview:setCellSizeToNodeSize(true)
    tableview:setGapBtwCells(5)
    tableview:setCellUIClass(UI_DimensionGateBlessPopupItem, create_callback)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setAlignCenter(true)
    tableview:setItemList(buff_list, true)
    if #buff_list <= 2 then
        tableview.m_scrollView:setTouchEnabled(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DimensionGateBlessPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DimensionGateBlessPopup:refresh()
end



-------------------------------------
-- class UI_DimensionGateBlessPopup
-- @brief 
-------------------------------------
UI_DimensionGateBlessPopupItem = class(UI, ITableViewCell:getCloneTable(),{
    m_buffNode = '',
    m_buffInfoLabel = '',
})


-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateBlessPopupItem:init(data)
    ccdump(data)
    self.m_uiName = 'UI_DimensionGateBlessPopupItem'
    --self.m_spriteName = 'res/ui/icons/buff/${spriteName}.png'
    local vars = self:load('dmgate_bless_popup_item.ui')

    self.m_buffNode = vars['buffNode']
    self.m_buffInfoLabel = vars['buffInfoLabel']
    
    self.m_buffInfoLabel:setString(data['t_desc'])
    self.m_buffInfoLabel:setTextColor(data['color'])
    --resource_name =  data['res_icon']--string.gsub(self.m_spriteName, '${spriteName}', tostring(data['type_id']))

    local icon = cc.Sprite:create( data['res_icon'])
    icon:setDockPoint(CENTER_POINT)
    icon:setAnchorPoint(CENTER_POINT)
    self.m_buffNode:addChild(icon)
end
    


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

UI_DimensionGateItemRewardPopup = class(PARENT, {
    m_parentData = '',
    m_closeBtn = '',
    m_itemNodes = '',
    m_itemMenues = '',
    m_itemCompleteNotes = '',


    m_checkBoxSpriteName = '',
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

    self.m_checkBoxSpriteName = 'res/ui/icons/stage_box_check.png'

    self.m_closeBtn = vars['closeBtn']
    
    self.m_itemNodes = {}
    self.m_itemMenues = {}
    self.m_itemCompleteNotes = {}
    
    local itemNum = 1
    while(vars['itemMenu' .. tostring(itemNum)]) do
        self.m_itemMenues[itemNum] = vars['itemMenu' .. tostring(itemNum)]
        self.m_itemNodes[itemNum] = vars['itemNode' .. tostring(itemNum)]
        self.m_itemCompleteNotes[itemNum] = vars['completeNode' .. tostring(itemNum)]
        itemNum = itemNum + 1
    end

    --if (#self.m_itemMenues ~= #self.m_itemNodes) then error('') end
end


function UI_DimensionGateItemRewardPopup:initUI()
end


function UI_DimensionGateItemRewardPopup:initButton()
    self.m_closeBtn:registerScriptTapHandler(function() self:click_closeBtn() end)
end


function UI_DimensionGateItemRewardPopup:refresh()

    local itemCount = #self.m_parentData

    if(itemCount > 1) then
        for i = 1, itemCount do
            self:create_itemCard(self.m_parentData[i]['item'], i)
        end
    else
        self:create_itemCard(self.m_parentData[1]['item'], 1)
        
        for i = 2, #self.m_itemMenues do
            self.m_itemMenues[i]:setVisible(false)
        end

        self.m_itemMenues[1]:setPositionX(self.m_itemMenues[2]:getPositionX())
    end
    

    -- local itemNum = #self.m_parentData
    -- local menuNum = #self.m_itemMenues
    -- local diffNum = (menuNum - itemNum)

    -- for i = diffNum, menuNum do 
    --     self.m_itemMenues[i]:setVisible(false)
    -- end

    -- for i = 1, itemNum do
    --     self:create_itemCard(self.m_parentData[i]['item'], i)            
    -- end

    -- -- TODO : 임시 재배치. 자동으로 배치되도록 수정 필요
    -- if itemNum == 1 then
    --     self.m_itemMenues[1]:setPositionX(self.m_itemMenues[2]:getPositionX())
    -- end

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

    if(g_dimensionGateData:isStageRewarded(self.m_parentData[index]['stage_id'])) then
        self.m_itemCompleteNotes[index]:setVisible(true)
        -- local checkBoxSprite = cc.Sprite:create(self.m_checkBoxSpriteName)
        -- if (checkBoxSprite) then
        --     --checkBoxSprite:setPosition(self.m_itemNodes[index]:getPosition())
        --     --checkBoxSprite:setScale(size)
            
	    --     checkBoxSprite:setDockPoint(CENTER_POINT)
	    --     checkBoxSprite:setAnchorPoint(CENTER_POINT)
        --     --checkBoxSprite:setContentSize(size)
        --     checkBoxSprite:setScale(2)
        --     --checkBoxSprite:setDockPoint(cc.p(0.5, 0.5))
        --     --checkBoxSprite:setAnchorPoint(cc.p(0.5, 0.5))
        --     self.m_itemNodes[index]:addChild(checkBoxSprite)
        -- end
    end
end