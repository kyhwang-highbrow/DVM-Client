local PARENT = class(UI, ITableViewCell:getCloneTable())
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
	local did = self.m_tRankInfo

	-- 랭킹
	local rank = self.m_tRankInfo['rank']
	vars['rankingLabel']:setString(rank)

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
		vars['scoreLabel'].m_label:setPositionX(-190)
		vars['pvpTierNode']:setVisible(true)

		local tier = self.m_tRankInfo['tier']
		local icon = ColosseumUserInfo:makeTierIcon(tier, 'small')
		vars['pvpTierNode']:addChild(icon)
	end
end

-------------------------------------
-- function click_detailBtn
-------------------------------------
function UI_OverallRankingListItem:makeDataPretty(t_data)
	self.m_tRankInfo = t_data
end

-------------------------------------
-- function click_detailBtn
-------------------------------------
function UI_OverallRankingListItem:click_detailBtn()
	ccdisplay('유저 상세 정보 보기는 준비중입니다.')
end

--@CHECK
UI:checkCompileError(UI_OverallRankingListItem)
