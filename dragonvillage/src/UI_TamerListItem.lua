local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TamerListItem
-------------------------------------
UI_TamerListItem = class(PARENT, {
        m_tamerData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerListItem:init(tamer_data)
    local vars = self:load('tamer_costume_tamer_item.ui')
    self.m_tamerData = tamer_data

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerListItem:initUI()
    local vars = self.vars
    local tamer_data = self.m_tamerData

    -- 이름
    vars['tamerTabLabel']:setString(tamer_data['t_name'])

    -- 이미지
    local tid = tamer_data['tid']
    local tamer_image = TableTamerCostume:getTamerSDImage(tid)
	if (tamer_image) then
        tamer_image:setDockPoint(CENTER_POINT)
        tamer_image:setAnchorPoint(CENTER_POINT)
		vars['tamerNode']:addChild(tamer_image)
	end

    -- 잠금
    local has_tamer = g_tamerData:hasTamer(tid)
    if (not has_tamer) then
        vars['lockSprite']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerListItem:initButton()
    local vars = self.vars
end