local PARENT = UI

local structLeaderBoard

-------------------------------------
-- class UI_ResultLeaderBoard_IncarnationOfSins
-------------------------------------
UI_ResultLeaderBoard_IncarnationOfSins = class(PARENT, {
        m_type = 'string', -- clan_raid, incarnation_of_sins

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

-- 앞/뒤 순위 정보 없을 때 자신의 점수에서 해당 값을 뺀 값을 뒤 순위 점수, 더한 점수를 앞 순위 점수로 사용
local DEFAULT_GAP = 1000000

-------------------------------------
-- function init
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:init(type, is_popup, is_move)
    local vars = self:load('rank_ladder_item_reward.ui')
    
    self.m_isPopup = is_popup
    if (is_popup) then -- is_popup 이 false인 경우 : UI_EventFullPopup에 노드 매달아서 사용하는 형태
        UIManager:open(self, UIManager.POPUP)
        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ResultLeaderBoard_IncarnationOfSins') 
    end

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self.m_type = type

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:initUI()
    local vars = self.vars 

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:initButton()
    self.vars['closeBtn']:setVisible(self.m_isPopup)
    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:refresh()
end

-------------------------------------
-- function setCurrentInfo
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:setCurrentInfo()
    local vars = self.vars
    local type = self.m_type

    vars['gaugeSprite']:setVisible(self.m_isPopup)

    -- 현재 점수
    vars['scoreLabel']:setString(Str('{1}점', comma_value(self.m_cur_score)))     -- 점수
    
    -- 현재 랭킹
    vars['rankLabel']:setString(Str('{1}위', comma_value(self.m_cur_rank)))       -- 랭킹

    -- 보상 아이템
    if g_eventIncarnationOfSinsData then
        vars['rewardMenu']:removeAllChildren()

        local cur_reward_data = g_eventIncarnationOfSinsData:getPossibleReward_IncarnationsOfSins(self.m_cur_rank, self.m_cur_ratio)
        local l_reward_data = g_itemData:parsePackageItemStr(cur_reward_data['reward'])
        local reward_size = table.count(l_reward_data)
        local icon_size = 150
        local icon_scale = 0.666
        local icon_interval = 5
        local l_ui_pos_list = getSortPosList((icon_size * icon_scale) + icon_interval, reward_size)

        for idx, item_info in ipairs(l_reward_data) do
            local item_id = item_info['item_id']
            local count = item_info['count']
            local ui = UI_ItemCard(item_id, count)
            ui.root:setScale(icon_scale)

            local node_name = 'rewardNode' .. idx
            vars['rewardMenu']:addChild(ui.root)
            ui.root:setPositionX(l_ui_pos_list[idx])
        end
    end

    if (self.m_tUpperRank) then
        -- 앞 순위 유저
        local ui_upper = UI_ResultLeaderBoard_IncarnationOfSinsListItem(type, self.m_tUpperRank, false)
        if (ui_upper) then
            vars['upperNode']:addChild(ui_upper.root)
        end
    end

    if (self.m_tLowerRank) then
        -- 뒤 순위 유저
        local ui_lower = UI_ResultLeaderBoard_IncarnationOfSinsListItem(type, self.m_tLowerRank, false) -- type, t_data, is_me,
        if (ui_lower) then
            vars['lowerNode']:addChild(ui_lower.root)
        end
    end

    if (self.m_tMeRank) then
        -- 자기 자신
        local ui_me = UI_ResultLeaderBoard_IncarnationOfSinsListItem(type, self.m_tMeRank, true)
        if (ui_me) then
            vars['meNode']:addChild(ui_me.root)
        end
    end

    vars['meNode']:setLocalZOrder(1)
end

-------------------------------------
-- function setChangeInfo
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:setChangeInfo()
    local vars = self.vars
    local type = self.m_type

    vars['gaugeSprite']:setVisible(self.m_isPopup)

    -- 콤마 라벨
    local score_tween_cb = function(number, label)
        local number = math.floor(number)
        label:setString(Str('{1}점', comma_value(number)))
    end
    
    -- 현재 점수
    local score_label = NumberLabel(vars['scoreLabel'], 0, 2)
    score_label:setTweenCallback(score_tween_cb)
    score_label:setNumber(self.m_before_score, true)
    score_label:setNumber(self.m_cur_score, false)


    local rank_tween_cb = function(number, label)
        local number = math.floor(number)
        label:setString(Str('{1}위', number))
    end

    -- 현재 랭킹
    local rank_label = NumberLabel(vars['rankLabel'], 0, 2)
    rank_label:setTweenCallback(rank_tween_cb)
    rank_label:setNumber(self.m_before_rank, true)
    rank_label:setNumber(self.m_cur_rank, false)

     -- + 콤마 라벨
    local diff_tween_cb = function(number, label)
        local number = math.floor(number)
        if (number > 0) then
            label:setString(string.format('+'..comma_value(number)))
        else
            label:setString(string.format(comma_value(number)))
        end
    end
    
    -- 점수 없을 때
    if (self.m_before_score == -1) then
        self.m_before_score = 0    
    end


    -- 랭킹 없을 때
    if (self.m_before_rank == -1) then
        self.m_before_rank = self.m_cur_rank
    end
end

-------------------------------------
-- function startMoving
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:startMoving()
    local vars = self.vars

    local cur_posX, cur_gap_per = self:getScorePosX(self.m_cur_score)
    local ex_posX, ex_gap_per = self:getScorePosX(self.m_before_score)
    local lower_score = self.m_cur_score - DEFAULT_GAP

    if (self.m_tLowerRank) then
        lower_score = self.m_tLowerRank['score']
    end
   
    -- 뒤 순위를 초월한 경우, 시작 위치 100으로 고정
    if (self.m_before_score < lower_score) then
        ex_posX = 100
    end
    
    -- 내 노드 움직임
    local action = cc.EaseOut:create(cc.MoveTo:create(2, cc.p(cur_posX, 0)), 2)
    vars['meNode']:setPositionX(ex_posX)
    vars['meNode']:runAction(action)

    -- 게이지 위치 초기화
    vars['gaugeSprite']:setPositionX(ex_posX + 34)
    vars['gaugeSprite']:setScale(0, 1)
    
    -- cur_pos까지 스프라이트 크기를 키우려면 : x스케일 = 원하는 길이 / 리소스 길이
    local target_scale = (cur_posX - ex_posX)/790
    local action = cc.EaseOut:create(cc.ScaleTo:create(2, target_scale, 1), 2)
    vars['gaugeSprite']:runAction(action)

    self:setChangeInfo()
end

-------------------------------------
-- function getScorePosX
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:getScorePosX(score)
    local vars = self.vars   
    local posX_upper = vars['upperNode']:getPositionX() 
    local posX_lower = vars['lowerNode']:getPositionX()

    -- 앞/뒤 순위 노드 간 간격
    local pos_gap = math.abs(posX_upper - posX_lower)
     
    local upper_score = self.m_cur_score + DEFAULT_GAP
    -- 최고 랭킹 디폴트
    if (self.m_tUpperRank) then
        upper_score = self.m_tUpperRank['score']
    end

    local lower_score = self.m_cur_score - DEFAULT_GAP
    -- 최저 랭킹 디폴트
    if (self.m_tLowerRank) then
        lower_score = self.m_tLowerRank['score']
    end

    -- 앞/뒤 순위 랭크 간격
    local score_gap = upper_score - lower_score

    -- 앞/뒤 랭크중 해당 점수가 어디에 위치하는지 퍼센트 계산
    local score_me_gap =  score - lower_score
    local gap_per = score_me_gap/ math.abs(score_gap)

    -- 해당 순위 위치 계산
    local posX_me = posX_lower + (pos_gap * gap_per)
     
    return posX_me, gap_per
end

-------------------------------------
-- function getClanRaidRewardCnt
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:getClanRaidRewardCnt(reward_data)
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
function UI_ResultLeaderBoard_IncarnationOfSins:setScore(add_score, current_score)
    if (not add_score) or (not current_score) then
        self.m_before_score = 0
        self.m_cur_score = 0
        return
    end
    self.m_before_score = tonumber(current_score) - tonumber(add_score)
    self.m_cur_score = tonumber(current_score)
end

-------------------------------------
-- function setRank
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:setRank(before, current)
    self.m_before_rank = tonumber(before)
    self.m_cur_rank = tonumber(current)
end

-------------------------------------
-- function setRatio
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:setRatio(before, current)
    self.m_before_ratio = tonumber(before)
    self.m_cur_ratio = tonumber(current)
end

-------------------------------------
-- function setRanker
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:setRanker(upper, me, lower)
    self.m_tUpperRank = upper
    self.m_tMeRank = me
    self.m_tLowerRank = lower

end


-------------------------------------
-- function testFunction
-- @brief 개발을 위해 임의로 결과 화면을 호출할 때 사용
-------------------------------------
function UI_ResultLeaderBoard_IncarnationOfSins:testFunction()
    local ret_json, success_load = TABLE:loadJsonTable('incarnation_of_sinsfinish_finish', '.txt')
        
    local uid = 'DVM_CLIENT_TEST'

    local m_lCloseRankers = {}
    m_lCloseRankers['me_ranker'] = nil
    m_lCloseRankers['upper_ranker'] = nil
    m_lCloseRankers['lower_rank'] = nil

    for _,data in ipairs(ret_json['rank_list']) do
        if (data['uid'] == uid) then
            m_lCloseRankers['me_ranker'] = data
        end
    end

    local my_rank = m_lCloseRankers['me_ranker']['rank']
    local upper_rank = my_rank - 1
    local lower_rank = my_rank + 1

    for _,data in ipairs(ret_json['rank_list']) do
        if (tonumber(data['rank']) == tonumber(upper_rank)) then
            m_lCloseRankers['upper_ranker'] = data
        end

        if (tonumber(data['rank']) == tonumber(lower_rank)) then
            m_lCloseRankers['lower_rank'] = data
        end
    end

    -- 게임 후, 앞/뒤 랭커 정보
    local t_upper, t_me, t_lower = m_lCloseRankers['upper_ranker'], m_lCloseRankers['me_ranker'], m_lCloseRankers['lower_rank']

    local t_ex_me = nil
    if (not t_ex_me) then -- 처음 때린 사람
        t_ex_me = {['score'] = 0, ['rank'] = t_me['rank'] + 1000, ['rate'] = 1}
    end

    local ui_leader_board = UI_ResultLeaderBoard_IncarnationOfSins('incarnation_of_sins', true, true) -- type, is_move, is_popup
    ui_leader_board:setScore(t_me['score'] - t_ex_me['score'], t_me['score']) -- param : 더해진 점수, 더해진 점수가 반영된 최종 점수
    ui_leader_board:setRatio(t_ex_me['rate'], t_me['rate'])
    ui_leader_board:setRank(t_ex_me['rank'], t_me['rank'])
    ui_leader_board:setRanker(t_upper, t_me, t_lower)
    ui_leader_board:setCurrentInfo()
    ui_leader_board:startMoving()
end

--@CHECK
UI:checkCompileError(UI_ResultLeaderBoard_IncarnationOfSins)
