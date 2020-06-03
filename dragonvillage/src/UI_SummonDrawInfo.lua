local PARENT = UI

-------------------------------------
-- class UI_SummonDrawInfo
-------------------------------------
UI_SummonDrawInfo = class(PARENT,{
		m_item_id = 'number',
        m_is_draw = 'bool',
        m_draw_cb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SummonDrawInfo:init(item_id, is_draw)
	local vars = self:load('package_global_anniversary_popup.ui')
	UIManager:open(self, UIManager.POPUP)
    self.m_item_id = item_id
    self.m_is_draw = is_draw

    if (not item_id) then
        self.m_item_id = 700601 -- defult : 토파즈 뽑기권
    end

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SummonDrawInfo')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SummonDrawInfo:initUI()
	local vars = self.vars
    local is_draw = self.m_is_draw
    local item_id = self.m_item_id

    -- 아이템 이름
    local item_name = TableItem:getItemName(item_id)
    vars['titleLabel']:setString(Str(item_name))

    -- 뽑기권 내용물
    local dragon_list_str = TablePickDragon:getCustomList(self.m_item_id)
    local dragon_list = plSplit(dragon_list_str, ',') -- 122023, 122323 .. 형식의 드래곤 아이디를 리스트로

    local ui_res = 'package_global_anniversary_popup_item.ui'
    local l_pos = getPosXForCenterSortting(1150, -430, #dragon_list, 287) -- background_width, start_pos, count, list_item_width
    for i, dragon_id in ipairs(dragon_list) do
        local list_item_ui = UI_DragonInfoListItem(dragon_id, ui_res)
        list_item_ui.root:setPosition(l_pos[i] ,0)
        vars['itemNode']:addChild(list_item_ui.root)       
    end

    -- 뽑기 버튼 or 확인(닫기) 버튼
    vars['okBtn']:setVisible(not is_draw)
    vars['summonBtn']:setVisible(is_draw)

    local make_func = function(did)
        local card_ui = MakeSimpleDragonCard(tonumber(did))
        card_ui.root:setScale(0.66)
        card_ui.vars['clickBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(tonumber(did), nil, 1, 0.8, true) end)      
        return card_ui
    end

    -- 뽑기권 내용물 드래곤 카드 세팅
    local dragon_cnt = #dragon_list
    local bg_width = vars['listTableNode']:getNormalSize()
    local bg_pos_x = vars['listTableNode']:getPositionX()
    local start_pos = bg_pos_x - bg_width/2 + 45
    local list_item_width = 100
    local l_pos_x = getPosXForCenterSortting(bg_width, start_pos, dragon_cnt, list_item_width)

    for i=1, dragon_cnt do
        local ui_item_card = make_func(dragon_list[i])
        ui_item_card.root:setPositionX(l_pos_x[i])
        vars['listTableNode']:addChild(ui_item_card.root)
    end
end

-------------------------------------
-- function setDrawCb
-------------------------------------
function UI_SummonDrawInfo:setDrawCb(draw_cb)
	self.m_draw_cb = draw_cb
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SummonDrawInfo:initButton()
	local vars = self.vars
	
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
    vars['summonBtn']:registerScriptTapHandler(function() self:click_summon() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SummonDrawInfo:refresh()
	local vars = self.vars

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SummonDrawInfo:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_summon
-------------------------------------
function UI_SummonDrawInfo:click_summon()
    if (self.m_draw_cb) then
        self.m_draw_cb()
    end
    self:close()
end


--@CHECK
UI:checkCompileError(UI_SummonDrawInfo)
