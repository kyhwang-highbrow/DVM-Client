local PARENT = UI_Package
-------------------------------------
-- class UI_Package_AdventureBreakthroughAbyss
-------------------------------------
UI_Package_AdventureBreakthroughAbyss = class(PARENT,{
    m_tableView = 'UIC_TableView',
    m_selectProductId = '',
})

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AdventureBreakthroughAbyss:initUI()
    PARENT.initUI(self)
    local l_item_list = g_adventureBreakthroughAbyssPackageData:getAbyssProductIdList()
    self.m_selectProductId = l_item_list[1]
    self:init_tabTableView()
    self:make_stageTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AdventureBreakthroughAbyss:initButton()
    PARENT.initButton(self)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AdventureBreakthroughAbyss:refresh()
    local vars = self.vars    
    
	local struct_product = g_shopDataNew:getProduct('abyss_pass', self.m_selectProductId)
    if (not struct_product) then
        return
    end

    local is_noti_visible = false
    local purchased_num = g_shopDataNew:getBuyCount(struct_product:getProductID())
    local limit = struct_product:getMaxBuyCount()
    self:initEachProduct(index, struct_product)

    is_noti_visible = (struct_product:getPrice() == 0) and (struct_product:isItBuyable())

    if vars['notiSprite'] then 
        vars['notiSprite']:setVisible(is_noti_visible)
    end
end

-------------------------------------
--- @function init_tabTableView
-------------------------------------
function UI_Package_AdventureBreakthroughAbyss:init_tabTableView()
    local node = self.vars['listNode']
    local l_item_list = g_adventureBreakthroughAbyssPackageData:getAbyssProductIdList()

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['selectSprite']:setVisible(data == self.m_selectProductId)
        ui.vars['listBtn']:registerScriptTapHandler(function()
            self.m_selectProductId = data
            self:make_stageTableView()
            self:refresh_tabTableView()
            self:refresh()
        end)

        ui.vars['notiSprite']:setVisible(g_adventureBreakthroughAbyssPackageData:isNotiVisible(data))
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(400, 85)
    table_view:setCellUIClass(UI_Package_AdventureBreakthroughAbyssTabButton, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList3(l_item_list, sort_func)
    self.m_tableView = table_view
end

--------------------------------------------------------------------------
--- @function refresh_tabTableView
--------------------------------------------------------------------------
function UI_Package_AdventureBreakthroughAbyss:refresh_tabTableView()
    local vars = self.vars
    for i , v in pairs(self.m_tableView.m_itemList) do
        local pid = v['data']
        local ui = v['ui']
        ui.vars['selectSprite']:setVisible(pid == self.m_selectProductId)
        ui.vars['notiSprite']:setVisible(g_adventureBreakthroughAbyssPackageData:isNotiVisible(pid))
    end
end

-------------------------------------
-- function make_stage_tableView
-------------------------------------
function UI_Package_AdventureBreakthroughAbyss:make_stageTableView()
    local vars = self.vars
    local node
    local active = g_adventureBreakthroughAbyssPackageData:isActive()

    if (active == true) then
        node = vars['productNodeLong']
    else
        node = vars['productNode']
    end

    node:removeAllChildren()

    local product_id = self.m_selectProductId
    local reward_list = g_adventureBreakthroughAbyssPackageData:getRewardListFromProductId(product_id)

    local function ctor_func(data)
        local index = g_adventureBreakthroughAbyssPackageData:getIndexFromProductId(product_id)
        if (index == 1) then
            data['res_name'] = 'package_adventure_clear_item.ui'
        else
            data['res_name'] = string.format('package_adventure_clear_item_%02d.ui', index)
        end
        data['product_id'] = self.m_selectProductId
        
        return UI_Package_AdventureBreakthroughAbyssItem(data, self)
    end

    local function create_func(ui, data)
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(490, 80+5)
    --table_view:setCellSizeToNodeSize(true)
    table_view:setCellUIClass(ctor_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(reward_list)
    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_AdventureBreakthroughAbyss:click_buyBtn()
    self:setBuyCB(function() 
        local product_id = self.m_selectProductId
        g_adventureBreakthroughPackageData:request_info(product_id, function() 
            self:make_stageTableView()
            self:refresh_tabTableView()
            self:refresh()
        end)
    end)

	local struct_product = g_shopDataNew:getProduct('abyss_pass', self.m_selectProductId)
    if (not struct_product) then
        return
    end

	local function cb_func(ret)
        if struct_product:isOnlyContain('rune_box') then
            ItemObtainResult_ShowMailBox(ret, MAIL_SELECT_TYPE.RUNE_BOX, self.m_obtainResultCloseCb)
        else        
            local is_basic_goods_shown = false
            if self.m_package_name and (string.find(self.m_package_name, 'package_lucky_box')) then
                is_basic_goods_shown = true
            end

            if (self.m_mailSelectType ~= MAIL_SELECT_TYPE.NONE) then
                ItemObtainResult_ShowMailBox(ret, self.m_mailSelectType, self.m_obtainResultCloseCb)
            else
                -- 아이템 획득 결과창
                ItemObtainResult_Shop(ret, is_basic_goods_shown, self.m_obtainResultCloseCb)
            end
        end

        -- 갱신이 필요한 상태일 경우
        if ret['need_refresh'] then
            self:refresh()
            g_eventData.m_bDirty = true

        elseif (self.m_isPopup == true) then
            self:close()
		end

        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end
	end

	struct_product:buy(cb_func)
    --UIManager:toastNotificationRed(('준비 중입니다.'))
end





-------------------------------------
-- class UI_Package_AdventureBreakthroughAbyssItem
-------------------------------------
UI_Package_AdventureBreakthroughAbyssItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'table',
    m_productId = 'number',
    m_ownerUI = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssItem:init(data, owner_ui)
--     {
--         ['stage']=1120607;
--         ['res_name']='package_adventure_clear_item_03.ui';
--         ['product_content']='';
--         ['mail_content']='700001;3000';
--         ['mission1']=1;
--         ['mission2']=1;
--         ['mission3']=1;
-- }
    self.m_data = data
    self.m_productId = data['product_id']
    self.m_ownerUI = owner_ui

    local res_name = data['res_name']
    self:load(res_name)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssItem:initUI()
    local vars = self.vars
    local t_data = self.m_data

    -- 스테이지
    local stage_id = t_data['stage']
    local stage_info = g_adventureData:getStageInfo(stage_id) -- StructAdventureStageInfo
    local str = stage_info:getStageRichName()
    vars['levelLabel']:setString(str)

    local reward_list = {}

    local product_content = ServerData_Item:parsePackageItemStr(t_data['product_content'])
    for i,v in ipairs(product_content) do
        table.insert(reward_list, v)
    end

    local mail_content = ServerData_Item:parsePackageItemStr(t_data['mail_content'])
    for i,v in ipairs(mail_content) do
        table.insert(reward_list, v)
    end

    for i,v in ipairs(reward_list) do
        local card = UI_ItemCard(v['item_id'], v['count'])
        card.root:setSwallowTouch(false)
        vars['itemNode' .. i]:addChild(card.root)
    end
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['linkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssItem:refresh()
    local vars = self.vars
    local data = self.m_data

    do -- 획득한 별 표시
        local stage_id = data['stage']
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local star = stage_info:getNumberOfStars()
        for i = 1, 3 do
            local node = vars['starSprite' .. i]
            if node then
                node:setVisible(i <= star)
            end
        end
    end

    local data_list = g_adventureBreakthroughAbyssPackageData:getDataList()

    -- 구매 전
    if (g_adventureBreakthroughAbyssPackageData:isActive(self.m_productId) == false) then
        -- 버튼 
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setVisible(true)
        vars['rewardBtn']:setEnabled(false)
    -- 구매 후
    else
        local stage_id = data['stage']

        -- 보상을 받았으면
        if (g_adventureBreakthroughAbyssPackageData:isReceivedReward(self.m_productId, stage_id) == true) then
            vars['receiveSprite']:setVisible(true)
            vars['rewardBtn']:setVisible(false)
            vars['linkBtn']:setVisible(false)
        -- 보상을 받지 않았으면
        else
            vars['receiveSprite']:setVisible(false)

            -- 보상을 받을 수 있으면
            if (g_adventureBreakthroughAbyssPackageData:isReceivableReward(self.m_productId, stage_id) == true) then
                vars['rewardBtn']:setVisible(true)
                vars['rewardBtn']:setEnabled(true)
                vars['linkBtn']:setVisible(false)

            -- 보상을 받을 수 없으면
            else
                vars['rewardBtn']:setVisible(false)
                vars['linkBtn']:setVisible(true)
            end
        end
    end

    if vars['rewardBtn']:isEnabled() then
        vars['infoLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
    else
        vars['infoLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
    end
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssItem:click_rewardBtn()
    local data = self.m_data
    local stage_id = data['stage']

    if (g_adventureBreakthroughAbyssPackageData:isReceivableReward(self.m_productId, stage_id) == false) then
        UIManager:toastNotificationRed(Str('별 3개로 클리어 시 보상을 획득할 수 있습니다.'))
        return
    end

    local function cb_func(ret)
        self:refresh()
        self.m_ownerUI:refresh_tabTableView()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_adventureBreakthroughPackageData:request_reward(self.m_productId, stage_id, cb_func)
end

-------------------------------------
-- function click_linkBtn
-- @brief 스테이지 바로가기 버튼
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssItem:click_linkBtn()
    local data = self.m_data
    local stage_id = data['stage']
    UINavigator:goTo('adventure', stage_id)
end