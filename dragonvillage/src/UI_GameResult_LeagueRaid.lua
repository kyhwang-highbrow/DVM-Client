local PARENT = UI_GameResultNew



----------------------------------------------------------------------------
-- class UI_GameResult_LeagueRaid
----------------------------------------------------------------------------
UI_GameResult_LeagueRaid = class(UI, {
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
end

----------------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:initUI()
    local vars = self.vars
    
    self:initDragonList()
    self:initRewardTable()
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
    
    for i = 0, 19 do
        table.insert(self.m_resultData['drop_reward_list'], self.m_resultData['drop_reward_list'][1])
    end
    local rune_cnt = #self.m_resultData['drop_reward_list']

    local interval = 95
    local max_cnt_per_line = 8
    local last_line_item_cnt = rune_cnt % max_cnt_per_line
    
    local l_pos = getSortPosList(interval, max_cnt_per_line)
    local l_last_line_pos = getSortPosList(interval, last_line_item_cnt)

    local total_lines = rune_cnt / 8 > 1 and rune_cnt / 8 + 1 or rune_cnt / 8
    total_lines = math_floor(total_lines)

    -- 스크롤 뷰 생성
    local scroll_view = cc.ScrollView:create()

    do  -- 스크롤 뷰 생성    
        local size = vars['tableViewNode']:getContentSize() -- 기본 사이즈 저장
        local dock_point = vars['tableViewNode']:getDockPoint()
        local anchor_point = vars['tableViewNode']:getAnchorPoint()
        local x, y = vars['tableViewNode']:getPosition()
        
        scroll_view:setNormalSize(size)
        scroll_view:setRelativeSizeAndType(cc.size(0, 0), 3, true) -- 렐러티브 사이즈 both로 지정
        scroll_view:setContentSize(cc.size(size['width'], interval * total_lines + interval / 2))
        scroll_view:setDockPoint(TOP_CENTER)
        scroll_view:setAnchorPoint(TOP_CENTER)
        scroll_view:setPosition(ZERO_POINT)
        vars['tableViewNode']:addChild(scroll_view) -- node에 붙임
        scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) -- 좌, 우 스크롤 사용

        scroll_view:setTouchEnabled(true)
    end

    for i,v in ipairs(self.m_resultData['drop_reward_list']) do
        local item_id = v[1]
        local count = v[2]
        local from = v[3]
        local t_sub_data = v[4]
        local x_index = i % 8 == 0 and 8 or i % 8
        local y_index = (i % 8 == 0) and math_floor(i / 8) or math_floor(i / 8) + 1
        local pos_list = (last_line_item_cnt > 0 and y_index >= total_lines) and l_last_line_pos or l_pos

        local item_card = UI_ItemCard(item_id, count, t_sub_data)
        item_card:setRarityVisibled(true)
        item_card.root:setScale(0.6)
        item_card.root:setSwallowTouch(false)
        item_card.root:setDockPoint(TOP_CENTER)
        item_card.root:setAnchorPoint(CENTER_POINT)
        scroll_view:addChild(item_card.root)

        local pos_x = pos_list[x_index]
        local pos_y = y_index <= 1 and 0 - math_floor(interval / 4) or 0 - math_floor(interval / 4) - interval * (y_index - 1)
        item_card.root:setPositionX(pos_x)
        item_card.root:setPositionY(pos_y)
    end

    ccdump(scroll_view:getContentOffset())
    -- 현 오프셋이 최소 오프셋보다 작으면 최상단으로 간것
    scroll_view:getContainer():setPositionY(0)

    if (vars['runeRewardLabel']) then vars['runeRewardLabel']:setString(comma_value(rune_cnt)) end
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
