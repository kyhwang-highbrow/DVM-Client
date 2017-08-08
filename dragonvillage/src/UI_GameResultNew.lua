-------------------------------------
-- class UI_GameResultNew
-------------------------------------
UI_GameResultNew = class(UI, {
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
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResultNew:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon)
    self.m_stageID = stage_id
    self.m_bSuccess = is_success
    self.m_time = time
    self.m_gold = gold or 0
    self.m_tTamerLevelupData = t_tamer_levelup_data
    self.m_lDragonList = l_dragon_list
    self.m_lDropItemList = l_drop_item_list
    self.m_secretDungeon = secret_dungeon
    self.m_staminaType = 'st'

    local vars = self:load('ingame_result_new.ui')
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

    vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    vars['switchBtn']:registerScriptTapHandler(function() self:click_switchBtn() end)
    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
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
        vars['difficultySprite']:setColor(cc.c3b(121, 186, 58))
        vars['gradeLabel']:setString(Str('보통'))
        vars['gradeLabel']:setColor(cc.c3b(121, 186, 58))

    elseif (difficulty == 2) then
        vars['difficultySprite']:setColor(cc.c3b(46, 162, 196))
        vars['gradeLabel']:setString(Str('어려움'))
        vars['gradeLabel']:setColor(cc.c3b(46, 162, 196))

    elseif (difficulty == 3) then
        vars['difficultySprite']:setColor(cc.c3b(196, 74, 46))
        vars['gradeLabel']:setString(Str('지옥'))
        vars['gradeLabel']:setColor(cc.c3b(196, 74, 46))

    end
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_GameResultNew:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_showTamer')
    table.insert(self.m_lWorkList, 'direction_hideTamer')
    table.insert(self.m_lWorkList, 'direction_showScore')
    table.insert(self.m_lWorkList, 'direction_start')
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
-- function doNextWork
-------------------------------------
function UI_GameResultNew:doNextWork()
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
        self[func_name](self)
    end
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
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    tamer_node:addChild(animator.m_node)
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
    if (self:checkAutoPlayRelease()) then return end
    self:doNextWork()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_GameResultNew:direction_hideTamer()
    local vars = self.vars
    local tamer_node = vars['tamerNode']
    local hide_act = cc.EaseExponentialOut:create(cc.MoveTo:create(1, cc.p(0, -1000)))
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
    if (self:checkAutoPlayRelease()) then return end
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
    if (self:checkAutoPlayRelease()) then return end
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
    if (self:checkAutoPlayRelease()) then return end
    self:doNextWork()
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
        local duration = 2
        if g_autoPlaySetting:isAutoPlay() then
            duration = 0.5
        end
        -- 2초 후 자동으로 이동
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
                self:doNextWork()
            end)))
    else
        vars['skipLabel']:setVisible(false)
        vars['noRewardMenu']:setVisible(true)
        vars['skipBtn']:setVisible(false)
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
    if (self:checkAutoPlayRelease()) then return end

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
    if (self:checkAutoPlayRelease()) then return end
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
    if (self:checkAutoPlayRelease()) then return end
end

-------------------------------------
-- function direction_dropItem
-- @brief
-------------------------------------
function UI_GameResultNew:direction_dropItem()
    local vars = self.vars
    local is_success = self.m_bSuccess
    if (not is_success) then 
        self:doNextWork()
        return
    end

    local interval = 95
    local count = #self.m_lDropItemList
    local l_pos = getSortPosList(interval, count)

    -- 보상이 없을때
    if (count <= 0) then
        vars['noRewardMenu']:setVisible(true)

        local animator = MakeAnimator('res/character/monster/common_elemental_lava_fire/common_elemental_lava_fire.spine')
        vars['noRewardMenu']:addChild(animator.m_node)
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setPositionY(50)
        animator:setScale(1.5)
    end

    for i,v in ipairs(self.m_lDropItemList) do
        --self:makeRewardItem(i, v)

        local item_id = v[1]
        local count = v[2]
        local from = v[3]

        local item_card = UI_ItemCard(item_id, count)
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
-- function direction_dropItem
-- @brief
-------------------------------------
function UI_GameResultNew:direction_dropItem_click()
    if (self:checkAutoPlayRelease()) then return end
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
    vars['skipBtn']:setVisible(false)
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
       vars['towerBtn']:setVisible(true)

    -- 모험 
    else
        vars['mapBtn']:setVisible(true)

    end
end

-------------------------------------
-- function direction_showButton_click
-------------------------------------
function UI_GameResultNew:direction_showButton_click()
    if (self:checkAutoPlayRelease()) then return end
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
    if (self:checkAutoPlayRelease()) then return end
end

-------------------------------------
-- function direction_masterRoad
-------------------------------------
function UI_GameResultNew:direction_masterRoad()
    if (self.m_bSuccess) then
        -- @ MASTER ROAD
        local t_data = {game_mode = g_gameScene.m_gameMode, stage_id = self.m_stageID, dungeon_mode = g_gameScene.m_dungeonMode}
        g_masterRoadData:updateMasterRoad(t_data)

        -- @ GOOGLE ACHIEVEMENT
        GoogleHelper.updateAchievement(t_data)
    end
    -- @ MASTER ROAD
    local t_data = {clear_key = 'u_lv'}
    g_masterRoadData:updateMasterRoad(t_data)

    -- @ GOOGLE ACHIEVEMENT
    GoogleHelper.updateAchievement(t_data)

    -- 마스터 로드 기록 후 연속 전투 체크
    self:checkAutoPlay()
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
    for i,v in ipairs(l_dragon_list) do
        local user_data = v['user_data']
        local table_data = v['table_data']
        local res_name = table_data['res']
        local evolution = user_data['evolution']
        local grade = user_data['grade']
		local attr = table_data['attr']
		local scale = table_data['scale']

        local animaotr = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
        animaotr.m_node:setDockPoint(cc.p(0.5, 0.5))
        animaotr.m_node:setAnchorPoint(cc.p(0.5, 0.5))
		
		-- 자코 추가로 스케일 개별 적용
        animaotr.m_node:setScale(math_clamp(scale, 1, 2))

        vars['dragonNode' .. i]:addChild(animaotr.m_node)

        do -- 드래곤 레벨, 경험치
            local lv_label      = vars['lvLabel' .. i]
            local exp_label     = vars['expLabel' .. i]
            local max_icon      = vars['maxSprite' .. i]
            local exp_gauge     = vars['expGauge' .. i]
            local level_up_vrp  = vars['lvUpVisual' .. i]
            local levelup_director = LevelupDirector_GameResult(lv_label, exp_label, max_icon, exp_gauge, level_up_vrp, grade)

            -- 최초 레벨업 시 포즈
            levelup_director.m_cbFirstLevelup = function()
                animaotr:changeAni('pose_1', false)
                animaotr:addAniHandler(function() animaotr:changeAni('idle', true) end)
            end

            local t_levelup_data = v['levelup_data']
            local src_lv        = t_levelup_data['prev_lv']
            local src_exp       = t_levelup_data['prev_exp']
            local dest_lv       = t_levelup_data['curr_lv']
            local dest_exp      = t_levelup_data['curr_exp']
            local type          = 'dragon'
            levelup_director:initLevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type, grade)
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
-- function click_backBtn
-- @brief 모드별 백버튼은 여기서 처리
-------------------------------------
function UI_GameResultNew:click_backBtn()
    local game_mode = g_gameScene.m_gameMode
    local dungeon_mode = g_gameScene.m_dungeonMode
    local condition = self.m_stageID
    QuickLinkHelper.gameModeLink(game_mode, dungeon_mode, condition)
end

-------------------------------------
-- function click_quickBtn
-------------------------------------
function UI_GameResultNew:click_quickBtn()
    local function finish_cb(game_key)

        -- 연속 전투일 경우 횟수 증가
        if (g_autoPlaySetting:isAutoPlay()) then
            g_autoPlaySetting.m_autoPlayCnt = (g_autoPlaySetting.m_autoPlayCnt + 1)
        end

        local stage_id = self.m_stageID

        local stage_name = 'stage_' .. stage_id
        local scene = SceneGame(game_key, stage_id, stage_name, false)
        scene:runScene()
    end

    local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = g_deckData:getDeckCombatPower(deck_name)
    g_stageData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb)
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_GameResultNew:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResultNew:click_homeBtn()
	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResultNew:click_againBtn()
    local stage_id = self.m_stageID
    UINavigator:goTo('adventure', stage_id)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResultNew:click_nextBtn()
    -- 다음 스테이지 ID 지정
    local stage_id = self.m_stageID
    local next_stage_id = g_stageData:getNextStage(stage_id)
    if next_stage_id then
        g_stageData:setFocusStage(next_stage_id)
    end

    UINavigator:goTo('adventure', next_stage_id)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResultNew:click_prevBtn()
    -- 이전 스테이지 ID 지정
    local stage_id = self.m_stageID
    prev_stage_id = getPrevStageID(stage_id)
    if prev_stage_id then
        g_stageData:setFocusStage(prev_stage_id)
    end

    UINavigator:goTo('adventure', prev_stage_id)
end

-------------------------------------
-- function click_switchBtn
-------------------------------------
function UI_GameResultNew:click_switchBtn()
    local vars = self.vars
    local switch_btn = vars['switchBtn']
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
		if (callback) then callback() end
        switch_btn:setEnabled(true)
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
    local stamina_type = self.m_staminaType

    local st_ad = g_staminasData:getStaminaCount(stamina_type)
    local max_cnt = g_staminasData:getStaminaMaxCnt(stamina_type)
    vars['energyLabel']:setString(Str('{1}/{2}', st_ad, max_cnt))

    local icon = IconHelper:getStaminaInboxIcon(stamina_type)
    vars['energyIconNode']:addChild(icon)
end

-------------------------------------
-- function makeRewardItem
-------------------------------------
function UI_GameResultNew:makeRewardItem(i, v)
    local vars = self.vars

    local item_id = v[1]
    local count = v[2]

    local item_card = UI_ItemCard(item_id, count)
    item_card:setRarityVisibled(true)

    local icon = item_card.root--DropHelper:getItemIconFromIID(item_id)
    vars['rewardNode' .. i]:setVisible(true)
    vars['rewardIconNode' .. i]:addChild(icon)

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    
    vars['rewardLabel' .. i]:setString(t_item['t_name'] .. '\nX ' .. count)

    return item_card
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
        
    local auto_play_stop = false

    local msg = nil

    -- 연속 전투 20회 제한 -> 무제한으로 변경
    --[[
    local max_cnt = 20
    if (g_autoPlaySetting.m_autoPlayCnt >= max_cnt) then
        auto_play_stop = true
        if (not msg) then
            msg = Str('연속 전투 {1}회가 종료되었습니다.', max_cnt)
        end
    end
    ]]--

    -- 패배 시 연속 전투 종료
    if g_autoPlaySetting:get('stop_condition_lose') then
        if (not self.m_bSuccess) then
            auto_play_stop = true
            msg = Str('패배로 인해 연속 전투가 종료되었습니다.')
        end
    end

    do -- 드래곤의 현재 승급 상태 중 레벨MAX가 되면 연속 모험 종료
        local stop = false
        for i,v in pairs(self.m_lDragonList) do
            if v['levelup_data']['is_max_level'] then
                if (v['levelup_data']['prev_lv'] < v['levelup_data']['curr_lv'])then
                    stop = true
                    auto_play_stop = true
                    msg = Str('최대레벨에 도달한 드래곤이 있어서\n연속 전투가 종료되었습니다.')
                end
            end
        end
    end

    -- 인연 던전 발견 시 연속 전투 종료 (발견 팝업이 뜸. 종료 팝업 띄울 필요없음)
    if g_autoPlaySetting:get('stop_condition_find_rel_dungeon') then
        if (self.m_secretDungeon) then
            auto_play_stop = true
        end
    end
    
    if (auto_play_stop == true) then
        -- 메세지 있는 경우에만 팝업 출력
        if (msg) then MakeSimplePopup(POPUP_TYPE.OK, msg) end
        return
    end

    -- 빠른 재시작
    self:click_quickBtn()
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
    end

    local function cancel_cb()
        doAllChildren(self.root, f_resume)
    end

    local msg = Str('연속 전투 진행 중입니다. \n연속 전투를 종료하시겠습니까?')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb, cancel_cb)
    
    return true
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

    -- 경험치 두배 핫타임
    if table.find(l_hottime, 'exp_2x') then
        for i=1, 5 do
            vars['hotTimeLabel' .. i]:setVisible(true)
        end
    end
end
