local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanMark
-------------------------------------
UI_ClanMark = class(PARENT, {
        m_prevStructClanMark = '',
        m_structClanMark = '',
        m_tableViewTD = '',
        m_bChanged = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanMark:init(struct_clan_mark)
    self.m_prevStructClanMark = struct_clan_mark
    self.m_structClanMark = struct_clan_mark:copy()

    local vars = self:load('clan_mark.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanMark'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanMark')

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
function UI_ClanMark:click_exitBtn()
    self.m_structClanMark = self.m_prevStructClanMark:copy()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanMark:initUI()
    local vars = self.vars

    -- 클랜 마크
    local icon = self.m_prevStructClanMark:makeClanMarkIcon()
    vars['markNode1']:removeAllChildren()
    vars['markNode1']:addChild(icon)

    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanMark:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['randomBtn']:registerScriptTapHandler(function() self:click_randomBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function click_randomBtn
-------------------------------------
function UI_ClanMark:click_randomBtn()
    local table_clan_mark = TableClanMark()

    self.m_structClanMark.m_bgIdx = math_random(1, table.count(table_clan_mark.m_bgMap))
    self.m_structClanMark.m_symbolIdx = math_random(1, table.count(table_clan_mark.m_symbolMap))
    self.m_structClanMark.m_colorIdx1 = math_random(1, table.count(table_clan_mark.m_colorMap))
    self.m_structClanMark.m_colorIdx2 = math_random(1, table.count(table_clan_mark.m_colorMap))

    self:init_TableView()
    self:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ClanMark:click_okBtn()
    self.m_bChanged = true
    self:close()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanMark:refresh()
    local vars = self.vars

    -- 클랜 마크
    local icon = self.m_structClanMark:makeClanMarkIcon()
    vars['markNode2']:removeAllChildren()
    vars['markNode2']:addChild(icon)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanMark:initTab()
    local vars = self.vars
    self:addTabWithLabel('symbol', vars['symbolTabBtn'], vars['symbolTabLabel'])
    self:addTabWithLabel('symbolColor1', vars['symbolColorTabBtn1'], vars['symbolColorTabLabel1'])
    self:addTabWithLabel('symbolColor2', vars['symbolColorTabBtn2'], vars['symbolColorTabLabel2'])
    self:addTabWithLabel('bg', vars['bgTabBtn'], vars['bgTabLabel'])

    self:setTab('symbol')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanMark:onChangeTab(tab, first)
    self:init_TableView()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanMark:init_TableView()
    local node = self.vars['bgNode']
    node:removeAllChildren()

    local table_clan_mark = TableClanMark()
    local l_item_list = self:getTableViewItemList()

	-- cell_size 지정
    local item_size = 100
    local cell_size = cc.size(item_size+ 12, item_size + 12)
    local color_size = cc.size(item_size, item_size)

	local table_view_td

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        local idx = data['idx']
        local curr_idx, icon
        local struct_clan_mark = self.m_structClanMark:copy()

        -- 심볼은 무채색 적당한 책상의 문양만 출력 : 클랜 마크 완성본에 가까움
        if (self.m_currTab == 'symbol') then
            curr_idx = struct_clan_mark.m_symbolIdx

			-- @eventmark 이벤트 커스텀 클랜 마크
			if (idx == 21) then
				struct_clan_mark.m_eventMark = data['res']

			-- 일반 클랜 마크
			else
				struct_clan_mark.m_symbolIdx = idx
				struct_clan_mark.m_colorIdx1 = 25
				struct_clan_mark.m_colorIdx2 = 27
				struct_clan_mark.m_bgIdx = 30
				struct_clan_mark.m_eventMark = nil
			end

			icon = struct_clan_mark:makeClanMarkIcon()

        -- 색상만 출력
        elseif (self.m_currTab == 'symbolColor1') then
            curr_idx = struct_clan_mark.m_colorIdx1
            local color = table_clan_mark:getColor(idx)

            icon = cc.LayerColor:create(cc.c4b(0,0,0,255))
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            icon:setContentSize(color_size)
            icon:setColor(color)

        -- 색상만 출력
        elseif (self.m_currTab == 'symbolColor2') then
            curr_idx = struct_clan_mark.m_colorIdx2
            local color = table_clan_mark:getColor(idx)

            icon = cc.LayerColor:create(cc.c4b(0,0,0,255))
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            icon:setContentSize(color_size)
            icon:setColor(color)

        -- 배경만 출력
        elseif (self.m_currTab == 'bg') then
            curr_idx = struct_clan_mark.m_bgIdx
            local bg_res = table_clan_mark:getBgRes(idx)

            icon = IconHelper:getIcon(bg_res)

        end

        if (curr_idx == idx) then
            ui.vars['selectSprite']:setVisible(true)
        else
            ui.vars['selectSprite']:setVisible(false)
        end

        ui.vars['markNode']:addChild(icon)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_listItem(ui, data) end)
    end

    -- 테이블 뷰 인스턴스 생성
    table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 6
	table_view_td:setCellUIClass(UI_ClanMarkListItem, create_func)
    table_view_td:setItemList(l_item_list)
    self.m_tableViewTD = table_view_td
	
    local function default_sort_func(a, b)
        local a = a['data']
        local b = b['data']

        return a['idx'] < b['idx']
    end
    table.sort(table_view_td.m_itemList, default_sort_func)
end

-------------------------------------
-- function getTableViewItemList
-------------------------------------
function UI_ClanMark:getTableViewItemList()
    local l_item_list

    local table_clan_mark = TableClanMark()

    if (self.m_currTab == 'symbol') then
        l_item_list = table_clan_mark.m_symbolMap

		-- @eventmark 커스텀 마크 가능하다면 추가
		local name = string.format('%s_%s', g_localData:getServerName(), g_clanData:getClanStruct():getClanName())
		local path = string.format(TableClanMark.getEventMarkPath(), name)
		if (cc.FileUtils:getInstance():isFileExist(path)) then
			table.insert(l_item_list, {['idx'] = 21, ['res'] = name})
		end

    elseif (self.m_currTab == 'symbolColor1') then
        l_item_list = table_clan_mark.m_colorMap

    elseif (self.m_currTab == 'symbolColor2') then
        l_item_list = table_clan_mark.m_colorMap

    elseif (self.m_currTab == 'bg') then
        l_item_list = table_clan_mark.m_bgMap

    end

    return l_item_list
end

-------------------------------------
-- function click_listItem
-------------------------------------
function UI_ClanMark:click_listItem(ui, data)

    local idx = data['idx']
    local prev_idx
    if (self.m_currTab == 'symbol') then
        prev_idx = self.m_structClanMark.m_symbolIdx

		-- @eventmark 이벤트 커스텀 클랜 마크
		if (idx == 21) then
			self.m_structClanMark.m_eventMark = data['res']
		else
			self.m_structClanMark.m_eventMark = nil
			self.m_structClanMark.m_symbolIdx = idx
		end

    elseif (self.m_currTab == 'symbolColor1') then
        prev_idx = self.m_structClanMark.m_colorIdx1
        self.m_structClanMark.m_colorIdx1 = idx

    elseif (self.m_currTab == 'symbolColor2') then
        prev_idx = self.m_structClanMark.m_colorIdx2
        self.m_structClanMark.m_colorIdx2 = idx

    elseif (self.m_currTab == 'bg') then
        prev_idx = self.m_structClanMark.m_bgIdx
        self.m_structClanMark.m_bgIdx = idx

    end

    ui.vars['selectSprite']:setVisible(true)


    do
        local t_item = self.m_tableViewTD:getItem(prev_idx)
        local ui = t_item['ui']
        if ui then
            ui.vars['selectSprite']:setVisible(false)
        end
    end

    self:refresh()
end



--@CHECK
UI:checkCompileError(UI_ClanMark)
