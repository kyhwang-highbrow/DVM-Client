local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyeSelectConfirmPopup
-------------------------------------
UI_DragonGoodbyeSelectConfirmPopup = class(PARENT,{
		m_lItemList = 'table',
        m_msg = 'string',
        m_cbOKBtn = 'function'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelectConfirmPopup:init(item_list, msg, ok_btn_cb)
    self.m_lItemList = item_list
	self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb

    local vars = self:load('dragon_goodbye_select_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeSelectConfirmPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelectConfirmPopup:initUI()
	local vars = self.vars

	local msg = self.m_msg
	vars['infoLabel']:setString(msg)

    if (#self.m_lItemList > 1) then
	    vars['itemNode']:setVisible(false)
        self:initTableView()
    else
        local t_item_data = self.m_lItemList[1]
        local item_ui = UI_ItemCard(t_item_data['item_id'], t_item_data['count'])
        vars['itemNode']:addChild(item_ui.root) 
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeSelectConfirmPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonGoodbyeSelectConfirmPopup:initTableView()
	local vars = self.vars

	local node = vars['itemListNode']

	-- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_ItemCard(object['item_id'], object['count'])
    end

    local function create_func(ui, data)
        ui.root:setScale(0.8)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(124, 139)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	table_view.m_bAlignCenterInInsufficient = true

    table_view:setItemList(self.m_lItemList)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelectConfirmPopup:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonGoodbyeSelectConfirmPopup:click_okBtn()
    if self.m_cbOKBtn then
        if self.m_cbOKBtn() then
            return
        end
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeSelectConfirmPopup)
