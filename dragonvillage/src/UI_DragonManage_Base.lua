local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonManage_Base
-------------------------------------
UI_DragonManage_Base = class(PARENT,{
        m_selectDragonData = 'table',           -- 선택된 드래곤의 유저 데이터
        m_selectDragonOID = 'number',           -- 선택된 드래곤의 dragon object id
        m_tableViewExt = 'TableViewExtension',  -- 하단의 드래곤 리스트 테이블 뷰
        m_dragonSelectFrame = 'sprite',         -- 선택된 드래곤의 카드에 표시
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
        self.m_dragonSelectFrame:retain()
        self.m_dragonSelectFrame:removeFromParent()
    end

    -- 테이블뷰에서 선택된 드래곤의 카드를 가져옴
    local dragon_object_id = self.m_selectDragonOID
    local t_item = self.m_tableViewExt.m_mapItem[dragon_object_id]
    local ui = t_item['ui']

    -- addChild 후 액션 실행(깜빡임)
    if ui then
        ui.root:addChild(self.m_dragonSelectFrame)
        self.m_dragonSelectFrame:stopAllActions()
        self.m_dragonSelectFrame:setOpacity(255)
        self.m_dragonSelectFrame:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
        self.m_dragonSelectFrame:release()
        return
    end

    self.m_dragonSelectFrame:release()
    self.m_dragonSelectFrame = nil
end

-------------------------------------
-- function setDefaultSelectDragon
-- @brief 지정된 드래곤이 없을 경우 기본 드래곤을 설정
-------------------------------------
function UI_DragonManage_Base:setDefaultSelectDragon()
    local item = self.m_tableViewExt.m_lItem[1]

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
    local item = self.m_tableViewExt.m_mapItem[dragon_object_id]

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
-------------------------------------
function UI_DragonManage_Base:init_dragonTableView()
    local list_table_node = self.vars['listTableNode']
    list_table_node:removeAllChildren()

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(0.7)

        local data = item['data']
        if (self.m_selectDragonOID == data['id']) then
            self:changeDragonSelectFrame()
        end
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        local data = item['data']
        local dragon_object_id = data['id']
        self:setSelectDragonData(dragon_object_id)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node)
    table_view_ext:setCellInfo(105, 105)
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    --table_view_ext:setItemInfo(g_dragonListData.m_lDragonList)
    table_view_ext:setItemInfo(g_dragonsData:getDragonsList())
    table_view_ext:update()

    -- 정렬
    local function default_sort_func(a, b)
        local a = a['data']
        local b = b['data']

        return a['did'] < b['did']
    end
    table_view_ext:insertSortInfo('default', default_sort_func)

    table_view_ext:sortTableView('default')

    self.m_tableViewExt = table_view_ext
end

--@CHECK
UI:checkCompileError(UI_DragonManage_Base)
