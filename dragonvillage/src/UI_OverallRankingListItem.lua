local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_OverallRankingListItem
-------------------------------------
UI_OverallRankingListItem = class(PARENT,{
		m_tRankInfo = '',
		m_isColosseum = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_OverallRankingListItem:init(t_data)
    self:load('total_ranking_item.ui')

	self:makeDataPretty(t_data)
	self.m_isColosseum = false

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_OverallRankingListItem:initUI()
    local vars = self.vars

	-- 랭킹
    local rank = self.m_tRankInfo['rank']

    if (rank <= 3) then
        local rank_icon = cc.Sprite:create(string.format('res/ui/icons/rank/rank_%02d.png', rank))
        rank_icon:setDockPoint(ZERO_POINT)
        rank_icon:setAnchorPoint(ZERO_POINT)
	    vars['rankNode']:addChild(rank_icon)
    else
        vars['rankingLabel'] = NumberLabel(vars['rankingLabel'], 0, COMMON_UI_ACTION_TIME)
	    vars['rankingLabel']:setNumber(rank)
    end
	
	-- 리더 드래곤 아이콘
	local dragon_icon = UI_DragonCard(self.m_tRankInfo['leader'])
	vars['iconNode']:addChild(dragon_icon.root)
	dragon_icon.root:setSwallowTouch(false)

	-- 유저 이름
	local user_name = self.m_tRankInfo['nick']
	vars['nameLabel']:setString(user_name)

	-- 스코어
	vars['scoreLabel'] = NumberLabel(vars['scoreLabel'], 0, COMMON_UI_ACTION_TIME)
	local score = self.m_tRankInfo['rp']
	vars['scoreLabel']:setNumber(score)
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
	local vars = self.vars
	
	-- 콜로세움 처리
	if (self.m_isColosseum) then
		vars['scoreLabel'].m_label:runAction(cc.MoveTo:create(COMMON_UI_ACTION_TIME/2, cc.p(-190, 0)))
		vars['pvpTierNode']:setVisible(true)

		local tier = self.m_tRankInfo['tier']
		local icon = StructUserInfoColosseum():makeTierIcon(tier, 'small')
		vars['pvpTierNode']:addChild(icon)
	end
end

-------------------------------------
-- function makeDataPretty
-------------------------------------
function UI_OverallRankingListItem:makeDataPretty(t_data)
	self.m_tRankInfo = t_data
end

-------------------------------------
-- function click_detailBtn
-------------------------------------
function UI_OverallRankingListItem:click_detailBtn()
	local is_visit = true
	RequestUserInfoDetailPopup(self.m_tRankInfo['uid'], is_visit, nil)
end

--@CHECK
UI:checkCompileError(UI_OverallRankingListItem)
