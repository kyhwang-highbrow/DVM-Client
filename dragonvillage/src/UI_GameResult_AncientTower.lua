local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_AncientTower
-------------------------------------
UI_GameResult_AncientTower = class(PARENT, {
    m_totalScore = 'cc.Label',

    m_scoreList = 'list',
    m_animationList = 'list',

    m_exScore = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_AncientTower:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open, score_calc, ex_score)
    self.m_staminaType = 'tower'

    local vars = self.vars
    self.m_exScore = ex_score

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
-- function setAnimationData
-- @brief 애니메이션에 필요한 노드 리스트로 관리
-------------------------------------
function UI_GameResult_AncientTower:setAnimationData()
    local vars = self.vars
    local score_calc = self.m_scoreCalc

    -- 스테이지 속성 보너스
    local stage_id = self.m_stageID
    local t_info = TABLE:get('anc_floor_reward')[stage_id]
    local attr = t_info['bonus_attr']


    -- 각 미션별 점수 계산 저장
    local score_list = {}
    table.insert(score_list, score_calc:calcClearBonus())
    table.insert(score_list, score_calc:calcClearTimeBonus())
    table.insert(score_list, score_calc:calcClearNoDeathBonus())
    if attr and (attr ~= '') and (not is_attr_tower) then
        table.insert(score_list, score_calc:calcAttrBonus())
    end

    --table.insert(score_list, score_calc:calcKillBossBonus())
    --table.insert(score_list, score_calc:calcAcitveSkillBonus())
    table.insert(score_list, score_calc:getFinalScore())
    
    -- 역대 내 최고 점수
    do
        local cur_score = score_calc:getFinalScore()
	    local best_score = g_ancientTowerData.m_challengingInfo.m_myHighScore or 0
        table.insert(score_list, best_score or 0)
    end

    do -- 지난 점수와의 차이 표시    
        local my_last_score = g_ancientTowerData.m_challengingInfo.m_myScore or 0
        local my_score = score_calc:getFinalScore()
        local change_score = my_score - my_last_score
        table.insert(score_list, change_score or 0)
        
        -- 바로 통신하지 않기 때문에 여기서 갱신
        if (my_score > my_last_score) then
            g_ancientTowerData.m_challengingInfo.m_myScore = my_score
        end
    end

    -- 애니메이션 적용되는 라벨 저장
    local var_list = {}
    table.insert(var_list, 'clearLabel1')
    table.insert(var_list, 'clearLabel2')

    table.insert(var_list, 'timeLabel1')
    table.insert(var_list, 'timeLabel2')

    table.insert(var_list, 'injuryLabel1')
    table.insert(var_list, 'injuryLabel2')

    if attr and (attr ~= '') and (not is_attr_tower) then
        table.insert(var_list, 'attrBonusLabel1')
        table.insert(var_list, 'attrBonusLabel2')
        vars['attrBonusLabel1']:setVisible(true)
        vars['attrBonusLabel2']:setVisible(true)
    else
        vars['attrBonusLabel1']:setVisible(false)
        vars['attrBonusLabel2']:setVisible(false)
    end

    table.insert(var_list, 'totalLabel1')
    table.insert(var_list, 'totalLabel2')
    table.insert(var_list, 'totalLabel3')
    table.insert(var_list, 'totalLabel4')
    table.insert(var_list, 'scoreChangeLabel')

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
-- function setAnimationData_Attr
-- @brief 애니메이션에 필요한 노드 리스트로 관리
-------------------------------------
function UI_GameResult_AncientTower:setAnimationData_Attr()
    local vars = self.vars
    local score_calc = self.m_scoreCalc

    -- 스테이지 속성 보너스
    local stage_id = self.m_stageID
    local t_info = TABLE:get('anc_floor_reward')[stage_id]
    local attr = t_info['bonus_attr']


    -- 각 미션별 점수 계산 저장
    local score_list = {}
    table.insert(score_list, score_calc:calcClearBonus())
    table.insert(score_list, score_calc:calcClearTimeBonus())
    table.insert(score_list, score_calc:calcClearNoDeathBonus())

    --table.insert(score_list, score_calc:calcKillBossBonus())
    --table.insert(score_list, score_calc:calcAcitveSkillBonus())
    table.insert(score_list, score_calc:getFinalScore())

    -- 애니메이션 적용되는 라벨 저장
    local var_list = {}
    table.insert(var_list, 'clearLabel1')
    table.insert(var_list, 'clearLabel2')

    table.insert(var_list, 'timeLabel1')
    table.insert(var_list, 'timeLabel2')

    table.insert(var_list, 'injuryLabel1')
    table.insert(var_list, 'injuryLabel2')

    vars['attrBonusLabel1']:setVisible(false)
    vars['attrBonusLabel2']:setVisible(false)

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
-- function setWorkList
-------------------------------------
function UI_GameResult_AncientTower:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
    -- table.insert(self.m_lWorkList, 'direction_showTamer')
	table.insert(self.m_lWorkList, 'check_tutorial')
	table.insert(self.m_lWorkList, 'check_masterRoad')
    -- table.insert(self.m_lWorkList, 'direction_hideTamer'
    table.insert(self.m_lWorkList, 'direction_showScore')
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
    table.insert(self.m_lWorkList, 'direction_showBox')
    table.insert(self.m_lWorkList, 'direction_openBox')
    table.insert(self.m_lWorkList, 'direction_dropItem')
    table.insert(self.m_lWorkList, 'direction_secretDungeon')
    table.insert(self.m_lWorkList, 'direction_showButton')
    table.insert(self.m_lWorkList, 'direction_moveMenu')
    table.insert(self.m_lWorkList, 'direction_dragonGuide')
    local is_attr = g_ancientTowerData:isAttrChallengeMode()
    if (not is_attr) then
        table.insert(self.m_lWorkList, 'direction_checkBestScore')
    end
    table.insert(self.m_lWorkList, 'direction_masterRoad')
end

-------------------------------------
-- function makeScoreAnimation
-------------------------------------
function UI_GameResult_AncientTower:makeScoreAnimation(is_attr)
    local vars          = self.vars
    local score_list    = self.m_scoreList
    local node_list     = self.m_animationList

    local score_node    = vars['scoreNode']
    local total_node    = vars['totalSprite']

    score_node:setVisible(true)
    total_node:setVisible(true)
    vars['scoreChangeLabel']:setVisible(not is_attr)
    vars['totalLabel3']:setVisible(not is_attr)
    vars['totalLabel3']:setString(Str('역대 내 최고점수'))
    vars['totalLabel4']:setVisible(not is_attr)

    doAllChildren(score_node,   function(node) node:setOpacity(0) end)
    doAllChildren(total_node,   function(node) node:setOpacity(0) end)

    -- 점수 카운팅 애니메이션
    for idx, node in ipairs(node_list) do
        if (is_attr) then
            self:runScoreAction_Attr(idx, node)
        else
            self:runScoreAction(idx, node)     
        end
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

    local is_numbering = (idx % 2 == 0)

    local pos_x, pos_y  = node:getPosition()

    local action_scale  = 1.08
    local add_x         = (is_numbering) and -move_x or move_x

    node:setScale(action_scale)
    node:setPositionX(pos_x - add_x)

    -- 라벨일 경우 넘버링 애니메이션 
    local number_func
    number_func = function()

        -- 순위 변동 표시 나타내는 라벨은 다르게 동작해서 하드코딩
        if (idx == #node_list) then
            local ind = #score_list
            local score = tonumber(score_list[ind])
            local score_str = ''
            if (score > 0) then
                score = math.abs(score)
                self.vars['newRecordNode']:setVisible(true)
                score_str = string.format('({@rank_up}▲{@default}%s)', comma_value(score))
            elseif (score < 0) then
                score = math.abs(score)
                score_str = string.format('({@rank_down}▼{@default}%s)', comma_value(score))
            else
                score_str = '(-)'
            end
            node:setString(score_str)
            self:removeScore()
        end

        if (not is_numbering) then return end
        local score = tonumber(score_list[idx/2])
        local is_ani = (score < #node_list - 2) and true or false
        node = NumberLabel(node, 0, number_time)
        node:setNumber(score, true)

        -- 최종 점수 애니메이션
        if (idx == #node_list - 3) then -- 마지막에서 3번째 노드가 총 점수 노드
            self:setTotalScoreLabel()
            self.m_totalScore:setNumber(score, is_ani)        
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
    if idx == (#node_list - 3) then
        local total_node = self.vars['totalSprite']
        local act1 = cc.DelayTime:create( ani_time * idx )
        local act2 = cc.FadeIn:create( fadein_time )
        local action = cc.Sequence:create( act1, act2 )
        total_node:runAction(action)
    end
end

-------------------------------------
-- function runScoreAction_Attr
-------------------------------------
function UI_GameResult_AncientTower:runScoreAction_Attr(idx, node)
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
    local new_node    = vars['newRecordNode']

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

    -- 점수 갱신 노드 사라짐
    doAllChildren(new_node, function(node)
        local act1 = cc.DelayTime:create(delay_time)
        local act2 = cc.FadeOut:create(0.2)
        local action = cc.Sequence:create(act1, act2)
        node:runAction(action) 
    end)

    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time + 0.5), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function checkAutoPlayCondition
-- @override
-------------------------------------
function UI_GameResult_AncientTower:checkAutoPlayCondition()
	local auto_play_stop, msg = PARENT.checkAutoPlayCondition(self)

    -- 승리 시 다음층으로 이동
	if (g_autoPlaySetting:get('tower_next_floor')) then  
        -- 패배했다면 더이상 조건체크 안함
        if (not self.m_bSuccess) then
            auto_play_stop = true
            msg = Str('패배로 인해 연속 전투가 종료되었습니다.')
            return auto_play_stop, msg
        end
        
        local is_attr = g_ancientTowerData:isAttrChallengeMode()
        -- 시험의 탑의 경우 개방된 최상위 층으로 판단
        if (is_attr) then
            local max_stage_id = g_attrTowerData:getAttrMaxStageId()
            if (self.m_stageID == max_stage_id) then
                auto_play_stop = true
                msg = Str('모든 층을 클리어하여 연속 전투가 종료되었습니다.')
            end
        -- 고대의 탑은 50층이 최상위 층
        else
            if (self.m_stageID == ANCIENT_TOWER_STAGE_ID_FINISH) then
                auto_play_stop = true
                msg = Str('모든 층을 클리어하여 연속 전투가 종료되었습니다.')
            end
        end     
        
	end

	return auto_play_stop, msg
end

-------------------------------------
-- function startGame
-- @override
-------------------------------------
function UI_GameResult_AncientTower:startGame()
    local function goto_cb()
	    -- 연속 전투 : 다음 층 도전
	    if (g_autoPlaySetting:isAutoPlay()) then
	    	if (g_autoPlaySetting:get('tower_next_floor')) then
	    		if (self.m_bSuccess) then
	    			local stage_id = self.m_stageID
	    			self.m_stageID = stage_id + 1
	    			g_ancientTowerData.m_stageIdInAuto = self.m_stageID
	    		end
	    	end
	    end

	    PARENT.startGame(self)
    end

    local attr = g_attrTowerData:getSelAttr()
    local stage_id = self.m_stageID
    local next_stage_id = g_stageData:getNextStage(stage_id)
    if (not attr) then
        g_ancientTowerData:request_ancientTowerInfo(next_stage_id, goto_cb)
    else
        goto_cb()
    end
end

-------------------------------------
-- function click_againBtn
-- @brief 다시하기
-------------------------------------
function UI_GameResult_AncientTower:click_againBtn()
    if (self:checkAutoPlayRelease()) then
        return
    end

    local stage_id = self.m_stageID    
    local function close_cb()
        g_ancientTowerData:checkAttrTowerAndGoStage(stage_id)
    end

    UINavigator:goTo('battle_ready', stage_id, close_cb)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_AncientTower:click_nextBtn()
    if (self:checkAutoPlayRelease()) then
        return
    end

    local attr = g_attrTowerData:getSelAttr()
    local stage_id = self.m_stageID
    local max_stage_id = ''

    if (attr) then
        max_stage_id = g_attrTowerData:getAttrMaxStageId()
    else
        max_stage_id = ANCIENT_TOWER_STAGE_ID_FINISH
    end

    if (stage_id >= max_stage_id) then
        UIManager:toastNotificationRed(Str('마지막 스테이지 입니다.'))
        return
    end
    
    
    -- 시험의 탑의 경우
    if (attr) then
        local stage_id = self.m_stageID
        local use_scene = true
        local next_stage_id = g_stageData:getNextStage(stage_id)
            
        local function close_cb()
            g_ancientTowerData:checkAttrTowerAndGoStage(next_stage_id)
        end

        local function goto_cb()
            UINavigator:goTo('battle_ready', next_stage_id, close_cb)
        end

        -- 클리어 정보, 도전 정보 필요해서 info 호출 후 이동
        if (attr) then
            g_attrTowerData:request_attrTowerInfo(attr, next_stage_id, goto_cb)
        else
            g_ancientTowerData:request_ancientTowerInfo(next_stage_id, goto_cb)
        end
    else
        if (self:blockButtonUntilWorkDone()) then
		    return
	    end
        local game_mode = g_gameScene.m_gameMode
        local dungeon_mode = g_gameScene.m_dungeonMode
        local condition = self.m_stageID
        QuickLinkHelper.gameModeLink(game_mode, dungeon_mode, condition)
    end
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_GameResult_AncientTower:click_prevBtn()
    if (self:checkAutoPlayRelease()) then
        return
    end

    local stage_id = self.m_stageID
    local use_scene = true
    local prev_stage_id = g_stageData:getSimplePrevStage(stage_id)

    local function close_cb()
        g_ancientTowerData:checkAttrTowerAndGoStage(prev_stage_id)
    end

    local function goto_cb()
        UINavigator:goTo('battle_ready', prev_stage_id, close_cb)
    end

    -- 클리어 정보, 도전 정보 필요해서 info 호출 후 이동
    local attr = g_attrTowerData:getSelAttr()
    if (attr) then
        g_attrTowerData:request_attrTowerInfo(attr, prev_stage_id, goto_cb)
    else
        g_ancientTowerData:request_ancientTowerInfo(prev_stage_id, goto_cb)
    end
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
        local is_attr = g_ancientTowerData:isAttrChallengeMode()
        if (is_attr) then
            self:setAnimationData_Attr()
        else
            self:setAnimationData()           
        end
        self:makeScoreAnimation(is_attr)
    else
        self:doNextWork()
    end
end

-------------------------------------
-- function direction_checkBestScore
-------------------------------------
function UI_GameResult_AncientTower:direction_checkBestScore()
    local score = self.m_scoreCalc:getFinalScore()
    local stage_id = self.m_stageID
    local is_success = self.m_bSuccess
    if (is_success) then
        -- 로컬 기록과 비교하여 더 높은 점수라면 팝업 띄워줌
        if (self.m_exScore < score) then
            local ui = UI_AncientTowerRenewBestTeam(stage_id, score, self.m_exScore)
            self.vars['ancientScoreGapPopupNode']:setVisible(true)
            self.vars['ancientScoreGapPopupNode']:addChild(ui.root)
        end
    end
    self:doNextWork()
end

-------------------------------------
-- function direction_secretDungeon
-------------------------------------
function UI_GameResult_AncientTower:direction_secretDungeon()
    if (self.m_secretDungeon) then
        MakeSimpleSecretFindPopup(self.m_secretDungeon)
    end

   
    local is_attr = g_ancientTowerData:isAttrChallengeMode()
    if (is_attr) then
        local finish_cb = function()     
            -- 시험의 탑 층별 개방 팝업
            if (g_attrTowerData:isAttrExpendedFirst()) then
                UI_ContentOpenPopup_AttrTower()
            end
        end
        
        local attr = g_attrTowerData:getSelAttr()
        local stage_id = self.m_stageID
        local prev_stage_id = g_stageData:getSimplePrevStage(stage_id)        
        g_attrTowerData:request_attrTowerInfo(attr, prev_stage_id, finish_cb)   
    end
    --[[
    -- 시험의 탑 컨텐츠 오픈 팝업
    if (self.m_content_open) then
       UI_ContentOpenPopup('attr_tower')
    end 
	--]]
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






local PARENT = UI

-------------------------------------
-- class UI_AncientTowerRenewBestTeam
-- @brief 고대의 탑, 베스트 팀 최고 점수 갱신했을 때 등장 팝업
-------------------------------------
UI_AncientTowerRenewBestTeam = class(PARENT, {
        m_best_score = 'number',
        m_ex_score = 'number',
        m_stage_id = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRenewBestTeam:init(stage_id, best_score, ex_score)
    local vars = self:load('tower_best_popup_02.ui')
    self.m_best_score = best_score
    self.m_ex_score = ex_score
    self.m_stage_id = stage_id

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self.root:setVisible(false) end, 'UI_AncientTowerRenewBestTeam')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerRenewBestTeam:initUI()
    local vars = self.vars
    
    local stage_id = self.m_stage_id
    local ex_score = self.m_ex_score
    local stage = stage_id%100

    vars['stageLabel']:setString(Str('{1}층', stage))
    vars['dscLabel']:setString(Str('현재 팀이 {1}층 베스트 팀으로 저장되었습니다.', stage))
    
    vars['scoreLabel1']:setString(comma_value(ex_score))
    vars['scoreLabel2']:setString(comma_value(self.m_best_score))

    vars['okBtn']:registerScriptTapHandler(function() self.root:setVisible(false) end)
    vars['closeBtn']:registerScriptTapHandler(function() self.root:setVisible(false) end)
end
