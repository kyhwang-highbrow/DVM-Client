local PARENT = UI
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankPopup = class(PARENT, {
    m_modeId = 'number',

    m_totalBtn = 'UIC_Button',
    m_tabBtns = 'List[UIC_Button]',
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
    UIManager:open(self, UIManager.POPUP)
    
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

    local index = 0
    while(vars['tabBtn' .. tostring(index)]) do
        self.m_tabBtns[index] = vars['tabBtn' .. tostring(index)]
        index = index + 1
    end

    self:initUI()
    self:initButton()
    self:refresh()      
    
    self:click_tabBtn(0)  
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

    local ui
    if (not index) or (index == 0) then
        ui = UI_DmgateRankTotal()
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

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankStage:init(mode_id, index)
    local vars = self:load('dmgate_rank_popup_stage.ui')
    self.m_modeId = mode_id
    self.m_tabIndex = index

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
function UI_DmgateRankStage:initPickRateSortList()
end


----------------------------------------------------------------------
-- function initUI
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
    sort_list:setSelectSortType('my')
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
    rank_tableview:setEmptyStr('랭킹 정보가 없습니다')
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
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
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
        local icon = self.m_rankInfo:makeTierIcon(nil, 'big')
        if (icon) then
            self.vars['tierNode']:addChild(icon)
        end
        self.vars['tierLabel']:setString(self.m_rankInfo:getTierName())

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

    -- 시간
    local clear_time = self.m_rankInfo['m_clear_time']
    if clear_time > 0.0 then 
        self.vars['timeLabel']:setString(Str('{1}초', string.format('%.3f', clear_time)))
    else
        self.vars['timeLabel']:setString('-')
    end
    

end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_DmgateRankTotal = class(PARENT, {
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateRankTotal:init()
    local vars = self:load('dmgate_rank_popup_total.ui')

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

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








