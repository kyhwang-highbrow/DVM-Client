local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_TamerCostumeShop
-------------------------------------
UI_TamerCostumeShop = class(PARENT,{
        m_selectTamerID = 'number',
        m_selectCostumeData = 'StructTamerCostume',
        m_selectShopInfo = 'table',

        m_tableViewTD = 'UIC_TableViewTD', -- 코스튬 리스트
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerCostumeShop:init(tamer_id)
    local vars = self:load('tamer_costume.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_selectTamerID = tamer_id

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TamerCostumeShop')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_TamerCostumeShop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_TamerCostumeShop'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('테이머 코스튬 상점')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerCostumeShop:initUI()
    local vars = self.vars
    vars['useBtn']:setEnabled(false)

    self:initTamerTableView()
end

-------------------------------------
-- function initTamerTableView
-- @brief 테이머 리스트
-------------------------------------
function UI_TamerCostumeShop:initTamerTableView()
    local vars = self.vars

    local table_tamer = TableTamer()
    local tamer_list = table.MapToList(table_tamer.m_orgTable)
    table.sort(tamer_list, function(a, b)
        return a['tid'] < b['tid']
    end)

    -- 테이머 선택 버튼 
    local function create_func(ui, data)
        local btn = ui.vars['tamerTabBtn']
        local label = ui.vars['tamerTabLabel']
        local tid = data['tid']
        self:addTabWithLabel(tid, btn, label)
    end

    local node = vars['tamerListNode']
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(240, 100)
    table_view:setCellUIClass(UI_TamerListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local make_item = true
    table_view:setItemList(tamer_list, make_item)

    self:setTab(self.m_selectTamerID)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerCostumeShop:initButton()
    local vars = self.vars
    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)
    vars['finishBtn']:registerScriptTapHandler(function() self:click_finishBtn() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_TamerCostumeShop:onChangeTab(tab, first)
    self.m_selectTamerID = tab
    self.m_selectCostumeData = g_tamerCostumeData:getUsedStructCostumeData(self.m_selectTamerID)

    self:refresh_costumeTableView()
    self:refresh()
    self:refresh_tableData()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerCostumeShop:refresh()
    local vars = self.vars
    local costume_data = self.m_selectCostumeData
    self.m_selectShopInfo = nil

    -- 테이머 코스튬 SD
    local node = vars['tamerSdNode']
    node:removeAllChildren()

    local table_tamer = TableTamer()
    local table_costume = TableTamerCostume()

    local tamer_id = self.m_selectTamerID
    local costume_id = costume_data:getCid() or TableTamerCostume:getDefaultCostumeID(tamer_id)
    
    -- 테이머 코스튬 정보
    local sd_res = costume_data:getResSD()
	local sd_animator = MakeAnimator(sd_res)
    vars['tamerSdNode']:addChild(sd_animator.m_node)

    local costume_name = costume_data:getName()
    vars['costumeTitleLabel']:setString(costume_name)

    local tamer_name = table_tamer:getValue(tamer_id, 't_name')
    vars['tamerNameLabel']:setString(tamer_name)

    -- 상태 (구입가능, 사용중, 사용가능)
    local is_used = costume_data:isUsed()
    local is_open = costume_data:isOpen() 
    local is_end = costume_data:isEnd()

    vars['selectBtn']:setVisible(not is_used and is_open)
    vars['useBtn']:setVisible(is_used)
    vars['buyBtn']:setVisible(not is_open)
    vars['priceNode']:setVisible(not is_open)

    vars['saleNode']:setVisible(false)
    vars['limitNode']:setVisible(false)
    vars['finishBtn']:setVisible(false)
    vars['infoLabel']:setVisible(false)

    -- 판매종료
    if (is_end) then
        vars['finishBtn']:setVisible(true)
        return
    end

    -- 가격 정보 표시
    if (not is_open) then
        local shop_info = g_tamerCostumeData:getShopInfo(costume_id)

        -- 열려있지 않은 테이머 경고 문구
        local is_lock = costume_data:isTamerLock()
        vars['infoLabel']:setVisible(not is_open and is_lock)

        local is_sale, msg = costume_data:isSale()
        local origin_price = shop_info['origin_price'] 
        local price = is_sale and shop_info['sale_price'] or shop_info['origin_price'] 
        local price_type = shop_info['price_type']
        local price_icon = IconHelper:getPriceIcon(price_type)

        -- 할인중
        if (is_sale) then
            vars['saleNode']:setVisible(true)
            vars['salePriceLabel1']:setString(comma_value(origin_price))
            vars['salePriceLabel2']:setString(comma_value(price))
            vars['priceLabel']:setString('')
            vars['saleTimeLabel']:setString(msg)

            vars['salePriceNode']:removeAllChildren()
            vars['salePriceNode']:addChild(price_icon)
        else
            vars['priceLabel']:setString(comma_value(price))
            vars['priceNode']:removeAllChildren()
            vars['priceNode']:addChild(price_icon)
        end

        local is_limit, msg = costume_data:isLimit()
        vars['limitNode']:setPositionY(is_sale and -161 or -201)

        -- 기간한정
        if (is_limit) then
            vars['limitNode']:setVisible(true)
            vars['limitLabel']:setString(msg)
        end

        self.m_selectShopInfo = shop_info
    end
end

-------------------------------------
-- function refresh_tableData
-------------------------------------
function UI_TamerCostumeShop:refresh_tableData()
    if (self.m_selectCostumeData) then
        for i,v in pairs(self.m_tableViewTD.m_itemList) do
            local ui = v['ui']
            if ui then
                local cid = self.m_selectCostumeData:getCid()
                ui:setSelected(cid)
                ui:refresh()
            end
        end
    end
end

-------------------------------------
-- function refresh_costumeTableView
-- @brief 선택한 테이머 코스튬 리스트
-------------------------------------
function UI_TamerCostumeShop:refresh_costumeTableView()
    local vars = self.vars

    local node = vars['costumListNode']
    node:removeAllChildren()

    local l_struct_costume = g_tamerCostumeData:makeStructCostumeList(self.m_selectTamerID)

    -- 코스튬 선택 버튼 
    local function create_func(ui, data)
        ui:setClickHandler(function(costume_data)
            self:click_costume(costume_data)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(200, 250)

    table_view_td:setCellUIClass(UI_TamerCostumeListItem, create_func)
    table_view_td.m_nItemPerCell = 3
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_struct_costume)

    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function click_costume
-------------------------------------
function UI_TamerCostumeShop:click_costume(costume_data)
    if (self.m_selectCostumeData:getCid() == costume_data:getCid()) then
        return
    end

    self.m_selectCostumeData = costume_data

    self:refresh()
    self:refresh_tableData()
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_TamerCostumeShop:click_selectBtn()
    local costume_data = self.m_selectCostumeData
    ccdump(costume_data)

    local costume_id = costume_data:getCid()
    local tamer_id = costume_data:getTamerID()

    local has_tamer = g_tamerData:hasTamer(tamer_id)
    if (not has_tamer) then
        UIManager:toastNotificationRed(Str('열려있지 않은 테이머는 코스튬을 변경 할 수 없습니다.'))
    else
        local function finish_cb()
            UIManager:toastNotificationGreen(Str('코스튬을 변경하였습니다.'))
            self:refresh()
            self:refresh_tableData()
        end

        g_tamerCostumeData:request_costumeSelect(costume_id, tamer_id, finish_cb)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_TamerCostumeShop:click_buyBtn()
    local function finish_cb()
        UIManager:toastNotificationGreen(Str('코스튬을 구입하였습니다.'))
        self:refresh()
        self:refresh_tableData()
    end
    
    local function show_popup()
        local ui = UI_TamerCostumeConfirmPopup(self.m_selectCostumeData)
        ui:setCloseCB(finish_cb)
    end

    local costume_data = self.m_selectCostumeData
    local is_open = costume_data:isOpen() 
    local is_lock = costume_data:isTamerLock()

    -- 구매불가
    if (not self.m_selectShopInfo) then
        return
    -- 열려있지않은 테이머라면 한번더 경고 문구
    elseif (not is_open and is_lock) then
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('해당 테이머를 소유하지 못했습니다.\n그래도 구매하시겠습니까?'), show_popup)
    else
        show_popup()
    end
end

-------------------------------------
-- function click_finishBtn 
-------------------------------------
function UI_TamerCostumeShop:click_finishBtn()
    UIManager:toastNotificationRed(Str('현재 구매할 수 없는 상품입니다.'))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TamerCostumeShop:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_TamerCostumeShop)
