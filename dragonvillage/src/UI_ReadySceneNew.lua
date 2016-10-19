--
-- 전투준비화면 플로우
-- 1. [스테이지 화면] (획듣 가능 보상, 적 출현 정보)
-- 2. 덱 변경(선택)
-- 3. 친구 선택
-- 전투

local l_leon_deck_idx = {}
l_leon_deck_idx[1] = 2
l_leon_deck_idx[2] = 4
l_leon_deck_idx[3] = 5
l_leon_deck_idx[4] = 6

local l_deck_ui_name = {}
l_deck_ui_name[1] = 'chNode' .. l_leon_deck_idx[1]
l_deck_ui_name[2] = 'chNode' .. l_leon_deck_idx[2]
l_deck_ui_name[3] = 'chNode' .. l_leon_deck_idx[3]
l_deck_ui_name[4] = 'chNode' .. l_leon_deck_idx[4]
l_deck_ui_name[5] = 'backupNode'

-------------------------------------
-- class UI_ReadySceneNew
-------------------------------------
UI_ReadySceneNew = class(UI, ITopUserInfo_EventListener:getCloneTable(), {
        m_cbStartButton = 'function',
        m_stageID = 'number',

        -- 스태미너 소모량
        m_staminaType = 'string',
        m_staminaValue = 'number',

        m_currDeckIdx = 'number',

        m_selectEffect = 'cc.Sprite',
        m_tableViewExt = 'TableViewExtension',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew:init(cb_start_button, stage_id)
    self.m_cbStartButton = cb_start_button

    local vars = self:load('ready_scene_02.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ReadySceneNew')

    self:doActionReset()
    self:doAction()

    self:initUI()
    self:init_dragonDeck()
    self:init_dragonTableView()

    self:changeStage(stage_id)
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_ReadySceneNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ReadySceneNew'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('모험(쉬움)')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadySceneNew:initUI()
    local vars = self.vars

    vars['rewardBtn']:setEnabled(false)
    vars['enemyInfoBtn']:setEnabled(true)

    vars['rewardBtn']:registerScriptTapHandler(function() self:message() end)
    vars['enemyInfoBtn']:registerScriptTapHandler(function() self:message() end)

    -- 자동 배치
    vars['autoBtn']:registerScriptTapHandler(function() self:message() end)
    vars['teamBtn1']:registerScriptTapHandler(function() self:message() end)
    vars['teamBtn2']:registerScriptTapHandler(function() self:message() end)
    vars['teamBtn3']:registerScriptTapHandler(function() self:message() end)
    vars['manageBtn']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')
        -- @TODO 임시로  
        -- local scene = SceneDragonManage()
        -- scene:runScene()
        UI_DragonManageScene(true)
    end)
    

    -- 스테이지 이동 버튼
    vars['stagePrevBtn']:registerScriptTapHandler(function() self:click_stagePrevBtn() end)
    vars['stageNextBtn']:registerScriptTapHandler(function() self:click_stageNextBtn() end)

    vars['friendSelectCloseBtn']:registerScriptTapHandler(function() self:click_friendSelectCloseBtn() end)
    vars['changeCloseBtn']:registerScriptTapHandler(function() self:click_changeCloseBtn() end)
    vars['changeBtn']:registerScriptTapHandler(function() self:click_changeBtn() end)
    vars['autoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)

    self.m_selectEffect = cc.Sprite:create('res/ui/dragon_card/dragon_item_select.png')
    self.m_selectEffect:setDockPoint(cc.p(0.5, 0.5))
    self.m_selectEffect:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_selectEffect:retain()
end

-------------------------------------
-- function close
-------------------------------------
function UI_ReadySceneNew:close()
    self.m_selectEffect:release()
    UI.close(self)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ReadySceneNew:click_exitBtn()

    -- 친구 선택창이 열려있을 경우 친구 선택창을 닫음
    if (self.vars['friendSelectNode']:isVisible()) then
        self.vars['friendSelectNode']:setVisible(false)
        return
    end

    -- 덱 선택창이 열려있을 경우 덱 선택창 닫음
    if (self.vars['changeNode']:isVisible()) then
        self.vars['changeNode']:setVisible(false)
        return
    end

    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:close()
end

-------------------------------------
-- function message
-------------------------------------
function UI_ReadySceneNew:message()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    UIManager:toastNotificationRed('미구현 기능입니다.')
end

-------------------------------------
-- function refreshStageAttrSynastry
-- @breif 스테이지 상성(속성) 갱신
-------------------------------------
function UI_ReadySceneNew:refreshStageAttrSynastry(stage_id)
    local vars = self.vars

    for i=1, 4 do
        vars['advNode' .. i]:removeAllChildren()
    end
    
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    -- 해당 스테이지의 속성
    local attr = t_drop['attr']

    local max_node_cnt = 4

    do -- 유리한 상성
        -- 해당 스테이지에서 나쁜 상성(몬스터 입장)
        local l_diadv_list = getAttrDisadvantageList(attr)
        
        for i=1, max_node_cnt do
            local node = vars['advNode' .. i]
            if (not node) then
                break
            end
            node:removeAllChildren()

            if l_diadv_list[i] then
                local icon = IconHelper:getAttributeIcon(l_diadv_list[i])
                node:addChild(icon)
            end
        end
    end

    --[[
    do -- 불리한 상성
        -- 해당 스테이지에서 좋은 상성(몬스터 입장)
        local l_adv_list = getAttrAdvantageList(attr)
        
        for i=1, max_node_cnt do
            local node = vars['disadvNode' .. i]
            if (not node) then
                break
            end
            node:removeAllChildren()

            if l_adv_list[i] then
                local icon = IconHelper:getAttributeIcon(l_adv_list[i])
                node:addChild(icon)
            end
        end
    end
    --]]
end

-------------------------------------
-- function setStaminaInfo
-------------------------------------
function UI_ReadySceneNew:setStaminaInfo(stage_id)

    if (stage_id == 99999) then
        self.m_staminaType = 'st_ad'
        self.m_staminaValue = 0
        self.vars['actingPowerLabel']:setString('0')
        return
    end

    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    -- 'stamina' 추후에 타입별 stamina 사용 예정
    -- local cost_type = t_drop['cost_type']
    local cost_value = t_drop['cost_value']

    self.vars['actingPowerLabel']:setString(cost_value)

    self.m_staminaType = 'st_ad'
    self.m_staminaValue = cost_value
end

-------------------------------------
-- function changeStage
-- @breif
-------------------------------------
function UI_ReadySceneNew:changeStage(stage_id)
    self.m_stageID = stage_id

    do -- 스테이지명 지정
        local vars = self.vars
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        local chapter_name = chapterName(chapter)
        vars['satgeLabel']:setString(chapter_name .. Str(' {1}-{2}', chapter, stage))
    end

    -- "획득 가능 보상" 출력
    self:refreshStageAttrSynastry(stage_id)


    do -- 획득 가능 보상 출력
        local vars = self.vars
        local drop_helper = DropHelper(stage_id)
        local l_icon = drop_helper:getDisplayItemIconList()
        for idx,icon in ipairs(l_icon) do
            vars['rewardView']:addChild(icon)
            icon:setAnchorPoint(cc.p(0, 1))
            icon:setDockPoint(cc.p(0, 1))
            icon:setScale(0.7)

            local item_per_cel = 5
            local item_width = 102
            local item_height = 102

            local idx_x = math_floor((idx-1) % item_per_cel)
            local idx_y = math_floor((idx-1) / item_per_cel)

            local pos_x = idx_x * item_width
            local pos_y = -idx_y * item_height

            icon:setPosition(pos_x, pos_y)
        end
    end

    -- 스테미나 정보 입력
    self:setStaminaInfo(stage_id)

    local difficulty, chapter, stage = parseAdventureID(stage_id)
    self.vars['stagePrevBtn']:setEnabled(1 < stage)
    self.vars['stageNextBtn']:setEnabled(stage < 8)
end

-------------------------------------
-- function click_stagePrevBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_stagePrevBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    local stage_id = self.m_stageID
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if (stage <= 1) then
        local chapter_name = chapterName(chapter)
        UIManager:toastNotificationRed(Str('"{1}"의 첫 스테이지 입니다.', chapter_name))
        return
    end

    self:changeStage(stage_id - 1)
end

-------------------------------------
-- function click_stageNextBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_stageNextBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    local stage_id = self.m_stageID
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if (stage >= 8) then
        local chapter_name = chapterName(chapter)
        UIManager:toastNotificationRed(Str('"{1}"의 마지막 스테이지 입니다.', chapter_name))
        return
    elseif (not g_adventureData:isOpenStage(stage_id + 1)) then
        UIManager:toastNotificationRed(Str('{1}스테이지를 먼저 클리어하세요!', stage))
        return
    end

    self:changeStage(stage_id + 1)
end

-------------------------------------
-- function click_friendSelectCloseBtn
-- @breif "친구 선택"창 닫기
-------------------------------------
function UI_ReadySceneNew:click_friendSelectCloseBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self.vars['friendSelectNode']:setVisible(false)
end

-------------------------------------
-- function click_changeCloseBtn
-- @breif 덱 변경창 닫기
-------------------------------------
function UI_ReadySceneNew:click_changeCloseBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self.vars['changeNode']:setVisible(false)
end

-------------------------------------
-- function click_changeBtn
-- @breif 덱 변경 버튼
-------------------------------------
function UI_ReadySceneNew:click_changeBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    local visible = self.vars['changeNode']:isVisible()

    if visible then
        self.vars['changeNode']:setVisible(false)
    else
        self.vars['changeNode']:setVisible(true)
        self.vars['friendSelectNode']:setVisible(false)
    end
end

-------------------------------------
-- function click_autoBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_autoBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')

    -- 장착된 드래곤을 해제하는 과정 (장착된 드래곤이 click_deckDragonItem 안에서 해제됨)
    for _,dragon_id in pairs(g_dragonListData.m_lDragonDeck) do
        self:click_deckDragonItem(dragon_id)
    end

    -- 챕터 정보를 얻어옴
    local stage_id = self.m_stageID
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if isExistValue(chapter, 1, 3) then
        self:click_deckDragonItem(120002) -- 파워드래곤
        self:click_deckDragonItem(120014) -- 허리케인
        self:click_deckDragonItem(120007) -- 핑크벨
        self:click_deckDragonItem(120013) -- 청룡
	elseif isExistValue(chapter, 2, 4) then 
        self:click_deckDragonItem(120002) -- 파워드래곤
        self:click_deckDragonItem(120016) -- 스파인
        self:click_deckDragonItem(120015) -- 리프드래곤
        self:click_deckDragonItem(120012) -- 리티오
	elseif (chapter == 5) then 
		self:click_deckDragonItem(120006) -- 가루다
		self:click_deckDragonItem(120001) -- 고대신룡
		self:click_deckDragonItem(120004) -- 크레센트 
		self:click_deckDragonItem(120003) -- 서펀트
	elseif (chapter == 6) then 
		self:click_deckDragonItem(120002) -- 파워드래곤
        self:click_deckDragonItem(120016) -- 스파인
        self:click_deckDragonItem(120015) -- 리프드래곤
		self:click_deckDragonItem(120011) -- 애플칙
    end

    -- 드래곤 리스트창을 띄움
    self.vars['changeNode']:setVisible(true)
    self.vars['friendSelectNode']:setVisible(false)
end

-------------------------------------
-- function click_startBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_startBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    local visible = self.vars['friendSelectNode']:isVisible()

    -- 임시로 친구선책 제외
    visible = true

    if (not visible) then
        self.vars['friendSelectNode']:setVisible(true)
        self.vars['changeNode']:setVisible(false)

    else
        local stage_id = self.m_stageID

        -- @TEST
        --stage_id = 99999

        -- 개발 스테이지
        if (stage_id == 99999) then
            local scene = SceneGame(stage_id, 'stage_dev', true)
            scene:runScene()
            return
        end

        if (not g_adventureData:isOpenStage(stage_id)) then
            MakeSimplePopup(POPUP_TYPE.OK, '{@BLACK}' .. Str('이전 스테이지를 클리어하세요.'))

        elseif (not g_userData:useStamina(self.m_staminaType, self.m_staminaValue)) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup)
            
        else
            local stage_name = 'stage_' .. stage_id
            local scene = SceneGame(stage_id, stage_name, false)
            scene:runScene()
        end
    end
end


-------------------------------------
-- function init_dragonDeck
-- @brief 1~4는 덱, 5는 대기
-------------------------------------
function UI_ReadySceneNew:init_dragonDeck()

    self.m_currDeckIdx = nil
    --@TODO 임시로 대기 막음
    for i=1, 4 do
        local ui_name = l_deck_ui_name[i]
        local node = self.vars[ui_name]
        node:removeAllChildren()

        local dragon_id = g_dragonListData.m_lDragonDeck[tostring(i)]
        if dragon_id then
            dragon_id = tonumber(dragon_id)

            local t_dragon_data = g_dragonListData:getDragon(dragon_id)
            local item = UI_Ready_DragonListItem(t_dragon_data)
            
            node:addChild(item.root)

            item.vars['clickBtn']:registerScriptTapHandler(function() self:click_deckDragonItem(dragon_id) end)
        else
            if (not self.m_currDeckIdx) then
                self.m_currDeckIdx = i
            elseif (i < self.m_currDeckIdx) then
                self.m_currDeckIdx = i
            end
        end
    end

    --
    if self.m_currDeckIdx then
        local ui_name = l_deck_ui_name[self.m_currDeckIdx]
        local node = self.vars[ui_name]
        node:addChild(self.m_selectEffect)
        self.m_selectEffect:stopAllActions()
        self.m_selectEffect:setOpacity(255)
        self.m_selectEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
    else
        self.m_selectEffect:removeFromParent()
    end
end

local function create_func(item)
    local ui = item['ui']
    local data = item['data']
    local dragon_id = data['did']
    ui.root:setScale(0.87)

    local setted, idx = g_dragonListData:isSettedDargon(dragon_id)

    if setted then
        if (not item['ready_icon']) then
            local icon = cc.Sprite:create('res/ui/dragon_card/dragon_ready_icon.png')
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            ui.root:addChild(icon)
            item['ready_icon'] = icon    
        else
            item['ready_icon']:setVisible(true)
        end
    end
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_ReadySceneNew:init_dragonTableView()
    local list_table_node = self.vars['changeTableViewNode']



    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        self:click_deckDragonItem(item['uique_id'])
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.VERTICAL)
    table_view_ext:setCellInfo2(4, 516, 130, 130, 130)
    table_view_ext:setItemUIClass(UI_Ready_DragonListItem, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(g_dragonListData.m_lDragonList)
    table_view_ext:update()

    self.m_tableViewExt = table_view_ext
end

-------------------------------------
-- function click_deckDragonItem
-- @breif 드래곤 아이콘 클릭(리스트에 있는 것과 덱에 있는 것 동일)
-------------------------------------
function UI_ReadySceneNew:click_deckDragonItem(dragon_id)
    SoundMgr:playEffect('EFFECT', 'ui_button')
    dragon_id = tostring(dragon_id)

    local setted, idx = g_dragonListData:isSettedDargon(dragon_id)

    -- 장착된 드래곤일 경우
    if setted then
        local ui_name = l_deck_ui_name[idx]
        g_dragonListData.m_lDragonDeck[tostring(idx)] = nil

        local t_item = self.m_tableViewExt.m_mapItem[tostring(dragon_id)]
        if t_item then
            if t_item['ready_icon'] then
                t_item['ready_icon']:setVisible(false)
            end
        end

        -- 드래곤 리스트를 띄움
        self.vars['changeNode']:setVisible(true)
        self.vars['friendSelectNode']:setVisible(false)
    else
        if (self.m_currDeckIdx) then
            g_dragonListData:setDeck(self.m_currDeckIdx, dragon_id)

            local t_item = self.m_tableViewExt.m_mapItem[dragon_id]

            if t_item then
                create_func(t_item)
            end
        else
            UIManager:toastNotificationRed('더 이상 출전시킬 수 없습니다.')
        end
    end

    self:init_dragonDeck()
    g_userData:setDirtyLocalSaveData()
end