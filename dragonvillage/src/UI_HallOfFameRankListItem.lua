local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_HallOfFameRankListItem
-------------------------------------
UI_HallOfFameRankListItem = class(PARENT,{
		m_tRankInfo = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameRankListItem:init(data)
    local vars = self:load('hall_of_fame_rank_popup_item.ui')
	self.m_tRankInfo = data
    
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
function UI_HallOfFameRankListItem:initUI()
    local vars = self.vars

	-- 랭킹
    local rank = self.m_tRankInfo['rank']
    vars['rankingLabel'] = NumberLabel(vars['rankingLabel'], 0, COMMON_UI_ACTION_TIME)
	vars['rankingLabel']:setNumber(rank)

	
	-- 리더 드래곤 아이콘
	local dragon_icon = UI_DragonCard(self.m_tRankInfo['leader'])
	vars['profileNode']:addChild(dragon_icon.root)
	dragon_icon.root:setSwallowTouch(false)

	-- 유저 이름
	local user_name = self.m_tRankInfo['nick']
	vars['userLabel']:setString(user_name)

	-- 스코어
	vars['scoreLabel'] = NumberLabel(vars['scoreLabel'], 0, COMMON_UI_ACTION_TIME)
	local score = self.m_tRankInfo['rp']
	vars['scoreLabel']:setNumber(score)

	vars['meSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameRankListItem:initButton()
    local vars = self.vars
	--vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)
	--vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_detailBtn
-------------------------------------
function UI_HallOfFameRankListItem:click_detailBtn()
	local is_visit = true
	RequestUserInfoDetailPopup(self.m_tRankInfo['uid'], is_visit, nil)
end