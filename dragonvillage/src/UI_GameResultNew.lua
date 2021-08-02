local PARENT = UI

-------------------------------------
-- class UI_GameResultNew
-------------------------------------
UI_GameResultNew = class(PARENT, {
        m_stageID = 'number',
        m_bSuccess = 'boolean',
        m_time = 'number',
        m_gold = 'number',
        m_tTamerLevelupData = 'table',
        m_lDragonList = 'list',
        m_lDropItemList = 'list',
        m_secretDungeon = 'table',

        m_lNumberLabel = 'list',
        m_lLevelupDirector = 'list',

        m_directionStep = 'number',
        m_lDirectionList = 'list',
        
        m_lWorkList = 'list',
        m_workIdx = 'number',

        m_staminaType = 'string',
        m_autoCount = 'boolean',

		m_isClearMasterRoad = 'boolean',

        m_content_open = 'boolean', -- 컨텐츠 오픈
        m_scoreCalc = '', -- 스코어 
        
        m_staminaInfo = 'UI_StaminaInfo',   -- 날개UI
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResultNew:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open, score_calc)
    self.m_stageID = stage_id
    self.m_bSuccess = is_success
    self.m_time = time
    self.m_gold = gold or 0
    self.m_tTamerLevelupData = t_tamer_levelup_data
    --self.m_lDragonList = l_dragon_list @2020-11-25 이제 서버에서 드래곤 정보 받을 필요 없이 클라 내부에서 해결하도록 변경
    self.m_lDragonList = self:getDragonList()
    self.m_lDropItemList = l_drop_item_list
    self.m_secretDungeon = secret_dungeon
    self.m_staminaType = 'st'
    self.m_autoCount = false
    self.m_content_open = content_open and content_open['open'] or false
    self.m_scoreCalc = score_calc

    local vars = self:load('ingame_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:initUI()
    self:initButton()
    
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_GameResultNew')

    -- @brief work초기화 용도로 사용함
    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameResultNew:initUI()
    local vars = self.vars
    local stage_id = self.m_stageID
    local t_tamer_levelup_data = self.m_tTamerLevelupData
    local l_dragon_list = self.m_lDragonList

    -- 스테이지를 클리어했을 경우 다음 스테이지 ID 지정
    if (self.m_bSuccess == true) then
        local next_stage_id = g_stageData:getNextStage(stage_id)
        if next_stage_id then
            g_stageData:setFocusStage(next_stage_id)
        end
    end

    do -- NumberLabel 초기화, 게임 플레이 시간, 획득 골드
        self.m_lNumberLabel = {}
        self.m_lNumberLabel['time'] = NumberLabel(vars['timeLabel'], 0, 1)
        self.m_lNumberLabel['gold'] = NumberLabel(vars['goldLabel'], 0, 1)
    end

    do
        -- 스테이지 이름
        local str = g_stageData:getStageName(stage_id)
        vars['titleLabel']:setString(str)

        -- 스테이지 난이도를 표시
        self:init_difficultyIcon(stage_id)
    end
    
    -- 레벨업 연출 클래스 리스트
    self.m_lLevelupDirector = {}

    -- 유저 레벨, 경험치
    if (0 < table.count(t_tamer_levelup_data)) then
        self:initTamer()
    end

    -- 드래곤 리스트
    self:initDragonList(t_tamer_levelup_data, l_dragon_list)    

    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameResultNew:initButton()
    local vars = self.vars

    vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['homeBtn']:registerScriptTapHandler(function() self:click_homeBtn() end)
    vars['againBtn']:registerScriptTapHandler(function() self:click_againBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)

    -- 모드별 버튼
    vars['mapBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['relationBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['goldBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['nightmareBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['treeBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['dragonBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['towerBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['attrTowerBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['ancientRuinBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    vars['switchBtn']:registerScriptTapHandler(function() self:click_switchBtn() end)
    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_statusInfoBtn() end)
    vars['infoBtn']:setVisible(true)
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
-------------------------------------
function UI_GameResultNew:init_difficultyIcon(stage_id)
    local vars = self.vars

    local difficulty, chapter, stage = parseAdventureID(stage_id)

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
function UI_GameResultNew:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
--    table.insert(self.m_lWorkList, 'direction_showTamer')
	table.insert(self.m_lWorkList, 'check_tutorial')
	table.insert(self.m_lWorkList, 'check_masterRoad')
--    table.insert(self.m_lWorkList, 'direction_hideTamer')
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
    table.insert(self.m_lWorkList, 'direction_personalpack')
    table.insert(self.m_lWorkList, 'direction_masterRoad')
end

-------------------------------------
-- function isWorkListDone
-------------------------------------
function UI_GameResultNew:isWorkListDone()
	if (not self.m_workIdx) then
		return false
	end
	local work_list_cnt = #self.m_lWorkList
	return (self.m_workIdx >= work_list_cnt)
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_GameResultNew:doNextWork()
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
-- function click_screenBtn
-------------------------------------
function UI_GameResultNew:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        if (self:checkAutoPlayRelease()) then return end
        self[func_name](self)
    end
end

-------------------------------------
-- function check_tutorial
-- @brief 강종을 대비해서 미리 튜토리얼을 저장한다
-------------------------------------
function UI_GameResultNew:check_tutorial()
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)
    if (game_mode == GAME_MODE_ADVENTURE) then
		local function cb_func()
			self:doNextWork()
		end
		-- @ TUTORIAL
		TutorialManager.getInstance():saveTutorialStepInAdventureResult(stage_id, cb_func)
	else
		self:doNextWork()
	end
end
-------------------------------------
-- function check_tutorial_click
-------------------------------------
function UI_GameResultNew:check_tutorial_click()
    -- nothing to do
end

-------------------------------------
-- function check_masterRoad
-- @brief 마스터의 길 클리어 체크
-------------------------------------
function UI_GameResultNew:check_masterRoad()
    -- 마스터의 길 : 유저 레벨 체크
    do
        -- @ MASTER ROAD
        local t_data = {clear_key = 'u_lv'}
        g_masterRoadData:updateMasterRoad(t_data)
    end

    -- 마스터의 길 : 스테이지 체크
    if (self.m_bSuccess) then
        -- @ MASTER ROAD
        local t_data = {
            game_mode = g_stageData:getGameMode(self.m_stageID),
            stage_id = self.m_stageID, 
            dungeon_mode = g_gameScene.m_dungeonMode, 
            is_success = true
        }
		local function cb_func(b)
			self.m_isClearMasterRoad = b or false
			self:doNextWork()
		end
        g_masterRoadData:updateMasterRoad(t_data, cb_func)

        -- @ GOOGLE ACHIEVEMENT
        GoogleHelper.updateAchievement(t_data)

	else
		self:doNextWork()

    end
end
-------------------------------------
-- function check_masterRoad_click
-------------------------------------
function UI_GameResultNew:check_masterRoad_click()
	-- nothing to do
end

-------------------------------------
-- function direction_showTamer
-- @brief 테이머 등장
-------------------------------------
function UI_GameResultNew:direction_showTamer()
    local is_success = self.m_bSuccess
    local vars = self.vars

    vars['titleNode']:setVisible(false)
    vars['resultMenu']:setVisible(false)

	local t_tamer =  g_tamerData:getCurrTamerTable()

    local tamer_node = vars['tamerNode']

    local tamer_res = t_tamer['res']
    local animator = MakeAnimator(tamer_res)
    if (animator.m_node) then
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        tamer_node:addChild(animator.m_node)
    end
    tamer_node:setVisible(true)
    vars['talkLabel']:setVisible(is_success)

	-- 표정 적용
	local face_ani = TableTamer:getTamerFace(t_tamer['type'], is_success)
	animator:changeAni(face_ani, true)

    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function direction_showTamer_click
-------------------------------------
function UI_GameResultNew:direction_showTamer_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_GameResultNew:direction_hideTamer()
    local vars = self.vars
    local tamer_node = vars['tamerNode']
    local hide_act = cc.EaseExponentialOut:create(cc.MoveTo:create(0.8, cc.p(0, -1000)))
    local after_act = cc.CallFunc:create(function()
		tamer_node:setVisible(false)
        self:doNextWork()
	end)

    tamer_node:runAction(cc.Sequence:create(hide_act, after_act))
end

-------------------------------------
-- function direction_hideTamer_click
-------------------------------------
function UI_GameResultNew:direction_hideTamer_click()
end

-------------------------------------
-- function direction_showScore
-------------------------------------
function UI_GameResultNew:direction_showScore()
    self:doNextWork()
end

-------------------------------------
-- function direction_showScore_click
-------------------------------------
function UI_GameResultNew:direction_showScore_click()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_GameResultNew:direction_start()
    local is_success = self.m_bSuccess
    local vars = self.vars
    
    vars['titleNode']:setVisible(true)
    vars['resultMenu']:setVisible(true)

    self:setSuccessVisual()

	vars['statsBtn']:setVisible(false)
    vars['homeBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)

    vars['skipLabel']:setVisible(false)
    vars['againBtn']:setVisible(false)

    -- 드래곤 레벨업 연출 node
    vars['dragonResultNode']:setVisible(true)

    -- 플레이 시간, 획득 골드
    self.m_lNumberLabel['time']:setNumber(self.m_time)
    self.m_lNumberLabel['gold']:setNumber(self.m_gold)

    -- 자동 재화 회득 
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

    if (game_mode == GAME_MODE_ADVENTURE) then
        local function update(dt)
            if (self.m_staminaInfo) then
                self.m_staminaInfo:refresh()
            end
        end
        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)   
    end

    -- 레벨업 연출 시작
    self:startLevelUpDirector()

    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function setSuccessVisual
-- @brief 성공 연출
-------------------------------------
function UI_GameResultNew:setSuccessVisual()
    local is_success = self.m_bSuccess
    local vars = self.vars

    vars['successVisual']:setVisible(true)

    -- 성공 or 실패
    if (is_success == true) then
        SoundMgr:playBGM('bgm_dungeon_victory', false)    
        vars['successVisual']:changeAni('success', false)
        vars['successVisual']:addAniHandler(function()
            vars['successVisual']:changeAni('success_idle', true)
        end)
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        vars['successVisual']:changeAni('fail')
    end
end

-------------------------------------
-- function direction_start_click
-------------------------------------
function UI_GameResultNew:direction_start_click()
    local is_level_up = false

    local t_levelup_data = self.m_tTamerLevelupData
    if (t_levelup_data) then
        local prev_lv = t_levelup_data['prev_lv'] or 0 
        local curr_lv = t_levelup_data['curr_lv'] or 0
        is_level_up = (prev_lv ~= curr_lv) and true or false
    end
    
    -- 레벨업 아닌 경우만 스킵 가능
    if (not is_level_up) then
        self:doNextWork()
    end
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_GameResultNew:direction_end()
    local is_success = self.m_bSuccess
    local vars = self.vars

    -- 플레이 시간, 획득 골드
    self.m_lNumberLabel['time']:setNumber(self.m_time, true)
    self.m_lNumberLabel['gold']:setNumber(self.m_gold, true)

    -- 레벨업 연출 종료
    self:stopLevelUpDirector()

    self.root:stopAllActions()

    -- @개발 스테이지
    if (self.m_stageID == DEV_STAGE_ID) then
        vars['mapBtn']:setVisible(true)
        return
    end

    if (is_success == true) then
        local duration = 1.3
        if g_autoPlaySetting:isAutoPlay() then
            duration = 0.5
        end
        -- 2초 후 자동으로 이동
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
                self:doNextWork()
            end)))
    else
        vars['skipLabel']:setVisible(false)
        vars['prevBtn']:setVisible(true)
		vars['statsBtn']:setVisible(true)
        vars['againBtn']:setVisible(true)

        self:doNextWork()
    end
end

-------------------------------------
-- function direction_end_click
-------------------------------------
function UI_GameResultNew:direction_end_click()
    -- @개발 스테이지
    if (self.m_stageID == DEV_STAGE_ID) then
        return
    end

    
    self:doNextWork()
end

-------------------------------------
-- function direction_showBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResultNew:direction_showBox()
    local vars = self.vars
    local is_success = self.m_bSuccess
    if (not is_success) then 
        self:doNextWork()
        return
    end

    -- 드래곤 레벨업 연출 node 끄기
    --vars['dragonResultNode']:setVisible(false)

    vars['boxVisual']:setVisible(true)
    vars['boxVisual']:changeAni('box_01', false)
    vars['boxVisual']:addAniHandler(function()
        --vars['boxVisual']:changeAni('box_02', true)
        self:doNextWork()
    end)

    -- 연속 전투일 경우 상자 바로 오픈
    if g_autoPlaySetting:isAutoPlay() then
        self:doNextWork()
    end
end

-------------------------------------
-- function direction_showBox_click
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResultNew:direction_showBox_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_openBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResultNew:direction_openBox()
    local vars = self.vars
    local is_success = self.m_bSuccess
    if (not is_success) then 
        self:doNextWork()
        return
    end

    vars['boxVisual']:changeAni('box_03', false)
    vars['boxVisual']:addAniHandler(function()
        vars['boxVisual']:setVisible(false) 
        self:doNextWork()
    end)
	
	-- 상자가 열리면서 사운드
    -- SoundMgr:playEffect('UI', 'ui_reward')
end

-------------------------------------
-- function direction_openBox_click
-- @brief
-------------------------------------
function UI_GameResultNew:direction_openBox_click()
end

-------------------------------------
-- function direction_dropItem
-- @brief
-------------------------------------
function UI_GameResultNew:direction_dropItem()
    local vars = self.vars
   local count = #self.m_lDropItemList
    
    -- 보상이 없을때
    if (count <= 0) then
        self:doNextWork()
        vars['noRewardMenu']:setVisible(true)
        return
    end

    local interval = 95
    local count = #self.m_lDropItemList
    local l_pos = getSortPosList(interval, count)

    for i,v in ipairs(self.m_lDropItemList) do
        local item_id = v[1]
        local count = v[2]
        local from = v[3]
        local t_sub_data = v[4]

        local item_card = UI_ItemCard(item_id, count, t_sub_data)
        item_card:setRarityVisibled(true)

        if (from == 'bonus') then
            local animator = MakeAnimator('res/item/item_marble/item_marble.vrp')
            animator:setAnchorPoint(cc.p(0.5, 0.5))
            animator:setDockPoint(cc.p(1, 1))
            animator:setScale(0.85)
            animator:setPosition(-20, -20)
            item_card.vars['clickBtn']:addChild(animator.m_node)
        end
        item_card.root:setScale(0.6)
        vars['dropRewardMenu']:addChild(item_card.root)

        local pos_x = l_pos[i]
        item_card.root:setPositionX(pos_x)
    end

    vars['skipLabel']:setVisible(false)

    self:doNextWork()
end

-------------------------------------
-- function direction_dropItem_click
-- @brief
-------------------------------------
function UI_GameResultNew:direction_dropItem_click()
end

-------------------------------------
-- function direction_secretDungeon
-- @brief 비밀던전 팝업 알림 팝업 표시
-------------------------------------
function UI_GameResultNew:direction_secretDungeon()
    if (self.m_secretDungeon) then
        MakeSimpleSecretFindPopup(self.m_secretDungeon)
    end

    self:doNextWork()
end

-------------------------------------
-- function direction_showButton
-------------------------------------
function UI_GameResultNew:direction_showButton()
    local vars = self.vars
	vars['statsBtn']:setVisible(true)
    vars['homeBtn']:setVisible(true)
    vars['againBtn']:setVisible(true)
    vars['nextBtn']:setVisible(true)
    vars['quickBtn']:setVisible(true)

    self:set_modeButton()
    self:doNextWork()
end

-------------------------------------
-- function set_modeButton
-- @brief 모드별 버튼 정리
-------------------------------------
function UI_GameResultNew:set_modeButton()
    local vars = self.vars
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

    vars['mapBtn']:setVisible(false)

    local function moveToCenterBtn()
        vars['prevBtn']:setVisible(false)
        vars['nextBtn']:setVisible(false)
        vars['againBtn']:setPositionX(-110)
        vars['quickBtn']:setPositionX(110)
    end

    -- 네스트 던전 모드
    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)

        local dungeon_mode = t_dungeon_id_info['dungeon_mode']
        if (dungeon_mode == NEST_DUNGEON_EVO_STONE) then
            vars['dragonBtn']:setVisible(true)

        elseif (dungeon_mode == NEST_DUNGEON_NIGHTMARE) then
            vars['nightmareBtn']:setVisible(true)
            
        elseif (dungeon_mode == NEST_DUNGEON_TREE) then
            vars['treeBtn']:setVisible(true)

        elseif (dungeon_mode == NEST_DUNGEON_GOLD) then
            vars['goldBtn']:setVisible(true)

        else
            vars['mapBtn']:setVisible(true)
        end

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        moveToCenterBtn()
        vars['relationBtn']:setVisible(true)

    -- 고대의 탑
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        if (attr) then
            vars['attrTowerBtn']:setVisible(true)
        else
            vars['towerBtn']:setVisible(true)
        end

    -- 고대 유적 던전
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        vars['ancientRuinBtn']:setVisible(true)

    -- 룬 수호자 던전
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        moveToCenterBtn()

    -- 차원의 문
    elseif (game_mode == GAME_MODE_DIMENSION_GATE) then
        moveToCenterBtn()

    -- 룬 페스티벌 (모험 모드로 간주)
    elseif (g_stageData:isRuneFestivalStage(stage_id) == true) then
        moveToCenterBtn()
        vars['mapBtn']:setVisible(false)
        --vars['statsBtn']:setVisible(false)
        --vars['homeBtn']:setVisible(false)
        self:adjustMenuButtonPos()

    -- 모험 
    else
        vars['mapBtn']:setVisible(true)

        -- 클리어 시
        if (self.m_bSuccess == true) then
            -- 다음 스테이지가 열려있을 경우
            local stage_id = self.m_stageID
            local next_stage_id = g_stageData:getNextStage(stage_id)
            if (next_stage_id ~= nil) and (g_stageData:isOpenStage(next_stage_id) == true) then
                -- 다음 스테이지를 한번도 클리어하지 못한 경우
                if (g_adventureData:isClearStage(next_stage_id) == false) then
                    -- 다음 버튼에 흔들림 추가
                    local action = cca.buttonShakeAction(2, 0.8) -- params : level, delay_time
                    vars['nextBtn']:runAction(action)
                end
            end
        end
    end
end

-------------------------------------
-- function adjustMenuButtonPos
-------------------------------------
function UI_GameResultNew:adjustMenuButtonPos()
    local vars = self.vars

    -- 먼저 추가되는 항목이 왼쪽에 표시
    local l_luaname = {}
    table.insert(l_luaname, 'homeBtn')
    table.insert(l_luaname, 'mapBtn')
    table.insert(l_luaname, 'statsBtn')

    -- 존재하는 버튼, visible이 켜진 버튼만 추가
    local l_node = {}
    for i,v in ipairs(l_luaname) do
        if (vars[v] and vars[v]:isVisible()) then
            table.insert(l_node, vars[v])
        end
    end

    -- 버튼 가운데 정렬
    local l_pos = getSortPosList(150, #l_node) -- params : interval, count
    for i,v in ipairs(l_node) do
        v:setPositionX(l_pos[i])
    end
end

-------------------------------------
-- function direction_showButton_click
-------------------------------------
function UI_GameResultNew:direction_showButton_click()
end

-------------------------------------
-- function direction_moveMenu
-------------------------------------
function UI_GameResultNew:direction_moveMenu()
    local vars = self.vars
    local switch_btn = vars['switchBtn']
    self:action_switchBtn(function() 
        switch_btn:setVisible(true)
        self:doNextWork()
    end)
    self:show_staminaInfo()
end

-------------------------------------
-- function direction_moveMenu_click
-------------------------------------
function UI_GameResultNew:direction_moveMenu_click()
end

-------------------------------------
-- function direction_dragonGuide
-------------------------------------
function UI_GameResultNew:direction_dragonGuide()
    local vars = self.vars
    if (self.m_bSuccess) then
        self:doNextWork()
    else
        local b_guide = false   
        for i, v in ipairs(self.m_lDragonList) do
            local dragon_data = v['user_data']
            local analysis_result = DragonGuideNavigator:analysis(dragon_data)
            local link_list = analysis_result['link']

            if (#link_list > 0) then
                b_guide = true
                break
            end
        end

        -- 가이드 가능한 상태에서만 UI 띄워줌
        if (b_guide) then
            local ui = UI_DragonGuidePopup(self.m_lDragonList)
            if (g_autoPlaySetting:isAutoPlay()) then
                self:doNextWork()
            else
                ui:setCloseCB(function() self:doNextWork() end)
            end
        else
            self:doNextWork()
        end
    end
end

-------------------------------------
-- function direction_dragonGuide_click
-------------------------------------
function UI_GameResultNew:direction_dragonGuide_click()
end

-------------------------------------
-- function direction_personalpack
-------------------------------------
function UI_GameResultNew:direction_personalpack()
    -- 연속 전투 중에는 출력하지 않는다.
    if (g_autoPlaySetting:isAutoPlay()) then
        self:doNextWork()
        return
    end

    g_personalpackData:pull(function() self:doNextWork() end)
end
-------------------------------------
-- function direction_personalpack_click
-------------------------------------
function UI_GameResultNew:direction_personalpack_click()
end

-------------------------------------
-- function direction_masterRoad
-------------------------------------
function UI_GameResultNew:direction_masterRoad()
	-- 승리 시
	if (self.m_bSuccess) then
		-- @ TUTORIAL : 1-7 end start
		local stage_id = self.m_stageID
		if (TutorialManager.getInstance():checkStartFreeSummon11(stage_id)) then
			local tutorial_key = TUTORIAL.ADV_01_07_END
			TutorialManager.getInstance():startTutorial(tutorial_key, self)

		-- 마스터의 길 클리어했다면
		elseif (self.m_isClearMasterRoad) then
			--UI_MasterRoadRewardPopup(stage_id)
            OpenMasterRoadRewardPopup(stage_id)

		end
	end

    -- 드래곤 성장일지 : 드래곤 등급, 레벨 체크
    local start_dragon_data = g_dragonDiaryData:getStartDragonDataWithList(self.m_lDragonList)
    if (start_dragon_data) then
        -- @ DRAGON DIARY
        local t_data = {clear_key = 'd_lv', sub_data = start_dragon_data}
        g_dragonDiaryData:updateDragonDiary(t_data)
    end

    -- 마스터 로드 기록 후 연속 전투 체크
    self:checkAutoPlay()
end

-------------------------------------
-- function direction_masterRoad_click
-------------------------------------
function UI_GameResultNew:direction_masterRoad_click()
end

-------------------------------------
-- function addLevelUpDirector
-- @brief 레벨업 연출 클래스 추가
-------------------------------------
function UI_GameResultNew:addLevelUpDirector(level_up_director)
    table.insert(self.m_lLevelupDirector, level_up_director)
end

-------------------------------------
-- function startLevelUpDirector
-- @brief 레벨업 연출 클래스 시작
-------------------------------------
function UI_GameResultNew:startLevelUpDirector()
    for i,v in ipairs(self.m_lLevelupDirector) do
        v:start()
    end
end

-------------------------------------
-- function stopLevelUpDirector
-- @brief 레벨업 연출 클래스 종료
-------------------------------------
function UI_GameResultNew:stopLevelUpDirector()
    for i,v in ipairs(self.m_lLevelupDirector) do
        v:stop(true)
    end
end

-------------------------------------
-- function initTamer
-- @brief 테이머 정보 설정
-------------------------------------
function UI_GameResultNew:initTamer()
    local t_levelup_data = self.m_tTamerLevelupData
    local vars = self.vars

    local prev_lv = t_levelup_data['prev_lv']
    local prev_exp = t_levelup_data['prev_exp']
    local curr_lv = t_levelup_data['curr_lv']
    local curr_exp = t_levelup_data['curr_exp']

    vars['userExpLabel']:setString(Str('경험치 +{1}', prev_exp))
    vars['userLvLabel']:setString(Str('레벨{1}', prev_lv))
    vars['userExpGg']:setPercentage(prev_exp / prev_lv * 100)

    local lv_label      = vars['userLvLabel']
    local exp_label     = vars['userExpLabel']
    local max_icon      = vars['userMaxSprite']
    local exp_gauge     = vars['userExpGg']
    local level_up_vrp  = vars['userLvUpVisual']
    local levelup_director = LevelupDirector_GameResult(lv_label, exp_label, max_icon, exp_gauge, level_up_vrp)

    local is_level_up = (prev_lv ~= curr_lv) and true or false

    -- 테이머 레벨업 연출 
    if (is_level_up) then
        levelup_director.m_cbAniFinish = function()
            self.root:stopAllActions()
            
            -- @ GOOGLE ACHIEVEMENT
            local t_data = {clear_key = 'u_lv'}
            GoogleHelper.updateAchievement(t_data)

            local ui = UI_UserLevelUp(t_levelup_data)
            ui:setCloseCB(function() self:doNextWork() end)
        end
    end

    levelup_director:initLevelupDirector(prev_lv, prev_exp, curr_lv, curr_exp, 'tamer')
    self:addLevelUpDirector(levelup_director)
end

-------------------------------------
-- function initDragonList
-- @brief 드래곤 정보 설정
-------------------------------------
function UI_GameResultNew:initDragonList(t_tamer_levelup_data, l_dragon_list)
    local dragon_cnt = #l_dragon_list
    local vars = self.vars

    self:sortDragonNode(dragon_cnt)
    -- 드래곤 리소스 생성
    for i, v in ipairs(l_dragon_list) do
        local user_data = v['user_data']
        local table_data = v['table_data']
        local res_name = table_data['res']
        local evolution = user_data['evolution']
        local grade = user_data['grade']
		local attr = table_data['attr']
		local scale = table_data['scale_'.. evolution]

        -- 외형 변환 적용 Animator
        local animator = AnimatorHelper:makeDragonAnimatorByTransform(user_data)
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
		
		-- 자코 추가로 스케일 개별 적용
        animator.m_node:setScale(math_clamp(scale, 1, 2))

        vars['dragonNode' .. i]:addChild(animator.m_node)

        do -- 드래곤 레벨, 경험치
            local lv_label      = vars['lvLabel' .. i]
            local exp_label     = vars['expLabel' .. i]
            local max_icon      = vars['maxSprite' .. i]
            local exp_gauge     = vars['expGauge' .. i]
            local level_up_vrp  = vars['lvUpVisual' .. i]
            local levelup_director = LevelupDirector_GameResult(lv_label, exp_label, max_icon, exp_gauge, level_up_vrp, grade)

            -- 최초 레벨업 시 포즈
            levelup_director.m_cbFirstLevelup = function()
                animator:changeAni('pose_1', false)
                animator:addAniHandler(function() animator:changeAni('idle', true) end)
            end

            -- @kwkang 2020-11-12부로 경험치를 아이템으로 획득하게 변경되어 레벨업 연출 필요 없음
            --local t_levelup_data = v['levelup_data']
            --local src_lv        = t_levelup_data['prev_lv']
            --local src_exp       = t_levelup_data['prev_exp']
            --local dest_lv       = t_levelup_data['curr_lv']
            --local dest_exp      = t_levelup_data['curr_exp']
            --local type          = 'dragon'
			--local rlv			= user_data['reinforce']['lv']
            local src_lv        = user_data['lv']
            local src_exp       = 0
            local dest_lv       = user_data['lv']
            local dest_exp      = 0
            local type          = 'dragon'
			local rlv			= user_data['reinforce']['lv']
            local mlv           = user_data['mastery_lv']
            levelup_director:initLevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type, grade, rlv, mlv)
            self:addLevelUpDirector(levelup_director)

            do -- 등급
                local sprite = IconHelper:getDragonGradeIcon(user_data, 1)
                vars['starNode' .. i]:removeAllChildren()
                vars['starNode' .. i]:addChild(sprite)
            end
        end
    end
end

-------------------------------------
-- function sortDragonNode
-- @brief 드래곤 노드(테이머 포함) 정렬
-------------------------------------
function UI_GameResultNew:sortDragonNode(dragon_cnt)
    local interval = 179
    local vars = self.vars

    -- 테이머 노드 하나 추가
    --local cnt = dragon_cnt + 1
    local cnt = dragon_cnt -- 테이머 제거
    local idx = 0

    if (cnt % 2) == 0 then
        idx = -((cnt / 2) - 0.5)
    else
        idx = -((cnt - 1) / 2)
    end

    local start_x = (idx * interval)

    for i=1, 5 do
        local node = vars['dragonBoard' .. i]
        
        if (i <= cnt) then
            node:setPositionX(start_x)
            start_x = (start_x + interval)    
        else
            node:setVisible(false)
        end
    end
end

-------------------------------------
-- function blockButtonUntilWorkDone
-- @brief 연출이 끝날때까지 back key를 막는다
-------------------------------------
function UI_GameResultNew:blockButtonUntilWorkDone()
	return (not self:isWorkListDone())
end

-------------------------------------
-- function click_backBtn
-- @brief 모드별 백버튼은 여기서 처리
-------------------------------------
function UI_GameResultNew:click_backBtn()
	if (self:blockButtonUntilWorkDone()) then
		return
	end

    if (self:checkIsTutorial()) then
        return
    end

    if (self:checkAutoPlayRelease()) then
        return
    end

    -- 룬 페스티벌 (모험 모드로 간주되어 모험 맵으로 이동하는 것 방지)
    local stage_id = self.m_stageID
    if (g_stageData:isRuneFestivalStage(stage_id) == true) then
        UINavigatorDefinition:goTo('event_rune_festival')
        return
    end

    local game_mode = g_gameScene.m_gameMode
    local dungeon_mode = g_gameScene.m_dungeonMode
    local condition = self.m_stageID
    QuickLinkHelper.gameModeLink(game_mode, dungeon_mode, condition)
end

-------------------------------------
-- function click_statusInfoBtn
-------------------------------------
function UI_GameResultNew:click_statusInfoBtn()
    if (self:checkAutoPlayRelease()) then
        return
    end

    UI_HelpStatus()
end

-------------------------------------
-- function click_quickBtn
-------------------------------------
function UI_GameResultNew:click_quickBtn(skip_check_auto_play_release)
	if (self:blockButtonUntilWorkDone()) then
		return
	end

    if (self:checkIsTutorial()) then
        return
    end

    if (skip_check_auto_play_release == nil) or (skip_check_auto_play_release == false) then
        if (self:checkAutoPlayRelease()) then
            return
        end
    end

	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local quick_btn = self.vars['quickBtn']
	quick_btn:setEnabled(false)

	-- 게임 시작 실패시 동작
	local function fail_cb()
		quick_btn:setEnabled(true)

        -- 만약 자동 전투 중이었다면 자동 전투 종료
        g_autoPlaySetting:setAutoPlay(false)
	end

    local stage_id = self.m_stageID
	local check_stamina
    local check_mode
    local check_dragon_inven
    local check_item_inven
    local start_game
	
	-- 활동력도 체크 (준비화면에 가는게 아니므로)
	check_stamina = function()
		if (g_staminasData:checkStageStamina(stage_id)) then
			check_mode()
		else
			fail_cb()

			-- 스태미나 충전
			local function finish_cb()
				self:show_staminaInfo()
			end
			g_staminasData:staminaCharge(stage_id, finish_cb)
		end
	end

    -- 룬 축제 이벤트 (일일 제한 확인)
	check_mode = function()
        if (g_stageData:isRuneFestivalStage(stage_id) == true) then
            local stamina_type, req_count = g_staminasData:getStageStaminaCost(stage_id)
            if (g_eventRuneFestival:isDailyStLimit(req_count) == true) then
                local function ok_cb()
                    quick_btn:setEnabled(true)
                end
                local msg = Str('하루 날개 사용 제한을 초과했습니다.')
                local submsg = g_eventRuneFestival:getRuneFestivalStaminaText() -- '일일 최대 {1}/{2}개 사용 가능'
                MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, ok_cb)
            else
                check_dragon_inven()
            end
        else
            check_dragon_inven()
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
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UI_RuneForge('manage')
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
-- function startGame
-------------------------------------
function UI_GameResultNew:startGame()
    local stage_id = self.m_stageID
	local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = g_deckData:getDeckCombatPower(deck_name)

	local function finish_cb(game_key)
        -- 씬 전환을 두번 호출 하지 않도록 하기 위함
	    local block_ui = UI_BlockPopup()

		-- 연속 전투일 경우 횟수 증가
		if (g_autoPlaySetting:isAutoPlay()) then
			g_autoPlaySetting.m_autoPlayCnt = (g_autoPlaySetting.m_autoPlayCnt + 1)
		end

		local stage_name = 'stage_' .. stage_id
		local scene = SceneGame(game_key, stage_id, stage_name, false)
		scene:runScene()
	end

    local game_mode = g_stageData:getGameMode(stage_id)
    -- 고대 유적 던전 start call 예외 처리
    if (game_mode == GAME_MODE_ANCIENT_RUIN) then
        g_ancientRuinData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb, fail_cb)
    else
        g_stageData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb, fail_cb)
    end
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_GameResultNew:click_statsBtn()
	if (self:blockButtonUntilWorkDone()) then
		return
	end

    if (self:checkIsTutorial()) then
        return
    end

    if (self:checkAutoPlayRelease()) then
        return
    end

	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResultNew:click_homeBtn()
	if (self:blockButtonUntilWorkDone()) then
		return
	end
    
    if (self:checkIsTutorial()) then
        return
    end

    if (self:checkAutoPlayRelease()) then
        return
    end
    	
	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local block_ui = UI_BlockPopup()

	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResultNew:click_againBtn()
	if (self:blockButtonUntilWorkDone()) then
		return
	end

    if (self:checkIsTutorial()) then
        return
    end

    if (self:checkAutoPlayRelease()) then
        return
    end

    local stage_id = self.m_stageID
    local function close_cb()
        -- 룬 축제 이벤트
        if (g_stageData:isRuneFestivalStage(stage_id) == true) then
            UINavigatorDefinition:goTo('event_rune_festival')
            return
        end

        UINavigator:goTo('adventure', stage_id)
    end

    UINavigator:goTo('battle_ready', stage_id, close_cb)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResultNew:click_nextBtn()
    if (self:checkIsTutorial()) then
        return
    end

    if (self:checkAutoPlayRelease()) then
        return
    end

    -- 다음 스테이지 ID 지정
    local stage_id = self.m_stageID
    local next_stage_id = g_stageData:getNextStage(stage_id)
    if next_stage_id then
        g_stageData:setFocusStage(next_stage_id)
    end

    local function close_cb()
        UINavigator:goTo('adventure', next_stage_id)
    end
    
    if next_stage_id then
        UINavigator:goTo('battle_ready', next_stage_id, close_cb)

    -- 다음 스테이지 없는 경우엔 모험맵으로 이동
    else
        UINavigator:goTo('adventure', stage_id)
    end
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_GameResultNew:click_prevBtn()
    if (self:checkAutoPlayRelease()) then
        return
    end

    -- 이전 스테이지 ID 지정
    local stage_id = self.m_stageID
    prev_stage_id = getPrevStageID(stage_id)
    if prev_stage_id then
        g_stageData:setFocusStage(prev_stage_id)
    end

    local function close_cb()
        UINavigator:goTo('adventure', prev_stage_id)
    end

    if prev_stage_id then
        UINavigator:goTo('battle_ready', prev_stage_id, close_cb)

    -- 이전 스테이지 없는 경우엔 모험맵으로 이동
    else
        UINavigator:goTo('adventure', stage_id)
    end
end

-------------------------------------
-- function click_switchBtn
-------------------------------------
function UI_GameResultNew:click_switchBtn()
    if (self:checkAutoPlayRelease()) then return end

    local vars = self.vars
    self:action_switchBtn()
end

-------------------------------------
-- function action_switchBtn
-------------------------------------
function UI_GameResultNew:action_switchBtn(callback)
    local vars = self.vars
    local result_menu = vars['resultMenu']
    local switch_btn = vars['switchBtn']
    local switch_sprite = vars['switchSprite']
    switch_btn:setEnabled(false)

    local is_up = (result_menu:getPositionY() ~= 450) and true or false
    local move_y = (is_up) and 450 or 136
    local angle = (is_up) and 0 or 180
    
    local move_act = cca.makeBasicEaseMove(0.5, 0, move_y)
    local after_act = cc.CallFunc:create(function()
        switch_btn:setEnabled(true)
		if (callback) then callback() end
	end)

    switch_sprite:runAction(cc.RotateTo:create(0.1, angle))
    result_menu:runAction(cc.Sequence:create(move_act, after_act))
end

-------------------------------------
-- function show_staminaInfo
-------------------------------------
function UI_GameResultNew:show_staminaInfo()
    local vars = self.vars
    vars['energyNode']:setVisible(true)

    local isStamina = self.m_staminaType == 'st'
    
    vars['energyLabel']:setVisible(not isStamina)
    vars['energyIconNode']:setVisible(not isStamina)
    vars['energyBgSprite']:setVisible(not isStamina)

    -- 스태미너 타입이면 클릭 가능한 버튼으로 추가
    if (isStamina) then
        self.m_staminaInfo = UI_StaminaInfo:create('st')

        do -- addChild, 위치 조정
            local ui = self.m_staminaInfo
            local x_pos_idx = 1

            self.vars['energyNode']:addChild(ui.root)
        end

        self.m_staminaInfo:refresh()
    else
        local stamina_type = self.m_staminaType

        local st_ad = g_staminasData:getStaminaCount(stamina_type)
        local max_cnt = g_staminasData:getStaminaMaxCnt(stamina_type)
        vars['energyLabel']:setString(Str('{1}/{2}', comma_value(st_ad), comma_value(max_cnt)))

        local icon = IconHelper:getStaminaInboxIcon(stamina_type)
        vars['energyIconNode']:addChild(icon)
    end
end

-------------------------------------
-- function checkAutoPlay
-- @brief
-------------------------------------
function UI_GameResultNew:checkAutoPlay()
    if (not g_autoPlaySetting:isAutoPlay()) then
        return
    end

    if (not g_friendData:checkAutoPlayCondition()) then 
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
-- function checkAutoPlayCondition
-- @brief
-------------------------------------
function UI_GameResultNew:checkAutoPlayCondition()
    local auto_play_stop = false
    local msg = nil

    -- 패배 시 연속 전투 종료
    if g_autoPlaySetting:get('stop_condition_lose') then
        if (not self.m_bSuccess) then
            auto_play_stop = true
            msg = Str('패배로 인해 연속 전투가 종료되었습니다.')
        end
    end

	-- 20-11-10 드래곤 레벨업 시스템 개편으로 인해 삭제된 옵션
    -- 드래곤의 현재 승급 상태 중 레벨MAX가 되면 연속 모험 종료
    --if g_autoPlaySetting:get('stop_condition_dragon_lv_max') then 
        --for i,v in pairs(self.m_lDragonList) do
            --if v['levelup_data']['is_max_level'] then
                --if (v['levelup_data']['prev_lv'] < v['levelup_data']['curr_lv'])then
                    --auto_play_stop = true
                    --msg = Str('최대레벨에 도달한 드래곤이 있어서\n연속 전투가 종료되었습니다.')
                --end
            --end
        --end
    --end

    -- 인연 던전 발견 시 연속 전투 종료 (발견 팝업이 뜸. 종료 팝업 띄울 필요없음)
    if g_autoPlaySetting:get('stop_condition_find_rel_dungeon') then
        if (self.m_secretDungeon) then
            auto_play_stop = true
        end
    end

	return auto_play_stop, msg
end

-------------------------------------
-- function checkAutoPlayRelease
-- @brief 연속 전투일 경우 스크린 터치시 연속 전투 해제 팝업 출력
-------------------------------------
function UI_GameResultNew:checkAutoPlayRelease()
    if (not g_autoPlaySetting:isAutoPlay()) then return false end

    local function f_pause(node) node:pause() end
    local function f_resume(node) node:resume() end
    doAllChildren(self.root, f_pause)

    local function ok_cb()
        -- 자동 전투 off
        g_autoPlaySetting:setAutoPlay(false)
        doAllChildren(self.root, f_resume)

        -- 카운트 중이었다면 off
        if (self.m_autoCount) then
            self.root:stopAllActions()
            self.vars['autoBattleNode']:setVisible(false)
        end
    end

    local function cancel_cb()
        doAllChildren(self.root, f_resume)
    end

    local msg = Str('연속 전투 진행 중입니다. \n연속 전투를 종료하시겠습니까?')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb, cancel_cb)
    
    return true
end

-------------------------------------
-- function countAutoPlay
-- @brief 연속 전투일 경우 재시작 하기전 카운트 해줌
-------------------------------------
function UI_GameResultNew:countAutoPlay()
    if (not g_autoPlaySetting:isAutoPlay()) then return false end

    self.m_autoCount = true
    local vars = self.vars
    local node = vars['autoBattleNode']

    if (node) then node:setVisible(true) end

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
            self:click_quickBtn(true) -- params : skip_check_auto_play_release
        end)
        self.root:runAction(cc.Sequence:create(act1, act2))
    end
end

-------------------------------------
-- function setHotTimeInfo
-- @brief
-------------------------------------
function UI_GameResultNew:setHotTimeInfo(l_hottime)
    local vars = self.vars

    -- 'exp_2x' -- 경험치 두배
    -- 'gold_2x' -- 골드 두배
    -- 'stamina_50p' -- 필요 활동력 50%

    local active, value = g_hotTimeData:getActiveHotTimeInfo_exp()
    if (active) then
        for i = 1, 5 do
            vars['hotTimeLabel' .. i]:setVisible(true)
            local str = string.format('+%d%%', value)
            vars['hotTimeLabel' .. i]:setString(str)
        end
    end
end

-------------------------------------
-- function click_manageBtn
-------------------------------------
function UI_GameResultNew:click_manageBtn()
    local ui = UI_DragonManageInfo()
    local function close_cb()
        self:sceneFadeInAction(func)
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function checkIsTutorial
-------------------------------------
function UI_GameResultNew:checkIsTutorial()
    return false
end

-------------------------------------
-- function getDragonList
-- @brief 전투에서 사용된 드래곤 정보
-------------------------------------
function UI_GameResultNew:getDragonList()
    local l_dragon_list = {}
    
    local game_mode = g_stageData:getGameMode(self.m_stageID)

    -- 드래곤 그릴 필요 없는 게임 모드
    if (isExistValue(game_mode, GAME_MODE_ANCIENT_RUIN, GAME_MODE_CLAN_RAID, GAME_MODE_COLOSSEUM, GAME_MODE_ARENA, GAME_MODE_ARENA_NEW, GAME_MODE_EVENT_ARENA, GAME_MODE_CLAN_WAR)) then
        
    else
        local l_deck, formation, deck_name, leader = g_deckData:getDeck()

        for i, doid in pairs(l_deck) do
            local user_data = g_dragonsData:getDragonDataFromUid(doid)
            local did = user_data['did']
            local table_data = TableDragon():get(did)
            local t_dragon_data = {['user_data'] = user_data, ['table_data'] = table_data}
            table.insert(l_dragon_list, t_dragon_data)
        end
    end

    return l_dragon_list
end
