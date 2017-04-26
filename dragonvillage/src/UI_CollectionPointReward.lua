local PARENT = UI

-------------------------------------
-- class UI_CollectionPointReward
-------------------------------------
UI_CollectionPointReward = class(PARENT,{
        m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionPointReward:init()
    local vars = self:load('collection_point_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CollectionPointReward')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionPointReward:initUI()
    local vars = self.vars
    self:init_tableView()

    do -- 콜랙션 포인트 임시 초기값
        vars['titleLabel']:setString(Str(g_collectionData:getTamerTitle()))
        vars['collectionPointLabel']:setString(comma_value(g_collectionData:getCollectionPoint()))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionPointReward:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionPointReward:refresh()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_CollectionPointReward:init_tableView()
    local node = self.vars['rewardListNode']
    --node:removeAllChildren()

    local l_item_list = g_collectionData:getCollectionPointList()

    local function finish_cb(ret)
        self.m_tableView:refreshAllItemUI()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_rewardBtn()
            g_collectionData:request_collectionPointReward(data['req_point'], finish_cb)
        end
        ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(246 + 10, 364)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setCellUIClass(UI_CollectionPointRewardListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 기본 아이템 제거
    table_view:delItem(0)

    -- 정렬
    table.sort(table_view.m_itemList, function(a, b)
            local a_data = a['data']
            local b_data = b['data']

            local a_value = a_data['req_point']
            local b_value = b_data['req_point']

            return a_value < b_value
        end)

    self.m_tableView = table_view
end

--@CHECK
UI:checkCompileError(UI_CollectionPointReward)
