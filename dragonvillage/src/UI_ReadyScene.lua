local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ReadyScene
-------------------------------------
UI_ReadyScene = class(PARENT,{
        m_stageID = 'number',
        m_tableViewExt = 'TableViewExtension',

        -- UI_ReadyScene_Deck 관련 변수
        m_readySceneDeck = 'UI_ReadyScene_Deck',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ReadyScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ReadyScene'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh에서 스테이지명 설정
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init_MemberVariable
-------------------------------------
function UI_ReadyScene:init_MemberVariable(stage_id)
    self.m_stageID = stage_id
end

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene:init(stage_id)
    self:init_MemberVariable(stage_id)

    local vars = self:load('ready_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ReadyScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_readySceneDeck = UI_ReadyScene_Deck(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadyScene:initUI()
    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadyScene:initButton()
    local vars = self.vars
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadyScene:refresh()
    local stage_id = self.m_stageID
    local vars = self.vars

    do -- 스테이지 이름
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        local chapter_name = chapterName(chapter)
        local str = chapter_name .. Str(' {1}-{2}', chapter, stage)
        self.m_titleStr = str
        g_topUserInfo:setTitleString(str)
    end

    do -- 필요 활동력 표시
        if (stage_id == 99999) then
            self.vars['actingPowerLabel']:setString('0')
        else
            local table_drop = TABLE:get('drop')
            local t_drop = table_drop[stage_id]

            -- 'stamina' 추후에 타입별 stamina 사용 예정
            -- local cost_type = t_drop['cost_type']
            local cost_value = t_drop['cost_value']

            vars['actingPowerLabel']:setString(cost_value)
        end
    end
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_ReadyScene:init_dragonTableView()
    local list_table_node = self.vars['listView']

    local function create_func(item)
        local ui = item['ui']
        local data = item['data']
        ui.root:setScale(0.9)

        local unique_id = data['id']
        self:refresh_dragonCard(unique_id)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        local ui = item['ui']
        local t_dragon_data = ui.m_dragonData
        self:click_dragonCard(t_dragon_data)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.VERTICAL)
    table_view_ext:setCellInfo2(4, 516, 130, 130, 130)
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(g_dragonsData:getDragonsList())
    --table_view_ext:update()

    self.m_tableViewExt = table_view_ext

    table_view_ext:insertSortInfo('normal', T_DRAGON_SORT['normal'])
    table_view_ext:insertSortInfo('lv', T_DRAGON_SORT['lv'])
    table_view_ext:sortTableView('normal')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ReadyScene:click_exitBtn()
    local function next_func()
        self:close()
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadyScene:click_dragonCard(t_dragon_data)
    self.m_readySceneDeck:click_dragonCard(t_dragon_data)
end

-------------------------------------
-- function isSettedDragon
-------------------------------------
function UI_ReadyScene:isSettedDragon(unique_id)
    if (not self.m_lDeckDragonCard) then
        return false
    end

    for i,v in pairs(self.m_lDeckDragonCard) do
        if (v.m_dragonData['id'] == unique_id) then
            return i
        end
    end

    return false
end

-------------------------------------
-- function click_startBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_startBtn()
    local stage_id = self.m_stageID

    -- @TEST
    --stage_id = 99999

    -- 개발 스테이지
    if (stage_id == 99999) then
        local scene = SceneGame(stage_id, 'stage_dev', true)
        scene:runScene()
        return
    end

    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed('최소 1명 이상은 출전시켜야 합니다.')

    elseif (not g_adventureData:isOpenStage(stage_id)) then
        MakeSimplePopup(POPUP_TYPE.OK, '{@BLACK}' .. Str('이전 스테이지를 클리어하세요.'))

        -- 날개 소모 임시로 skip(서버 연동에서 다시 부활)
--    elseif (not g_userDataOld:useStamina(self.m_staminaType, self.m_staminaValue)) then
--        MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup)
            
    else
        local function next_func()
            local stage_name = 'stage_' .. stage_id
            local scene = SceneGame(stage_id, stage_name, false)
            scene:runScene()
        end

        self:checkChangeDeck(next_func)
    end
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_ReadyScene:refresh_dragonCard(doid)
    if (not self.m_readySceneDeck) then
        return
    end

    self.m_readySceneDeck:refresh_dragonCard(doid)
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadyScene:checkChangeDeck(next_func)
    return self.m_readySceneDeck:checkChangeDeck(next_func)
end

-------------------------------------
-- function getDragonCount
-------------------------------------
function UI_ReadyScene:getDragonCount()
    return self.m_readySceneDeck:getDragonCount()
end

-------------------------------------
-- function close
-------------------------------------
function UI_ReadyScene:close()
    UI.close(self)
end

--@CHECK
UI:checkCompileError(UI_ReadyScene)
