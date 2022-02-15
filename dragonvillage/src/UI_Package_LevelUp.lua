local PARENT = UI_Package

-------------------------------------
-- class UI_Package_LevelUp_01
-------------------------------------
UI_Package_LevelUp_01 = class(PARENT,{
        m_productId = 'number'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUp_01:init(struct_product, is_popup)
    -- 매개변수 초기화
    self.m_isPopup = is_popup or false

    -- UI 세팅
    self:initUISetting()
	
	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton(self.m_isPopup)
    self:refresh()
end

-------------------------------------
-- function initUISetting
-------------------------------------
function UI_Package_LevelUp_01:initUISetting()
    local vars = self:load('package_levelup.ui')
    if (self.m_isPopup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_LevelUp_01')
    end

    self.m_productId = LEVELUP_PACKAGE_PRODUCT_ID
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_LevelUp_01:refresh()
    if (self.m_productId == nil) then
        return
    end
    
    PARENT.refresh(self)

    self:init_tableView()

    local vars = self.vars
    if g_levelUpPackageDataOld:isActive(self.m_productId) then
        vars['completeNode']:setVisible(true)
        vars['contractBtn']:setVisible(false)
        vars['buyBtn']:setVisible(false)
    else
        vars['completeNode']:setVisible(false)
        vars['buyBtn']:setVisible(true)
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_Package_LevelUp_01:init_tableView()
    local vars = self.vars
    vars['productNode']:removeAllChildren()
    vars['productNodeLong']:removeAllChildren()

    local node = vars['productNode']
    if g_levelUpPackageDataOld:isActive(self.m_productId) then
        node = vars['productNodeLong']
        vars['productNode']:setVisible(false)
        vars['productNodeLong']:setVisible(true)
    else
        vars['productNode']:setVisible(true)
        vars['productNodeLong']:setVisible(false)
    end

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        return UI_Package_LevelUpListItem.createItem(data, self.m_productId)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 80+5)
    table_view:setCellUIClass(create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)


    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_item_list = g_levelUpPackageDataOld:getLevelUpPackageTable(self.m_productId)
    table_view:setItemList(l_item_list)

    do -- 정렬
        local function sort_func(a, b)
            local a_value = a['data']['level']
            local b_value = b['data']['level']
            return a_value < b_value
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    -- 보상 받기 가능한 idx로 이동
    local lv, idx = g_levelUpPackageDataOld:getFocusRewardLevel(self.m_productId)
    if lv then
        table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        table_view:relocateContainerFromIndex(idx, false)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_LevelUp_01:click_buyBtn()
	local struct_product = self.m_structProduct

    if (not struct_product) then
        return
    end

	local function cb_func(ret)
        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)


        local finish_func = function()
            -- 구매하면 바로 로비에서 노출되도록 dirty 처리
            g_levelUpPackageDataOld:setDirty(self.m_productId, true)
        end
        -- 갱신
        self:request_serverInfo(finish_func)
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function request_serverInfo
-------------------------------------
function UI_Package_LevelUp_01:request_serverInfo(finish_func)
    local function cb_func()
        self:refresh()
        if (finish_func) then
            finish_func()
        end
    end

    g_levelUpPackageDataOld:request_lvuppackInfo(cb_func, nil, self.m_productId)
end
























-------------------------------------
-- class UI_Package_LevelUp
-------------------------------------
UI_Package_LevelUp = class(PARENT,{

})

-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUp:init(struct_product_list, is_popup, package_name)
    
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_LevelUp:initUI()
    PARENT.initUI(self)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_LevelUp:initButton()
    PARENT.initButton(self)
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_LevelUp:refresh()
    PARENT.refresh(self)

    self:init_tableView()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_Package_LevelUp:init_tableView()
    local vars = self.vars
    local node

    if (g_levelUpPackageData:isActive() == true) then
        node = vars['productNodeLong']
    else
        node = vars['productNode']
    end

    node:removeAllChildren()

    local product_id = self.m_structProduct:getProductID()
    local reward_list = g_levelUpPackageData:getRewardListFromProductId(product_id)

    local function ctor_func(data)
        local index = g_levelUpPackageData:getIndexFromProductId(product_id)

        if (index == 1) then
            data['res_name'] = 'package_levelup_item.ui'
        else
            data['res_name'] = string.format('package_levelup_item_%02d.ui', index)
        end
        data['product_id'] = product_id

        return UI_Package_LevelUpItem(data)
    end

    local function create_func(ui, data)
        --ui.m_productId = product_id
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 80+5)
    --table_view:setCellSizeToNodeSize(true)
    table_view:setCellUIClass(ctor_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    
    table_view:setItemList(reward_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- -- 보상 받기 가능한 idx로 이동
    -- local stage_id, idx = g_adventureClearPackageData03:getFocusRewardStage()
    -- if stage_id then
    --     table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    --     table_view:relocateContainerFromIndex(idx, false)
    -- end
    
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_LevelUp:click_buyBtn()
    self:setBuyCB(function() 
        self:refresh()
    end)

    PARENT.click_buyBtn(self)
end







-------------------------------------
-- class UI_Package_LevelUpItem
-------------------------------------
UI_Package_LevelUpItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'table',
    m_productId = 'number',
})


-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUpItem:init(data)
    self.m_data = data
    self.m_productId = data['product_id']

    local res_name = data['res_name']
    local vars = self:load(res_name)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_LevelUpItem:initUI()
    local vars = self.vars
    local t_data = self.m_data

    -- 레벨 표시
    vars['levelLabel']:setString('Lv.' .. t_data['level'])

    local reward_list = {}

    local product_content = g_itemData:parsePackageItemStr(t_data['product_content'])
    for index, item in ipairs(product_content) do
        table.insert(reward_list, item)
    end

    local mail_content = g_itemData:parsePackageItemStr(t_data['mail_content'])
    for index, item in ipairs(mail_content) do
        table.insert(reward_list, item)
    end

    for index, reward in ipairs(reward_list) do
        local card = UI_ItemCard(reward['item_id'], reward['count'])
        card.root:setSwallowTouch(false)
        vars['itemNode' .. index]:addChild(card.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_LevelUpItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end



-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_LevelUpItem:refresh()
    local vars = self.vars

    -- 구매 전
    if (g_levelUpPackageData:isActive(self.m_productId) == false) then
        -- 버튼 
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setVisible(true)
        vars['rewardBtn']:setEnabled(false)
    -- 구매 후
    else
        local level = self.m_data['level']
        -- 보상을 받았으면
        if (g_levelUpPackageData:isReceivedReward(self.m_productId, level) == true) then
            
            vars['receiveSprite']:setVisible(true)
            vars['rewardBtn']:setVisible(false)
        -- 보상을 받지 않았으면
        else
            vars['receiveSprite']:setVisible(false)

            -- 보상을 받을 수 있으면
            if (g_levelUpPackageData:isReceivableReward(self.m_productId, level) == true) then
                vars['rewardBtn']:setVisible(true)
                vars['rewardBtn']:setEnabled(true)

            -- 보상을 받을 수 없으면
            else
                vars['rewardBtn']:setVisible(true)
                vars['rewardBtn']:setEnabled(false)
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
function UI_Package_LevelUpItem:click_rewardBtn()
    local vars = self.vars

    local data = self.m_data
    local level = data['level']

    local function cb_func(ret)
        self:refresh()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_levelUpPackageData:request_reward(self.m_productId, level, cb_func, nil)
end