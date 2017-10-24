local PARENT = UI_Package

-------------------------------------
-- class UI_Package_LevelUp
-------------------------------------
UI_Package_LevelUp = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUp:init(package_name, is_popup)
    --[[
    local vars = self:load(string.format('%s.ui', package_name))
    self.m_data = TablePackageBundle:getDataWithName(package_name) 
    self.m_pids = TablePackageBundle:getPidsWithName(package_name) 
    self.m_isPopup = is_popup or false

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Bundle')
    end

    self:initUI()
	self:initButton()
    self:refresh()
    --]]
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_LevelUp:refresh()
    PARENT.refresh(self)

    cclog('### UI_Package_LevelUp:refresh()')
    self:init_tableView()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_Package_LevelUp:init_tableView()
    local vars = self.vars
    vars['productNode']:removeAllChildren()
    local node = vars['productNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 80+5)
    table_view:setCellUIClass(UI_Package_LevelUpListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)


    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    --local struct_subscribed_info = self:getSubscribedInfo()
    --local l_item_list = struct_subscribed_info:getDayRewardInfoList()
    local l_item_list = {1,2,3,4,5,6}
    table_view:setItemList(l_item_list)

    --[[
    -- 오늘 날짜로 이동
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    local idx = struct_subscribed_info['cur_day']
    table_view:relocateContainerFromIndex(idx, false)
    --]]
end