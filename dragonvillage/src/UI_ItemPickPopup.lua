local PARENT = UI

-------------------------------------
-- class UI_ItemPickPopup
-------------------------------------
UI_ItemPickPopup = class(PARENT,{
        m_itemId = 'number',
		m_itemList = 'table',
		m_isDraw = 'boolan',

		m_focusItemId = 'item_id',
        m_mid = 'string',
        m_cbFunc = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemPickPopup:init(mid, item_id, is_draw, cb_func)
    self.m_itemId = item_id
	self.m_isDraw = is_draw
    self.m_mid = mid
    self.m_cbFunc = cb_func
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
    vars['titleLabel']:setString(Str(item_desc))

	vars['itemNode']:removeAllChildren()
	local item_card = UI_ItemCard(item_id)
	vars['itemNode']:addChild(item_card.root)

    -- 해당 안되는 아이템에는 select를 꺼줌
	for i, v in ipairs(self.m_itemList) do
		if (v['item_id'] == item_id) then
            self:setSelected(item_id, v['ui'], true)
        else
            self:setSelected(item_id, v['ui'], false)
        end
	end
	self.m_focusItemId = item_id
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_ItemPickPopup:setSelected(item_id, ui_card, is_selected)
    local table_item = TableItem()
    local t_item = table_item:get(item_id)

    -- 없다면 select_sprite를 만듬
    if (not ui_card.vars['selectSprite']) then
        local selected_sprite = cc.Sprite:create('res/ui/a2d/card/card_cha_frame_select.png')
        ui_card.vars['selectSprite'] = selected_sprite
        ui_card.vars['selectSprite']:setDockPoint(CENTER_POINT)
        ui_card.vars['selectSprite']:setAnchorPoint(CENTER_POINT)
        ui_card.root:addChild(selected_sprite)
    end

    ui_card.vars['selectSprite']:setVisible(is_selected)
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
	local item_id = self.m_focusItemId
	local name = TableItem:getItemName(item_id)
    local count = self:getItemCount(item_id)
    name = name .. 'x' .. comma_value(count)

	local msg = Str('[{1}](이)가 선택되었습니다.', name)
	local function ok_btn_cb()
		local mid = self.m_mid
		self:request_eventThankReward()
	end

	MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb)
end

-------------------------------------
-- function request_eventThankReward
-------------------------------------
function UI_ItemPickPopup:request_eventThankReward()  
    -- 파라미터
    local uid = g_userData:get('uid')
	local item_id = self.m_focusItemId

    local item_count = self:getItemCount(item_id)
	local item_str = string.format('%d;%d', item_id, item_count) -- 700001;100
    local mid = self.m_mid
	-- 콜백 함수
    local function success_cb(ret)
		if (self.m_cbFunc) then
            self.m_cbFunc(true) -- 우편함 갱신
        end

        -- 얻은 아이템 ObtainPopup으로 보여줌
        if (ret['item_info']) and (ret['item_info']['item_id']) and (ret['item_info']['count']) then
	        local l_item_list = {
            {
			    ['item_id'] = ret['item_info']['item_id'],
			    ['count'] = ret['item_info']['count']
	        }}
            local msg = Str('보상이 우편함으로 전송되었습니다.', today_step)
            local ok_btn_cb = nil
            UI_ObtainPopup(l_item_list, msg, ok_btn_cb)
        end

		self:close()
	end

    -- 콜백 함수
    local function fail_cb(ret)
	end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/pick_item')
    ui_network:setParam('uid', uid)
    ui_network:setParam('mid', mid) 
	ui_network:setParam('item', item_str)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function getItemCount
-------------------------------------
function UI_ItemPickPopup:getItemCount(item_id)
    local item_count = 0
	for i, v in ipairs(self.m_itemList) do
		if (v['item_id'] == item_id) then
			item_count = v['count']
		end
	end
    return item_count
end