local PARENT = UI

-------------------------------------
-- class UI_AncientTowerBestDeckPopup
-------------------------------------
UI_AncientTowerBestDeckPopup = class(PARENT,{
        m_cbApplyBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerBestDeckPopup:init(cb_click_apply)
    self.m_uiName = 'UI_AncientTowerBestDeckPopup'
    local vars = self:load('tower_best_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_cbApplyBtn = cb_click_apply

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

    local sort_func = function(a,b)
        return tonumber(a['stage_id']) < tonumber(b['stage_id'])
    end

    table.sort(l_deck, sort_func)

    -- 덱 팝업에 덱 적용 버튼 있을 경우
    local create_func = function(ui, data)
        --ui:setApplyBtnFunc(self.m_cbApplyBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view:setCellUIClass(UI_AncientTowerBestDeckListItem, create_func)
    table_view.m_defaultCellSize = cc.size(1217, 77)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    table_view:setItemList(l_deck)
    
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(table_index)
   
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
