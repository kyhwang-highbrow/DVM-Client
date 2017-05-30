local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonBoardListItem
-------------------------------------
UI_DragonBoardListItem = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardListItem:init(t_data)
    -- UI load
	self:load('dragon_board_item.ui')

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonBoardListItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardListItem:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonBoardListItem)
