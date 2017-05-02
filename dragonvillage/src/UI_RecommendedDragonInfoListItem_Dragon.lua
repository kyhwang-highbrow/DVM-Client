local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RecommendedDragonInfoListItem_Dragon
-------------------------------------
UI_RecommendedDragonInfoListItem_Dragon = class(PARENT,{
		m_tDragonInfo = ''
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:init(t_data)
    self:load('dragon_ranking_dragon_item.ui')

	self.m_tDragonInfo = t_data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:initUI()
    local vars = self.vars
	local did = self.m_tDragonInfo['did']

	-- 순위
	local rank = self.m_tDragonInfo['rank']
	vars['rankingLabel']:setString(rank)

	-- 드래곤 카드
	local dragon_icon = MakeSimpleDragonCard(did)
	vars['dragonNode']:addChild(dragon_icon.root)
	dragon_icon.root:setSwallowTouch(false)

	-- 드래곤 이름
	local dragon_name = TableDragon:getDragonName(did)
	vars['nameLabel']:setString(dragon_name)

	-- 퍼센트
	local percent = self.m_tDragonInfo['percent']
	vars['rankingGaugeLabel']:setString(string.format('%.2f%%', percent))
	
	-- 게이지 (액션)
	vars['rankingGauge']:setPercentage(0)
	vars['rankingGauge']:runAction(cc.ProgressTo:create(0.3, percent))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:refresh()
end

--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoListItem_Dragon)
