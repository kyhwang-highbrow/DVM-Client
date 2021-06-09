local PARENT = UI

-------------------------------------
-- class UI_UserInfoDetailPopup_SetTitle
-------------------------------------
UI_UserInfoDetailPopup_SetTitle = class(PARENT, {
	m_lHoldingList = 'list',
    m_tableView = 'UIC_TableView',
    m_currTitle = 'number',

    m_titleQuestMap = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:init(l_title_list)
    self.m_uiName = 'UI_UserInfoDetailPopup_SetTitle'

    local vars = self:load('user_info_title.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserInfoDetailPopup_SetTitle')

    -- init
    self.m_lHoldingList = l_title_list
    self.m_currTitle = g_userData:getTitleID()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:initUI()
    local vars = self.vars
    self:makeTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:click_closeBtn()
	self:close()
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:makeTableView()
    local vars = self.vars
    local node = vars['listNode']

    -- 칭호 획득 조건 
    self.m_titleQuestMap = TableQuest:getTitleQuestMap()

	-- 칭호 뭉치
	local l_title = self:makeSortedTitleList()

    do -- 테이블 뷰 생성
        node:removeAllChildren()
        
        local function create_func(t_data)
            return self:makeCellUI(t_data)
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(900, 100 + 5)
        table_view:setCellUIClass(create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_title)

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function makeSortedTitleList
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:makeSortedTitleList()
    local table_tamer_id = TableTamerTitle()
    local l_title = table.MapToList(table_tamer_id.m_orgTable)
    
    -- 장착, 보유, id 순으로 정렬
    local use_a, use_b, have_a, have_b
    table.sort(l_title, function(a, b)
        use_a = (self.m_currTitle == a['title_id'])
        use_b = (self.m_currTitle == b['title_id'])
        have_a = (table.find(self.m_lHoldingList, a['title_id']))
        have_b = (table.find(self.m_lHoldingList, b['title_id']))

        -- 장착
        if (use_a) then
            return true
        elseif (use_b) then
            return false

        -- 보유
        elseif (have_a) and (have_b) then
            return a['title_id'] < b['title_id']
        elseif (have_a) then
            return true
        elseif (have_b) then
            return false

        -- 그외 ID 순
        else
            return a['title_id'] < b['title_id']
        end
    end)

    return l_title
end

--@CHECK
UI:checkCompileError(UI_UserInfoDetailPopup_SetTitle)

-------------------------------------
-- function makeCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_UserInfoDetailPopup_SetTitle:makeCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('user_info_title_item.ui')
    
    local title_id = t_data['title_id']
    local title = Str(t_data['t_name'])


    -- 보유 여부
    local is_holding = table.find(self.m_lHoldingList, title_id)
    if (is_holding) then
        vars['selectBtn']:registerScriptTapHandler(function()
            local function cb_func()
                UI_ToastPopup(Str('칭호가 변경되었습니다.'))
                self.m_closeCB(title_id)
                self.m_closeCB = nil
                self:close()
            end
            g_userData:request_setTitle(title_id, cb_func)
        end)
    else
        vars['nothingSprite']:setVisible(true)

        -- 2018.04.24 klee - 미보유 타이틀도 보여줌
        --[[
        -- 미보유 타이틀은 글자수만큼의 ?로 대체
        local str_len = uc_len(title)
        title = string.rep('?', str_len)
        ]]--
    end
    
    -- 칭호
    vars['titleLabel']:setString(title)
    
    -- 획득 조건
    local str_clear = self.m_titleQuestMap[title_id]
    if (str_clear) then
        vars['questLabel']:setString(str_clear)
    else
        vars['questLabel']:setString('')
    end

    -- 선택 여부
    local is_use = (title_id == self.m_currTitle)
    vars['selectSprite']:setVisible(is_use)
    vars['selectBtn']:setVisible(not is_use)
    vars['removeBtn']:setVisible(is_use)

    if (is_use) then
        vars['removeBtn']:registerScriptTapHandler(function()
            local function cb_func()
                UI_ToastPopup(Str('칭호가 해제되었습니다.'))
                self.m_closeCB(0)
                self.m_closeCB = nil
                self:close()
            end
            g_userData:request_setTitle(0, cb_func)
        end)
    end

	return ui
end
