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

    g_levelUpPackageData:request_lvuppackInfo(cb_func, nil, self.m_productId)
end