local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_AncientTower
-------------------------------------
UI_GameResult_AncientTower = class(PARENT, {
    m_ancientScoreCalc = 'AncientTowerScoreCalc',

    m_totalScore = 'cc.Label',

    m_scoreList = 'list',
    m_animationList = 'list',

    m_attr_tower_open = 'boolean',
})

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_AncientTower:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open, score_calc)
    local vars = self.vars
    self.m_ancientScoreCalc = score_calc
    self.m_staminaType = 'tower'
    self.m_attr_tower_open = content_open['open'] or false

    vars['againBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)
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
-- function makeAnimationData
-- @brief 애니메이션에 필요한 노드 리스트로 관리
-------------------------------------
function UI_GameResult_AncientTower:setAnimationData()
    local vars = self.vars
    local score_calc = self.m_ancientScoreCalc

    -- 스테이지 속성 보너스
    local stage_id = self.m_stageID
    local t_info = TABLE:get('anc_floor_reward')[stage_id]
    local attr = t_info['bonus_attr']


    -- 각 미션별 점수 계산 저장
    local score_list = {}
    table.insert(score_list, score_calc:calcClearBonus())
    table.insert(score_list, score_calc:calcClearTimeBonus())
    table.insert(score_list, score_calc:calcClearNoDeathBonus())
    if attr and (attr ~= '') then
        table.insert(score_list, score_calc:calcAttrBonus())
    end
    --table.insert(score_list, score_calc:calcKillBossBonus())
    --table.insert(score_list, score_calc:calcAcitveSkillBonus())
    table.insert(score_list, score_calc:getWeakGradeMinusScore())
    table.insert(score_list, score_calc:getFinalScore())

    -- 애니메이션 적용되는 라벨 저장
    local var_list = {}
    table.insert(var_list, 'clearLabel1')
    table.insert(var_list, 'clearLabel2')

    table.insert(var_list, 'timeLabel1')
    table.insert(var_list, 'timeLabel2')

    table.insert(var_list, 'injuryLabel1')
    table.insert(var_list, 'injuryLabel2')

    if attr and (attr ~= '') then
        table.insert(var_list, 'attrBonusLabel1')
        table.insert(var_list, 'attrBonusLabel2')
        vars['attrBonusLabel1']:setVisible(true)
        vars['attrBonusLabel2']:setVisible(true)
    else
        vars['attrBonusLabel1']:setVisible(false)
        vars['attrBonusLabel2']:setVisible(false)
    end

    table.insert(var_list, 'weakLabel1')
    table.insert(var_list, 'weakLabel2')

    table.insert(var_list, 'totalLabel1')
    table.insert(var_list, 'totalLabel2')

    -- 현재 약화 등급 
    local weak_grade = g_ancientTowerData:getWeakGrade()
    if (weak_grade > 0) then
        vars['weakLabel1']:setString(Str('약화 등급 패널티', weak_grade))
        vars['weakLabel2']:setColor(cc.c3b(255, 96, 0))
    else
        vars['weakLabel1']:setVisible(false)
        vars['weakLabel2']:setVisible(false)
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
        local is_ani = (score < #node_list - 2) and true or false
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
        local action = cc.Sequence:create(act1, act2)
        node:runAction(action) 
    end)

    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time + 0.5), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_againBtn
-- @brief 다시하기
-------------------------------------
function UI_GameResult_AncientTower:click_againBtn()
    local stage_id = self.m_stageID
    g_ancientTowerData:checkAttrTowerAndGoStage(stage_id)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_AncientTower:click_nextBtn()
    local stage_id = self.m_stageID
    local use_scene = true
    local next_stage_id = g_stageData:getNextStage(stage_id)
    g_ancientTowerData:checkAttrTowerAndGoStage(next_stage_id)
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_GameResult_AncientTower:click_prevBtn()
    local stage_id = self.m_stageID
    local use_scene = true
    local prev_stage_id = g_stageData:getSimplePrevStage(stage_id)
    g_ancientTowerData:checkAttrTowerAndGoStage(prev_stage_id)
end

-------------------------------------
-- function direction_showScore
-------------------------------------
function UI_GameResult_AncientTower:direction_showScore()
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
-- function direction_secretDungeon
-------------------------------------
function UI_GameResult_AncientTower:direction_secretDungeon()
    if (self.m_secretDungeon) then
        MakeSimpleSecretFindPopup(self.m_secretDungeon)
    end

    -- 시험의 탑 컨텐츠 오픈 팝업
    if (self.m_attr_tower_open) then
       UI_ContentOpenPopup('attr_tower')
    end 

    self:doNextWork()
end

-------------------------------------
-- function setSuccessVisual_Ancient
-- @brief 고대의 탑 전용 성공 연출 
-------------------------------------
function UI_GameResult_AncientTower:setSuccessVisual_Ancient()
    local is_success = self.m_bSuccess
    local vars = self.vars

    vars['successVisual']:setVisible(true)
    if (is_success == true) then
        SoundMgr:playBGM('bgm_dungeon_victory', false)  
        vars['successVisual']:changeAni('success_tower_appear', false)
        vars['successVisual']:addAniHandler(function()
            vars['successVisual']:changeAni('success_tower_idle', true)
        end)
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        vars['successVisual']:changeAni('fail')
    end
end

-------------------------------------
-- function setSuccessVisual
-------------------------------------
function UI_GameResult_AncientTower:setSuccessVisual()
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