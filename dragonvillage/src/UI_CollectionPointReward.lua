local PARENT = UI

-------------------------------------
-- class UI_CollectionPointReward
-------------------------------------
UI_CollectionPointReward = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionPointReward:init()
    local vars = self:load('collection_point_reward.ui')
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
    self:init_tableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionPointReward:initButton()
    local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
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

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_func()
            self:click_requestBtn(data)
        end

        ui.vars['requestBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(564, 108)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendRecommendUserListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('추천 친구가 없습니다.'))

    --[[
    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
    --]]

    self.m_tableView = table_view
end

--@CHECK
UI:checkCompileError(UI_CollectionPointReward)
