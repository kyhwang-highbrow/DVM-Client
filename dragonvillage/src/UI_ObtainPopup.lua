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
function UI_ObtainPopup:init(l_item, msg, ok_btn_cb)
    local vars = self:load('popup_obtain.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_ObtainPopup')

	-- initialize
	self.m_lItemList = l_item
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

    self:closeWithAction()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ObtainPopup:createListUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('obtain_item.ui')
	local item_id = t_data['item_id']
	local item_cnt = t_data['count']
		
	-- item icon
	local item_card = UI_ItemCard(item_id, item_cnt)
	if (item_card) then
		vars['itemNode']:addChild(item_card.root)
	end

	-- item label
	local item_name = TableItem:getItemName(item_id)
	local item_str = Str('{1} {2}개를 획득했습니다.', item_name, item_cnt)
	vars['countLabel']:setString(item_str)

	return ui
end

--@CHECK
UI:checkCompileError(UI_ObtainPopup)
