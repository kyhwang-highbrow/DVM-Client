local PARENT = UI

-------------------------------------
-- class UI_GameResult_Illusion
-------------------------------------
UI_GameResult_Illusion = class(PARENT, {
        m_stageID = 'number',
        m_bSuccess = 'boolean',
        m_time = 'number',
        m_damage = 'number',  
        m_lDragonList = 'list',
        m_lDropItemList = 'list',
        m_secretDungeon = 'table',

        m_lNumberLabel = 'list',

        m_directionStep = 'number',
        m_lDirectionList = 'list',
        
        m_lWorkList = 'list',
        m_workIdx = 'number',

        m_staminaType = 'string',
        m_autoCount = 'boolean',

		m_isClearMasterRoad = 'boolean',

        m_content_open = 'boolean', -- 컨텐츠 오픈
        m_scoreCalc = '', -- 스코어

        m_totalScore = 'cc.Label',
        
        m_scoreList = 'list',
        m_animationList = 'list',

})

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_Illusion:init(stage_id, is_success, l_dragon_list, secret_dungeon, time, damage, t_tamer_levelup_data, l_drop_item_list, score_calc)
    self.m_stageID = stage_id
    self.m_bSuccess = is_success
    self.m_time = time
    self.m_damage = damage
    self.m_secretDungeon = secret_dungeon
    self.m_lDragonList = l_dragon_list
    if (l_drop_item_list) then
        self.m_lDropItemList = l_drop_item_list['items_list']
    end 
    self.m_staminaType = 'st'
    self.m_autoCount = false
    self.m_content_open = content_open and content_open['open'] or false
    self.m_scoreCalc = score_calc

    self:initUI()
    self:initButton()

    -- @brief work초기화 용도로 사용함
    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameResult_Illusion:initUI()
    local vars = self:load('event_illusion_result.ui')
    UIManager:open(self, UIManager.POPUP)
    
    local vars = self.vars
    local stage_id = self.m_stageID

    do
        -- 스테이지 이름
        local str = g_stageData:getStageName(stage_id)
        vars['titleLabel']:setString(str)

        -- 스테이지 난이도를 표시
        self:init_difficultyIcon(stage_id)
    end

    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameResult_Illusion:initButton()
    local vars = self.vars

    vars['againBtn']:registerScriptTapHandler(function() self:click_againBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_statusInfoBtn() end)
    vars['infoBtn']:setVisible(true)

    vars['switchBtn']:registerScriptTapHandler(function() self:click_switchBtn() end)
    vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn() end)
    vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['homeBtn']:registerScriptTapHandler(function() self:click_homeBtn() end)
    vars['illusionBtn']:registerScriptTapHandler(function() self:click_illusionBtn() end)
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
-------------------------------------
function UI_GameResult_Illusion:init_difficultyIcon(stage_id)
    local vars = self.vars

    local difficulty = g_illusionDungeonData:parseStageID(stage_id)

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
    table.insert(self.m_lWorkList, 'direction_showReward')
    table.insert(self.m_lWorkList, 'direction_delay')
    table.insert(self.m_lWorkList, 'direction_moveMenu')
    table.insert(self.m_lWorkList, 'direction_checkAutoPlay')
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_GameResult_Illusion:doNextWork()
    -- runAction으로 딜레이 건 후 doNextWork 하는 경우와 클릭하여 doNextWork하는 경우 미세한 차이면 겹칠 수 있음
    -- stopAction으로 처리
    self.root:stopAllActions()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        --cclog('\n')
        --cclog('############################################################')
        --cclog('# idx : ' .. self.m_workIdx .. ', func_name : ' .. func_name)
        --cclog('############################################################')
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function direction_showScore
-------------------------------------
function UI_GameResult_Illusion:direction_showScore()
    self.root:stopAllActions()
    local is_success = self.m_bSuccess
    self:setSuccessVisual_Ancient()
    self:setAnimationData()
    self:makeScoreAnimation()

end

-------------------------------------
-- function direction_delay
-------------------------------------
function UI_GameResult_Illusion:direction_delay()
    local delay_time = 2
    local next_func = function()
        self:doNextWork()
    end
    
    local act_next = cc.CallFunc:create(next_func)
    local act_delay = cc.DelayTime:create(delay_time)

    local action = cc.Sequence:create(act_delay, act_next)
    self.root:runAction(action)
end
-------------------------------------
-- function makeAnimationData
-- @brief 애니메이션에 필요한 노드 리스트로 관리
-------------------------------------
function UI_GameResult_Illusion:setAnimationData()
    local vars = self.vars
    local score_calc = self.m_scoreCalc

    local score_list = {}
    local damage_score = score_calc:calcDamageBonus()
    local time_score = score_calc:calcClearTimeBonus()
    local diff_score = score_calc:calcDiffBonus()
    local participant_score = score_calc:calcParticipantBonus()
    local total_score = score_calc:calcFinalScore()

    table.insert(score_list, damage_score) -- damage
    table.insert(score_list, time_score) -- time
    table.insert(score_list, diff_score) -- 난이도
    table.insert(score_list, participant_score) -- 참여 점수
    table.insert(score_list, total_score) -- 전체 점수
  

    -- 애니메이션 적용되는 라벨 저장
    local var_list = {}
    table.insert(var_list, 'damageLabel1')
    table.insert(var_list, 'damageLabel2')

    table.insert(var_list, 'timeLabel1')
    table.insert(var_list, 'timeLabel2')

    table.insert(var_list, 'difficultyLabel1')
    table.insert(var_list, 'difficultyLabel2')

    table.insert(var_list, 'experienceLabel1')
    table.insert(var_list, 'experienceLabel2')

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
        if (idx == 10) then
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
    if idx == 10 then
        local total_node = self.vars['totalSprite']
        local act1 = cc.DelayTime:create( ani_time * idx )
        local act2 = cc.FadeIn:create( fadein_time )
        local action = cc.Sequence:create( act1, act2 )
        total_node:runAction(action)
    end
end

-------------------------------------
-- function startGame
-- @override
-------------------------------------
function UI_GameResult_Illusion:startGame()
    local stage_id = self.m_stageID
	local deck_name = 'illusion'

	local function finish_cb(game_key)
		-- 연속 전투일 경우 횟수 증가
		if (g_autoPlaySetting:isAutoPlay()) then
			g_autoPlaySetting.m_autoPlayCnt = (g_autoPlaySetting.m_autoPlayCnt + 1)
		end

		local stage_name = 'stage_' .. stage_id
		local scene = SceneGameIllusion(game_key, stage_id, stage_name, false)
		scene:runScene()
	end
    g_illusionDungeonData:request_illusionStart(self.m_stageID, deck_name, finish_cb, fail_cb) -- param : (stage_id, deck_name, finish_cb, fail_cb)

end

-------------------------------------
-- function click_illusionBtn
-------------------------------------
function UI_GameResult_Illusion:click_illusionBtn()
    UINavigatorDefinition:goTo('event_illusion_dungeon')
end

-------------------------------------
-- function setTotalScoreLabel
-- @brief 최종 스코어 bmfont 생성
-------------------------------------
function UI_GameResult_Illusion:setTotalScoreLabel()
    local vars = self.vars

    local total_score
    if (self.m_bSuccess) then
        total_score = cc.Label:createWithBMFont('res/font/tower_score.fnt', '')
    else
        total_score = cc.Label:createWithBMFont('res/font/tower_score_defeat.fnt', '')
    end
    
    total_score:setAnchorPoint(cc.p(0.5, 0.5))
    total_score:setDockPoint(cc.p(0.5, 0.5))
    total_score:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    total_score:setAdditionalKerning(0)
    vars['totalScoreNode']:addChild(total_score)

    total_score = NumberLabel(total_score, 0, 0.3)
    self.m_totalScore = total_score
end

-------------------------------------
-- function direction_showReward
-------------------------------------
function UI_GameResult_Illusion:direction_showReward()
    local l_drop = self.m_lDropItemList
    local vars = self.vars

    if (not l_drop) then
        vars['defeatLabel']:setVisible(true)
        self:doNextWork()
        return
    end
    
    vars['defeatLabel']:setVisible(false)
    
    local interval = 95
    local count = #l_drop
    local l_pos = getSortPosList(interval, count)

    for i, data in ipairs(l_drop) do
        local item_id = data['item_id']
        local count = data['count']
        local from = data['from']

        local item_card = UI_ItemCard(item_id, count, t_sub_data)
        item_card:setRarityVisibled(true)
        item_card.root:setScale(0.6)
        vars['iconNode']:addChild(item_card.root)

        local pos_x = l_pos[i]
        item_card.root:setPositionX(pos_x)
    end

    self:doNextWork()
end

-------------------------------------
-- function setSuccessVisual_Ancient
-- @brief 고대의 탑 전용 성공 연출 
-------------------------------------
function UI_GameResult_Illusion:setSuccessVisual_Ancient()
    local is_success = self.m_bSuccess
    local vars = self.vars

    vars['successVisual']:setVisible(true)
    if (is_success == true) then
        SoundMgr:playBGM('bgm_dungeon_victory', false)  
        vars['successVisual']:changeAni('clear_idle', false)
        vars['successVisual']:addAniHandler(function()
            vars['successVisual']:changeAni('clear_idle', true)
        end)
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        vars['successVisual']:changeAni('colossum_defeat_idle_02')
    end
end

-------------------------------------
-- function direction_moveMenu
-------------------------------------
function UI_GameResult_Illusion:direction_moveMenu()
    local vars = self.vars
    local switch_btn = vars['switchBtn']
    self:action_switchBtn(function() 
        switch_btn:setVisible(true)
        self:doNextWork()
    end)
end

-------------------------------------
-- function direction_moveMenu_click
-------------------------------------
function UI_GameResult_Illusion:direction_moveMenu_click()    
end

-------------------------------------
-- function click_switchBtn
-------------------------------------
function UI_GameResult_Illusion:click_switchBtn()
    local vars = self.vars
    self:action_switchBtn()
end

-------------------------------------
-- function action_switchBtn
-------------------------------------
function UI_GameResult_Illusion:action_switchBtn(callback)
    local vars = self.vars
    local result_menu = vars['resultMenu']
    local switch_btn = vars['switchBtn']
    local switch_sprite = vars['switchSprite']
    switch_btn:setEnabled(false)

    local angle = 0
    if (result_menu:getPositionY() == 130) then
        move_y = 430 -- 위로 올릴 위치
        angle = 0
    else
        move_y = 130 -- 기본 위치
        angle = 180
    end
    
    local move_act = cca.makeBasicEaseMove(0.5, 0, move_y)
    local after_act = cc.CallFunc:create(function()
        switch_btn:setEnabled(true)
		if (callback) then callback() end
	end)

    switch_sprite:runAction(cc.RotateTo:create(0.1, angle))
    result_menu:runAction(cc.Sequence:create(move_act, after_act))
end

-------------------------------------
-- function click_statusInfoBtn
-------------------------------------
function UI_GameResult_Illusion:click_statusInfoBtn()
    UI_HelpStatus()
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_Illusion:click_nextBtn()
    -- 다음 스테이지 ID 지정
    local stage_id = self.m_stageID
    local next_stage_id = g_illusionDungeonData:getNextStage(stage_id)
    if next_stage_id then
        local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
        local last_stage_id = struct_illusion:getIllusionLastStage()
        if (stage_id > last_stage_id) then
            UIManager:toastNotificationRed(Str('이전 난이도를 먼저 클리어하세요!'))
            return
        end
        
    -- 다음 스테이지 없는 경우
    else
        UIManager:toastNotificationRed(Str('마지막 스테이지 입니다.'))
        return
    end

    UI_ReadySceneNew_IllusionDungeon(next_stage_id)
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_GameResult_Illusion:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResult_Illusion:click_homeBtn()
	
	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local block_ui = UI_BlockPopup()

	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_Illusion:click_againBtn()
    UI_ReadySceneNew_IllusionDungeon(self.m_stageID)
end

-------------------------------------
-- function click_quickBtn
-------------------------------------
function UI_GameResult_Illusion:click_quickBtn()
	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local quick_btn = self.vars['quickBtn']
	quick_btn:setEnabled(false)

	-- 게임 시작 실패시 동작
	local function fail_cb()
		quick_btn:setEnabled(true)
	end

    local stage_id = self.m_stageID
	local check_stamina
    local check_dragon_inven
    local check_item_inven
    local start_game
	
	-- 활동력도 체크 (준비화면에 가는게 아니므로)
	check_stamina = function()
		if (g_staminasData:checkStageStamina(stage_id)) then
			check_dragon_inven()
		else
			fail_cb()

			-- 스태미나 충전
			local function finish_cb()
				self:show_staminaInfo()
			end
			g_staminasData:staminaCharge(stage_id, finish_cb)
		end
	end

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            self:click_manageBtn()
			fail_cb()
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            UI_Inventory()
			fail_cb()
        end
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end

    start_game = function()
        -- 빠른 재시작
        self:startGame()
    end

    check_stamina()
end

-------------------------------------
-- function direction_checkAutoPlay
-------------------------------------
function UI_GameResult_Illusion:direction_checkAutoPlay()
    -- 마스터 로드 기록 후 연속 전투 체크
    self:checkAutoPlay()
end

-------------------------------------
-- function checkAutoPlay
-- @brief
-------------------------------------
function UI_GameResult_Illusion:checkAutoPlay()

    if (not g_autoPlaySetting:isAutoPlay()) then
        return
    end
        
	local auto_play_stop, msg = self:checkAutoPlayCondition()
    
    if (auto_play_stop == true) then
        -- 자동 전투 off
        g_autoPlaySetting:setAutoPlay(false)

        -- 메세지 있는 경우에만 팝업 출력
        if (msg) then MakeSimplePopup(POPUP_TYPE.OK, msg) end
        return
    end

    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() self:countAutoPlay()  end)))
end

-------------------------------------
-- function countAutoPlay
-- @brief 연속 전투일 경우 재시작 하기전 카운트 해줌
-------------------------------------
function UI_GameResult_Illusion:countAutoPlay()
    if (not g_autoPlaySetting:isAutoPlay()) then return false end

    self.m_autoCount = true
    local vars = self.vars
    local node = vars['autoBattleNode']
    node:setVisible(true)

    local count_label = vars['countLabel']
    count_label:setString('')

    local count_num = 3
    local count_time = 1

    -- count ani
    for i = count_num, 1, -1 do
        local act1 = cc.DelayTime:create((count_num - i) * count_time)
        local act2 = cc.CallFunc:create(function() 
            count_label:setString(tostring(i)) 
            count_label:setOpacity(255)
            count_label:setScale(1)
        end)
        local act3 = cc.Spawn:create(cc.FadeOut:create(count_time), cc.ScaleTo:create(count_time, 0.8))

        count_label:runAction(cc.Sequence:create(act1, act2, act3))        
    end

    -- close
    do
        local act1 = cc.DelayTime:create(count_num * count_time)
        local act2 = cc.CallFunc:create(function()
            node:setVisible(false) 
            self:click_quickBtn() 
        end)
        self.root:runAction(cc.Sequence:create(act1, act2))
    end
end

-------------------------------------
-- function checkAutoPlayCondition
-- @override
-------------------------------------
function UI_GameResult_Illusion:checkAutoPlayCondition()
	local auto_play_stop = false
    local msg = nil

    -- 패배 시 연속 전투 종료
    if g_autoPlaySetting:get('stop_condition_lose') then
        if (not self.m_bSuccess) then
            auto_play_stop = true
            msg = Str('패배로 인해 연속 전투가 종료되었습니다.')
        end
    end

    -- 일일 최대 환상 토큰 획득 시 전투 종료
    if g_autoPlaySetting:get('illusion_max_try') then
        local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
        local remain_token = struct_illusion.remain_token
        if (not remain_token or remain_token == 0) then
            auto_play_stop = true
            msg = Str('획득 가능한 토큰 수량을 초과하여 연속 전투가 종료됩니다.')
        end
    end

	return auto_play_stop, msg
end
