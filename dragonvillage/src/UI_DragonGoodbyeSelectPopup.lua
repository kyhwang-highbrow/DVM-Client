local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyeSelectPopup
-------------------------------------
UI_DragonGoodbyeSelectPopup = class(PARENT,{
		m_lItemList = 'table',
        m_msg = 'string',
        m_cbOKBtn = 'function'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelectPopup:init(lItemList, msg, ok_btn_cb)
    self.m_lItemList = lItemList
	self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb

    local vars = self:load('goodbye_select_popup_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_DragonGoodbyeSelectPopup')

    self:initUI()
    self:initButton()
	self:initTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelectPopup:initUI()
	local vars = self.vars

	local msg = self.m_msg
	vars['stateLabel']:setString(msg)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeSelectPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonGoodbyeSelectPopup:initTableView()
	local vars = self.vars

	local node = vars['itemListNode']

	-- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_ItemCard(object['item_id'], object['count'])
    end

    local function create_func(ui, data)
        ui.root:setScale(0.72)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(119, 119)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	table_view.m_bAlignCenterInInsufficient = true

    table_view:setItemList(self.m_lItemList)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelectPopup:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonGoodbyeSelectPopup:click_okBtn()
    if self.m_cbOKBtn then
        if self.m_cbOKBtn() then
            return
        end
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeSelectPopup)
