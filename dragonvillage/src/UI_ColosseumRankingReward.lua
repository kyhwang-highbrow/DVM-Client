local PARENT = UI

-------------------------------------
-- class UI_ColosseumRankingReward
-------------------------------------
UI_ColosseumRankingReward = class(PARENT, {
		m_lastWeekInfo = 'str'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRankingReward:init()
    local vars = self:load('colosseum_ranking_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

	-- 멤버 변수 할당
	self.m_lastWeekInfo = g_colosseumData:getLastWeekInfo()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ColosseumRankingReward')

    self:initUI()
    self:initButton()
    self:refresh()

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
 -- function click_exitBtn
-------------------------------------
function UI_ColosseumRankingReward:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRankingReward:initUI()
    local vars = self.vars
	local tier = self.m_lastWeekInfo['tier']
	local l_tier_info = stringSplit(tier, '_')
	local tier_name = l_tier_info[1]
	local tier_grade = l_tier_info[2]

	-- 티어 이름
	local tier_full_name = ColosseumUserInfo:getTierName(tier)
    vars['tierLabel']:setString(tier_full_name)

	-- 티어 아이콘
    local tier_icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['tierNode']:addChild(tier_icon)

	-- 지난 주 순위
	local last_week_rank = self.m_lastWeekInfo['rank']
    vars['rankingLabel']:setString(Str('{1}위', last_week_rank))

	-- 보상 지급 문구
	local reward_value = TableColosseumReward():getWeeklyRewardCash(tier_name, tier_grade)
    vars['rewardLabel']:setString(reward_value)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRankingReward:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRankingReward:refresh()
end

--@CHECK
UI:checkCompileError(UI_ColosseumRankingReward)
