local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_NestDungeonScene
-------------------------------------
UI_NestDungeonScene = class(PARENT, {
        m_tableView = 'UIC_TableView', -- 네스트 던전의 세부 모드들 리스트
        m_selectNestDungeonInfo = 'table', -- 현재 선택된 세부 모드
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonScene:init()
    local vars = self:load('nest_dungeon_scene1.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_NestDungeonScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
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
function UI_NestDungeonScene:initUI()
    local vars = self.vars

    do -- 테이블 뷰 생성
        local node = vars['tableViewNode']

        -- 셀 아이템 생성 콜백
        local function create_func(ui, data, key)
            ui.root:setLocalZOrder(100 - key)
            ui.vars['enterButton']:registerScriptTapHandler(function() self:click_dungeonBtn(ui, data, key) end)
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(380, 670)
        table_view:setCellUIClass(UI_NestDragonDungeonListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        table_view:setItemList(g_nestDungeonData:getNestDungeonInfo())

        self.m_tableView = table_view
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
    local stage_list = g_nestDungeonData:getNestDungeonInfo_stageList(nest_dungeon_id)


    -- 셀 아이템 생성 콜백
    local function create_func(ui, data, key)
        --ui.root:setLocalZOrder(100 - key)
        --ui.vars['enterButton']:registerScriptTapHandler(function() self:click_dungeonBtn(ui, data, key) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(853, 152)
    table_view:setCellUIClass(UI_NestDragonStageListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(stage_list, false, true)

    --ccdump(stage_list)
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
function UI_NestDungeonScene:click_dungeonBtn(ui, data, key)
    if self.m_selectNestDungeonInfo then
        self:closeSubMenu()
        return
    end

    local node = ui.root

    local x, y = node:getPosition()
    local world_pos = node:getParent():convertToWorldSpace(cc.p(x, y))

    local node_pos = self.root:convertToNodeSpace(world_pos)


    -- root로 옮김
    node:retain()
    node:removeFromParent()
    node:setPosition(node_pos['x'], node_pos['y'])

    self.root:addChild(node)
    node:release()

    local t_item = self.m_tableView:getItem(key)
    t_item['ui'] = nil

    ui:cellMoveTo(0.5, cc.p(210, 360))

    self.vars['tableViewNode']:setVisible(false)

    self.m_selectNestDungeonInfo = {ui=ui, key=key, data=data}


    self:makeNestModeTableView()
end

-------------------------------------
-- function closeSubMenu
-------------------------------------
function UI_NestDungeonScene:closeSubMenu()

    if (not self.m_selectNestDungeonInfo) then
        return
    end

    -- 스테이지 리스트 테이블 뷰 삭제
    self.vars['detailTableViewNode']:removeAllChildren()

    local ui = self.m_selectNestDungeonInfo['ui']
    local key = self.m_selectNestDungeonInfo['key']
    local t_item = self.m_tableView:getItem(key)
    self.m_selectNestDungeonInfo = nil


    local node = ui.root

    local x, y = node:getPosition()
    local world_pos = node:getParent():convertToWorldSpace(cc.p(x, y))

    local container = self.m_tableView.m_scrollView:getContainer()
    local node_pos = container:convertToNodeSpace(world_pos)

    node:retain()
    node:removeFromParent()
    node:setPosition(node_pos['x'], node_pos['y'])

    container:addChild(node, 100 - t_item['idx'])
    node:release()
    
    t_item['ui'] = ui
    local data = t_item['data']

    self.m_tableView:expandTemp(0.5)

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


--@CHECK
UI:checkCompileError(UI_NestDungeonScene)
