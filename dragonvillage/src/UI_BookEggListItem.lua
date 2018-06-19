local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_BookEggListItem
-------------------------------------
UI_BookEggListItem = class(PARENT,{
		m_eggInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BookEggListItem:init(t_data)
    self:load('hatchery_incubate_info_item.ui')
    self.m_eggInfo = t_data

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BookEggListItem:initUI()
    local vars = self.vars
    local t_data = self.m_eggInfo

    -- 알 카드
    local egg_id = t_data['item_id']
    local ui = UI_ItemCard(tonumber(egg_id))
    vars['eggNode']:addChild(ui.root)

    -- 알 이름
    local name = TableItem():getValue(egg_id, 't_name')
    vars['eggNameLabel']:setString(name)

    -- 알 설명
    local desc = TableItem():getValue(egg_id, 't_desc')
    vars['eggInfoLabel']:setString(desc)

    -- 이동 버튼 활성화/비활성화
    local is_exist = (g_eggsData:getEggCount(egg_id) > 0)
    vars['moveBtn']:setEnabled(is_exist)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BookEggListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BookEggListItem:refresh()
	local vars = self.vars
	
end

--@CHECK
UI:checkCompileError(UI_BookEggListItem)
