local PARENT = UI_GameResultNew



----------------------------------------------------------------------------
-- class UI_GameResult_LeagueRaid
----------------------------------------------------------------------------
UI_GameResult_LeagueRaid = class(UI, {

    m_workIdx = 'number',
    m_lWorkList = 'list',

    m_stage_id = 'number',
    m_bSuccess = 'boolean',

    m_resultData = 'table',
    
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
    m_statsBtn = '',            -- 전투 통계

    m_okBtn = 'Button'
})


----------------------------------------------------------------------------
-- function init
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:init(stage_id, is_success, result_data)
    local vars = self:load('league_raid_result.ui')
    self.m_uiName = 'UI_GameResult_LeagueRaid'

    UIManager:open(self, UIManager.POPUP)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_GameResult_LeagueRaid')

    self.m_stage_id = stage_id
    self.m_bSuccess = is_success

    self.m_resultData = result_data
    
    -- title Nodes
    self.m_titleMenu = vars['titleMenu']            -- 
    self.m_titleLabel = vars['titleLabel']          -- 스테이지 이름 텍스트
    self.m_gradeLabel = vars['gradeLabel']          -- 난이도 텍스트

    self.m_timeMenu = vars['timeMenu']              -- 시간 메뉴
    --self.m_timeLabel = NumberLabel(vars['timeLabel'], 0, 1)            -- 시간 텍스트
    self.m_timeLabel = vars['timeLabel']
    -- buttons
    self.m_btnMenu = vars['btnMenu']                -- 버튼 전체 관리를 위한 메뉴
    self.m_statsBtn = vars['statsBtn']              -- 전투 통계

    self.m_okBtn = vars['okBtn']
       
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

    self:setWorkList()
    self:doNextWork()end

----------------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:initUI()
    local vars = self.vars
    
    self:initDragonList()
    self:initRewardTable()

    vars['tableViewNode']:setVisible(false)
    vars['okBtn']:setVisible(false)
    vars['statsBtn']:setVisible(false)
end


----------------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:initButton()
    self.m_okBtn:registerScriptTapHandler(function() self:click_homeBtn() end)

    self.m_statsBtn:registerScriptTapHandler(function() self:click_statsBtn() end)
end


----------------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:refresh()

end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_GameResult_LeagueRaid:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}

    table.insert(self.m_lWorkList, 'direction_start')

	table.insert(self.m_lWorkList, 'direction_showBox')
    table.insert(self.m_lWorkList, 'direction_openBox')

    table.insert(self.m_lWorkList, 'direction_end')
end


-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_GameResult_LeagueRaid:direction_start()
    local is_win = self.m_bSuccess
    local vars = self.vars
    local visual_node = vars['resultVisual']
    visual_node:setVisible(true)

    -- 성공 or 실패가 없음 그냥 결과임
    SoundMgr:playBGM('bgm_dungeon_victory', false)    
    visual_node:changeAni('result_appear', false)
    visual_node:addAniHandler(function()
        visual_node:changeAni('result_idle', true)
    end)

    self:doNextWorkWithDelayTime(0.5)
end





-------------------------------------
-- function direction_showBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResult_LeagueRaid:direction_showBox()
    local vars = self.vars


    vars['boxVisual']:setVisible(true)
    vars['boxVisual']:changeAni('box_01', false)
    vars['boxVisual']:addAniHandler(function()
        --vars['boxVisual']:changeAni('box_02', true)
        self:doNextWork()
    end)
end


-------------------------------------
-- function direction_openBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResult_LeagueRaid:direction_openBox()
    local vars = self.vars

    vars['boxVisual']:setVisible(true)
    vars['boxVisual']:changeAni('box_03', false)
    vars['boxVisual']:addAniHandler(function()
        vars['boxVisual']:setVisible(false) 
        vars['tableViewNode']:setVisible(true)
        self:doNextWork()
    end)
end


-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_GameResult_LeagueRaid:direction_end()
    local vars = self.vars
    vars['okBtn']:setVisible(true)
    vars['statsBtn']:setVisible(true)

    self:showLeaderBoard()
end


-------------------------------------
-- function showLeaderBoard
-------------------------------------
function UI_GameResult_LeagueRaid:showLeaderBoard()
    local vars = self.vars
    
    -- todo
    local ui_leader_board = UI_ResultLeagueRaidScore(self.m_resultData)
end



----------------------------------------------------------------------------
-- function initDragonList
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:initDragonList()
    local deck_list = g_deckData:getDeck()

    local dragon_list = {}

    for _, doid in pairs(deck_list) do
        local user_data = g_dragonsData:getDragonDataFromUid(doid)
        local did = user_data['did']
        local dragon_data = TableDragon():get(did)
        local result = {['user_data'] = user_data, ['dragon_data'] = dragon_data}
        table.insert(dragon_list, result)
    end

end

----------------------------------------------------------------------------
-- function initRewardTable
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:initRewardTable()
    local vars = self.vars

    local rune_cnt = 0

    if (not self.m_resultData or not self.m_resultData['drop_reward_list']) then 
        if (vars['runeRewardLabel']) then vars['runeRewardLabel']:setString(comma_value(rune_cnt)) end
        return 
    
    end

    local rune_cnt = #self.m_resultData['drop_reward_list']
    local interval = 95
    local max_cnt_per_line = 8

    local l_item = {}
    for i,v in ipairs(self.m_resultData['drop_reward_list']) do
        table.insert(l_item, v[1])
    end
    
    -- 생성 시 함수
    local function create_func(ui, data)
        ui.root:setScale(0.6)
    end

    -- 테이블뷰 생성 TD
    local table_view = UIC_TableViewTD(vars['tableViewNode'])
    table_view:setAlignCenter(true)
    table_view:setHorizotalCenter(true)
    table_view.m_cellSize = cc.size(interval, interval)
    table_view.m_nItemPerCell = max_cnt_per_line
    table_view:setCellUIClass(UI_ItemCard, create_func)
    table_view:setItemList(l_item)
    
    if (vars['runeRewardLabel']) then vars['runeRewardLabel']:setString(comma_value(rune_cnt)) end
end



-------------------------------------
-- function direction_showBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResult_LeagueRaid:direction_showBox()
    local vars = self.vars

    vars['boxVisual']:setVisible(true)
    vars['boxVisual']:changeAni('box_01', false)
    vars['boxVisual']:addAniHandler(function()
        --vars['boxVisual']:changeAni('box_02', true)
        self:doNextWork()
    end)
end


----------------------------------------------------------------------------
-- function click_statusInfoBtn
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:click_statusInfoBtn()
    UI_HelpStatus()
end


----------------------------------------------------------------------------
-- function click_readyBtn
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:click_readyBtn()

end

----------------------------------------------------------------------------
-- function click_quickStartBtn
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:click_quickStartBtn()
    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
    local block_ui = UI_BlockPopup()

    self:startGame()
end

----------------------------------------------------------------------------
-- function click_homeBtn
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:click_homeBtn()
    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
    local block_ui = UI_BlockPopup()

    UINavigator:goTo('league_raid')
end


----------------------------------------------------------------------------
-- function click_statsBtn
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

----------------------------------------------------------------------------
-- function startGame
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:startGame()
    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
    local block_ui = UI_BlockPopup()
    local deck_name = g_deckData:getSelectedDeckName()

    local function finish_cb(game_key)
        local stage_name = 'stage_' .. self.m_stage_id

        scene = SceneGame(game_key, self.m_stage_id, stage_name, false)

        scene:runScene()
    end
    
    -- required params : user_id, stage_id, deck_name, token
    g_stageData:requestGameStart(self.m_stage_id, deck_name, nil, finish_cb)
end






-------------------------------------
-- function doNextWork
-------------------------------------
function UI_GameResult_LeagueRaid:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function doNextWorkWithDelayTime
-------------------------------------
function UI_GameResult_LeagueRaid:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end