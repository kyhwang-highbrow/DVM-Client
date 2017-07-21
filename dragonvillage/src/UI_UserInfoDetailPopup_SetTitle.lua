local PARENT = UI

-------------------------------------
-- class UI_UserInfoDetailPopup_SetTitle
-------------------------------------
UI_UserInfoDetailPopup_SetTitle = class(PARENT, {
	m_lTitleList = 'list',
})

-------------------------------------
-- function init
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:init(l_title_list)
    self.m_uiName = 'UI_UserInfoDetailPopup_SetTitle'

    local vars = self:load('user_info_title.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserInfoDetailPopup_SetTitle')

    -- init
    self.m_lTitleList = l_title_list

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:refresh()
    local vars = self.vars
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:makeTableView()
    local vars = self.vars
    local node = vars['listNode']

	-- 퀘스트 뭉치
	local l_list = TABLE:get('tamer_title')

    do -- 테이블 뷰 생성
        node:removeAllChildren()
         
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(900, 100 + 5)
        table_view:setCellUIClass(self.makeCellUI)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_list)

        self.m_tableView = table_view
    end
end

--@CHECK
UI:checkCompileError(UI_UserInfoDetailPopup_SetTitle)

-------------------------------------
-- function makeCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle.makeCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('user_info_title_item.ui')

	return ui
end
