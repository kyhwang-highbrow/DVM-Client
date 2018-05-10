local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RandomShop
-------------------------------------
UI_RandomShop = class(PARENT,{
    })

local NEED_REFRESH_VALUE = 50
local NEED_REFRESH_TYPE = 'cash'
-------------------------------------
-- function init
-------------------------------------
function UI_RandomShop:init()
    local vars = self:load('shop_random.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_RandomShop')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_RandomShop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RandomShop'
    self.m_titleStr = Str('나르비 상점')
    self.m_subCurrency = 'ancient' -- 고대주화 노출
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RandomShop:initUI()
    local vars = self.vars
    self:initTableView()

    do -- 새로고침
        local icon = IconHelper:getPriceIcon(NEED_REFRESH_TYPE)
        vars['priceNode']:addChild(icon)
        vars['priceLabel']:setString(comma_value(NEED_REFRESH_VALUE))
    end

    do -- 갱신시간
        local function update(dt)
            if (g_randomShopData.m_bDirty) then
                g_randomShopData.m_bDirty = false
                self:refresh_shopInfo()
                vars['timeLabel']:setString('')
            else
                local str = g_randomShopData:getStatusText()
                vars['timeLabel']:setString(str)
            end
        end
        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RandomShop:initButton()
    local vars = self.vars
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_RandomShop:initTableView()
    local vars = self.vars
    local node = vars['listNode']
    node:removeAllChildren()

    local l_item_list = g_randomShopData:getProductList()

    -- 테이블 뷰 인스턴스 생성
    table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(305, 285)
    table_view_td.m_nItemPerCell = 4
	table_view_td:setCellUIClass(UI_RandomShopListItem)
    table_view_td:setItemList(l_item_list)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RandomShop:refresh()
end

-------------------------------------
-- function refresh_shopInfo
-- @brief 무료 갱신 가능한 상태 : 클라에서 서버에 shopInfo 다시 호출
-------------------------------------
function UI_RandomShop:refresh_shopInfo()
    -- UI 블럭
    local block_ui = UI_BlockPopup()
    -- 백키 블럭 
    UIManager:blockBackKey(true)

    -- 해당 UI가 열린후 생성된 UI 모두 닫아줌
    local is_opend, idx, ui = self:findOpendUI('UI_RandomShop')
    self:closeUIList(idx, false) -- param : idx, include_idx

    local finish_cb = function()
        -- UI 블럭 해제
        block_ui:close()
        -- 백키 블럭 해제
        UIManager:blockBackKey(false)
    end

    local function coroutine_function(dt)
		local co = CoroutineHelper()
        local fail_cb = function() 
            co.ESCAPE()
            finish_cb()
        end

        co:work()
		cclog('# 랜덤 상점 무료 갱신중')
		g_randomShopData:request_shopInfo(co.NEXT, fail_cb)
		if co:waitWork() then return end
        finish_cb()
        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function click_refreshBtn
-------------------------------------
function UI_RandomShop:click_refreshBtn()
    if (not ConfirmPrice(NEED_REFRESH_TYPE, NEED_REFRESH_VALUE)) then
        -- 재화 부족
        return
    end

    local function ok_btn_cb()
        local finish_cb = function()
            self:initTableView()
        end
        g_randomShopData:request_refreshInfo(finish_cb)
    end

    local msg = Str('새로운 상품으로 교체하시겠습니까?')
    UI_ConfirmPopup(NEED_REFRESH_TYPE, NEED_REFRESH_VALUE, msg, ok_btn_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RandomShop:click_exitBtn() 
    self:close()
end

--@CHECK
UI:checkCompileError(UI_RandomShop)
