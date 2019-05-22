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

local SCORE_DIFF = {[1] = 0, [2] = 1000, [3] = 2000, [4] = 5000}
local SCORE_PART = {['none'] = 0, ['illusion_dragon'] = 2500, ['my_dragon'] = 5000}

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_Illusion:init(stage_id, is_success, time, damage)
    self.m_stageID = stage_id
    self.m_bSuccess = is_success
    self.m_time = time
    self.m_damage = damage
    self.m_lDragonList = l_dragon_list
    self.m_lDropItemList = l_drop_item_list
    self.m_staminaType = 'st'
    self.m_autoCount = false
    self.m_content_open = content_open and content_open['open'] or false
    self.m_scoreCalc = score_calc

    self:initUI()
    self:initButton()
    
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_GameResult_Illusion')

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
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
--        모험모드에서 사용하므로 고대의 탑에선 off
-------------------------------------
function UI_GameResult_Illusion:init_difficultyIcon(stage_id)
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
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
    table.insert(self.m_lWorkList, 'direction_delay')
    table.insert(self.m_lWorkList, 'direction_moveMenu')
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
    -- 성공시에만 스코어 연출
    if (is_success) then
        self:setAnimationData()
        self:makeScoreAnimation()
    else
        self:doNextWork()
    end
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

    local score_list = {}
    local damage_score = math.floor(self.m_damage / 10000)
    local time_score = math.floor((5000 / 300) * (300 - self.m_time))
    
    -- 난이도 점수
    local diff = g_illusionDungeonData:parseStageID(self.m_stageID)
    local diff_score = SCORE_DIFF[tonumber(diff)] or 0

    -- 참가 점수
    local participant = g_illusionDungeonData:getParticiPantInfo()
    local participant_score = 0  
    if (participant < 0) then
        participant_score = SCORE_PART['none']
    elseif (participant == 0) then
        participant_score = SCORE_PART['illusion_dragon']
    elseif (participant > 0) then
        participant_score = SCORE_PART['my_dragon']
    end

    local total_score = damage_score + time_score + diff_score + participant_score

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
function UI_GameResult_Illusion:click_againBtn()
    UINavigatorDefinition:goTo('event_illusion_dungeon')
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_Illusion:click_nextBtn()
        UINavigatorDefinition:goTo('event_illusion_dungeon')
end

-------------------------------------
-- function setTotalScoreLabel
-- @brief 최종 스코어 bmfont 생성
-------------------------------------
function UI_GameResult_Illusion:setTotalScoreLabel()
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
-- function setSuccessVisual_Ancient
-- @brief 고대의 탑 전용 성공 연출 
-------------------------------------
function UI_GameResult_Illusion:setSuccessVisual_Ancient()
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
    if (result_menu:getPositionY() == 100) then
        move_y = 450 -- 위로 올릴 위치
        angle = 180
    else
        move_y = 100 -- 기본 위치
        angle = 0
    end
    
    local move_act = cca.makeBasicEaseMove(0.5, 0, move_y)
    local after_act = cc.CallFunc:create(function()
        switch_btn:setEnabled(true)
		if (callback) then callback() end
	end)

    switch_sprite:runAction(cc.RotateTo:create(0.1, angle))
    result_menu:runAction(cc.Sequence:create(move_act, after_act))
end