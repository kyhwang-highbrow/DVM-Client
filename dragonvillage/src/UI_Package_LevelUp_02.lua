local PARENT = UI_Package_LevelUp

-------------------------------------
-- class UI_Package_LevelUp_02
-------------------------------------
UI_Package_LevelUp_02 = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUp_02:init(struct_product, is_popup)
end

-------------------------------------
-- function initUISetting
-------------------------------------
function UI_Package_LevelUp_02:initUISetting()
    local vars = self:load('package_levelup_02.ui')
    if (self.m_isPopup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_LevelUp')
    end

    self:initUI()
	self:initButton(self.m_isPopup)
    self:refresh()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_Package_LevelUp_02:init_tableView()
    local vars = self.vars
    vars['productNode']:removeAllChildren()
    vars['productNodeLong']:removeAllChildren()

    local node = vars['productNode']
    if g_levelUpPackageData:isActive() then
        node = vars['productNodeLong']
        vars['productNode']:setVisible(false)
        vars['productNodeLong']:setVisible(true)
    else
        vars['productNode']:setVisible(true)
        vars['productNodeLong']:setVisible(false)
    end

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
        --ccdump(data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 80+5)
    table_view:setCellUIClass(UI_Package_LevelUpListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)


    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_item_list = TABLE:get('table_package_levelup_02')
    table_view:setItemList(l_item_list)

    do -- 정렬
        local function sort_func(a, b)
            local a_value = a['data']['level']
            local b_value = b['data']['level']
            return a_value < b_value
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    -- 보상 받기 가능한 idx로 이동
    local lv, idx = g_levelUpPackageData:getFocusRewardLevel()
    if lv then
        table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        table_view:relocateContainerFromIndex(idx, false)
    end
end