local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ReadyScene
-------------------------------------
UI_ReadyScene = class(PARENT,{
        m_stageID = 'number',
        m_lDeckDragonCard = 'UI_DragonCard',
        m_currSlotIdx = 'number',
        m_selectEffect = 'cc.Sprite',
        m_tableViewExt = 'TableViewExtension',
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

    local vars = self:load('ready_scene_new.ui')
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadyScene:initUI()
    self:init_dragonTableView()

    self.m_selectEffect = cc.Sprite:create('res/ui/dragon_card/dragon_item_select.png')
    self.m_selectEffect:setDockPoint(cc.p(0.5, 0.5))
    self.m_selectEffect:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_selectEffect:retain()
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

    self:refresh_deck()
end

-------------------------------------
-- function refresh_deck
-- @breif 설정된 덱 리프레시
-------------------------------------
function UI_ReadyScene:refresh_deck()

    -- 남아있는 UI 삭제
    if self.m_lDeckDragonCard then
        for i,v in pairs(self.m_lDeckDragonCard) do
            v.root:removeFromParent()
        end
    end
    self.m_lDeckDragonCard = {}


    local l_deck = g_deckData:getDeck('1')

    for i,v in pairs(l_deck) do
        local unique_id = v
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(unique_id)
        if t_dragon_data then
            self:makeSettedDragonCard(t_dragon_data, i)
        end
    end

    self:refresh_currSlotIdx()
end

-------------------------------------
-- function makeSettedDragonCard
-- @breif
-------------------------------------
function UI_ReadyScene:makeSettedDragonCard(t_dragon_data, idx)
    local ui = UI_DragonCard(t_dragon_data)

    self.vars['chNode' .. idx]:addChild(ui.root)

    self.m_lDeckDragonCard[idx] = ui

    ui.vars['clickBtn']:registerScriptTapHandler(function()
        self:click_dragonCard(t_dragon_data)
    end)

    -- 장착된 드래곤
    self:refresh_dragonCard(true, t_dragon_data['id'])
end

-------------------------------------
-- function refresh_currSlotIdx
-- @breif 빈슬롯중 낮은 슬롯
-------------------------------------
function UI_ReadyScene:refresh_currSlotIdx()
    self.m_currSlotIdx = nil

    for i=1, 5 do
        if (self.m_lDeckDragonCard[i] == nil) then
            self.m_currSlotIdx = i
            break
        end
    end

    self.m_selectEffect:removeFromParent()
    if self.m_currSlotIdx then
        local node = self.vars['chNode' .. self.m_currSlotIdx]
        if node then
            node:addChild(self.m_selectEffect)
            self.m_selectEffect:stopAllActions()
            self.m_selectEffect:setOpacity(255)
            self.m_selectEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
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
        local deck_idx = self:isSettedDragon(unique_id)
        self:refresh_dragonCard(deck_idx, unique_id)
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
    local unique_id = t_dragon_data['id']

    local deck_idx = self:isSettedDragon(unique_id)

    -- 설정된 드래곤일 경우 해제
    if deck_idx then
        self.m_lDeckDragonCard[deck_idx].root:removeFromParent()
        self.m_lDeckDragonCard[deck_idx] = nil
        self:refresh_currSlotIdx()

        -- 체크표 해제
        self:refresh_dragonCard(false, unique_id)
        return
    end

    -- 장착 가능한 슬롯이 있을 경우
    if self.m_currSlotIdx then
        self:makeSettedDragonCard(t_dragon_data, self.m_currSlotIdx)
        self:refresh_currSlotIdx()
        return
    end

    UIManager:toastNotificationRed('더 이상 출전시킬 수 없습니다.')
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

    if (table.count(self.m_lDeckDragonCard) <= 0) then
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
function UI_ReadyScene:refresh_dragonCard(is_setted, unique_id)
    local item = self.m_tableViewExt.m_mapItem[unique_id]

    if (not item) then
        return
    end

    local ui = item['ui']

    if (not ui) then
        return
    end

    if is_setted then
        if (not item['ready_icon']) then
            local icon = cc.Sprite:create('res/ui/dragon_card/dragon_ready_icon.png')
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            ui.root:addChild(icon)
            item['ready_icon'] = icon    
        else
            item['ready_icon']:setVisible(true)
        end
    else
        if item['ready_icon'] then
            item['ready_icon']:setVisible(false)
        end
    end
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadyScene:checkChangeDeck(next_func)
    local l_deck = g_deckData:getDeck('1')

    local b_change = false

    for i=1, 5 do
        if (l_deck[i] and (not self.m_lDeckDragonCard[i])) then
            b_change = true
            break
        end

        if l_deck[i] and (l_deck[i] ~= self.m_lDeckDragonCard[i].m_dragonData['id']) then
            b_change = true
            break
        end

        if (not l_deck[i] and (self.m_lDeckDragonCard[i])) then
            b_change = true
            break
        end
    end

    if (b_change) then
        local uid = g_userData:get('uid')

        local function success_cb(ret)
            if ret['deck'] then
                g_serverData:applyServerData(ret['deck'], 'deck')
            end
            next_func()
        end

        local ui_network = UI_Network()
        ui_network:setUrl('/users/set_deck')
        ui_network:setHmac(false)
        ui_network:setRevocable(true)
        ui_network:setParam('uid', uid)
        ui_network:setParam('deckno', 1)
        ui_network:setParam('edid1', self.m_lDeckDragonCard[1] and self.m_lDeckDragonCard[1].m_dragonData['id'] or nil)
        ui_network:setParam('edid2', self.m_lDeckDragonCard[2] and self.m_lDeckDragonCard[2].m_dragonData['id'] or nil)
        ui_network:setParam('edid3', self.m_lDeckDragonCard[3] and self.m_lDeckDragonCard[3].m_dragonData['id'] or nil)
        ui_network:setParam('edid4', self.m_lDeckDragonCard[4] and self.m_lDeckDragonCard[4].m_dragonData['id'] or nil)
        ui_network:setParam('edid5', self.m_lDeckDragonCard[5] and self.m_lDeckDragonCard[5].m_dragonData['id'] or nil)
        ui_network:setSuccessCB(success_cb)
        ui_network:request()
    else
        next_func()
    end
end

-------------------------------------
-- function close
-------------------------------------
function UI_ReadyScene:close()
    self.m_selectEffect:release()
    UI.close(self)
end

--@CHECK
UI:checkCompileError(UI_ReadyScene)
