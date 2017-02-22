local PARENT = UI

-------------------------------------
-- class UI_ColosseumFirstRewardListItem
-------------------------------------
UI_ColosseumFirstRewardListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumFirstRewardListItem:init(tier_name)
    local vars = self:load('colosseum_reward_popup_item_01.ui')

    self:initUI(tier_name)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumFirstRewardListItem:initUI(tier_name)
    -- 레전드는 별도 함수 사용
    if (tier_name == 'legend') then
        self:makeLegendUI()
	elseif (tier_name == 'master') then
		self:makeMasterUI()
	else
		self:makeOtherTierUI(tier_name)
    end

	-- 보상 표시는 표시하지 않음
	self.vars['rewardSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumFirstRewardListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumFirstRewardListItem:refresh()
end

-------------------------------------
-- function makeLegendUI
-------------------------------------
function UI_ColosseumFirstRewardListItem:makeLegendUI()
    local vars = self.vars
    local table_colosseum_reward = TableColosseumReward()
	local tier_name = 'legend'

    vars['legendNode']:setVisible(true)
    vars['normalTierNode']:setVisible(false)

    -- 아이콘
    local icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['legendIcon']:addChild(icon)

    -- 최소 점수
    local min_rp = table_colosseum_reward:getMinRP('legend')
    vars['legendScoreLabel']:setString(Str('{1}점+', comma_value(min_rp)))

    -- 보상
    local cash = table_colosseum_reward:getFirstRewardCash('legend')
    vars['legendRewardLabel']:setString(Str('{1}개', comma_value(cash)))
end

-------------------------------------
-- function makeMasterUI
-------------------------------------
function UI_ColosseumFirstRewardListItem:makeMasterUI()
    local vars = self.vars
    local table_colosseum_reward = TableColosseumReward()
	
	local tier_name = 'master'
	local max_grade = 4

	-- 티어 명칭
    local tier_full_name = ColosseumUserInfo:getTierName(tier_name)
    vars['tierLabel']:setString(Str('{1}\n최초 달성 보상', tier_full_name))

	-- 아이콘
	local icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['tierNode']:addChild(icon)

    for grade = 1, max_grade do
        -- 세부 조건
        local text
        if (grade == 1) then
            text = Str('2위')
        elseif (grade == 2) then
            text = Str('3위')
        elseif (grade == 3) then
            text = Str('4~10위')
        elseif (grade == 4) then
            text = Str('11~50위')
        end
        vars['gradeLabel' .. grade]:setString(text)
        
        -- 최소 점수
        local min_rp = table_colosseum_reward:getMinRP(tier_name, grade)
        vars['scoreLabel' .. grade]:setString(Str('{1}점+', comma_value(min_rp)))

        -- 보상
        local cash = table_colosseum_reward:getFirstRewardCash(tier_name, grade)
        vars['rewardLabel' .. grade]:setString(Str('{1}개', comma_value(cash)))
    end
end

-------------------------------------
-- function makeOtherTierUI
-------------------------------------
function UI_ColosseumFirstRewardListItem:makeOtherTierUI(tier_name)
    local vars = self.vars
    local table_colosseum_reward = TableColosseumReward()
	
	local tier_name = tier_name or 'bronze'
	local max_grade = 3

	-- 4번째는 사용안함
	vars['gradeLabel4']:setVisible(false)
    vars['scoreNode4']:setVisible(false)
    vars['rewardNode4']:setVisible(false)

	-- 티어 명칭
    local tier_full_name = ColosseumUserInfo:getTierName(tier_name)
    vars['tierLabel']:setString(Str('{1}\n최초 달성 보상', tier_full_name))

	-- 아이콘
	local icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['tierNode']:addChild(icon)

    for grade = 1, max_grade do
        -- 세부 등급
        vars['gradeLabel' .. grade]:setString(Str('{1}등급', grade))
        
        -- 최소 점수
        local min_rp = table_colosseum_reward:getMinRP(tier_name, grade)
        vars['scoreLabel' .. grade]:setString(Str('{1}점+', comma_value(min_rp)))

        -- 보상
        local cash = table_colosseum_reward:getFirstRewardCash(tier_name, grade)
        vars['rewardLabel' .. grade]:setString(Str('{1}개', comma_value(cash)))
    end
end