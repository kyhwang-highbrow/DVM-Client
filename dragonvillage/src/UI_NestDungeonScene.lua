local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_NestDungeonScene
-------------------------------------
UI_NestDungeonScene = class(PARENT, {
        m_tableView = 'UIC_TableView', -- 네스트 던전의 세부 모드들 리스트
        m_selectNestDungeonInfo = 'table', -- 현재 선택된 세부 모드
        m_bDirtyDungeonList = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonScene:init(stage_id)
    local vars = self:load('nest_dungeon_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_NestDungeonScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI(stage_id)
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_NestDungeonScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_NestDungeonScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('네스트 던전')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDungeonScene:initUI(stage_id)
    local vars = self.vars

    do -- 테이블 뷰 생성
        local node = vars['tableViewNode']
        node:removeAllChildren()

        -- 셀 아이템 생성 콜백
        local function create_func(ui, data)
            ui.vars['enterButton']:registerScriptTapHandler(function() self:click_dungeonBtn(ui, data) end)
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(380, 660)
        table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
        table_view:setCellUIClass(UI_NestDungeonListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        table_view:setItemList(g_nestDungeonData:getNestDungeonListForUI())

        -- 정렬
        local function sort_func(a, b) 
            if a['data']['is_open'] > b['data']['is_open'] then
                return true
            elseif a['data']['is_open'] < b['data']['is_open'] then
                return false
            end

            return a['data']['mode_id'] < b['data']['mode_id']
        end
        table.sort(table_view.m_itemList, sort_func)
        

        self.m_tableView = table_view
    end

    -- focus할 stage_id가 있을 경우 
    if stage_id then
        local dungeon_id = g_nestDungeonData:getDungeonIDFromStateID(stage_id)

        for i,v in pairs(self.m_tableView.m_itemList) do
            if (dungeon_id == v['data']['mode_id']) then
                local ui = self.m_tableView:getCellUI(v['unique_id'])
                self:click_dungeonBtn(ui, v['data'], v['unique_id'])

                -- 테이블 뷰에서 연출을 하기 위해 스케일이 변경된 상태 (원상복구를 위해 액션)
                local scale_to = cc.ScaleTo:create(0.5, 1)
                local action = cc.EaseInOut:create(scale_to, 2)
                ui.root:runAction(action)

                break
            end
        end
    end
end

-------------------------------------
-- function makeNestModeTableView
-- @brief 네스트 던전 모드 선택했을 때 오른쪽에 나오는 세부 리스트
-------------------------------------
function UI_NestDungeonScene:makeNestModeTableView()
    local node = self.vars['detailTableViewNode']

    local t_data = self.m_selectNestDungeonInfo['data']
    local nest_dungeon_id = t_data['mode_id']
    local stage_list = g_nestDungeonData:getNestDungeon_stageListForUI(nest_dungeon_id)


    -- 셀 아이템 생성 콜백
    local function create_func(ui, data)
        return true
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(886, 152)
    table_view:setCellUIClass(UI_NestDungeonStageListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(stage_list)

    local content_size = node:getContentSize()
    table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_x = x + content_size['width']
        ui.root:setPosition(new_x, y)

        ui:cellMoveTo(0.25, cc.p(x, y))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NestDungeonScene:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDungeonScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_NestDungeonScene:click_exitBtn()
    if self.m_selectNestDungeonInfo then
        self:closeSubMenu()
        return
    end

    local scene = SceneLobby()
    scene:runScene()
end


-------------------------------------
-- function click_dungeonBtn
-------------------------------------
function UI_NestDungeonScene:click_dungeonBtn(ui, data)
    if self.m_selectNestDungeonInfo then
        self:closeSubMenu()
        return
    end

    local node = ui.root
    local node_pos = convertToAnoterParentSpace(node, self.root)

    -- root로 옮김
    node:retain()
    node:removeFromParent()
    node:setPosition(node_pos['x'], node_pos['y'])

    self.root:addChild(node)
    node:release()

    local key = data['mode_id']
    local t_item = self.m_tableView:getItem(key)
    t_item['ui'] = nil


    local target_pos = convertToAnoterNodeSpace(node, self.vars['dungeonNode'])
    ui:cellMoveTo(0.5, target_pos)
    --ui:cellMoveTo(0.5, cc.p(210, 360))

    self.vars['tableViewNode']:setVisible(false)

    self.m_selectNestDungeonInfo = {ui=ui, key=key, data=data}

    -- 0.5초 후 실행
    self.vars['detailTableViewNode']:stopAllActions()
    cca.reserveFunc(self.vars['detailTableViewNode'], 0.25, function() self:makeNestModeTableView() end)
end

-------------------------------------
-- function closeSubMenu
-------------------------------------
function UI_NestDungeonScene:closeSubMenu()

    if (not self.m_selectNestDungeonInfo) then
        return
    end

    -- 액션 stop
    self.vars['detailTableViewNode']:stopAllActions()

    -- 스테이지 리스트 테이블 뷰 삭제
    self.vars['detailTableViewNode']:removeAllChildren()

    local ui = self.m_selectNestDungeonInfo['ui']
    local key = self.m_selectNestDungeonInfo['key']
    local t_item = self.m_tableView:getItem(key)
    self.m_selectNestDungeonInfo = nil

    local node = ui.root
    local container = self.m_tableView.m_scrollView:getContainer()
    local node_pos = convertToAnoterParentSpace(node, container)

    node:retain()
    node:removeFromParent()
    node:setPosition(node_pos['x'], node_pos['y'])

    container:addChild(node, 100 - t_item['idx'])
    node:release()
    
    t_item['ui'] = ui
    local data = t_item['data']

    self.m_tableView:setDirtyItemList()

    self.vars['tableViewNode']:setVisible(true)


    for i,v in ipairs(self.m_tableView.m_itemList) do
        if (v['unique_id'] ~= key) then
            
            if v['ui'] then
                v['ui'].root:setScale(0)
                local scale_to = cc.ScaleTo:create(0.25, 1)
                local action = cc.EaseInOut:create(scale_to, 2)
                local sequence = cc.Sequence:create(cc.DelayTime:create(0.3 + (i-1) * 0.02), action)
                v['ui'].root:runAction(sequence)
            end
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_NestDungeonScene:update(dt)
    if (not self.root:isVisible()) then
        return
    end

    if (not self.m_bDirtyDungeonList) then

        -- 세부 모드를 선택한 경우 해당 항목만 확인
        if self.m_selectNestDungeonInfo then
            local dungeon_id = self.m_selectNestDungeonInfo['data']['mode_id']
            local t_dungeon_info = g_nestDungeonData:updateNestDungeonTimer(dungeon_id)
            if t_dungeon_info['dirty_info'] then
                self.m_bDirtyDungeonList = true
                self:refreshDungeonList()
            end
        else
            -- 세부 모드를 선택하지 않았을 경우 전체를 확인
            local dirty_dungeon_list = g_nestDungeonData:checkNeedUpdateNestDungeonInfo()
            if dirty_dungeon_list then
                self.m_bDirtyDungeonList = true
                self:refreshDungeonList()
            end
        end
    end
    
end

-------------------------------------
-- function refreshDungeonList
-------------------------------------
function UI_NestDungeonScene:refreshDungeonList()
    -- 열려있는 서브 메뉴가 있을 경우 닫음
    self:closeSubMenu()

    -- 새로운 정보로 리스트뷰 새로 생성
    local function cb_func()
        self:initUI()
        self.m_bDirtyDungeonList = false

        UIManager:toastNotificationGreen(Str('네스트 던전 항목이 갱신되었습니다.'))
    end

    -- 새로운 던전 정보 요청
    g_nestDungeonData:requestNestDungeonInfo(cb_func)
end


--@CHECK
UI:checkCompileError(UI_NestDungeonScene)
