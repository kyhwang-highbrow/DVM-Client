local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonManage_Base
-------------------------------------
UI_DragonManage_Base = class(PARENT,{
        m_selectDragonData = 'table',           -- 선택된 드래곤의 유저 데이터
        m_selectDragonOID = 'number',           -- 선택된 드래곤의 dragon object id
        m_tableViewExt = 'TableViewExtension',  -- 하단의 드래곤 리스트 테이블 뷰
        m_dragonSelectFrame = 'sprite',         -- 선택된 드래곤의 카드에 표시
        m_dragonSortMgr = 'DragonSortManager',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManage_Base:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManage_Base'
    self.m_bVisible = true
    self.m_titleStr = Str('드래곤 관리')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-- @brief 상속받아서 쓰는 용도
--        하위 클래스에서 init을 해야함
-------------------------------------
function UI_DragonManage_Base:init()

    -- 드래곤들의 덱설정 여부 데이터 갱신
    g_deckData:resetDragonDeckInfo()

end

-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_DragonManage_Base:init_dragonSortMgr(b_ascending_sort, sort_type)
    self.m_dragonSortMgr = DragonSortManagerCommon(self.vars, self.m_tableViewExt, b_ascending_sort, sort_type)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManage_Base:initUI()
    self:init_dragonTableView()
    self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManage_Base:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManage_Base:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManage_Base:click_exitBtn()
    self:close()
end

-------------------------------------
-- function close
-------------------------------------
function UI_DragonManage_Base:close()
    if self.m_dragonSelectFrame then
        self.m_dragonSelectFrame:release()
        self.m_dragonSelectFrame = nil
    end

    PARENT.close(self)
end

-------------------------------------
-- function setSelectDragonDataRefresh
-- @brief 선택된 드래곤의 데이터를 최신으로 갱신
-------------------------------------
function UI_DragonManage_Base:setSelectDragonDataRefresh()
    local dragon_object_id = self.m_selectDragonOID
    self.m_selectDragonData = g_dragonsData:getDragonDataFromUid(dragon_object_id)
end

-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonManage_Base:setSelectDragonData(dragon_object_id, b_force)
    if (not b_force) and (self.m_selectDragonOID == dragon_object_id) then
        return
    end

    if (not g_dragonsData:getDragonDataFromUid(dragon_object_id)) then
        return self:setDefaultSelectDragon()
    end

    if (not self:checkDragonSelect(dragon_object_id)) then
        return
    end

    -- 선택된 드래곤의 데이터를 최신으로 갱신
    self.m_selectDragonOID = dragon_object_id
    self.m_selectDragonData = g_dragonsData:getDragonDataFromUid(dragon_object_id)

    -- 선택된 드래곤 카드에 프레임 표시
    self:changeDragonSelectFrame()

    -- 선택된 드래곤이 변경되면 refresh함수를 호출
    self:refresh()
end

-------------------------------------
-- function changeDragonSelectFrame
-- @brief 선택된 드래곤 카드에 프레임 표시
-------------------------------------
function UI_DragonManage_Base:changeDragonSelectFrame()
    -- 없으면 새로 생성
    if (not self.m_dragonSelectFrame) then
        self.m_dragonSelectFrame = cc.Sprite:create('res/ui/frame/dragon_select_frame.png')
        self.m_dragonSelectFrame:setDockPoint(cc.p(0.5, 0.5))
        self.m_dragonSelectFrame:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_dragonSelectFrame:retain()
    else
    -- 있으면 부모에게서 떼어냄
        self.m_dragonSelectFrame:removeFromParent()
    end

    -- 테이블뷰에서 선택된 드래곤의 카드를 가져옴
    local dragon_object_id = self.m_selectDragonOID
    local t_item = self.m_tableViewExt.m_itemMap[dragon_object_id]
    local ui = t_item['ui']

    -- addChild 후 액션 실행(깜빡임)
    if ui then
        ui.root:addChild(self.m_dragonSelectFrame)
        self.m_dragonSelectFrame:stopAllActions()
        self.m_dragonSelectFrame:setOpacity(255)
        self.m_dragonSelectFrame:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
        return
    end
end

-------------------------------------
-- function setDefaultSelectDragon
-- @brief 지정된 드래곤이 없을 경우 기본 드래곤을 설정
-------------------------------------
function UI_DragonManage_Base:setDefaultSelectDragon(doid)
    if doid then
        local b_force = true
        self:setSelectDragonData(doid, b_force)
        return
    end

    local item = self.m_tableViewExt.m_itemList[1]

    if (item) then
        local dragon_object_id = item['data']['id']
        local b_force = true
        self:setSelectDragonData(dragon_object_id, b_force)
    end
end

-------------------------------------
-- function refresh_dragonIndivisual
-- @brief 특정 드래곤의 object_id로 갱신
-------------------------------------
function UI_DragonManage_Base:refresh_dragonIndivisual(dragon_object_id)
    local item = self.m_tableViewExt.m_itemMap[dragon_object_id]

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(dragon_object_id)

    -- 테이블뷰 리스트의 데이터 갱신
    item['data'] = t_dragon_data

    -- UI card 버튼이 있을 경우 데이터 갱신
    if item and item['ui'] then
        local ui = item['ui']
        ui.m_dragonData = t_dragon_data
        ui:refreshDragonInfo()
    end

    -- 갱신된 드래곤이 선택된 드래곤일 경우
    if (dragon_object_id == self.m_selectDragonOID) then
        self:setSelectDragonData(dragon_object_id, true)
    end
end

-------------------------------------
-- function init_dragonTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonManage_Base:init_dragonTableView()

    local skip_update = false

    if (not self.m_tableViewExt) then
        local list_table_node = self.vars['listTableNode']

        local function create_func(ui, data)
            self:createDragonCardCB(ui, data)
            ui.root:setScale(0.66)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectDragonData(data['id']) end)
        end

        local table_view = UIC_TableView(list_table_node)
        table_view.m_defaultCellSize = cc.size(100, 100)
        table_view:setCellUIClass(UI_DragonCard, create_func)
        self.m_tableViewExt = table_view

        skip_update = true
    end

    local l_item_list = g_dragonsData:getDragonsList()
    self.m_tableViewExt:setItemList(l_item_list, skip_update)
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-------------------------------------
function UI_DragonManage_Base:createDragonCardCB(ui, data)
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-------------------------------------
function UI_DragonManage_Base:checkDragonSelect(doid)
    return true
end

--@CHECK
UI:checkCompileError(UI_DragonManage_Base)