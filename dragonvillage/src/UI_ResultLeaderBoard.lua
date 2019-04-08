local PARENT = UI

local structLeaderBoard

-------------------------------------
-- class UI_ResultLeaderBoard
-------------------------------------
UI_ResultLeaderBoard = class(PARENT, {
        m_before_rank = 'number',
        m_cur_rank = 'number',
        m_before_ratio = 'number',
        m_cur_ratio = 'number',
        m_before_score = 'number',
        m_cur_score = 'number',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeaderBoard:init(type)
    local vars = self:load('rank_ladder.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResultLeaderBoard')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResultLeaderBoard:initUI()
    local vars = self.vars 

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ResultLeaderBoard:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ResultLeaderBoard:refresh()
end

-------------------------------------
-- function setCurrentInfo
-------------------------------------
function UI_ResultLeaderBoard:setCurrentInfo()
    local vars = self.vars

    -- 현재 점수
    vars['scoreLabel']:setString(comma_value(self.m_cur_score))        -- 점수
    vars['scoreDifferLabel']:setString('')
    --vars['scoreDifferLabel']:setString(comma_value(self.m_cur_score - self.m_before_score))  -- 점수 차이
     
    -- 현재 랭킹
    vars['rankLabel']:setString(comma_value(self.m_cur_rank))       -- 랭킹
    vars['rankDifferLabel']:setString('')
    --vars['rankDifferLabel']:setString(comma_value(self.m_before_rank - self.m_cur_rank)) -- 랭킹 차이

    local cur_reward_data = g_clanRaidData:possibleReward_ClanRaid(self.m_cur_rank, self.m_cur_ratio)
    local cur_reward_1_cnt, cur_reward_2_cnt  = self:getClanRaidRewardCnt(cur_reward_data)
   
    -- 현재 보상1
    -- vars['rewardNode1']:setString(blankValue)   -- 아이콘 노드
    vars['rewardLabel1']:setString(comma_value(cur_reward_1_cnt))  -- 보상1 갯수
    vars['rewardLabel2']:setString('')  -- 보상1 차이
    vars['rewardLabel3']:setString(comma_value(cur_reward_2_cnt))  -- 보상2 갯수
    vars['rewardLabel4']:setString('')  -- 보상2 차이


    -- 
    local ui_upper = UI_ResultLeaderBoardListItem(type, '찬란한혜택', 5, 100, false, sub_data) -- type, user_name, rank, score, is_me, sub_data
    vars['upperNode']:addChild(ui_upper.root)

    local ui_me = UI_ResultLeaderBoardListItem(type, '도롱이', 3, 300, true, sub_data)
    vars['meNode']:addChild(ui_me.root)

    local ui_lower = UI_ResultLeaderBoardListItem(type, '캐논쥬비터', 1, 500, false, sub_data)
    vars['lowerNode']:addChild(ui_lower.root)

end

-------------------------------------
-- function getClanRaidRewardCnt
-------------------------------------
function UI_ResultLeaderBoard:getClanRaidRewardCnt(reward_data)
    if (not reward_data) then
        return 0, 0
    end
    --[[  
      "clan_exp":"",
      "category":"colosseum",
      "t_name":"2위~5위",
      "ratio_min":"",
      "rank_min":2,
      "ratio_max":"",
      "rank_max":5,
      "reward_value":"",
      "week":1,
      "rank_id":2002,
      "reward":"clancoin;90"
    --]]
    
    local cur_reward_1_cnt = 0
    local cur_reward_2_cnt = 0

    -- 클랜 코인   
    local l_reward = plSplit(reward_data['reward'], ';')
    if (l_reward[2]) then
        cur_reward_1_cnt = l_reward[2]
    end

    -- 클랜 경험치
    if (reward_data['clan_exp']) then
        cur_reward_2_cnt = reward_data['clan_exp']
    end

    return tonumber(cur_reward_1_cnt), tonumber(cur_reward_2_cnt)
end


-------------------------------------
-- function setScore
-------------------------------------
function UI_ResultLeaderBoard:setScore(before, current)
    self.m_before_score = tonumber(before)
    self.m_cur_score = tonumber(current)
end

-------------------------------------
-- function setRank
-------------------------------------
function UI_ResultLeaderBoard:setRank(before, current)
    self.m_before_rank = tonumber(before)
    self.m_cur_rank = tonumber(current)
end

-------------------------------------
-- function setRatio
-------------------------------------
function UI_ResultLeaderBoard:setRatio(before, current)
    self.m_before_ratio = tonumber(before)
    self.m_cur_ratio = tonumber(current)
end



-------------------------------------
-- function makeLeaderBoard
-------------------------------------
function makeLeaderBoard(type, is_move)
    
    local ui_leader_board = UI_ResultLeaderBoard(type)
    if (type =='clan_raid') then
        ui_leader_board:setScore(0, 100)
        ui_leader_board:setRatio(0.0, 0.3)
        ui_leader_board:setRank(1, 10)
        ui_leader_board:setCurrentInfo()
    end
end



--@CHECK
UI:checkCompileError(UI_ResultLeaderBoard)
