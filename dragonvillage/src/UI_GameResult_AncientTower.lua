local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_AncientTower
-------------------------------------
UI_GameResult_AncientTower = class(PARENT, {
    m_ancientScoreCalc = 'AncientTowerScoreCalc',

    m_totalScore = 'cc.Label',

    m_scoreList = 'list',
    m_animationList = 'list',
})

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_AncientTower:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, score_calc)
    local vars = self.vars
    self.m_ancientScoreCalc = score_calc
    self.m_staminaType = 'tower'

    vars['againBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)

    self.root:stopAllActions()
    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function makeAnimationData
-- @brief 애니메이션에 필요한 노드 리스트로 관리
-------------------------------------
function UI_GameResult_AncientTower:setAnimationData()
    local vars = self.vars
    local score_calc = self.m_ancientScoreCalc

    -- 각 미션별 점수 계산 저장
    local score_list = {}
    table.insert(score_list, score_calc:calcClearBonus())
    table.insert(score_list, score_calc:calcClearTimeBonus())
    table.insert(score_list, score_calc:calcClearNoDeathBonus())
    table.insert(score_list, score_calc:calcKillBossBonus())
    table.insert(score_list, score_calc:calcAcitveSkillBonus())
    table.insert(score_list, score_calc:getWeakGradeMinusScore())
    table.insert(score_list, score_calc:getFinalScore())

    -- 애니메이션 적용되는 라벨 저장
    local var_list = 
    {
        'clearLabel1',  'clearLabel2',  'timeLabel1',  'timeLabel2', 
        'injuryLabel1', 'injuryLabel2', 'dragLabel1',  'dragLabel2',
        'skillLabel1',  'skillLabel2',  'weakLabel1',  'weakLabel2', 
        'totalLabel1',  'totalLabel2'
    }

    -- 현재 약화 등급 
    local weak_grade = g_ancientTowerData:getWeakGrade()
    vars['weakLabel1']:setString(Str('약화 {1}등급', weak_grade))
    if (weak_grade > 0) then
        vars['weakLabel2']:setColor(cc.c3b(255, 96, 0))
    end

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
function UI_GameResult_AncientTower:makeScoreAnimation()
    local vars          = self.vars
    local score_list    = self.m_scoreList
    local node_list     = self.m_animationList

    local score_node    = vars['scoreNode']
    local total_node    = vars['totalSprite']
    local result_menu   = vars['resultMenu']

    score_node:setVisible(true)
    total_node:setVisible(true)
    result_menu:setVisible(false)

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
function UI_GameResult_AncientTower:runScoreAction(idx, node)
    local score_list    = self.m_scoreList
    local node_list     = self.m_animationList

    local move_x        = 20
    local delay_time    = 0.0 -- 애니메이션 간 간격
    local fadein_time   = 0.1 -- 페이드인 타임
    local number_time   = 0.2 -- 넘버링 타임
    local ani_time      = delay_time + fadein_time + number_time

    local is_numbering  = (idx % 2 == 0)
    local pos_x, pos_y  = node:getPosition()

    local action_scale  = 1.08
    local add_x         = (is_numbering) and -move_x or move_x

    node:setScale(action_scale)
    node:setPositionX(pos_x - add_x)

    -- 라벨일 경우 넘버링 애니메이션 
    local number_func
    number_func = function()
        if (not is_numbering) then return end
        local score = tonumber(score_list[idx/2])
        local is_ani = (score < 10) and true or false
        node = NumberLabel(node, 0, number_time)
        node:setNumber(score, is_ani)

        -- 최종 점수 애니메이션
        if (idx == #node_list) then
            self:setTotalScoreLabel()
            self.m_totalScore:setNumber(score, is_ani)
            self:removeScore()
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
    if idx == (#node_list - 2) then
        local total_node = self.vars['totalSprite']
        local act1 = cc.DelayTime:create( ani_time * idx )
        local act2 = cc.FadeIn:create( fadein_time )
        local action = cc.Sequence:create( act1, act2 )
        total_node:runAction(action)
    end
end

-------------------------------------
-- function removeScore
-------------------------------------
function UI_GameResult_AncientTower:removeScore()
    local vars          = self.vars
    local score_node    = vars['scoreNode']
    local total_node    = vars['totalSprite']
    local result_menu   = vars['resultMenu']

    local delay_time = 2.0

    -- 최종 점수 같이 사라짐
    total_node:stopAllActions()
    doAllChildren(total_node, function(node)
        local act1 = cc.DelayTime:create(delay_time)
        local act2 = cc.FadeOut:create(0.2)
        local action = cc.Sequence:create(act1, act2)
        node:runAction(action)
    end)

    -- 스코어 노드 사라짐
    doAllChildren(score_node, function(node)
        local act1 = cc.DelayTime:create(delay_time)
        local act2 = cc.FadeOut:create(0.2)
        local act3 = cc.CallFunc:create(function() self:makeResultUI() end)
        local action = cc.Sequence:create(act1, act2, act3)
        node:runAction(action) 
    end)
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
--        모험모드에서 사용하므로 고대의 탑에선 off
-------------------------------------
function UI_GameResult_AncientTower:init_difficultyIcon(stage_id)
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
end

-------------------------------------
-- function click_againBtn
-- @brief 다시하기
-------------------------------------
function UI_GameResult_AncientTower:click_againBtn()
    local use_scene = true
    g_ancientTowerData:goToAncientTowerScene(use_scene)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_AncientTower:click_nextBtn()
    g_ancientTowerData:goToAncientTowerScene()
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_GameResult_AncientTower:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_showTamer')
    table.insert(self.m_lWorkList, 'direction_hideTamer')
    table.insert(self.m_lWorkList, 'direction_showScore')
    table.insert(self.m_lWorkList, 'direction_end')
    table.insert(self.m_lWorkList, 'direction_showBox')
    table.insert(self.m_lWorkList, 'direction_openBox')
    table.insert(self.m_lWorkList, 'direction_dropItem')
    table.insert(self.m_lWorkList, 'direction_secretDungeon')
    table.insert(self.m_lWorkList, 'direction_showButton')
    table.insert(self.m_lWorkList, 'direction_moveMenu')
    table.insert(self.m_lWorkList, 'direction_masterRoad')
end

-------------------------------------
-- function direction_showScore
-------------------------------------
function UI_GameResult_AncientTower:direction_showScore()
    local is_success = self.m_bSuccess
    self.root:stopAllActions()

    self:setSuccessVisual_Ancient()

    -- 성공시에만 스코어 연출
    if (is_success) then
        self:setAnimationData()
        self:makeScoreAnimation()
    else
        self:makeResultUI()
    end
end

-------------------------------------
-- function direction_showScore_click
-------------------------------------
function UI_GameResult_AncientTower:direction_showScore_click()
    if (self:checkAutoPlayRelease()) then return end
end

-------------------------------------
-- function setSuccessVisual_Ancient
-- @brief 고대의 탑 전용 성공 연출 
-------------------------------------
function UI_GameResult_AncientTower:setSuccessVisual_Ancient()
    local is_success = self.m_bSuccess
    local vars = self.vars

    self:setSuccessVisual()

    if (is_success == true) then
        vars['successVisual']:changeAni('success_tower_appear', false)
        vars['successVisual']:addAniHandler(function()
            vars['successVisual']:changeAni('success_tower_idle', true)
        end)
    end
end

-------------------------------------
-- function setTotalScoreLabel
-- @brief 최종 스코어 bmfont 생성
-------------------------------------
function UI_GameResult_AncientTower:setTotalScoreLabel()
    local vars = self.vars

    local total_score = cc.Label:createWithBMFont('res/font/tower_score.fnt', '')
    total_score:setAnchorPoint(cc.p(0.5, 0.5))
    total_score:setDockPoint(cc.p(0.5, 0.5))
    total_score:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    total_score:setAdditionalKerning(0)
    vars['totalScoreNode']:addChild(total_score)

    total_score = NumberLabel(total_score, 0, 0.3)
    self.m_totalScore = total_score
end

-------------------------------------
-- function makeResultUI
-- @brief 성공 연출 후 결과 화면 다시 보여주고 doNextWork()로 원래 워크 플로우 진행
-------------------------------------
function UI_GameResult_AncientTower:makeResultUI()
    
    local is_success = self.m_bSuccess
    local vars = self.vars
    vars['resultMenu']:setVisible(true)
	vars['statsBtn']:setVisible(false)
    vars['homeBtn']:setVisible(false)
    vars['againBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)
    vars['skipLabel']:setVisible(false)
    vars['againBtn']:setVisible(false)

    -- 드래곤 레벨업 연출 node
    vars['dragonResultNode']:setVisible(true)

    -- 플레이 시간, 획득 골드
    self.m_lNumberLabel['time']:setNumber(self.m_time)
    self.m_lNumberLabel['gold']:setNumber(self.m_gold)

    -- 레벨업 연출 시작
    self:startLevelUpDirector()

    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function() self:doNextWork() end)))
end
