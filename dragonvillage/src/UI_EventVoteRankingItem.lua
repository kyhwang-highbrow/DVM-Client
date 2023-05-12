local PARENT = class(UI, ITableViewCell:getCloneTable())
local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_EventVoteRankingItem
-------------------------------------
UI_EventVoteRankingItem = class(PARENT, {
        m_structDragon = 'StructDragonObject',
		m_logKey = 'str',
		m_voteSum = 'num',
		m_rank = 'num',
        m_score = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteRankingItem:init(t_data, sum)
    local t_dragon_data = {}
    t_dragon_data['did'] = t_data['did']
    t_dragon_data['evolution'] = 3
    t_dragon_data['grade'] = 7

    self.m_rank = t_data['rank']
    self.m_score = t_data['score']
    self.m_structDragon = StructDragonObject(t_dragon_data)
	self.m_voteSum = sum

    if self.m_rank <= 5 then    
	    self:load('event_vote_ticket_ranking_item_01.ui')
    else
        self:load('event_vote_ticket_ranking_item_02.ui')
    end

	-- UI 초기화
    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteRankingItem:initUI()
	local vars = self.vars
    local struct_dragon = self.m_structDragon
    
	-- dragon icon
	local ui = UI_DragonCard(struct_dragon)

	if self.m_rank <= 1 then
		ui.root:setScale(0.9)
		ui.root:setPositionY(100)
	elseif self.m_rank <= 5 then
		ui.root:setScale(0.8)
		ui.root:setPositionY(80)
	else
		ui.root:setScale(0.88)
	end	

	vars['dragonIconNode']:addChild(ui.root)
	
	-- 랭킹
	if vars['rankLabel'] ~= nil then
		vars['rankLabel'] = NumberLabel(vars['rankLabel'], 0, COMMON_UI_ACTION_TIME)
	end

	-- 이름
	if vars['dragonNameLabel'] ~= nil then
		vars['dragonNameLabel']:setString(TableDragon:getDragonName(struct_dragon.did))
	end
	
	-- 누적 damage
	if vars['gaugeLabel'] ~= nil then
		vars['gaugeLabel'] = NumberLabel_Pumping(vars['gaugeLabel'], 0, COMMON_UI_ACTION_TIME)
	end
		
	-- 누적 damage
	if vars['countLabel'] ~= nil then
		vars['countLabel'] = NumberLabel_Pumping(vars['countLabel'], 0, COMMON_UI_ACTION_TIME)
	end
end

-------------------------------------
-- function initGauge
-------------------------------------
function UI_EventVoteRankingItem:initGauge()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteRankingItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteRankingItem:refresh()
	local vars = self.vars

	-- 게이지 초기화
	self:initGauge()

	if vars['gaugeLabel'] ~= nil then
		vars['gaugeLabel']:setNumber(self.m_score)
	end

	-- 랭킹
	if vars['rankLabel'] ~= nil then
		vars['rankLabel']:setNumber(self.m_rank)
	end

	-- 퍼센트
	local percentage = (self.m_score/self.m_voteSum) * 100
	if vars['pickRateLabel'] ~= nil then
		vars['pickRateLabel']:setString(string.format('%0.2f%%', percentage))
	end

	-- 투표 수
	if vars['countLabel'] ~= nil then
		vars['countLabel']:setNumber(self.m_score)
	end

	-- 누적 수치의 비율	
	local gauge_node = vars['pickRateGauge']
	if gauge_node ~= nil then
		gauge_node:setPercentage(0)
		gauge_node:runAction(cc.ProgressTo:create(COMMON_UI_ACTION_TIME, percentage))
	end
end