local PARENT = UI

-------------------------------------
-- class UI_AdventureStageInfo
-------------------------------------
UI_AdventureStageInfo = class(PARENT,{
        m_stageID = 'number',
        m_currTab = 'string', -- 'item' or 'monster'
        m_bInitItemTableView = 'boolean',
        m_bInitMonsterTableView = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureStageInfo:init(stage_id)
    self:init_MemberVariable(stage_id)

    local vars = self:load('adventure_stage_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdventureStageInfo')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function init_MemberVariable
-------------------------------------
function UI_AdventureStageInfo:init_MemberVariable(stage_id)
    self.m_stageID = stage_id
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdventureStageInfo:initUI()
    self:click_tabBtn('item')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureStageInfo:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_tabBtn('item') end)
    vars['enemyInfoBtn']:registerScriptTapHandler(function() self:click_tabBtn('monster') end)
    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureStageInfo:refresh()
    local vars = self.vars
    local stage_id = self.m_stageID

    do -- 스테이지 이름
        local stage_name = g_stageData:getStageName(stage_id)
        vars['titleLabel']:setString(stage_name)
    end

    do -- 모험 소비 활동력
        if (stage_id == DEV_STAGE_ID) then
            self.vars['actingPowerLabel']:setString('0')
        else
            local table_drop = TABLE:get('drop')
            local t_drop = table_drop[stage_id]
            -- 'stamina' 추후에 타입별 stamina 사용 예정
            -- local cost_type = t_drop['cost_type']
            local cost_value = t_drop['cost_value']
            self.vars['actingPowerLabel']:setString(cost_value)
        end 
    end

    local table_stage_desc = TableStageDesc()
    
    if (not table_stage_desc:get(stage_id)) then
        return
    end

    do -- 스테이지 설명
        local desc = table_stage_desc:getStageDesc(stage_id)
        vars['dscLabel']:setString(desc)
    end

    -- 스테이조 난이도 뱃지
    self:refresh_difficultyBadge()


    do -- 이전, 다음 버튼
        local prev_stage = g_stageData:getSimplePrevStage(stage_id)
        vars['prevBtn']:setVisible(prev_stage ~= nil)

        local next_stage = g_stageData:getSimpleNextStage(stage_id)
        vars['nextBtn']:setVisible(next_stage ~= nil)
    end
end

-------------------------------------
-- function refresh_difficultyBadge
-- @brief 스테이지 난이도 (모험모드에 한함)
-------------------------------------
function UI_AdventureStageInfo:refresh_difficultyBadge()
    local vars = self.vars
    local stage_id = self.m_stageID

    local game_mode = g_stageData:getGameMode(stage_id)

    -- 모험 모드
    if (game_mode ~= GAME_MODE_ADVENTURE) then
        vars['difficultySprite']:setVisible(false)
        vars['difficultyLabel']:setVisible(false)

    -- 기타 모드(170118기준으로 네스트 던전이 해당)
    else
        vars['difficultySprite']:setVisible(true)
        vars['difficultyLabel']:setVisible(true)

        local difficulty, chapter, stage = parseAdventureID(stage_id)

        if (difficulty == 1) then
            vars['difficultySprite']:setColor(cc.c3b(121, 186, 58))
            vars['difficultyLabel']:setString(Str('쉬움'))

        elseif (difficulty == 2) then
            vars['difficultySprite']:setColor(cc.c3b(46, 162, 196))
            vars['difficultyLabel']:setString(Str('보통'))

        elseif (difficulty == 3) then
            vars['difficultySprite']:setColor(cc.c3b(196, 74, 46))
            vars['difficultyLabel']:setString(Str('어려움'))
        end
    end

    do -- 정렬
        if (game_mode ~= GAME_MODE_ADVENTURE) then
            vars['titleLabel']:setPositionX(0)
        else
            local difficulty_width = vars['difficultySprite']:getContentSize()['width']
            local title_width = vars['titleLabel']:getStringWidth()
            
            local total_width = (title_width + difficulty_width)
            vars['difficultySprite']:setPositionX(-(total_width / 2) + (difficulty_width/2))
            vars['titleLabel']:setPositionX(-(total_width / 2) + difficulty_width + (title_width/2))
        end
    end
end

-------------------------------------
-- function refresh_monsterList
-------------------------------------
function UI_AdventureStageInfo:refresh_monsterList()
    local vars = self.vars
    local stage_id = self.m_stageID

    do -- 몬스터 아이콘 리스트
        local l_monster_id = g_stageData:getMonsterIDList(stage_id)
        if (not l_monster_id) then return end

        local list_table_node = self.vars['monsterListNode']
        list_table_node:removeAllChildren()
        local cardUIClass = UI_MonsterCard
        local cardUISize = 0.6
        local width, height = cardUIClass:getCardSize(cardUISize)

        -- 인연 던전의 경우
        local t_info = g_secretDungeonData:parseSecretDungeonID(stage_id)
        if (t_info['dungeon_mode'] == SECRET_DUNGEON_RELATION) then
            local makeUI = function(did)
                local t_dragon_data = {}
                t_dragon_data['did'] = did
                t_dragon_data['evolution'] = 1
                t_dragon_data['grade'] = 1
                t_dragon_data['skill_0'] = 1
                t_dragon_data['skill_1'] = 1
                t_dragon_data['skill_2'] = 0
                t_dragon_data['skill_3'] = 0

                local ui = UI_DragonCard(t_dragon_data)
                return ui
            end

            cardUIClass = makeUI
        end
        
        -- 리스트 아이템 생성 콜백
        local function create_func(item)
            local ui = item['ui']
            ui.root:setScale(cardUISize)
        end

        -- 클릭 콜백 함수
        local click_item = nil

        -- 테이블뷰 초기화
        local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.HORIZONTAL)
        table_view_ext:setCellInfo(width, height)
        table_view_ext:setItemUIClass(cardUIClass, click_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
        table_view_ext:setItemInfo(l_monster_id)
        table_view_ext:update()
    end
end

-------------------------------------
-- function refresh_rewardInfo
-- @brief 획득 가능 보상
-------------------------------------
function UI_AdventureStageInfo:refresh_rewardInfo()
    -- stage_id로 드랍정보를 얻어옴
    local stage_id = self.m_stageID
    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()

    local list_table_node = self.vars['dropListNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(item)
        local ui = item['ui']
        ui.root:setDockPoint(cc.p(0, 0))
        ui.root:setAnchorPoint(cc.p(0, 0))
        ui.root:setScale(0.6)
    end

    -- 클릭 콜백 함수
    local function click_item(item)
        local ui = item['ui']
        ui:click_clickBtn()
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.HORIZONTAL)
    table_view_ext:setCellInfo(90, 90)
    table_view_ext:setItemUIClass(UI_ItemCard, click_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(l_item_list)
    table_view_ext:update()
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_AdventureStageInfo:click_enterBtn()
    local func = function()
        local stage_id = self.m_stageID

        local function close_cb()
            self:sceneFadeInAction()
        end

        local ui = UI_ReadyScene(stage_id)
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_tabBtn
-- @brief '획득 가능 보상', '출현 정보'
-------------------------------------
function UI_AdventureStageInfo:click_tabBtn(tab_type, force)
    if (not force) and (self.m_currTab == tab_type) then
        return
    end

    self.m_currTab = tab_type

    local vars = self.vars

    vars['rewardBtn']:setEnabled(true)
    vars['enemyInfoBtn']:setEnabled(true)

    if (self.m_currTab == 'item') then
        vars['monsterListNode']:setVisible(false)
        vars['dropListNode']:setVisible(true)
        vars['rewardBtn']:setEnabled(false)
        
        if (not self.m_bInitItemTableView) then
            self:refresh_rewardInfo()
            self.m_bInitItemTableView = true
        end

    elseif (self.m_currTab == 'monster') then
        vars['monsterListNode']:setVisible(true)
        vars['dropListNode']:setVisible(false)
        vars['enemyInfoBtn']:setEnabled(false)

        if (not self.m_bInitMonsterTableView) then
           self:refresh_monsterList()
           self.m_bInitMonsterTableView = true
        end
        
    else
        error('self.m_currTab : ' .. self.m_currTab)
    end
end

-------------------------------------
-- function click_prevBtn
-- @brief
-------------------------------------
function UI_AdventureStageInfo:click_prevBtn()
    local stage_id = g_stageData:getSimplePrevStage(self.m_stageID)
    self:changeStageID(stage_id)
end

-------------------------------------
-- function click_nextBtn
-- @brief
-------------------------------------
function UI_AdventureStageInfo:click_nextBtn()
    local stage_id = g_stageData:getSimpleNextStage(self.m_stageID)
    self:changeStageID(stage_id)
end


-------------------------------------
-- function changeStageID
-------------------------------------
function UI_AdventureStageInfo:changeStageID(stage_id)
    if (self.m_stageID == stage_id) then
        return
    end

    if (not g_stageData:isOpenStage(stage_id)) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이전 스테이지를 클리어하세요.'))
        return
    end

    self.m_stageID = stage_id
    self:refresh()

    self.m_bInitItemTableView = false
    self.m_bInitMonsterTableView = false
    self:click_tabBtn(self.m_currTab, true)
end



--@CHECK
UI:checkCompileError(UI_AdventureStageInfo)
