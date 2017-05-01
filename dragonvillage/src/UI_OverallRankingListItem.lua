local PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_OverallRankingListItem
-------------------------------------
UI_OverallRankingListItem = class(PARENT,{
		m_tInfo = '',
		m_rank = 'num'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_OverallRankingListItem:init(t_data)
    self:load('total_ranking_item.ui')
	
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_OverallRankingListItem:initUI()
    local vars = self.vars
	local did

	-- 랭킹
	local rank = self.m_tDragonInfo['rank']
	vars['rankingLabel']:setString(rank)

	-- 드래곤 아이콘
	local dragon_icon = UI_DragonCard(t_dragon_info)
	vars['iconNode']:addChild(dragon_icon.root)
	dragon_icon.root:setSwallowTouch(false)

	-- 드래곤 이름
	local dragon_name = TableDragon:getDragonName(did)
	vars['nameLabel']:setString(dragon_name)

	-- 스코어
	local score = 0
	vars['scoreLabel']:setString(score)

	-- 콜로세움 티어 아이콘
	--vars['pvpTierNode']
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_OverallRankingListItem:initButton()
    local vars = self.vars
	vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_OverallRankingListItem:refresh()
end

-------------------------------------
-- function click_detailBtn
-------------------------------------
function UI_OverallRankingListItem:click_detailBtn(ui_quest_popup)
	ccdisplay('ㅎㅎㅎㅎ')
end

--@CHECK
UI:checkCompileError(UI_OverallRankingListItem)
