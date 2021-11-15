local PARENT = UI

-------------------------------------
-- class UI_ObtainPopup
-------------------------------------
UI_ObtainPopup = class(PARENT, {
		m_lItemList = 'list',
		m_isSingle = '',
        m_msg = 'string',
        m_cbOKBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ObtainPopup:init(l_item, msg, ok_btn_cb, is_merge_all_item)
    local vars = self:load('popup_obtain.ui')
    UIManager:open(self, UIManager.POPUP)

	self.m_uiName = 'UI_ObtainPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_ObtainPopup')

	-- initialize
	self.m_lItemList = self:makePrettyList(l_item, is_merge_all_item)
	self.m_isSingle = (#l_item == 1)
    self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ObtainPopup:initUI()
	local vars = self.vars
	
	vars['singleNode']:setVisible(self.m_isSingle)

	if (self.m_isSingle) then
		vars['dscLabel']:setString(self.m_msg or Str('보상을 획득했습니다.'))
		for _, t_item in pairs(self.m_lItemList) do
			local item_id = t_item['item_id']
			local item_cnt = t_item['count']
			local item_card = UI_ItemCard(item_id, item_cnt)
			if (item_card) then
				vars['iconNode']:addChild(item_card.root)
			end
		end
	else
		self:makeObtainTableView()
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ObtainPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ObtainPopup:refresh()
	local vars = self.vars
end

-------------------------------------
-- function makePrettyList
-- @brief 특정 재화들은 여러개가 있을 경우 합친다.
-------------------------------------
function UI_ObtainPopup:makePrettyList(l_item, is_merge_all_item) 
	local l_ret = {}
	local t_simple = {}
	local table_item_type = TableItemType()

	for i, v in pairs(l_item) do
		local item_id = v['item_id']
		local is_merge_type  

		if (table_item_type:isCanReadAll(item_id)) then
			
			-- 우편함의 우정/스테/돈 경우 무조건 합산
			if (table_item_type:isMailFp(item_id) or table_item_type:isMailStaminas(item_id) or table_item_type:isMailMoney(item_id)) then
				is_merge_type = true
			-- 아이템의 경우 is_merge_all_item == true 인 경우만 합산
			elseif (table_item_type:isMailItem(item_id)) then
				if (is_merge_all_item) then
					is_merge_type = true
				else
					is_merge_type = false
				end
			-- 그 외의 경우 
			else
				table_item_type:errorUndefineType(item_id)
				is_merge_type = false
			end
			
			if (is_merge_type) then
				if (t_simple[item_id]) then
					t_simple[item_id]['count'] = t_simple[item_id]['count'] + v['count']
				else
					t_simple[item_id] = v
				end
			else
				l_ret[i] = v
			end
		-- 합산 안되는 경우
		else
			l_ret[i] = v
		end
	end

	-- 일반 오브젝트 아이템 리스트 상단에 합치는 재화들을 넣어준다.
	for i, v in pairs(t_simple) do
		table.insert(l_ret, 1, v)
	end

	return l_ret
end

-------------------------------------
-- function makeObtainTableView
-------------------------------------
function UI_ObtainPopup:makeObtainTableView()
	local node = self.vars['listNode']
	local function create_func(t_data)
		return self:createListUI(t_data)
	end
	
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, 105)
    table_view:setCellUIClass(create_func, nil)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(self.m_lItemList)
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ObtainPopup:click_okBtn()
    if self.m_cbOKBtn then
        self.m_cbOKBtn()
    end

    self:close()
end

-------------------------------------
-- function createListUI
-------------------------------------
function UI_ObtainPopup:createListUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('obtain_item.ui')
	local item_id = t_data['item_id']
	local item_cnt = t_data['count']
    local item_type = TableItem:getItemType(item_id)
		
	local item_card

    -- 상품이 룬일 경우
    if (item_type == 'rune') then
        local t_rune_data = g_runesData:getRuneObject(t_data['oids'][1])
        if (t_rune_data) then
            item_card = UI_RuneCard(t_rune_data)
            if (item_card) then vars['itemNode']:addChild(item_card.root) end
        end
    else
        -- item icon
	    item_card = UI_ItemCard(item_id, item_cnt)
	    if (item_card) then
		    vars['itemNode']:addChild(item_card.root)
	    end
    end

    local table_item = TableItem()

	-- item label
	local item_name = table_item:getItemName(item_id)
    local item_desc = table_item:getItemDesc(item_id)

    local item_str = ''
    if item_desc then
        item_str = Str('{@item_name}{1} : {@default}{2}', item_name, item_desc)
    else
        item_str = item_name
    end

	vars['countLabel']:setString(item_str)

	return ui
end

-------------------------------------
-- function createMailListUI
-------------------------------------
function UI_ObtainPopup.createMailListUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('obtain_item.ui')
	local item_id = t_data['item_id']
	local item_cnt = t_data['count']
		
	-- item icon
	local item_card = UI_ItemCard(item_id, item_cnt)
	if (item_card) then
		vars['itemNode']:addChild(item_card.root)
	end

    local table_item = TableItem()

	-- item label
	local item_name = table_item:getItemName(item_id)
    local item_desc = table_item:getItemDesc(item_id)

    local item_str = ''
    if item_desc then
        item_str = Str('{@item_name}{1} : {@default}{2}', item_name, item_desc)
    else
        item_str = item_name
    end

	vars['countLabel']:setString(item_str)

	return ui
end

-------------------------------------
-- function ItemObtainResult_Shop
-- @brief
-- @param t_ret
-------------------------------------
function ItemObtainResult_Shop(t_ret, show_all)
    if (not t_ret) then
        return
    end

    local type = type or 'reward'

    -- 구매한 아이템, 우편함으로 전송된 경우
    if (t_ret['new_mail'] == true) then
        g_highlightData:setHighlightMail()
        local toast_msg = Str('상품이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
    end

    -- 드래곤 뽑기를 구입 즉시 지급하는 특이한 경우에 대한 예외처리
    -- 서버 구조상 뽑기가 연관되어 있는 경우 added_dragons로 주게 되어 여기서 처리
    if (t_ret['added_dragons']) then
        -- @kwkang 100개 뽑기 결과창으로 보여줌, 21-01-19 기준 바로 드래곤을 지급하는 상품은 100개 뽑기 상품밖에 없음. 추후에 생기면 그 때 분기 추가하도록..
        local l_dragon_list = t_ret['added_dragons']
        g_dragonsData:applyDragonData_list(t_ret['added_dragons'])

        UI_GachaResult_Dragon100('shop', l_dragon_list)
        return
    end

    -- 예외처리
    local added_items = t_ret['added_items']
    if (not added_items) then
        return
    end

    local items_list = added_items['items_list']
    if (not items_list) then
        return
    end

    local item_id, count, t_sub_data = ServerData_Item:parseAddedItems_firstItem(added_items)
    local item_type = TableItem:getItemType(item_id)

    -- 상품이 하나인 경우
    if (#items_list == 1) and (item_type ~= 'grindstone') then
        -- 기본 재화 구매는 결과를 보여주지 않음
        if (TableItem:getItemIDFromItemType(item_type) and not show_all) then
            return
        end
    end

    -- 상품이 룬일 경우
    if (item_type == 'rune') then
        -- 룬 뽑기 결과창으로 보여줌
        local l_rune_list = added_items['runes']
        UI_GachaResult_Rune('shop', l_rune_list)
        return
    end

    -- 혹시나 상점에서 여러 상품을 즉시 지급하였을 경우
    local l_item = items_list
    local msg = Str('구매 완료')
    local ok_btn_cb = nil
    UI_ObtainPopup(l_item, msg, ok_btn_cb)
end

-------------------------------------
-- function ItemObtainResult
-- @brief
-- @param t_ret
-------------------------------------
function ItemObtainResult(t_ret, is_mail)
    if (not t_ret) then
        return
    end

    local type = type or 'reward'

    -- 우편함으로 정송
    if (t_ret['new_mail'] == true) then
        g_highlightData:setHighlightMail()
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
    end

    -- 예외처리
    local added_items = t_ret['added_items']
    if (not added_items) then
        return
    end

    local items_list = added_items['items_list']
    if (not items_list) then
        return
    end

    -- 아이템이 하나이고 룬일 경우
    if (#items_list == 1) then
        local item_id, count, t_sub_data = ServerData_Item:parseAddedItems_firstItem(added_items)
        local item_type = TableItem:getItemType(item_id)

        -- 기본 재화 구매는 결과를 보여주지 않음
        if (TableItem:getItemIDFromItemType(item_type)) then
            return
        end

        -- 메일로 받은 아이템일경우 룬만 팝업을 표시
        if (is_mail and (item_type ~= 'rune')) then
            local toast_msg = Str('아이템을 지급받았습니다.')
            UI_ToastPopup(toast_msg)
            return
        end

        -- 아이템 정보창 띄움
        local ui = UI_ItemInfoPopup(item_id, count, t_sub_data)
        ui:showItemInfoPopupOkBtn() -- "획득 장소"버튼은 끄고 "확인"버튼만 띄우도록 처리
        return
    end


    local l_item = items_list
    local msg = Str('보상 획득')
    local ok_btn_cb = nil
    UI_ObtainPopup(l_item, msg, ok_btn_cb)
end

-------------------------------------
-- function ItemObtainResult_hasCloseCb
-- @brief 아이템 보여준 후 콜백이 필요할 경우 사용하는 팝업
-- @param t_ret
-------------------------------------
function ItemObtainResult_hasCloseCb(t_ret, is_mail, close_cb)
    if (not t_ret) then
        return
    end

    local type = type or 'reward'

    -- 우편함으로 전송
    if (t_ret['new_mail'] == true) then
        g_highlightData:setHighlightMail()
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
    end

    -- 예외처리
    local added_items = t_ret['added_items']
    if (not added_items) then
        return
    end

    local items_list = added_items['items_list']
    if (not items_list) then
        return
    end

    -- 아이템이 하나이고 룬일 경우
    if (#items_list == 1) then
        local item_id, count, t_sub_data = ServerData_Item:parseAddedItems_firstItem(added_items)
        local item_type = TableItem:getItemType(item_id)

        -- 기본 재화 구매는 결과를 보여주지 않음
        if (TableItem:getItemIDFromItemType(item_type)) then
            UIManager:toastNotificationGreen(Str('보상을 수령하였습니다.'))
            close_cb()
            return
        end

        -- 메일로 받은 아이템일경우 룬만 팝업을 표시
        if (is_mail and (item_type ~= 'rune')) then
            local toast_msg = Str('아이템을 지급받았습니다.')
            local toast_ui = UI_ToastPopup(toast_msg)
            toast_ui:setCloseCB(close_cb)
            return
        end

        -- 아이템 정보창 띄움
        local ui = UI_ItemInfoPopup(item_id, count, t_sub_data)
        ui:showItemInfoPopupOkBtn() -- "획득 장소"버튼은 끄고 "확인"버튼만 띄우도록 처리
        ui:setCloseCB(close_cb)
        return
    end


    local l_item = items_list
    local msg = Str('보상 획득')
    local ok_btn_cb = close_cb
    UI_ObtainPopup(l_item, msg, ok_btn_cb)
end

-------------------------------------
-- function ItemObtainResult_Mail
-- @brief
-- @param t_ret
-------------------------------------
function ItemObtainResult_Mail(t_ret)
    ItemObtainResult(t_ret, true) -- t_ret, is_mail
end

-------------------------------------
-- function ItemObtainResult_ShowMailBox
-- @brief 받은 아이템을 우편함 형식으로 보여줌
-- @param close_cb은 우편함 팝업 띄울때만 사용
-------------------------------------
function ItemObtainResult_ShowMailBox(t_ret, select_type, close_cb)
    if (not t_ret) then
        return
    end

    -- 이 함수는 우편함으로 전송된 아이템 결과만 표시
    -- 바로 추가된 아이템이 있을 경우 기존에 사용하던 ItemObtainResult에서 결과화면 출력하도록 함
    if (t_ret['added_items']) then
        ItemObtainResult(t_ret, true)
    end

    -- 우편함으로 전송
    if (t_ret['new_mail'] == true) then
        UINavigator:goTo('mail_select', select_type, close_cb)
    end
end

--@CHECK
UI:checkCompileError(UI_ObtainPopup)
