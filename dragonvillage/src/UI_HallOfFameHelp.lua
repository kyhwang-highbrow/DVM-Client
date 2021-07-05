local PARENT = UI

-------------------------------------
-- class UI_HallOfFameHelp
-------------------------------------
UI_HallOfFameHelp = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameHelp:init()
    local vars = self:load('help_hall_of_fame.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFameHelp')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameHelp:initUI()
    local vars = self.vars
	
	local idx = 1
	local create_cb_func = function(ui, data)
		ui.vars['secondSprite']:setVisible(idx%2 == 0)
		idx = idx + 1
	end

	local t_rank = TABLE:get('table_halloffame_rank')
    local l_rank = table.MapToList(t_rank)

    local sort_func = function(a, b)
        return a['rank_id'] < b['rank_id']
    end

    -- 테이블 정렬
    table.sort(l_rank, sort_func)


	-- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['scoreScrollNode'])
    table_view.m_defaultCellSize = cc.size(765, 45)
    table_view:setCellUIClass(UI_HallOfFameHelpListItem, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameHelp:initButton()
    local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end




local PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_HallOfFameHelpListItem
-------------------------------------
UI_HallOfFameHelpListItem = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameHelpListItem:init(data)
    local vars = self:load('help_hall_of_fame_item.ui')
	self:initUI(data)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameHelpListItem:initUI(data)
	local vars = self.vars
	local min = data['rank_min']
	local max = data['rank_max']
	local rank_str = ''
	if (min == max) then
		rank_str =  Str('{1}위', min)
	else
		rank_str = string.format('%d ~ %s', min, Str('{1}위', max))
	end

	vars['rankLabel']:setString(rank_str)
	vars['arenaScoreLabel']:setString(tostring(data['point_arena']))
	vars['towerScoreLabel']:setString(tostring(data['point_ancient']))
	--vars['challengeScoreLabel']:setString(tostring(data['point_challenge']))
end

 

