local PARENT = UI

-------------------------------------
-- class UI_TamerInfoPopup
-------------------------------------
UI_TamerInfoPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerInfoPopup:init()
    local vars = self:load('tamer_select_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TamerInfoPopup')

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
function UI_TamerInfoPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerInfoPopup:initUI()
    self:makeTamerListView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerInfoPopup:refresh()
end

-------------------------------------
-- function makeTamerListView
-- @brief
-------------------------------------
function UI_TamerInfoPopup:makeTamerListView()
    local node = self.vars['tableViewNode']

    -- 셀 아이템 생성 콜백
    local function create_func(ui, data, key)
        ui.vars['selectBtn']:registerScriptTapHandler(function()
                UIManager:toastNotificationGreen(Str('"고니"가 선택되었습니다.'))
            end)
        return true
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(198, 550)
    table_view:setCellUIClass(UI_TamerSelectItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList({1,2,3,4,5,6})

    -- 아이템 등장 연출
    local content_size = node:getContentSize()
    table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_y = y - content_size['height']
        ui.root:setPosition(x, new_y)

        ui:cellMoveTo(0.25, cc.p(x, y))
    end
end

--@CHECK
UI:checkCompileError(UI_TamerInfoPopup)
