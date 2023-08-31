local PARENT = UI

-------------------------------------
-- class UI_Help
-------------------------------------
UI_Help = class(PARENT,{
        m_preSelectedCategoryUI = 'cell',

        m_focusCategory = 'stirng',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Help:init(focus_category)
    local vars = self:load('help_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Help')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_focusCategory = focus_category or 'battle'

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Help:initUI()
    self:makeTableView_category()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Help:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Help:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Help:click_closeBtn()
    self:close()
end

-------------------------------------
-- function makeTableView_category
-------------------------------------
function UI_Help:makeTableView_category()
	local vars = self.vars
	local node = vars['btnNode']

	local l_help_list = TableHelp:getArrangedList()

    local focus_idx = nil
    for i, v in pairs(l_help_list) do
        if v['category'] == self.m_focusCategory then
            focus_idx = v['idx']
            break
        end
    end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local create_cb_func = function(ui, t_data)
            local function click_func()
                -- 도움말 내용 생성
                self:makeTableView_content(t_data['l_content'])
                
                -- 이전 버튼 활성화
                if (self.m_preSelectedCategoryUI) then
                    self.m_preSelectedCategoryUI.vars['helpBtn']:setEnabled(true)
                    self.m_preSelectedCategoryUI.vars['btnLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
                end

                -- 현재 버튼 비활성화
                ui.vars['helpBtn']:setEnabled(false)
                ui.vars['btnLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
                self.m_preSelectedCategoryUI = ui
            end

            -- 버튼 등록
            ui.vars['helpBtn']:registerScriptTapHandler(click_func)

            -- focus 처리
            if (self.m_focusCategory == t_data['category']) then
                click_func()
            end
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(250, 70 + 3)
        table_view:setCellUIClass(self.makeCellUI_category, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList3(l_help_list)

        table_view:update(0)
        table_view:relocateContainerFromIndex(focus_idx or 1)
    end
end

-------------------------------------
-- function makeTableView_content
-------------------------------------
function UI_Help:makeTableView_content(l_content)
	local vars = self.vars
	local node = vars['contentNode']

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 생성 콜백
		local create_cb_func = function(ui)
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view:setUseVariableSize(true)
        table_view:setCellUIClass(self.makeCellUI_content, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_content, true)
    end
end

-------------------------------------
-- function makeCellUI_category
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_Help.makeCellUI_category(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('help_popup_item_01.ui')
	
    local category = t_data['t_category']
    vars['btnLabel']:setString(Str(category))
    vars['btnLabel']:setTextColor(cc.c4b(240, 215, 159, 255))

	return ui
end

-------------------------------------
-- function makeCellUI_content
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_Help.makeCellUI_content(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('help_popup_item_02.ui')
	
    local title = Str(t_data['title'])
    vars['titleLabel']:setString(title)

    local content = Str(t_data['content'])
    vars['contentLabel']:setString(content)

    UI_Help.adjustCellHeight(ui)

	return ui
end

-------------------------------------
-- function adjustCellHeight
-------------------------------------
function UI_Help.adjustCellHeight(ui)
	local vars = ui.vars

	-- content 영역의 높이를 가져온다.
	local label_height = vars['contentLabel']:getTotalHeight()

    -- titleLabel 영역 높이를 가져옴
    local title_height = vars['titleLabel']:getTotalHeight()

	-- titleLabel을 포함하여 container 사이즈 조정
	local con_size = vars['container']:getContentSize()
	local con_height = label_height + title_height + 50
	local new_size = cc.size(con_size['width'], con_height)
	vars['container']:setNormalSize(con_size['width'], con_height)

	-- cell size 저장
	ui:setCellSize(new_size)
end
