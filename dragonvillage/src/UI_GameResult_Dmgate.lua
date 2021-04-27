local PARENT = UI_GameResultNew



----------------------------------------------------------------------------
-- class UI_GameResult_Dmgate
----------------------------------------------------------------------------
UI_GameResult_Dmgate = class(UI, {
    m_stage_id = 'number',
    m_bSuccess = 'boolean',
    m_time = 'number',

    -- 
    m_gameResultVisual = '', 

    -- title Nodes
    m_titleMenu = '',   -- 
    m_titleLabel = '',  -- 스테이지 이름 텍스트
    m_gradeLabel = '',  -- 난이도 텍스트

    m_timeMenu = '',    -- 시간 메뉴
    m_timeLabel = '',   -- 시간 텍스트

    -- dragon nodes
    m_dragonResultNode = '',    -- 드래곤 전체 노드
    m_dragonBoards = '',        -- 드래곤 각자의 노드
    m_dragonNodes = '',         -- 드래곤 애니메이션을 위한 노드
    m_dragonStarNodes = '',     -- 드래곤 등급을 위한 노드
    m_dragonLvLabels = '',      -- 드래곤 레벨 텍스트를 위한 노드

    -- buttons
    m_btnMenu = '',             -- 버튼 전체 관리를 위한 메뉴
    m_statusInfoBtn = '',             -- 상태 효과
    m_readyBtn = '',            -- 배틀 준비
    m_quickStartBtn = '',       -- 빠른 재시작
    m_dmgateBtn = '',           -- 차원문 메인으로
    m_statsBtn = '',            -- 전투 통계
    m_homeBtn = '',             -- 마을
})


----------------------------------------------------------------------------
-- function init
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:init(stage_id, is_success, time)
    local vars = self:load('dmgate_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_GameResult_Dmgate')

    self.m_stage_id = stage_id
    self.m_bSuccess = is_success
    self.m_time = time

    self.m_gameResultVisual = vars['gameResultVisual']
    
    -- title Nodes
    self.m_titleMenu = vars['titleMenu']            -- 
    self.m_titleLabel = vars['titleLabel']          -- 스테이지 이름 텍스트
    self.m_gradeLabel = vars['gradeLabel']          -- 난이도 텍스트

    self.m_timeMenu = vars['timeMenu']              -- 시간 메뉴
    --self.m_timeLabel = NumberLabel(vars['timeLabel'], 0, 1)            -- 시간 텍스트
    self.m_timeLabel = vars['timeLabel']
    -- buttons
    self.m_btnMenu = vars['btnMenu']                -- 버튼 전체 관리를 위한 메뉴
    self.m_statusInfoBtn = vars['statusInfoBtn']                -- 상태 효과
    self.m_readyBtn = vars['readyBtn']              -- 배틀 준비
    self.m_quickStartBtn = vars['quickStartBtn']    -- 빠른 재시작
    self.m_dmgateBtn = vars['dmgateBtn']            -- 차원문 메인으로
    self.m_statsBtn = vars['statsBtn']              -- 전투 통계
    self.m_homeBtn = vars['homeBtn']                -- 마을
       
    -- dragon nodes
    self.m_dragonResultNode = vars['dragonResultNode']      -- 드래곤 전체 노드
    self.m_dragonBoards = {}          -- 드래곤 각자의 노드
    self.m_dragonNodes = {}           -- 드래곤 애니메이션을 위한 노드
    self.m_dragonStarNodes = {}      -- 드래곤 등급을 위한 노드
    self.m_dragonLvLabels = {}        -- 드래곤 레벨 텍스트를 위한 노드

    local dragonNum = 1
    while(vars['dragonBoard' .. tostring(dragonNum)] ~= nil) do
        self.m_dragonBoards[dragonNum] = vars['dragonBoard' .. tostring(dragonNum)]
        self.m_dragonNodes[dragonNum] = vars['dragonNode' .. tostring(dragonNum)]
        self.m_dragonStarNodes[dragonNum] = vars['dragonStarNode' .. tostring(dragonNum)]
        self.m_dragonLvLabels[dragonNum] = vars['dragonLvLabel' .. tostring(dragonNum)]
        dragonNum = dragonNum + 1
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:initUI()
    local vars = self.vars
    
    --
    self:initGameResultVRP()
    self:initDragonList()

    --
    local stage_name = g_dmgateData:getStageName(self.m_stage_id)
    local chapter_name = g_dmgateData:getStageChapterText(self.m_stage_id)
    self.m_titleLabel:setString(stage_name)
    local diff_name = g_dmgateData:getStageDiffText(self.m_stage_id)
    local diff_color = g_dmgateData:getStageDiffTextColor(self.m_stage_id)
    self.m_gradeLabel:setString(diff_name)
    self.m_gradeLabel:setTextColor(diff_color)
    --self.m_timeLabel:setNumber(self.m_time)
    local min = math.modf(self.m_time / 60)
    local sec = self.m_time % 60
    self.m_timeLabel:setString(string.format('%02d:%02d', min, sec))
end


----------------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:initButton()
    self.m_statusInfoBtn:registerScriptTapHandler(function() self:click_statusInfoBtn() end)

    self.m_readyBtn:registerScriptTapHandler(function() self:click_readyBtn() end)
    self.m_quickStartBtn:registerScriptTapHandler(function() self:click_quickStartBtn() end)
    self.m_dmgateBtn:registerScriptTapHandler(function() self:click_dmgateBtn() end)
    
    self.m_homeBtn:registerScriptTapHandler(function() self:click_homeBtn() end)
    self.m_statsBtn:registerScriptTapHandler(function() self:click_statsBtn() end)
end


----------------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:refresh()
    g_dmgateData:MakeSeasonResetPopup(g_dmgateData:getModeID(self.m_stage_id), false)
end


----------------------------------------------------------------------------
-- function initGameResultVRP
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:initGameResultVRP()
    self.m_gameResultVisual:setVisible(true)
    if (self.m_bSuccess) then
        SoundMgr:playBGM('bgm_dungeon_victory', false)
        self.m_gameResultVisual:changeAni('success', false)
        self.m_gameResultVisual:addAniHandler(function() self.m_gameResultVisual:changeAni('success_idle', true) end)

    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)   
        self.m_gameResultVisual:changeAni('fail', false)
        self.m_gameResultVisual:addAniHandler(function() self.m_gameResultVisual:changeAni('fail_idle', true) end)
    end
end

----------------------------------------------------------------------------
-- function initDragonList
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:initDragonList()
    local deck_list = g_deckData:getDeck()

    local dragon_list = {}

    for _, doid in pairs(deck_list) do
        local user_data = g_dragonsData:getDragonDataFromUid(doid)
        local did = user_data['did']
        local dragon_data = TableDragon():get(did)
        local result = {['user_data'] = user_data, ['dragon_data'] = dragon_data}
        table.insert(dragon_list, result)
    end

    self:sortDragonNodes(#dragon_list)

    for i, v in ipairs(dragon_list) do
        local user_data = v['user_data']
        local dragon_data = v['dragon_data']

        local resource_name = dragon_data['res']
        local evolution = user_data['evolution']
        local scale = dragon_data['scale_' .. evolution]

        -- 외형 변환 적용 Animator
        local animator = AnimatorHelper:makeDragonAnimatorByTransform(user_data)
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))

        -- 스케일 적용
        animator.m_node:setScale(math_clamp(scale, 1, 2))

        self.m_dragonNodes[i]:addChild(animator.m_node)

        -- 등급
        local sprite = IconHelper:getDragonGradeIcon(user_data, 1)
        self.m_dragonStarNodes[i]:removeAllChildren()
        self.m_dragonStarNodes[i]:addChild(sprite)

        -- 레벨
        self.m_dragonLvLabels[i]:setVisible(true)
        self.m_dragonLvLabels[i]:setString('Lv.' .. user_data['lv'])
        
    end

end

----------------------------------------------------------------------------
-- function click_statusInfoBtn
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:click_statusInfoBtn()
    UI_HelpStatus()
end


----------------------------------------------------------------------------
-- function click_readyBtn
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:click_readyBtn()
    SceneDmgate(self.m_stage_id, true):runScene()
end

----------------------------------------------------------------------------
-- function click_quickStartBtn
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:click_quickStartBtn()
    --SceneDmgate(self.m_stageID, true):runScene()
    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
    local block_ui = UI_BlockPopup()

    self:startGame()
end

----------------------------------------------------------------------------
-- function click_dmgateBtn
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:click_dmgateBtn()
    SceneDmgate():runScene()
end


----------------------------------------------------------------------------
-- function click_homeBtn
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:click_homeBtn()
    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
    local block_ui = UI_BlockPopup()

    local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end


----------------------------------------------------------------------------
-- function click_statsBtn
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

----------------------------------------------------------------------------
-- function startGame
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:startGame()
    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
    local block_ui = UI_BlockPopup()
    local deck_name = g_deckData:getSelectedDeckName()

    local function finish_cb(game_key)
        local stage_name = 'stage_' .. self.m_stage_id

        scene = SceneGame(game_key, self.m_stage_id, stage_name, false)

        scene:runScene()
    end
    
    -- url : dmgate/start
    -- required params : user_id, stage_id, deck_name, token
    g_stageData:requestGameStart(self.m_stage_id, deck_name, nil, finish_cb)
end


----------------------------------------------------------------------------
-- function sortDragonNodes
----------------------------------------------------------------------------
function UI_GameResult_Dmgate:sortDragonNodes(dragon_num)
    local interval = self.m_dragonBoards[2]:getPositionX() - self.m_dragonBoards[1]:getPositionX()
    
    local gap

    if (dragon_num % 2) then -- 홀수
        gap = -((dragon_num - 1) / 2)
    else
        gap = -((dragon_num / 2) - 0.5)
    end

    local start_pos_x = (gap * interval)

    for index, dragonBoard in pairs(self.m_dragonBoards) do
        
        if (index <= dragon_num) then
            dragonBoard:setPositionX(start_pos_x)
            start_pos_x = start_pos_x + interval
        else
            dragonBoard:setVisible(false)
        end
    end
end