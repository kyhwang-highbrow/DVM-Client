local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_AdventureStageInfo
-------------------------------------
UI_AdventureStageInfo = class(PARENT,{
        m_stageID = 'number',
        m_currTab = 'string', -- 'item' or 'monster'
        m_bInitItemTableView = 'boolean',
        m_bInitMonsterTableView = 'boolean',

        m_orgWidth = 'number',
        m_orgHeight = 'number',
    })

UI_AdventureStageInfo.REWARD = 'reward'
UI_AdventureStageInfo.ENEMY = 'enemyInfo'

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureStageInfo:init(stage_id)
    self:init_MemberVariable(stage_id)

    local vars = self:load('adventure_stage_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- UI 클래스명 지정
    self.m_uiName = 'UI_AdventureStageInfo'
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
    local size = self.vars['popupNode']:getContentSize()
    self.m_orgWidth = size['width']
    self.m_orgHeight = size['height']
    
    self:initTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdventureStageInfo:initTab()
    local vars = self.vars
    self:addTabAuto(UI_AdventureStageInfo.REWARD, vars, vars['dropListNode'])
    self:addTabAuto(UI_AdventureStageInfo.ENEMY, vars, vars['monsterListNode'])
    self:setTab(UI_AdventureStageInfo.REWARD)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureStageInfo:initButton()
    local vars = self.vars
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)

    if (game_mode == GAME_MODE_ADVENTURE) then
        vars['starButton']:registerScriptTapHandler(function() self:click_starButton() end)
    else
        vars['starButton']:setVisible(false)
        vars['bossSprite']:setPositionY(0)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureStageInfo:refresh()
    local vars = self.vars
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

    do -- 스테이지 이름
        local stage_name = g_stageData:getStageName(stage_id)
        vars['titleLabel']:setString(stage_name)

        local string_width = vars['titleLabel']:getStringWidth()
        local pos_x = -(string_width / 2)
        vars['difficultyLabel']:setPositionX(pos_x - 10)
    end

    do -- 모험 소비 활동력
        if (stage_id == DEV_STAGE_ID) then
            self.vars['actingPowerLabel']:setString('0')
        else
            local table_drop = TABLE:get('drop')
            local t_drop = table_drop[stage_id]
            local cost_value = t_drop['cost_value']
            self.vars['actingPowerLabel']:setString(cost_value)
        end 
    end

    -- 모험 소비 활동력 핫타임 관련
    if (game_mode == GAME_MODE_ADVENTURE) then
        local active, value = g_hotTimeData:getActiveHotTimeInfo_stamina()
        if active then
            local table_drop = TABLE:get('drop')
            local t_drop = table_drop[stage_id]
            local cost_value = math_floor(t_drop['cost_value'] / 2)
            vars['actingPowerLabel']:setString(cost_value)
            vars['actingPowerLabel']:setTextColor(cc.c4b(0, 255, 255, 255))
            vars['hotTimeSprite']:setVisible(true)
            vars['hotTimeStLabel']:setString('1/2')
            vars['staminaNode']:setVisible(false)
        else
            vars['actingPowerLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
            vars['hotTimeSprite']:setVisible(false)
            vars['staminaNode']:setVisible(true)
        end
    end

    local table_stage_desc = TableStageDesc()
    
    if (not table_stage_desc:get(stage_id)) then
        return
    end

    do -- 스테이지 설명
        local desc = table_stage_desc:getStageDesc(stage_id)

        -- 지정된 설명이 없을 경우 랜덤한 모험모드 설명을 출력
        if (not desc) or (desc == '') then
            desc = TableLoadingGuide:getRandomStageGuid()
        end
        vars['dscLabel']:setString(desc)
    end

    do -- 스테이지 버프 설명
        local desc = TableStageData():getValue(stage_id, 't_help')
        if (desc and desc ~= '') then
            vars['popupNode']:setContentSize(self.m_orgWidth, 450)
            vars['buffLabel']:setVisible(true)
            vars['buffLabel']:setString(desc)
        else
            vars['popupNode']:setContentSize(self.m_orgWidth, self.m_orgHeight)
            vars['buffLabel']:setVisible(false)
        end
    end

    -- 스테이조 난이도 뱃지
    self:refresh_difficultyBadge()


    do -- 이전, 다음 버튼
        local prev_stage = g_stageData:getSimplePrevStage(stage_id)
        vars['prevBtn']:setVisible(prev_stage ~= nil)

        local next_stage = g_stageData:getSimpleNextStage(stage_id)
        vars['nextBtn']:setVisible(next_stage ~= nil)
    end

    -- 획득한 별 표시
    if (game_mode == GAME_MODE_ADVENTURE) then
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        -- 깜짝 출현 챕터
        if (chapter == SPECIAL_CHAPTER.ADVENT) then
            vars['starButton']:setVisible(false)
        else
            local stage_info = g_adventureData:getStageInfo(stage_id)
            local num_of_stars = stage_info:getNumberOfStars()

            for i=1, 3 do
                local visible = stage_info['mission_' .. i]
                vars['starSprite' .. i]:setVisible(visible)
            end

            if (num_of_stars < 3) then
                vars['starButton']:setAutoShake(true)
            else
                vars['starButton']:setAutoShake(false)
            end
        end
    end

    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local vars = self.vars
        local type = TableDrop:getStageStaminaType(self.m_stageID)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:removeAllChildren()
        vars['staminaNode']:addChild(icon)
    end

    do -- 보스 스테이지
        local is_boss_stage, monster_id = g_stageData:isBossStage(stage_id)
        vars['bossSprite']:setVisible(is_boss_stage)
        vars['bossNode']:setVisible(true)

        vars['bossNode']:removeAllChildren()

        -- 1.1.4 엔진 업데이트 분기처리
        --if (not IS_QA_SERVER() and not isWin32() and getAppVerNum() < 1001004) then
        if (false) then
            -- 고대 유적 보스의 경우 스파인 캐쉬를 날림
            if (game_mode == GAME_MODE_ANCIENT_RUIN) then
                sp.SkeletonAnimation:removeCache('res/character/monster/boss_ancient_all/boss_ancient_all.json')
            end
        end

        if (monster_id) then
            local res, attr, evolution = TableMonster:getMonsterRes(monster_id)
            local animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
            animator:changeAni('idle', true)
            animator:setScale(0.8)
            vars['bossNode']:addChild(animator.m_node)
            
            -- 보석 거대용 보스
            if isExistValue(monster_id, 135031) then
                animator:setScale(0.5)
                animator:setPositionX(150)

            -- 거목 던전 보스
            elseif isExistValue(monster_id, 135021, 135022, 135023, 135024, 135025) then
                animator:setScale(0.7)
                animator:setPositionX(-50)

            -- 악몽 던전 보스
            elseif isExistValue(monster_id, 136011, 136012, 136013, 136014, 136015, 136021, 136022, 136023, 136024, 136025) then
                animator:setScale(0.7)
                animator:setPositionX(-50)

            -- 고대 유적 던전 보스
            elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
                animator:setScale(0.5)

            -- 룬 수호자 던전 보스
            elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
                animator:setScale(0.7)

            end

            do -- 보스 이름, 속성 아이콘
                -- 이름
                local name = TableMonster:getMonsterName(monster_id)
                vars['bossNameLabel']:setString(name)

                -- 속성
                local attr = TableMonster:getMonsterAttr(monster_id)
                vars['bossAttrNode']:removeAllChildren()
                local icon = IconHelper:getAttributeIconButton(attr)
                vars['bossAttrNode']:addChild(icon)

                -- 위치 조정
                local str_width = vars['bossNameLabel']:getStringWidth() + 5
                local w, h = vars['bossAttrNode']:getNormalSize() + 5

                local total_width = (str_width + w)
                local start_x = -(total_width / 2)

                vars['bossAttrNode']:setPositionX(start_x + (w/2))
                vars['bossNameLabel']:setPositionX(start_x + w + (str_width/2))
            end
        end
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
        vars['difficultyLabel']:setVisible(false)

    -- 기타 모드(170118기준으로 네스트 던전이 해당)
    else
        vars['difficultyLabel']:setVisible(true)

        local difficulty, chapter, stage = parseAdventureID(stage_id)

        if (difficulty == 1) then
            vars['difficultyLabel']:setColor(COLOR['diff_normal'])
            vars['difficultyLabel']:setString(Str('보통'))

        elseif (difficulty == 2) then
            vars['difficultyLabel']:setColor(COLOR['diff_hard'])
            vars['difficultyLabel']:setString(Str('어려움'))

        elseif (difficulty == 3) then
            vars['difficultyLabel']:setColor(COLOR['diff_hell'])
            vars['difficultyLabel']:setString(Str('지옥'))
        elseif (difficulty == 4) then
            vars['difficultyLabel']:setColor(COLOR['diff_hellfire'])
            vars['difficultyLabel']:setString(Str('불지옥'))
        end
    end
end

-------------------------------------
-- function refresh_monsterList
-------------------------------------
function UI_AdventureStageInfo:refresh_monsterList()
    local node = self.vars['monsterListNode']
    node:removeAllChildren()

    local stage_id = self.m_stageID

    local function make_func(data)
        local ui = UI_MonsterCard(data)
        ui:setStageID(stage_id)
        return ui
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.6)
    end

    -- stage_id로 몬스터 아이콘 리스트
    local l_item_list = g_stageData:getMonsterIDList(stage_id)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(94, 98)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
end

-------------------------------------
-- function refresh_rewardInfo
-- @brief 획득 가능 보상
-------------------------------------
function UI_AdventureStageInfo:refresh_rewardInfo()
    local node = self.vars['dropListNode']
    node:removeAllChildren()


    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.6)
    end

    -- stage_id로 드랍정보를 얻어옴
    local stage_id = self.m_stageID
    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()


    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(94, 98)
    table_view:setCellUIClass(UI_ItemCard, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
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

        if (game_mode == GAME_MODE_CLAN_RAID) then
            local stage_name = 'stage_' .. stage_id
            local scene = SceneGameClanRaid(nil, stage_id, stage_name, true)
            scene:runScene()
        else
            local ui = UI_ReadySceneNew(stage_id)
            ui:setCloseCB(close_cb)
        end
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_tabBtn
-- @brief '획득 가능 보상', '출현 정보'
-------------------------------------
function UI_AdventureStageInfo:onChangeTab(tab, first)
    if (not first) and (self.m_currTab == tab_type) then
        return
    end

    self.m_currTab = tab
    if (self.m_currTab == UI_AdventureStageInfo.REWARD) then
        if (not self.m_bInitItemTableView) then
            self:refresh_rewardInfo()
            self.m_bInitItemTableView = true
        end

    elseif (self.m_currTab == UI_AdventureStageInfo.ENEMY) then
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
-- function click_starButton
-- @brief
-------------------------------------
function UI_AdventureStageInfo:click_starButton()
    local vars = self.vars
    vars['starButton']:setAutoShake(false)

    local stage_id = self.m_stageID

    local ui = UI_AdventureStageMissionInfo(stage_id)

    local function close_cb()
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local num_of_stars = stage_info:getNumberOfStars()

        if (num_of_stars < 3) then
            vars['starButton']:setAutoShake(true)
        else
            vars['starButton']:setAutoShake(false)
        end
    end
    ui:setCloseCB(close_cb)
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
    self:onChangeTab(self.m_currTab, true)
end



--@CHECK
UI:checkCompileError(UI_AdventureStageInfo)
