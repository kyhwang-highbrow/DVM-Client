local PARENT = UI

-------------------------------------
-- class UI_ItemPickPopup
-------------------------------------
UI_ItemPickPopup = class(PARENT,{
        m_itemId = 'number',
		m_itemList = 'table',
		m_isDraw = 'boolan',

		m_focusItemId = 'item_id'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemPickPopup:init(item_id, is_draw)
    self.m_itemId = item_id
	self.m_isDraw = is_draw

    local vars = self:load('popup_select_material.ui')
    UIManager:open(self, UIManager.POPUP)

	self.m_itemList = {}
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ItemPickPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ItemPickPopup:initUI()
    local vars = self.vars
    local item_id = self.m_itemId

    -- 선택권 내용물
    local table_pick_item = TABLE:get('table_pick_item')
    local t_pick_item = table_pick_item[item_id]
    local item_str = t_pick_item['item_id']

    local item_list = plSplit(item_str, ',')
    local l_pos = getPosXForCenterSortting(600, -280, #item_list, 83) -- background_width, start_pos, count, list_item_width
    for i, item_str in ipairs(item_list) do
        local l_content = plSplit(item_str, ';')
        local item_id = tonumber(l_content[1])
        local cnt = tonumber(l_content[2]) or 0	

        list_item_ui = UI_ItemCard(item_id, cnt or 0) -- 아이템 카드
        list_item_ui.root:setScale(0.55)
        list_item_ui.root:setPosition(l_pos[i], 0)
		table.insert(self.m_itemList, {['item_id'] = item_id, ['count'] = cnt, ['ui'] = list_item_ui})

		list_item_ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_select(item_id) end)
        vars['listNode']:addChild(list_item_ui.root) 
    end

	self:click_select(self.m_itemList[1]['item_id'])

	vars['okBtn']:setVisible(not self.m_isDraw)
	vars['choiceBtn']:setVisible(self.m_isDraw)
end

-------------------------------------
-- function click_select
-------------------------------------
function UI_ItemPickPopup:click_select(item_id)
	local vars = self.vars

	-- 선택한 아이템 라벨, 설명, 아이콘
	local item_name = TableItem:getItemName(item_id)
	local item_desc = TableItem:getItemDesc(item_id)
    vars['itemLabel']:setString(Str(item_name))
    vars['dscLabel']:setString(Str(item_desc))

	vars['itemNode']:removeAllChildren()
	local item_card = UI_ItemCard(item_id)
	vars['itemNode']:addChild(item_card.root)
	for i, v in ipairs(self.m_itemList) do
		if (v['ui'].vars['checkSprite']) then
			if (v['item_id'] == item_id) then	
				v['ui'].vars['checkSprite']:setVisible(true)
			else
				v['ui'].vars['checkSprite']:setVisible(false)
			end
		end
	end
	self.m_focusItemId = item_id
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ItemPickPopup:initButton()
    local vars = self.vars 
    vars['choiceBtn']:registerScriptTapHandler(function() self:click_choiceBtn() end)
	vars['okBtn']:registerScriptTapHandler(function() self:close() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_choiceBtn
-------------------------------------
function UI_ItemPickPopup:click_choiceBtn()
    self:request_eventThankReward()
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_ItemPickPopup:request_eventThankReward()  
    -- 파라미터
    local uid = g_userData:get('uid')
	local item_id = self.m_focusItemId
	local item_count = 0
	for i, v in ipairs(self.m_itemList) do
		if (v['item_id'] == item_id) then
			item_count = v['count']
		end
	end
	local mid = string.format('%d;%d', item_id, item_count)
    
	-- 콜백 함수
    local function success_cb(ret)
		-- ObtainPopup
		self:close()
	end

    -- 콜백 함수
    local function fail_cb(ret)
	end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/pick_item')
    ui_network:setParam('uid', uid)
    ui_network:setParam('mid', mid) -- 700001;100
	ui_network:setParam('item_id', self.m_itemId)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end