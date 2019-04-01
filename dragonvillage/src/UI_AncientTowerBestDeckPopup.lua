local PARENT = UI

-------------------------------------
-- class UI_AncientTowerBestDeckPopup
-------------------------------------
UI_AncientTowerBestDeckPopup = class(PARENT,{
      
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerBestDeckPopup:init()
    self.m_uiName = 'UI_AncientTowerBestDeckPopup'
    local vars = self:load('tower_best_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AncientTowerBestDeckPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerBestDeckPopup:initUI()
    local vars = self.vars

    local l_deck = g_settingDeckData:getDeckAllAncient('ancient')

    if (not l_deck) then
        return 
    end

    l_deck = l_deck['ancient_deck']
    l_deck = table.MapToList(l_deck)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view:setCellUIClass(UI_AncientTowerBestDeckListItem, nil)
    table_view.m_defaultCellSize = cc.size(1217, 77)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    table_view:setItemList(l_deck)
    
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(table_index)
    --[[

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view:setCellUIClass(UI_AncientTowerBestDeckListItem, nil)
    table_view.m_defaultCellSize = cc.size(900, 130)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local l_item_list = table.MapToList(g_capsuleBoxData.m_scheduleTable)
    
    -- 캡슐 판매일 오래된 것부터 출력되도록 정렬
    local function sort_func(a, b)
        local a_time = a['day']
        local b_time = b['day']

        return a_time < b_time
    end
    table.sort(l_item_list, sort_func)

    local table_index = 0
    for i,v in ipairs(l_item_list) do
        if (v['day'] == g_capsuleBoxData.m_day) then
            table_index = i
            break
        end
    end

    -- 마지막에 추가하는 테이블 아이템
    local advance_notice_item = { advance_notice = '{@ORANGE}' .. Str('업데이트 예정')}
    l_item_list['advance_notice'] = advance_notice_item

    -- 현재 판매중인 캡슐 상품 정보
    table_view:setItemList(l_item_list)
    
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(table_index)
    --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerBestDeckPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerBestDeckPopup:refresh()
    
end


--@CHECK
UI:checkCompileError(UI_AncientTowerBestDeckPopup)
