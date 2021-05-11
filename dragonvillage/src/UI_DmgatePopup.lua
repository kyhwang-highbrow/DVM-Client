local PARENT = UI

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- class UI_DmgateInfoBtnPopup
-- @brief 
----------------------------------------------------------------------
UI_DmgateInfoBtnPopup = class(PARENT, {})
 
----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateInfoBtnPopup:init()
	self.m_uiName = 'UI_DmgateInfoBtnPopup'

    local vars = self:load('dmgate_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DmgateInfoBtnPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- class UI_DmgateBlessBtnPopup
-- @brief 
----------------------------------------------------------------------
UI_DmgateBlessBtnPopup = class(PARENT,{
    m_titleNode = '',

    m_scrollNode = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DmgateBlessBtnPopup:init()
    self.m_uiName = 'UI_DmgateBlessBtnPopup'
    local vars = self:load('dmgate_bless_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_titleNode = vars['blessLabel']
    self.m_scrollNode = vars['scrollNode']

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DmgateBlessBtnPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DmgateBlessBtnPopup:initUI()
    self.m_titleNode:setString(Str('시즌 효과'))
    self:addBlessTableView(self.m_scrollNode)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DmgateBlessBtnPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DmgateBlessBtnPopup:refresh()
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_DmgateBlessBtnPopup:addBlessTableView(scroll_node)
    local buff_list = g_dmgateData:getBuffList(DIMENSION_GATE_ANGRA)

    if (not buff_list) or (#buff_list <= 0) then return false end

    local function create_callback(ui, data)
    end
    
    local tableview = UIC_TableView(scroll_node)
    tableview:setCellSizeToNodeSize(true)
    tableview:setGapBtwCells(5)
    tableview:setCellUIClass(UI_DmgateBlessItem, create_callback)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setAlignCenter(true)
    tableview:setItemList(buff_list, true)
    if #buff_list <= 2 then
        tableview.m_scrollView:setTouchEnabled(false)
    end

    return true
end

-------------------------------------
-- class UI_DmgateBlessBtnPopup
-- @brief 
-------------------------------------
UI_DmgateBlessItem = class(UI, ITableViewCell:getCloneTable(),{
    m_buffNode = '',
    m_buffInfoLabel = '',
})


-------------------------------------
-- function init
-------------------------------------
function UI_DmgateBlessItem:init(data)

    self.m_uiName = 'UI_DmgateBlessItem'
    --self.m_spriteName = 'res/ui/icons/buff/${spriteName}.png'
    local vars = self:load('dmgate_bless_popup_item.ui')

    self.m_buffNode = vars['buffNode']
    self.m_buffInfoLabel = vars['buffInfoLabel']
    
    self.m_buffInfoLabel:setString(data['t_desc'])
    self.m_buffInfoLabel:setTextColor(data['color'])
    --resource_name =  data['res_icon']--string.gsub(self.m_spriteName, '${spriteName}', tostring(data['type_id']))

    local icon_path = isNullOrEmpty(data['res_icon']) and 'res/ui/icons/skill/skill_empty.png' or data['res_icon']
    local icon = cc.Sprite:create(icon_path)
    if (icon) then
        icon:setDockPoint(CENTER_POINT)
        icon:setAnchorPoint(CENTER_POINT)
        self.m_buffNode:addChild(icon)
    end
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- class UI_DmgateSeasonResetPopup
----------------------------------------------------------------------
UI_DmgateSeasonResetPopup = class(PARENT, {
    m_modeId = 'number',

    m_seasonMenu = 'cc.Menu',   -- 시즌 초기화시 보여줄 메뉴
    m_openMenu = 'cc.Menu',     -- 상층 개방시 보여줄 메뉴

    --m_seasonEffectMenu = 'cc.Menu', -- 시즌효과를 보여줄 메뉴
    m_scrollNode = 'cc.Node',   -- 시즌 효과 아이템 배치를 위한 아이템 노드
})


----------------------------------------------------------------------
-- function init
-- param mode_id 차원문 별로 구분하기 위한 index id (앙그라 1, 마누스 2, ...)
----------------------------------------------------------------------
function UI_DmgateSeasonResetPopup:init(mode_id, is_season_reset)
    self.m_modeId = mode_id

    self.m_uiName = 'UI_dmgateSeasonResetPopup'
    local vars = self:load('dmgate_scene_open_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DmgateBlessBtnPopup')

    self.m_seasonMenu = vars['seasonMenu']
    self.m_openMenu = vars['openMenu']
    self.m_scrollNode = vars['scrollNode']

    self:initUI(is_season_reset)
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateSeasonResetPopup:initUI(is_season_reset)

    -- STATE에 따라 보여줄 텍스트 레이블
    if is_season_reset then
        self.m_seasonMenu:setVisible(true)
    else
        self.m_openMenu:setVisible(true)
    end

    -- 시즌 효과 테이블 뷰
    local buff_list = g_dmgateData:getBuffList(self.m_modeId)

    local function create_callback(ui, data) end

    local tableview = UIC_TableView(self.m_scrollNode)
    tableview:setCellSizeToNodeSize(true)
    tableview:setGapBtwCells(5)
    tableview:setCellUIClass(UI_DmgateBlessItem, create_callback)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setAlignCenter(true)
    tableview:setItemList(buff_list, true)
    if #buff_list <= 2  then
        tableview.m_scrollView:setTouchEnabled(false)
    end
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateSeasonResetPopup:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end
----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateSeasonResetPopup:refresh()
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- class UI_DmgateRewardBtnPopup
----------------------------------------------------------------------
UI_DmgateRewardBtnPopup = class(PARENT, {
    m_parentData = '',
    m_closeBtn = '',
    m_itemNodes = '',
    m_itemMenues = '',
    m_itemCompleteNotes = '',


    m_checkBoxSpriteName = '',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRewardBtnPopup:init(data)
    local vars = self:load('dmgate_scene_item_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DmgateRewardBtnPopup')

    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end


----------------------------------------------------------------------
-- function initMember
----------------------------------------------------------------------
function UI_DmgateRewardBtnPopup:initMember(data)
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


----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateRewardBtnPopup:initUI()
end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateRewardBtnPopup:initButton()
    self.m_closeBtn:registerScriptTapHandler(function() self:click_closeBtn() end)
end


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateRewardBtnPopup:refresh()

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
end

----------------------------------------------------------------------
-- function click_closeBtn
----------------------------------------------------------------------
function UI_DmgateRewardBtnPopup:click_closeBtn()
    self:close()
end

----------------------------------------------------------------------
-- function create_itemCard
----------------------------------------------------------------------
function UI_DmgateRewardBtnPopup:create_itemCard(str, index)
    local ITEM_ID = 1
    local ITEM_NUM = 2
    local itemString = seperate(str, ';')
    local item_id = tonumber(itemString[ITEM_ID])
    local item_num = tonumber(itemString[ITEM_NUM])

    local card = UI_ItemCard(item_id, item_num)
    self.m_itemNodes[index]:addChild(card.root)

    if(g_dmgateData:isStageRewarded(self.m_parentData[index]['stage_id'])) then
        self.m_itemCompleteNotes[index]:setVisible(true)
    end
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////

UI_DmgateRankPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankPopup:init(ui_name)
    self.m_uiName = 'UI_DmgateRankPopup'
    local vars = self:load(ui_name)
    UIManager:open(self, UIManager.POPUP)
    
    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DmgateRankPopup')

    self:initUI()
    self:initButton()
    self:refresh()        
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateRankPopup:initUI()
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateRankPopup:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateRankPopup:refresh()
end
