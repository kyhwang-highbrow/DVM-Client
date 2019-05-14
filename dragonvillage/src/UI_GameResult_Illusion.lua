local PARENT = UI_GameResult_AncientTower

-------------------------------------
-- class UI_GameResult_Illusion
-------------------------------------
UI_GameResult_Illusion = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_Illusion:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open, score_calc, ex_score)
   
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameResult_Illusion:initUI()
    local vars = self.vars

    do -- NumberLabel 초기화, 게임 플레이 시간, 획득 골드
        self.m_lNumberLabel = {}
        self.m_lNumberLabel['time'] = NumberLabel(vars['timeLabel'], 0, 1)
        self.m_lNumberLabel['gold'] = NumberLabel(vars['goldLabel'], 0, 1)
    end

    do
        -- 스테이지 이름
        local str = g_stageData:getStageName(1911001)
        vars['titleLabel']:setString(str)

        -- 스테이지 난이도를 표시
        self:init_difficultyIcon(1911001)
    end

    -- 레벨업 연출 클래스 리스트
    self.m_lLevelupDirector = {}

    self:doActionReset()
    self:doAction()

    vars['itemAutoBtn']:setVisible(false)
    vars['itemAutoLabel']:setVisible(false)
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
-------------------------------------
function UI_GameResult_Illusion:init_difficultyIcon(stage_id)
    local vars = self.vars

    local difficulty = 1

    -- 난이도
    if (difficulty == 1) then
        vars['difficultySprite']:setColor(COLOR['diff_normal'])
        vars['gradeLabel']:setString(Str('보통'))
        vars['gradeLabel']:setColor(COLOR['diff_normal'])

    elseif (difficulty == 2) then
        vars['difficultySprite']:setColor(COLOR['diff_hard'])
        vars['gradeLabel']:setString(Str('어려움'))
        vars['gradeLabel']:setColor(COLOR['diff_hard'])

    elseif (difficulty == 3) then
        vars['difficultySprite']:setColor(COLOR['diff_hell'])
        vars['gradeLabel']:setString(Str('지옥'))
        vars['gradeLabel']:setColor(COLOR['diff_hell'])
    elseif (difficulty == 4) then
        vars['difficultySprite']:setColor(COLOR['diff_hellfire'])
        vars['gradeLabel']:setString(Str('불지옥'))
        vars['gradeLabel']:setColor(COLOR['diff_hellfire'])
    end
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_GameResult_Illusion:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}

    table.insert(self.m_lWorkList, 'direction_showScore')
    table.insert(self.m_lWorkList, 'direction_end')
end

-------------------------------------
-- function direction_showScore
-------------------------------------
function UI_GameResult_Illusion:direction_showScore()
    self.root:stopAllActions()
    local is_success = self.m_bSuccess
    self:setSuccessVisual_Ancient()
    -- 성공시에만 스코어 연출
    if (is_success) then
        self:setAnimationData()
        self:makeScoreAnimation()
    else
        self:doNextWork()
    end
end

-------------------------------------
-- function makeAnimationData
-- @brief 애니메이션에 필요한 노드 리스트로 관리
-------------------------------------
function UI_GameResult_Illusion:setAnimationData()
    local vars = self.vars

    local score_list = {}
    table.insert(score_list, 1000)
    table.insert(score_list, 1000)
  

    -- 애니메이션 적용되는 라벨 저장
    local var_list = {}
    table.insert(var_list, 'timeLabel1')
    table.insert(var_list, 'timeLabel2')
    table.insert(var_list, 'totalLabel1')
    table.insert(var_list, 'totalLabel2')


    local node_list = {}
    for _, v in ipairs(var_list) do
        local node = vars[v]
        if string.find(v, '2') then
            node:setString(tostring(0))
        end
        table.insert(node_list, node)
    end

    self.m_scoreList = score_list
    self.m_animationList = node_list
end

-------------------------------------
-- function makeScoreAnimation
-------------------------------------
function UI_GameResult_Illusion:makeScoreAnimation(is_attr)
    local vars          = self.vars
    local score_list    = self.m_scoreList
    local node_list     = self.m_animationList

    local score_node    = vars['scoreNode']
    local total_node    = vars['totalSprite']

    score_node:setVisible(true)
    total_node:setVisible(true)

    doAllChildren(score_node,   function(node) node:setOpacity(0) end)
    doAllChildren(total_node,   function(node) node:setOpacity(0) end)

    -- 점수 카운팅 애니메이션
    for idx, node in ipairs(node_list) do
        self:runScoreAction(idx, node)     
    end
end

-------------------------------------
-- function runScoreAction
-------------------------------------
function UI_GameResult_Illusion:runScoreAction(idx, node)
    local score_list    = self.m_scoreList
    local node_list     = self.m_animationList
    local move_x        = 20
    local delay_time    = 0.0 -- 애니메이션 간 간격
    local fadein_time   = 0.1 -- 페이드인 타임
    local number_time   = 0.2 -- 넘버링 타임
    local ani_time      = delay_time + fadein_time + number_time

    local is_numbering = (idx % 2 == 0)

    local pos_x, pos_y  = node:getPosition()

    local action_scale  = 1.08
    local add_x         = (is_numbering) and -move_x or move_x

    node:setScale(action_scale)
    node:setPositionX(pos_x - add_x)

    -- 라벨일 경우 넘버링 애니메이션 
    local number_func
    number_func = function()
        if (idx == #node_list) then
            local ind = #score_list
            local score = tonumber(score_list[ind])
            local score_str = ''

            node:setString(score_str)
            self:doNextWork()
        end

        if (not is_numbering) then return end
        local score = tonumber(score_list[idx/2])
        node = NumberLabel(node, 0, number_time)
        node:setNumber(score, true)

        -- 최종 점수 애니메이션
        if (idx == 4) then
            self:setTotalScoreLabel()
            self.m_totalScore:setNumber(score, true)        
        end
    end

    local act1 = cc.DelayTime:create( ani_time * idx )

    local act2 = cc.FadeIn:create( fadein_time )
    local act3 = cc.EaseInOut:create( cc.MoveTo:create(fadein_time, cc.p(pos_x, pos_y)), 2 )
    local act4 = cc.Spawn:create( act2, act3 )

    local act5 = cc.EaseInOut:create( cc.ScaleTo:create(number_time, 1), 2 )
    local act6 = cc.CallFunc:create( number_func )
    local act7 = cc.Spawn:create( act5, act6 )

    local action = cc.Sequence:create( act1, act4, act7 )
    node:runAction( action )

    -- 최종 점수 Sprite
    if idx == 4 then
        local total_node = self.vars['totalSprite']
        local act1 = cc.DelayTime:create( ani_time * idx )
        local act2 = cc.FadeIn:create( fadein_time )
        local action = cc.Sequence:create( act1, act2 )
        total_node:runAction(action)
    end
end