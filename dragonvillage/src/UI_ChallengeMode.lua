local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChallengeMode
-------------------------------------
UI_ChallengeMode = class(PARENT, {
        m_tableView = 'table',
        m_selectedStageID = 'number', -- 현재 선택된 스테이지 아이디
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeMode:init()
    local vars = self:load_keepZOrder('challenge_mode_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ChallengeMode')

    self:initUI()
    self:initButton()
    self:refresh()
    self:refresh_playerRank()

    self:sceneFadeInAction(function() self:appearDone() end)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ChallengeMode:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ChallengeMode'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('그림자의 신전')
    self.m_staminaType = 'st'
    self.m_subCurrency = 'valor'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeMode:initUI()
    local vars = self.vars

    -- 테이블 뷰 생성
    self:initUI_tableView()

    if vars['bgSprite'] then
        -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
        local scr_size = cc.Director:getInstance():getWinSize()
        vars['bgSprite']:setScale(scr_size.width / 1280)
    end

    -- 남은 시간 표기
    local str_time = g_challengeMode:getChallengeModeStatusText()
    vars['timeLabel']:setString(str_time)
end

-------------------------------------
-- function initUI_tableView
-- @brief 테이블 뷰 생성
-------------------------------------
function UI_ChallengeMode:initUI_tableView()
    local vars = self.vars

    local node = vars['floorNode']
    node:removeAllChildren()
        
	-- 층 생성
	local t_floor = g_challengeMode:getChallengeModeStagesInfo()

	-- 셀 아이템 생성 콜백
	local create_func = function(ui, data)
        ui.vars['stageBtn']:registerScriptTapHandler(function()
            self:selectFloor(data)
        end)

        local stage_id = data['stage']
        if (stage_id == self.m_selectedStageID) then
            self:changeFloorVisual(stage_id, ui)
        end

		return true
    end
		
    -- 테이블 뷰 인스턴스 생성
    self.m_tableView = UIC_TableView(node)
    --self.m_tableView:setUseVariableSize(true)
    self.m_tableView.m_defaultCellSize = cc.size(500, 129)
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
    self.m_tableView:setCellUIClass(UI_ChallengeModeListItem, create_func)
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_tableView:setItemList(t_floor, false)

    --self.m_tableView.m_scrollView:setLimitedOffset(true)

    local function sort_func(a, b)
        return a['data']['stage'] < b['data']['stage']
    end
    table.sort(self.m_tableView.m_itemList, sort_func)
end

-------------------------------------
-- function appearDone
-- @brief UI전환 종료 시점
-------------------------------------
function UI_ChallengeMode:appearDone()
    local t_data = {stage=g_challengeMode:getSelectedStage()}
    self:selectFloor(t_data)

    -- 현재 도전중인 층이 바로 보이도록 처리
    if self.m_selectedStageID then
        local floor = self.m_selectedStageID
        self.m_tableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        self.m_tableView:relocateContainerFromIndex(floor + 1)
    end

    -- 그림자의 신전 배경 설명
    UI_ChallengeModeInfoPopup:open('bg')
end

-------------------------------------
-- function refresh_playerRank
-- @brief 플레이어 랭킹 정보 갱신
-------------------------------------
function UI_ChallengeMode:refresh_playerRank()
    local vars = self.vars
    
    -- 플레이어 정보 받아옴
    local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
    
    -- 리더 드래곤
    local card = struct_user_info:getLeaderDragonCard()
    vars['profileNode']:removeAllChildren()
    vars['profileNode']:addChild(card.root)

    -- 랭킹
    local rank_text = struct_user_info:getRankText(true) -- param : detail
    vars['rankLabel']:setString(rank_text)

    -- 승리한 상대
    local str = struct_user_info:getChallengeMode_clearText()
    vars['clearLabel']:setString(str)

    -- 승점
    local str = struct_user_info:getChallengeMode_pointText()
    vars['scoreLabel']:setString(str)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_ChallengeMode:refresh(stage)
    local vars = self.vars
    vars['formationNode']:removeAllChildren()
    vars['tamerNode']:removeAllChildren()

    if (not stage) then
        return
    end

    local t_data = g_challengeMode:getChallengeMode_StageDetailInfo(stage)
    local struct_user_info = g_challengeMode:makeChallengeModeStructUserInfo(t_data)

    local l_dragon_obj = struct_user_info:getDeck_dragonList()
    local leader = struct_user_info.m_pvpDeck['leader']
    local formation = struct_user_info.m_pvpDeck['formation']

    
    
    local player_2d_deck = UI_2DDeck(true, true)
    player_2d_deck:setDirection('right')
    vars['formationNode']:addChild(player_2d_deck.root)
    player_2d_deck:initUI()

    -- 드래곤 생성 (리더도 함께)
    player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
    -- 진형 설정
    player_2d_deck:setFormation(formation)
    player_2d_deck:runAction()


    -- 테이머
    local animator = struct_user_info:getDeckTamerSDAnimator()
    vars['tamerNode']:addChild(animator.m_node)

    do-- 테이머 명칭
        local t_data = g_challengeMode:getChallengeMode_StageInfo(stage)
        local rank = t_data['rank']
        local nick = t_data['nick']
        local clan = t_data['clan']
        local str = Str('{1}위', rank)
        str = str .. ' {@}' .. nick
        if (clan and (clan ~= '')) then
            str = str .. ' {@clan_name}' .. clan
        end
        vars['tamerNameLabel']:setString(str)
    end

    -- 날개
    local st = g_challengeMode:getChallengeMode_staminaCost(stage)
    vars['priceaLabel']:setString(tostring(st))

    do-- 버튼 상태 처리
        -- 시즌 보상 획득만 가능한 상태
        if (g_challengeMode:getChallengeModeState() == ServerData_ChallengeMode.STATE['REWARD']) then
            vars['startBtn']:setVisible(false)
            vars['lockSprite']:setVisible(false)

        -- 시즌 진행 중인 상태
        elseif g_challengeMode:isOpenStage_challengeMode(stage) then
            vars['startBtn']:setVisible(true)
            vars['lockSprite']:setVisible(false)

        --시즌 진행 중이지만 스테이지가 잠긴 상태
        else
            vars['startBtn']:setVisible(false)
            vars['lockSprite']:setVisible(true)

            local t_data = g_challengeMode:getChallengeMode_StageInfo(stage - 1)
            local str = Str('{1}위에게 승리 혹은 3회 도전 시 잠금 해제', t_data['rank'])
            vars['lockLabel']:setString(str)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeMode:initButton()
    local vars = self.vars

    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infonfoBtn() end)
    vars['lockSprite']:setEnabled(false) -- 버튼으로 되어있음
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ChallengeMode:click_exitBtn()
	self:close()
end

-------------------------------------
-- function click_startBtn
-- @brief 출전 덱 설정 버튼
-------------------------------------
function UI_ChallengeMode:click_startBtn()
    local stage = self.m_selectedStageID
    if g_challengeMode:isOpenStage_challengeMode(stage) then
        UI_ChallengeModeDeckSettings(CHALLENGE_MODE_STAGE_ID)

        -- 안내 팝업 띄움
        local play_cnt = g_challengeMode:getChallengeModeStagePlayCnt(stage)
        if (play_cnt < 3) then
            -- 점수 산정 방식
            UI_ChallengeModeInfoPopup:open('score')
        else
            -- 소비 날개 안내
            UI_ChallengeModeInfoPopup:open('wing')
        end
    else
        MakeSimplePopup(POPUP_TYPE.OK, Str('이전 스테이지를 클리어하세요.'))
    end
end

-------------------------------------
-- function click_rankBtn
-- @brief 랭킹, 보상 정보 버튼
-------------------------------------
function UI_ChallengeMode:click_rankBtn()
    local ui = UI_ChallengeModeRankingPopup()

    -- 랭킹 팝업에서 실시간 랭킹을 다시 받아오기 때문에 UI 갱신
    local function close_cb()
        self:refresh_playerRank()
    end
    
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_infonfoBtn
-- @brief 랭킹, 보상 정보 버튼
-------------------------------------
function UI_ChallengeMode:click_infonfoBtn()
    UI_ChallengeModeInfoPopup()
end

-------------------------------------
-- function selectFloor
-------------------------------------
function UI_ChallengeMode:selectFloor(floor_info)
    local stage = floor_info['stage']

    if (self.m_selectedStageID ~= stage) then
        local function finish_cb(ret)
            local prev = self.m_selectedStageID
            self.m_selectedStageID = stage
            
            -- 실제로 진행될 스테이지 정보 저장
            g_challengeMode:setSelectedStage(self.m_selectedStageID)

            self:changeFloorVisual(prev)
            self:changeFloorVisual(self.m_selectedStageID)
            self:refresh(stage)
        end

        g_challengeMode:request_challengeModeStageDetailInfo(stage, finish_cb)
    end
end

-------------------------------------
-- function changeFloorVisual
-------------------------------------
function UI_ChallengeMode:changeFloorVisual(stage_id, ui)
    local t_item = self.m_tableView.m_itemMap[stage_id]
    if (not t_item) and (not ui) then
        return
    end
    local ui = ui or t_item['ui']
    
    if (not ui) then
        return
    end

    local is_selected = (stage_id == self.m_selectedStageID)

    if (is_selected) then
        ui.vars['selectedVisual']:setVisible(true)
        ui.vars['selectedBg']:setVisible(true)
    else
        ui.vars['selectedVisual']:setVisible(false)
        ui.vars['selectedBg']:setVisible(false)
    end
end

-------------------------------------
-- function onClose
-------------------------------------
function UI_ChallengeMode:onClose()
    PARENT.onClose(self)
    g_challengeMode:resetSelectedStage()
end

--@CHECK
UI:checkCompileError(UI_ChallengeMode)