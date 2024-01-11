local PARENT = UI


local function convertTimeToStringFormat(time)
    time = string.format('%.2f', tostring(time))
    local decimal = 0
    local floating = 0
    decimal, floating = string.match(tostring(time), "([^.]*)%.([^.]*)")

    local minutes = math.floor(tonumber(decimal) / 60)
    local sec = tonumber(decimal) % 60

    local millisec = tonumber(floating)
    return string.format('%02d:%02d:%02d', minutes, sec, millisec)
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankPopup = class(PARENT, {
    m_modeId = 'number',

    m_totalBtn = 'UIC_Button',
    m_tabBtns = 'List[UIC_Button]',
    m_tabLabels = 'List[LabelTTF]',
    m_tabMenu = 'cc.Menu',
    m_stageRankMenu = 'cc.Menu',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankPopup:init(mode_id)
    self.m_modeId = mode_id
    self.m_uiName = 'UI_DmgateRankPopup'
    local vars = self:load('dmgate_rank_popup.ui')

    UIManager:open(self, UIManager.SCENE)
    
    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DmgateRankPopup')

    self.m_tabMenu = vars['tabMenu']

    --self.m_totalBtn = vars['totalRankBtn']
    --self.m_totalBtn:registerScriptTapHandler(function() self:click_tabBtn() end)
    self.m_tabBtns = {}
    self.m_tabLabels = {}

    local index = 0
    while(vars['tabBtn' .. tostring(index)]) do
        self.m_tabBtns[index] = vars['tabBtn' .. tostring(index)]
        self.m_tabLabels[index] = vars['tabLabel' .. tostring(index)]
        index = index + 1
    end

    self:initUI()
    self:initButton()
    self:refresh()

    local cleared_stage_id = g_dmgateData:getClearedMaxStageInList(mode_id)
    local next_stage_id

    -- 차원문 클리어한 스테이지가 없는 경우
    if (cleared_stage_id == nil) then
        next_stage_id = g_dmgateData:makeDimensionGateID(self.m_modeId, 1, 0, 1)
    else -- 있는 경우 다음 스테이지
        next_stage_id = g_dmgateData:getNextStageID(cleared_stage_id)
    end

    -- 차원문 스테이지를 모두 클리어 한 경우
    if next_stage_id == nil then
        tab_id = 0
    else
        tab_id = g_dmgateData:getStageID(next_stage_id)
    end

    self:click_tabBtn(tab_id)  
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateRankPopup:initUI()
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateRankPopup:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    for index, button in pairs(self.m_tabBtns) do 
        button:registerScriptTapHandler(function() self:click_tabBtn(index) end)
    end
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateRankPopup:refresh()
end


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateRankPopup:click_tabBtn(index)
    self.m_tabMenu:removeAllChildren()

    for i, button in pairs(self.m_tabBtns) do 
        if i == index then
            button:setEnabled(false)
            self.m_tabLabels[i]:setTextColor(cc.c4b(0, 0, 0, 255))
        else
            button:setEnabled(true)
            
            self.m_tabLabels[i]:setTextColor(cc.c4b(240, 215, 159, 255))
        end
    end

    local ui
    if (not index) or (index == 0) then
        ui = UI_DmgateRankTotal(self.m_modeId)
    else
        ui = UI_DmgateRankStage(self.m_modeId, index)
    end

    self.m_tabMenu:addChild(ui.root)
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankStage = class(PARENT, {
    m_modeId = 'number',
    m_tabIndex = 'number',

    m_bRankEmpty = 'boolean',

    m_rankNum = 'number',
    m_rankItemGap = 'number',

    m_pickRateSortBtn = 'UIC_Button',
    m_pickRateSortLabel = 'UIC_Label',
    m_pickRateTableView = 'UIC_TableView',
    

    m_rankSortBtn = 'UIC_Button',
    m_rankSortLabel = 'UIC_Label',
    m_rankTableView = 'UIC_TableView',
    m_rankNode = 'cc.Node',
    m_userNode = 'cc.Node',

    m_dragonPickRatesUI = 'UI_DragonPickRates(node)',

    m_dragonSortBtn = 'UIC_Button',
    m_dragonSortLabel = 'UIC_Label',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankStage:init(mode_id, index)
    local vars = self:load('dmgate_rank_popup_stage.ui')
    self.m_modeId = mode_id
    self.m_tabIndex = index

    self.m_bRankEmpty = false

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self.m_rankNum = 20
    self.m_rankItemGap = 20

    self.m_pickRateSortBtn = vars['stageBtn']
    self.m_pickRateSortLabel = vars['stageLabel']

    self.m_rankSortBtn = vars['userRankBtn']
    self.m_rankSortLabel = vars['userRankLabel']
    self.m_rankNode = vars['userListNode']
    self.m_userNode = vars['userMeNode']

    self.m_dragonSortBtn = vars['stageBtn']
    self.m_dragonSortLabel = vars['stageLabel']

    self:initUI()
    self:initButton()
    self:refresh()        
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateRankStage:initUI()
    local vars = self.vars
    self:initRankSortList()

    self:initDragonRankSortList()
    -----------------------------------------------------------
    -- local rank_list

    -- local create_func = function(ui, data)
        
    -- end

    -- local tableview = UIC_TableView(vars['userListNode'])
    -- tableview:setCellSizeToNodeSize()
    -- tableview:setGapBtwCells(5)
    -- tableview:setCellUIClass(UI_DmgateRankStageItem, create_func)
    
    -- tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- tableview:setItemList(rank_list, true)
    -----------------------------------------------------------
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateRankStage:initDragonRankSortList()
    local vars = self.vars
    local button = self.m_dragonSortBtn
    local label = self.m_dragonSortLabel
    
    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local sort_list = UIC_SortList()

    sort_list.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    sort_list:setNormalSize(width, height)
    sort_list:setPosition(x, y)
    sort_list:setDockPoint(button:getDockPoint())
    sort_list:setAnchorPoint(button:getAnchorPoint())
    sort_list:init_container()

    sort_list:setExtendButton(button)
    sort_list:setSortTypeLabel(label)

    parent:addChild(sort_list.m_node)

    sort_list:addSortType('under', Str('하층'))
    sort_list:addSortType('normal', Str('보통'))
    sort_list:addSortType('hard', Str('어려움'))
    sort_list:addSortType('hell', Str('지옥'))

    sort_list:setSortChangeCB(function(type) self:onChangeDragonRankSort(type) end)

    -- 클리어한 최종 스테이지
    local sort_type = 'under'
    local cleared_max_stage = g_dmgateData:getClearedMaxStageInList(self.m_modeId)

    local next_stage_id
    -- 클리어한 스테이지가 없는 경우
    if (cleared_max_stage == nil) then
        next_stage_id = g_dmgateData:makeDimensionGateID(self.m_modeId, 1, 0, 1)
    else -- 있는 경우 다음 스테이지
        next_stage_id = g_dmgateData:getNextStageID(cleared_max_stage)
    end


    local stage_difficulty
    -- 차원문 스테이지를 모두 클리어한 경우
    if next_stage_id == nil then
        stage_difficulty = g_dmgateData:getDifficultyID(cleared_max_stage)
    else
        stage_difficulty = g_dmgateData:getDifficultyID(next_stage_id)
    end

    if (stage_difficulty == 1) then sort_type = 'normal' end
    if (stage_difficulty == 2) then sort_type = 'hard' end
    if (stage_difficulty == 3) then sort_type = 'hell' end


    sort_list:setSelectSortType(sort_type)
end

----------------------------------------------------------------------
-- function initDragonPickRateList
----------------------------------------------------------------------
function UI_DmgateRankStage:init_dragonRankTableView(data)
    if (not self.m_dragonPickRatesUI) then
        self.m_dragonPickRatesUI = UI_DragonPickRates(self.vars['dragonUseListNode'], 'dmgate_rank_popup_stage_dragon_item.ui')
    end

    self.m_dragonPickRatesUI:updateList(data)
end


----------------------------------------------------------------------
-- function onChangeDragonRankSort
----------------------------------------------------------------------
function UI_DmgateRankStage:onChangeDragonRankSort(type)
    local difficulty = 3
    local chapter = 2
    --self.m_dragonSortLabel
    
    if (type == 'under') then
        chapter = 1
        difficulty = 0

    elseif (type == 'normal') then
        difficulty = 1

    elseif (type == 'hard') then
        difficulty = 2

    elseif (type == 'hell') then
        difficulty = 3

    end

    local diff_color = g_dmgateData:getStageDiffTextColorByIndex(difficulty)
    self.m_dragonSortLabel:setTextColor(diff_color)

    local data = {}
    data['category'] = 'dmgate'
    data['group'] = g_dmgateData:getDmgateID(self.m_modeId)
    data['stage'] = g_dmgateData:makeDimensionGateID(self.m_modeId, chapter, difficulty, self.m_tabIndex)

    local function success_cb(ret)
        self:init_dragonRankTableView(ret)
    end

    g_dragonPickRateData:request_getPickRate(data, success_cb)
end




----------------------------------------------------------------------
-- function initRankSortList
----------------------------------------------------------------------
function UI_DmgateRankStage:initRankSortList()
    local vars = self.vars
    local button = self.m_rankSortBtn
    local label = self.m_rankSortLabel
    
    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local sort_list = UIC_SortList()

    sort_list.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    sort_list:setNormalSize(width, height)
    sort_list:setPosition(x, y)
    sort_list:setDockPoint(button:getDockPoint())
    sort_list:setAnchorPoint(button:getAnchorPoint())
    sort_list:init_container()

    sort_list:setExtendButton(button)
    sort_list:setSortTypeLabel(label)

    parent:addChild(sort_list.m_node)


    sort_list:addSortType('my', Str('내 랭킹'))
    sort_list:addSortType('top', Str('최상위 랭킹'))
    sort_list:addSortType('friend', Str('친구 랭킹'))
    if g_clanData and (not g_clanData:isClanGuest()) then
        sort_list:addSortType('clan', Str('클랜원 랭킹'))
    end

    sort_list:setSortChangeCB(function(type) self:onChangeRankSort(type) end)
    sort_list:setSelectSortType('top')
end

----------------------------------------------------------------------
-- function onChangeRankSort
----------------------------------------------------------------------
function UI_DmgateRankStage:onChangeRankSort(type)
    local sort_type
    local offset
    if (type == 'my') then
        sort_type = 'world'
        offset = -1

    elseif (type == 'top') then
        sort_type = 'world'
        offset = 1

    elseif (type == 'friend') then
        sort_type = 'friend'
        offset = 1

    elseif (type == 'clan') then
        sort_type = 'clan'
        offset = 1
    else
        sort_type = 'world'
        offset = -1
    end

    self:request_rank(sort_type, offset)
end

----------------------------------------------------------------------
-- function request_rank
----------------------------------------------------------------------
function UI_DmgateRankStage:request_rank(sort_type, offset)
    local data = {}
    data['offset'] = offset
    data['limit'] = self.m_rankNum
    data['type'] = sort_type
    data['dm_id'] = g_dmgateData:getDmgateID(self.m_modeId)

    if self.m_tabIndex ~= 0 then
        data['stage'] = g_dmgateData:makeDimensionGateID(self.m_modeId, 2, 3, self.m_tabIndex)
    end

    local function success_cb(ret, sort_type, offset)
        self:init_rankTableView(ret, sort_type, offset)
    end

    g_dmgateData:request_rank(data, success_cb)
end

----------------------------------------------------------------------
-- function init_rankTableView
----------------------------------------------------------------------
function UI_DmgateRankStage:init_rankTableView(ret, sort_type, offset)
    local vars = self.vars

    self.m_rankNode:removeAllChildren()
    self.m_userNode:removeAllChildren()
    
    local rank_list = ret['list'] or {}

    local uid = g_userData:get('uid')

    local create_cb = function(ui, data)
        
    end

    local my_rank_cb = function()
        local ui = UI_DmgateRankStageItem(ret['my_info'] or {})
        self.m_userNode:addChild(ui.root)
        ui.vars['meSprite']:setVisible(true)
    end

     -- 이전 랭킹 버튼 누른 후 콜백
    local function prev_btn_cb(_offset)
        self:request_rank(sort_type, _offset)
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function next_btn_cb(_offset)
        self:request_rank(sort_type, _offset)
    end
    
    local rank_tableview = UIC_RankingList()
    rank_tableview:setRankUIClass(UI_DmgateRankStageItem, create_cb)
    rank_tableview:setRankList(rank_list)
    rank_tableview:setEmptyStr(Str('랭킹 정보가 없습니다'))
    rank_tableview:setMyRank(my_rank_cb)
    rank_tableview:setOffset(offset)
    rank_tableview:makeRankMoveBtn(prev_btn_cb, next_btn_cb, self.m_rankItemGap)
    rank_tableview:makeRankList(self.m_rankNode)


    local index
    if (sort_type == 'world') and (offset == 1) then
        index = 1
    else
        for i, v in ipairs(rank_list) do
            if (v['uid'] == uid) then index = i break end
        end
    end

    -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    rank_tableview.m_rankTableView:update(0)
    rank_tableview.m_rankTableView:relocateContainerFromIndex(index)
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateRankStage:initButton()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateRankStage:refresh()
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankStageItem = class(class(UI, IRankListItem:getCloneTable()), {
    m_rankInfo = 'table',

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankStageItem:init(rank_info)
    self.m_rankInfo = StructUserInfo(rank_info)
    local vars = self:load('dmgate_rank_popup_stage_user_item.ui')

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)

    --self:initRankInfo(vars, self.m_rankInfo)

    if rawget(self.m_rankInfo, 'm_clan_info') then
        local struct_clan = StructClan({})
        struct_clan:applySimple(self.m_rankInfo['m_clan_info'])
        self.m_rankInfo:setStructClan(struct_clan)
    end

    self:initUI()
    self:initButton()
    self:refresh()        
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateRankStageItem:initUI()

    local uid = g_userData:get('uid')

    if (self.m_rankInfo['m_rank'] == 'next') or (self.m_rankInfo['m_rank'] == 'prev') then
        self.vars[self.m_rankInfo['m_rank'] .. 'Btn']:setVisible(true)
        return
    end

    if (self.m_rankInfo:getUid() == uid) then
        self.vars['meSprite']:setVisible(true)
    end

    -- 순위
    local rank = self.m_rankInfo['m_rank']

    if rank and tonumber(rank) > 0 then 
        self.vars['rankingLabel']:setString(Str('{1}위', comma_value(rank)))
    else
        self.vars['rankingLabel']:setString('-')
    end

    -- 티어
        -- local icon = self.m_rankInfo:makeTierIcon(nil, 'big')
        -- if (icon) then
        --     self.vars['tierNode']:addChild(icon)
        -- end
        -- self.vars['tierLabel']:setString(self.m_rankInfo:getTierName())

    -- 리더 드래곤
    self.m_rankInfo:setLeaderDragonObject(self.m_rankInfo['m_leader'])
    local ui = self.m_rankInfo:getLeaderDragonCard()
    if ui then
        ui.root:setSwallowTouch(false)
        self.vars['profileNode']:addChild(ui.root)
        
        -- ui.vars['clickBtn']:registerScriptTapHandler(function() 
        --     local is_visit = true
        --     UI_UserInfoDetailPopup:open(t_rank_info, is_visit, nil)
        -- end)
    end
    -- 레벨, 닉네임
    self.vars['userLabel']:setString(Str('Lv.{1} ', self.m_rankInfo:getLv()) .. self.m_rankInfo:getNickname())

    -- 클랜
    local struct_clan = self.m_rankInfo:getStructClan()
    if struct_clan then
        self.vars['clanLabel']:setString(struct_clan:getClanName())

        local icon = struct_clan:makeClanMarkIcon()
        if icon then self.vars['markNode']:addChild(icon) end
    else
        self.vars['clanLabel']:setVisible(false)
    end
    self.vars['clanBtn']:getParent():setSwallowTouch(false)

    -- 시간
    local clear_time = self.m_rankInfo['m_clear_time']
    if clear_time > 0.0 then 
        self.vars['timeLabel']:setString(convertTimeToStringFormat(clear_time))
        --self.vars['timeLabel']:setString(Str('{1}초', string.format('%.3f', clear_time)))
    else
        self.vars['timeLabel']:setString('-')
    end
    

end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankTotal = class(PARENT, {
    m_modeId = 'number',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotal:init(mode_id)
    local vars = self:load('dmgate_rank_popup_total.ui')
    self.m_modeId = mode_id

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:request_rank()

    self:initUI()
    self:initButton()
    self:refresh()        
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateRankTotal:initUI()

end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateRankTotal:initButton()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateRankTotal:refresh()
end

----------------------------------------------------------------------
-- function request_rank
----------------------------------------------------------------------
function UI_DmgateRankTotal:request_rank() 
    local data = {}
    data['limit'] = 50
    data['dm_id'] = g_dmgateData:getDmgateID(self.m_modeId)

    
    local function success_cb(ret)
        self:init_rankTableView(ret)
    end


    g_dmgateData:request_rank(data, success_cb)
end

----------------------------------------------------------------------
-- function init_rankTableView
----------------------------------------------------------------------
function UI_DmgateRankTotal:init_rankTableView(ret)    
    local vars = self.vars

    -- ret['list'] = { {
    --     lv = 31,
    --     tier = "bronze_3",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110002,
    --     costume = 730204,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = false,
    --     un = 9463,
    --     score = -1,
    --     total = 0,
    --     nick = "ksjang3",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 6,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121854,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "ksjang3",
    --     rank = -1
    --   }, {
    --     lv = 99,
    --     tier = "bronze_3",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110003,
    --     costume = 730300,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = false,
    --     un = 130839362,
    --     score = -1,
    --     total = 0,
    --     nick = "l은달lHenesK",
    --     leader = {
    --       lv = 1,
    --       mastery_lv = 0,
    --       grade = 3,
    --       rlv = 0,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 120414,
    --       transform = 1,
    --       mastery_skills = { },
    --       evolution = 1,
    --       mastery_point = 0
    --     },
    --     uid = "MFqooDQK9maoJkK3UzMKQ5zFhLB2",
    --     rank = -1
    --   }, {
    --     lv = 99,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110001,
    --     costume = 730100,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 9443,
    --     score = -1,
    --     total = 0,
    --     nick = "ksjang112",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 6,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121683,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "ksjang",
    --     rank = -1
    --   }, {
    --     lv = 99,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110004,
    --     costume = 730406,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 1956459,
    --     score = -1,
    --     total = 0,
    --     nick = "TEST001",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 0,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121962,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "vEH4nldukuRKrj032pVBAhetafz1",
    --     rank = -1
    --   }, {
    --     lv = 99,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110004,
    --     costume = 730400,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 9223,
    --     score = -1,
    --     total = 0,
    --     nick = "고니",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 0,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121752,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "ykil",
    --     rank = -1
    --   }, {
    --     lv = 34,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110002,
    --     costume = 730200,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 9698,
    --     score = -1,
    --     total = 0,
    --     nick = "test1228",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 0,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121954,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "test1228",
    --     rank = -1
    --   }, {
    --     lv = 97,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110003,
    --     costume = 730300,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 141049,
    --     score = -1,
    --     total = 0,
    --     nick = "HeinCheese",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 0,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 122055,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "2I5hY6XUrnTnEjnixGUkVrbUSB73",
    --     rank = -1
    --   }, {
    --     lv = 99,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110005,
    --     costume = 730502,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 71984,
    --     score = -1,
    --     total = 0,
    --     nick = "꿔바로우",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 10,
    --       grade = 6,
    --       rlv = 6,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121595,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 10
    --     },
    --     uid = "1hFq4remJYO0v85189RfUbofist1",
    --     rank = -1
    --   }, {
    --     lv = 99,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110004,
    --     costume = 730403,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 130862025,
    --     score = -1,
    --     total = 0,
    --     nick = "kamari",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 0,
    --       grade = 6,
    --       rlv = 0,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 121792,
    --       transform = 3,
    --       mastery_skills = { },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "YeoFSrDmUxZY3nM02LEjh5zrSft2",
    --     rank = -1
    --   }, {
    --     lv = 99,
    --     tier = "beginner",
    --     clan_info = {
    --       id = "5ddb4931970c6204bef38543",
    --       name = "testctwar56",
    --       mark = ""
    --     },
    --     tamer = 110005,
    --     costume = 730503,
    --     rp = -1,
    --     clear_time = -1,
    --     challenge_score = 0,
    --     rate = "-Infinity",
    --     last_tier = "beginner",
    --     arena_score = 0,
    --     ancient_score = 0,
    --     beginner = true,
    --     un = 2176990,
    --     score = -1,
    --     total = 0,
    --     nick = "I은달I동그라미",
    --     leader = {
    --       lv = 60,
    --       mastery_lv = 10,
    --       grade = 6,
    --       rlv = 6,
    --       eclv = 0,
    --       dragon_skin = 0,
    --       did = 120185,
    --       transform = 3,
    --       mastery_skills = {
    --         ["110301"] = 3,
    --         ["110101"] = 3,
    --         ["110203"] = 3,
    --         ["110402"] = 1
    --       },
    --       evolution = 3,
    --       mastery_point = 0
    --     },
    --     uid = "cqKc3TF98AZDRsmjfBBiF3OcwK62",
    --     rank = -1
    --   } }



    if #ret['list'] == 0 then 
        vars['rankMenu']:setVisible(false)
        vars['userMeNode']:setVisible(false)
        vars['totalRankListNode']:setVisible(false)

        vars['infoMenu']:setVisible(true)
        return
    end

    local rank_top_list = {}
    local rank_rest_list = {}

    for key, data in pairs(ret['list']) do
        if key <= 3 then
            table.insert(rank_top_list, data)
        else
            table.insert(rank_rest_list, data)
        end
    end

    for i = 1, 3 do
        local ui = UI_DmgateRankTotalTopItem(rank_top_list[i])
        vars['tamerNode' .. tostring(i)]:addChild(ui.root)
    end

    local my_rank_cb = function()
        local ui = UI_DmgateRankTotalItem(ret['my_info'] or {})
        self.vars['userMeNode']:addChild(ui.root)
        ui.vars['meSprite']:setVisible(true)
    end

    local function create_func(ui, data)
        
    end    

    -- if #rank_rest_list > 0 then
    -- local tableview = UIC_TableView(vars['totalRankListNode'])
    --     tableview:setCellSizeToNodeSize(true)
    --     --tableview.m_defaultCellSize = cc.p()
    --     tableview:setGapBtwCells(5)
    --     tableview:setCellUIClass(UI_DmgateRankTotalItem, create_func)
    --     tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --     tableview:setItemList(rank_rest_list, true)
    -- end

    
    local rank_tableview = UIC_RankingList()
    rank_tableview:setRankUIClass(UI_DmgateRankTotalItem, create_func)
    rank_tableview:setRankList(rank_rest_list)
    --rank_tableview:setEmptyStr(Str('랭킹 정보가 없습니다'))
    rank_tableview:setMyRank(my_rank_cb)
    --rank_tableview:setOffset(offset)
    --rank_tableview:makeRankMoveBtn(prev_btn_cb, next_btn_cb, self.m_rankItemGap)
    rank_tableview:makeRankList(vars['totalRankListNode'], cc.size(550, 55 + 5))
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  class UI_DmgateRankTotalItem
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankTotalItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_rankInfo = '',
})


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotalItem:init(rank_info)
    self.m_rankInfo = StructUserInfo(rank_info)
    local vars = self:load('dmgate_rank_popup_total_item_02.ui')

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    
    if rawget(self.m_rankInfo, 'm_clan_info') then
        local struct_clan = StructClan({})
        struct_clan:applySimple(self.m_rankInfo['m_clan_info'])
        self.m_rankInfo:setStructClan(struct_clan)
    end

    self:initUI()
    self:initButton()
    self:refresh()  
end


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotalItem:initUI()
    local uid = g_userData:get('uid')

    if (self.m_rankInfo:getUid() == uid) then
        self.vars['meSprite']:setVisible(true)
    end
    
    -- 순위
    local rank = self.m_rankInfo['m_rank']

    if rank and tonumber(rank) > 0 then 
        self.vars['rankLabel']:setString(Str('{1}위', comma_value(rank)))
    else
        self.vars['rankLabel']:setString('-')
    end

    -- 레벨, 닉네임
    self.vars['userLabel']:setString(Str('Lv.{1} ', self.m_rankInfo:getLv()) .. self.m_rankInfo:getNickname())

    -- 클랜
    local struct_clan = self.m_rankInfo:getStructClan()
    if struct_clan then
        self.vars['clanLabel']:setString(struct_clan:getClanName())

        local icon = struct_clan:makeClanMarkIcon()
        if icon then self.vars['markNode']:addChild(icon) end
    else
        self.vars['clanLabel']:setVisible(false)
    end

    -- 시간
    local clear_time = self.m_rankInfo['m_clear_time']
    if clear_time > 0.0 then 
        self.vars['timeLabel']:setString(convertTimeToStringFormat(clear_time))
        --self.vars['timeLabel']:setString(Str('{1}초', string.format('%.3f', clear_time)))
    else
        self.vars['timeLabel']:setString('-')
    end
end

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotalItem:initButton()
    
end
----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotalItem:refresh()

end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  class UI_DmgateRankTotalTopItem
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankTotalTopItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_rankInfo = '',
})


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotalTopItem:init(rank_info)
    self.m_rankInfo = StructUserInfo(rank_info)
    local vars = self:load('dmgate_rank_popup_total_item_01.ui')

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)
    
    if rawget(self.m_rankInfo, 'm_clan_info') then
        local struct_clan = StructClan({})
        struct_clan:applySimple(self.m_rankInfo['m_clan_info'])
        self.m_rankInfo:setStructClan(struct_clan)
    end

    self:initUI(rank_info)
    --self:initButton()
    --self:refresh()  
end


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotalTopItem:initUI(rank_info)
    local vars = self.vars

    if (rank_info == nil) then
        vars['userLabel']:setVisible(false)
        vars['clanMenu']:setVisible(false)
        vars['timeLabel']:setVisible(false)
        return
    end
    
    do -- 테이머 아이콘 갱신
        local icon = IconHelper:getTamerProfileIconWithCostumeID(self.m_rankInfo['m_costume'])
        -- 전달 받은 랭킹 유저의 코스튬 ID에 해당하는 정보가 없는 경우
        if (icon == nil) then
            icon = IconHelper:getTamerProfileIconWithCostumeID()
        end
        vars['tamerNode']:removeAllChildren()

        if icon then
            vars['tamerNode']:addChild(icon)
        end
    end

    -- 레벨, 닉네임
    self.vars['userLabel']:setString(Str('Lv.{1} ', self.m_rankInfo:getLv()) .. self.m_rankInfo:getNickname())

    -- 클랜
    local struct_clan = self.m_rankInfo:getStructClan()
    if struct_clan then
        self.vars['clanLabel']:setString(struct_clan:getClanName())

        local icon = struct_clan:makeClanMarkIcon()
        if icon then self.vars['markNode']:addChild(icon) end
    else
        --  local user_label_pos_y = vars['userLabel']:getPositionY()
        --  local clan_label_pos_y = vars['clanMenu']:getPositionY()
        --  local time_label_pos_y = vars['timeLabel']:getPositionY()

        -- vars['userLabel']:setPositionY(user_label_pos_y - (user_label_pos_y - clan_label_pos_y) * 0.5)
        -- vars['timeLabel']:setPositionY(time_label_pos_y + (clan_label_pos_y - time_label_pos_y) * 0.5)

        self.vars['timeLabel']:setPositionY(self.vars['clanMenu']:getPositionY())
        self.vars['clanMenu']:setVisible(false)
    end
    
    -- 시간
    local clear_time = self.m_rankInfo['m_clear_time']
    if clear_time > 0.0 then 
        self.vars['timeLabel']:setString(convertTimeToStringFormat(clear_time))
        --self.vars['timeLabel']:setString(Str('{1}초', string.format('%.3f', clear_time)))
    else
        self.vars['timeLabel']:setString('-')
    end

    --vars['tamerNode']
end