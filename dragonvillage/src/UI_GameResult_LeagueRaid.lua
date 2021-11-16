local PARENT = UI_GameResultNew



----------------------------------------------------------------------------
-- class UI_GameResult_LeagueRaid
----------------------------------------------------------------------------
UI_GameResult_LeagueRaid = class(UI, {
    m_newInfo = 'table',

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

    m_okBtn = 'Button',

    m_rewardTableView = 'UIC_tableView',

    m_tRuneCardTable = 'table',
})


----------------------------------------------------------------------------
-- function init
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:init(stage_id, is_success, result_data, new_info)
    local vars = self:load('league_raid_result.ui')
    self.m_uiName = 'UI_GameResult_LeagueRaid'

    UIManager:open(self, UIManager.POPUP)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_GameResult_LeagueRaid')
    self.m_newInfo = new_info

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
    --self:initRuneCardList()
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

    table.insert(self.m_lWorkList, 'direction_showScore')

    local rune_cnt = #self.m_resultData['drop_reward_list']
    if (rune_cnt > 0) then
	    table.insert(self.m_lWorkList, 'direction_showBox')
        table.insert(self.m_lWorkList, 'direction_openBox')
    end

    table.insert(self.m_lWorkList, 'direction_showRunes')

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
-- function direction_showScore
-- @brief 점수 연출
-------------------------------------
function UI_GameResult_LeagueRaid:direction_showScore()
    local vars = self.vars

    local total_score = cc.Label:createWithBMFont('res/font/tower_score.fnt', '')
    total_score:setAnchorPoint(cc.p(0.5, 0.5))
    total_score:setDockPoint(cc.p(0.5, 0.5))
    total_score:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    total_score:setAdditionalKerning(0)
    vars['scoreNode']:addChild(total_score)

    local new_score = NumberLabel(total_score, 0, 0.3)
    new_score:setNumber(g_leagueRaidData.m_currentDamage, false)

    self:doNextWorkWithDelayTime(0.8)
end


-------------------------------------
-- function direction_showRunes
-- @brief 종료 연출
-------------------------------------
function UI_GameResult_LeagueRaid:direction_showRunes()
    local vars = self.vars
    --self:initRewardTable()
    if (not self.m_resultData or not self.m_resultData['drop_reward_list']) then 
        if (vars['runeRewardLabel']) then vars['runeRewardLabel']:setString(comma_value(rune_cnt)) end
        self:doNextWorkWithDelayTime(0.5)
        return 
    end

    local rune_cnt = #self.m_resultData['drop_reward_list']

    if (rune_cnt <= 0) then 
        self:doNextWorkWithDelayTime(0.5)
        return
    end



    local interval = 80
    local max_cnt_per_line = 11

    local l_item = {}
    for i,v in ipairs(self.m_resultData['drop_reward_list']) do
        -- struct rune obj
        local t_rune_data = g_runesData:getRuneObject(v[4]['roid'])
		if (t_rune_data ~= nil) then
            table.insert(l_item, t_rune_data)
        end

        --table.insert(l_item, v[1])
    end

    -- 생성 시 함수
    local function create_func(ui, data)
        
    end

    -- 테이블뷰 생성 TD
    local table_view = UIC_TableViewTD(vars['tableViewNode'])
    table_view:setCellCreateDirecting(-1)
    table_view:setAlignCenter(true)
    table_view:setHorizotalCenter(true)
    table_view.m_cellSize = cc.size(interval, interval)
    table_view.m_nItemPerCell = max_cnt_per_line
    table_view:setCellUIClass(UI_RuneCard, create_func)
    table_view:setItemList(l_item, true)
    table_view.m_scrollView:setTouchEnabled(false)

    table_view:update(0)

    local ui_list = table_view.m_itemList
    local action_delay_time = 0.2
    local ani_interval = 0.0

    for index, item_card in ipairs(ui_list) do
        if (item_card and item_card['ui']) then
            item_card['ui'].root:setVisible(false)
        end
    end

    -- 아이템 카드 보여주는 액션
    local function show_reward(item_card, is_last)
        local item_node = item_card.root
        item_node:setVisible(true)
        cca.stampShakeAction(item_node, 0.5 * 1.1, 0.1, 0, 0, 0.5)

        if (is_last) then
            self:doNextWorkWithDelayTime(0.5)
        end
    end


    for index, item_card in ipairs(ui_list) do
        if (item_card and item_card['ui']) then
            local is_last = (index == #ui_list)
            item_card['ui'].root:setScale(0.5)

            cca.reserveFunc(self.root, 
                            action_delay_time * ((index - 1) + ani_interval), 
                            function() show_reward(item_card['ui'], is_last) end)

        end
    end


    --self:doNextWorkWithDelayTime(0.8)
end





-------------------------------------
-- function initRuneCardList
-------------------------------------
function UI_GameResult_LeagueRaid:initRuneCardList()
	local vars = self.vars

	local rune_cnt = #self.m_resultData['drop_reward_list']	-- 총 룬 카드 수
	local card_interval = 110	-- 룬 카드 가로 오프셋

    local l_pos_list = getSortPosList(card_interval, rune_cnt)
    
    local b_is_first_open = true

	for idx, t_rune_data in ipairs(self.m_resultData['drop_reward_list']) do
        ccdump(t_rune_data)

		-- 룬 카드 생성
		local struct_rune_object = g_runesData:getRuneObject(t_rune_data['drop']['roid'])-- raw data를 StructRuneObject 형태로 변경
        local node = vars['runeNode' .. idx]
        local roid = struct_rune_object['roid']
		
        local card = UI_RuneCard_Gacha(struct_rune_object)

        local function open_start_cb()
            SoundMgr:playEffect('UI', 'ui_card_flip')
        end
        
        card:setOpenStartCB(open_start_cb)
		node:addChild(card.root)
		self.m_tRuneCardTable[roid] = card

        -- 카드 위치 정렬
        node:setPositionX(l_pos_list[idx])    
        node:setPositionY(math_floor(idx / 8) * 95 * -1)   
	end

    for roid, rune_card in pairs(self.m_tRuneCardTable) do
        rune_card.root:setOpacity(0)
        local x, y = rune_card.root:getPosition()
         -- 등장할 때 미끄러지면서 생성되기
        local move_distance = 50
        local duration = 0.2
        local move = cc.MoveTo:create(duration, cc.p(x, y))
        local fade_in = cc.FadeIn:create(duration)
        local action = cc.EaseInOut:create(cc.Spawn:create(fade_in, move), 1.3)
        
        local function card_set_sound_play()
            SoundMgr:playEffect('UI', 'ui_card_set')
        end

        local sequence = cc.Sequence:create( cc.CallFunc:create(card_set_sound_play), action)

        rune_card.root:setPositionY(y + move_distance)
        rune_card.root:runAction(sequence)
    end
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
    local my_info = g_leagueRaidData:getMyInfo()

    if (my_info and g_leagueRaidData.m_currentDamage <= my_info['score']) then return end

    local ui_leader_board = UI_ResultLeagueRaidScore(self.m_resultData, self.m_newInfo)
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
    if (vars['runeRewardLabel']) then vars['runeRewardLabel']:setString(comma_value(rune_cnt)) end

    --[[
    local interval = 95
    local max_cnt_per_line = 8

    local l_item = {}
    for i,v in ipairs(self.m_resultData['drop_reward_list']) do
        table.insert(l_item, v[1])
    end
    
    -- 생성 시 함수
    local function create_func(ui, data)
        local item_id = tonumber(data)
        local table_item = TableItem():get(item_id)

        ui.root:setScale(0.6)

        if (table_item and table_item['grade']) then 
            local grade = tonumber(table_item['grade'])
            self:setItemCardRarity(ui, grade)
        end
    end

    -- 테이블뷰 생성 TD
    local table_view = UIC_TableViewTD(vars['tableViewNode'])
    table_view:setAlignCenter(true)
    table_view:setHorizotalCenter(true)
    table_view.m_cellSize = cc.size(interval, interval)
    table_view.m_nItemPerCell = max_cnt_per_line
    table_view:setCellUIClass(UI_ItemCard, create_func)

    self.m_rewardTableView = table_view
    --table_view:setItemList(l_item)]]
    
end


-------------------------------------
-- function setItemCardRarity
-------------------------------------
function UI_GameResult_LeagueRaid:setItemCardRarity(item_card, grade)
	if (grade > 6) then
		local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
		rarity_effect:changeAni('summon_hero', true)
		rarity_effect:setScale(1.7)
		rarity_effect:setAlpha(0)
		item_card.root:addChild(rarity_effect.m_node)
        rarity_effect.m_node:runAction(cc.FadeIn:create(0.5))
	end
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

    SoundMgr:playBGM('bgm_lobby')
end


----------------------------------------------------------------------------
-- function click_statsBtn
----------------------------------------------------------------------------
function UI_GameResult_LeagueRaid:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_LeagueRaidStatisticsPopup(g_gameScene.m_gameWorld)
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
