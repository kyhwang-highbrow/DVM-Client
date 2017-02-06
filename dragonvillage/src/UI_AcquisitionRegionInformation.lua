local PARENT = UI

-------------------------------------
-- class UI_AcquisitionRegionInformation
-------------------------------------
UI_AcquisitionRegionInformation = class(PARENT, {
        m_itemID = 'item_id',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AcquisitionRegionInformation:init(item_id)
    self.m_itemID = item_id

    local vars = self:load('location_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AcquisitionRegionInformation')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AcquisitionRegionInformation:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_AcquisitionRegionInformation:initUI()
    local vars = self.vars
    local item_id = self.m_itemID

    -- 아이템 아이콘
    local item = UI_ItemCard(item_id)
    vars['itemNode']:addChild(item.root)
    
    -- 아이템 이름
    local name = TableItem():getValue(item_id, 't_name')
    vars['itemLabel']:setString(Str(name))

    self:regionListView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AcquisitionRegionInformation:initButton(t_user_info)
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_AcquisitionRegionInformation:refresh(t_user_info)
    local vars = self.vars
end

-------------------------------------
-- function regionListView
-- @brief
-------------------------------------
function UI_AcquisitionRegionInformation:regionListView()
    local node = self.vars['listNode']

    local item_id = self.m_itemID
    local l_region = TableItem:getRegionList(item_id)

    if (not l_region) then
        return
    end

    -- 셀 아이템 생성 콜백
    local function create_func(ui, data, key)
        --[[
        ui.vars['selectBtn']:registerScriptTapHandler(function()
                UIManager:toastNotificationGreen(Str('"고니"가 선택되었습니다.'))
            end)
        --]]
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(520, 100)
    table_view:setCellUIClass(UI_AcquisitionRegionListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_region)

    -- 아이템 등장 연출
    local content_size = node:getContentSize()
    table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_x = x + content_size['width']
        ui.root:setPosition(new_x, y)

        ui:cellMoveTo(0.5, cc.p(x, y))
    end
end

--@CHECK
UI:checkCompileError(UI_AcquisitionRegionInformation)
