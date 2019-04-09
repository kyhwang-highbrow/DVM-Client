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
        
        m_tUpperRank = 'table',
        m_tMeRank = 'table',
        m_tLowerRank = 'table',

        m_isPopup = 'boolean',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeaderBoard:init(type, is_popup)
    local vars = self:load('rank_ladder.ui')
    self.m_isPopup = is_popup
    if (is_popup) then -- is_popup 이 false인 경우 : UI_EventFullPopup에 노드 매달아서 사용하는 형태
        UIManager:open(self, UIManager.POPUP)
        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResultLeaderBoard') 
    end

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
    self.vars['closeBtn']:setVisible(self.m_isPopup)
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

    vars['gaugeSprite']:setVisible(self.m_isPopup)

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


    -- 앞 순위 유저
    local ui_upper = UI_ResultLeaderBoardListItem(type, '캐논쥬비터', 1, 10000, false, sub_data)
    vars['upperNode']:addChild(ui_upper.root)

    -- 자기 자신
    local ui_me = UI_ResultLeaderBoardListItem(type, '도롱이', 4, 8000, true, sub_data)
    vars['meNode']:addChild(ui_me.root)

    -- 뒤 순위 유저
    local ui_lower = UI_ResultLeaderBoardListItem(type, '찬란한혜택', 5, 1000, false, sub_data) -- type, user_name, rank, score, is_me, sub_data
    vars['lowerNode']:addChild(ui_lower.root)

end

-------------------------------------
-- function startMoving
-------------------------------------
function UI_ResultLeaderBoard:startMoving()
    local vars = self.vars

    local cur_posX, cur_gap_per = self:getScorePosX(self.m_cur_score)
    local ex_posX, ex_gap_per = self:getScorePosX(self.m_before_score)
    
    -- 뒤 순위를 초월한 경우, 시작 위치 100으로 고정
    if (self.m_before_score < self.m_tLowerRank.score) then
        ex_posX = 100
    end

    -- 내 노드 움직임
    local action = cc.MoveTo:create(2, cc.p(cur_posX, 50))
    vars['meNode']:setPositionX(ex_posX)
    vars['meNode']:runAction(action)

    -- 게이지 위치 초기화
    vars['gaugeSprite']:setPositionX(ex_posX + 50)
    vars['gaugeSprite']:setScale(0, 2)
    
    -- cur_pos까지 스프라이트 크기를 키우려면 : x스케일 = 원하는 길이 / 리소스 길이
    local target_scale = (cur_posX - ex_posX - 25)/592
    local action = cc.ScaleTo:create(2, target_scale, 2)
    vars['gaugeSprite']:runAction(action)
end

-------------------------------------
-- function getScorePosX
-------------------------------------
function UI_ResultLeaderBoard:getScorePosX(score)
     local vars = self.vars   
     local posX_upper = vars['upperNode']:getPositionX() 
     local posX_lower = vars['lowerNode']:getPositionX()
     
     -- 앞/뒤 순위 노드 간 간격
     local pos_gap = math.abs(posX_upper - posX_lower)
     
     -- 앞/뒤 순위 랭크 간격
     local score_gap = self.m_tUpperRank['score'] - self.m_tLowerRank['score']
     
     -- 앞/뒤 랭크중 해당 순위가 어디에 위치하는지 퍼센트 계산
     local score_me_gap =  score - self.m_tLowerRank['score']
     local gap_per = score_me_gap/ math.abs(score_gap)
     
     -- 해당 순위 위치 계산
     local posX_me = posX_lower + (pos_gap * gap_per)
     
     return posX_me, gap_per
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
-- function setRanker
-------------------------------------
function UI_ResultLeaderBoard:setRanker(upper, me, lower)
    self.m_tUpperRank = upper
    self.m_tMeRank = me
    self.m_tLowerRank = lower
end



-------------------------------------
-- function makeLeaderBoard
-------------------------------------
function makeLeaderBoard(type, is_move) 
    local t_upper = {rank = 1, score = 10000}
    local t_lower = {rank = 5, score = 1000}
    local t_me = {rank = 4, score = 8000}

    -- @jhakim 190409 애니메이션 들어가서 움직이는 건 무조건 팝업형태라고 가정
    local is_popup = is_move

    local ui_leader_board = UI_ResultLeaderBoard(type, is_popup)
    if (type =='clan_raid') then
        ui_leader_board:setScore(0, 8000)
        ui_leader_board:setRatio(0.0, 0.3)
        ui_leader_board:setRank(7, 4)
        ui_leader_board:setRanker(t_upper, t_me, t_lower)
        ui_leader_board:setCurrentInfo()
    end

    if (is_move) then
        ui_leader_board:startMoving()
    end

    return ui_leader_board
end



--@CHECK
UI:checkCompileError(UI_ResultLeaderBoard)
