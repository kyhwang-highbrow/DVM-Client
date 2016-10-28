--[[
    새로운 컨트롤을 개발하지 않고 테이블뷰를 활용하는 이유
    (아래의 사항들을 깔끔하게 구현하기에 시간이 많이 필요하기때문...)
    0. 스크롤 영역 클리핑 노드 처리 기능
    1. 스크롤되었을 때 화면 밖으로 나간 버튼의 클릭을 막는 기능
    2. 스크롤과 버튼 클릭 동시 처리 관련 이슈 (setSwallowTouch)
    3. 화면에 보여지는 컨트롤을 실시간으로 생성하는 이슈
--]]

--[[
    추가기능
    1. 정렬 기능 추가
--]]

-------------------------------------
-- class TableViewExtension
-- @brief 부모 노드를 전달 받아서 노드의 크기만한 테이블뷰를 생성
-------------------------------------
TableViewExtension = class({
        m_parentNode = 'cc.Node',
        m_tableViewTD = 'cc.TableView',
        m_lItem = 'list',
        m_mapItem = 'table',
        m_lSortInfo = 'table', -- {name = sort_func}
        m_currSortType = 'string',
     })

TableViewExtension.HORIZONTAL = 0
TableViewExtension.VERTICAL = 1

-------------------------------------
-- function init
-------------------------------------
function TableViewExtension:init(parent_node, direction)
    self.m_parentNode = parent_node

    -- 테이블 뷰 생성
    local content_size = parent_node:getContentSize()
    self:makeTableViewTD(content_size, direction)

    -- 부모노드의 이벤트 핸들러로 cleanup함수 호출
    self.m_parentNode:registerScriptHandler(function(event)
            if (event == 'cleanup') then
                self:cleanup()
            end
        end)

    do -- 정렬
        self.m_lSortInfo = {}
        self.m_currSortType = nil
    end
end

-------------------------------------
-- function makeTableViewTD
-------------------------------------
function TableViewExtension:makeTableViewTD(size, direction)
    direction = direction or TableViewExtension.HORIZONTAL
    
    -- 테이블뷰 노드 생성
    local tableView = cc.TableView:create(size)
    local node = TableViewTD.create(tableView)
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    -- 기본을 true로 설정함
    node:setBounceable(true)

    -- 방향성 지정
    node:setDirection(direction) -- 0=HORIZONTAL, 1=VERTICAL 가로인지 세로인지 여부
    if (direction == TableViewExtension.VERTICAL) then
        node:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) -- 위에서부터 정렬 (cc.TABLEVIEW_FILL_TOPDOWN, cc.TABLEVIEW_FILL_BOTTOMUP)
    end
    
    -- 엔진 cpp단에서 사용하는 함수(무조건 호출해야함)
    node:setDelegate()

    self.m_parentNode:addChild(node)
    self.m_tableViewTD = node
end

-------------------------------------
-- function setCellInfo
-- @brief 심플하게 사용 (가로, 세로만 넣도록)
-------------------------------------
function TableViewExtension:setCellInfo(width, height)
    local nItemPerCell = 1
    local cellSize = cc.size(width, height)
    local itemSize = nil
    local gapSize = nil
    local bUseEachSize = false

    self.m_tableViewTD:setCellInfo(nItemPerCell, cellSize, itemSize, gapSize, bUseEachSize)
end

-------------------------------------
-- function setCellInfo2
-- @brief
-------------------------------------
function TableViewExtension:setCellInfo2(nItemPerCell, cell_width, cell_height, item_width, item_height)
    local nItemPerCell = nItemPerCell or 1
    local cellSize = cc.size(cell_width, cell_height)
    local itemSize = cc.size(item_width, item_height)
    local gapSize = nil
    local bUseEachSize = false

    self.m_tableViewTD:setCellInfo(nItemPerCell, cellSize, itemSize, gapSize, bUseEachSize)
end

-------------------------------------
-- function setItemInfo
-- @breif 리스트에 출력할 테이블을 설정
--        key값은 고유한 데이터여야 한다
-------------------------------------
function TableViewExtension:setItemInfo(l_list)
    self:cleanup()

    self.m_lItem = {}
    self.m_mapItem = {}

    for key,value in pairs(l_list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = value
        table.insert(self.m_lItem, t_item)

        -- 맵에 등록(즉각적으로 찾기 위해)
        if self.m_mapItem[key] then
            error('key : ' .. key)
        end
        self.m_mapItem[key] = t_item
    end

    self.m_tableViewTD:setItemInfo(self.m_lItem)
end

-------------------------------------
-- function setCreateUIFunc
-------------------------------------
function TableViewExtension:setCreateUIFunc(create_ui_func)
    local items = {}
    local touchCellFunc = nil
    self.m_tableViewTD:setItemInfo(items, create_ui_func, touchCellFunc)
end

-------------------------------------
-- function setItemUIClass
-- @brief
-------------------------------------
function TableViewExtension:setItemUIClass(item_class, click_cb, create_func)

    local function create_ui_func(t_param)
        local ui = t_param['item']['ui']

        -- UI가 없을 경우 최초로 생성
        if (not ui) then
            local data = t_param['item']['data']
            ui = item_class(data)
            ui.root:setAnchorPoint(cc.p(0, 0))
            ui.root:setPosition(t_param['itemPos']['x'], t_param['itemPos']['y'])
            
            --cclog('######## new')

            if ui.vars['clickBtn'] then
                ui.vars['clickBtn']:setVisible(true)
                ui.vars['clickBtn']:setEnabled(true)

                local function tap_handler()
                    if click_cb then
                        click_cb(t_param['item'])
                    end
                end
                ui.vars['clickBtn']:registerScriptTapHandler(tap_handler)
            end

            ui.root:setSwallowTouch(false)
            if ui.vars['root'] then
                ui.vars['root']:setSwallowTouch(false)
            end
            ui.root:retain() -- cleanup함수에서 release
            t_param['item']['ui'] = ui
        else
            --cclog('######## old')
        end
        
        if (ui.root:getParent()) then
            ui.root:removeFromParent()
        end
        t_param['cell']:addChild(ui.root)

        if create_func then
            create_func(t_param['item'])
        end
    end

    self:setCreateUIFunc(create_ui_func)
end

-------------------------------------
-- function update
-- @brief 갱신(reload 기능)
-------------------------------------
function TableViewExtension:update()
    self.m_tableViewTD:update()
end

-------------------------------------
-- function insertSortInfo
-- @brief
-------------------------------------
function TableViewExtension:insertSortInfo(sort_type, sort_func)
    self.m_lSortInfo[sort_type] = sort_func
end

-------------------------------------
-- function sortTableView
-- @brief
-------------------------------------
function TableViewExtension:sortTableView(sort_type)
    if (self.m_currSortType == sort_type) then
        return
    end

    self.m_currSortType = sort_type

    local sort_func = self.m_lSortInfo[sort_type]
    table.sort(self.m_lItem, sort_func)

    self:update()
end

-------------------------------------
-- function cleanup
-- @brief 부모노드가 cleanup될 때 retain을 걸었던 ui들을 release
-------------------------------------
function TableViewExtension:cleanup()
    if (not self.m_lItem) then
        return
    end

    for _,v in pairs(self.m_lItem) do
        if v['ui'] then
            v['ui'].root:release()
            v['ui'] = nil
        end
    end
end