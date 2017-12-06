local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcheryRelationTab
-------------------------------------
UI_HatcheryRelationTab = class(PARENT,{
        m_sortManagerDragon = 'SortManager_Dragon',
        m_uicSortList = 'UIC_SortList',
        m_tableViewTD = 'UIC_TableViewTD',
        m_selectedDid = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryRelationTab:init(owner_ui)
    local vars = self:load('hatchery_relation.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcheryRelationTab:onEnterTab(first)
    if (not self.m_selectedDid) then
        self.m_ownerUI:showNpc() -- NPC 등장
    else
        self.m_ownerUI:hideNpc() -- NPC 퇴장
    end

    if first then
        self:initButton()
        self:init_TableView()
        self:init_dragonSortMgr()

        -- 첫 아이템 클릭
        local t_item = self.m_tableViewTD.m_itemList[1]
        if t_item and t_item['data'] and t_item['data']['did'] then
            local did = t_item['data']['did']
            self:click_dragonCard(did)
        else
            self:refresh()
        end
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryRelationTab:onExitTab()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_HatcheryRelationTab:init_TableView()
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
        
        -- 선택되어있는 아이템일 경우
        if (self.m_selectedDid == data['did']) then
            ui:setSelected(true)
        end
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(128 + 12, 166 + 12)
    table_view_td.m_nItemPerCell = 4
    table_view_td:setCellUIClass(UI_HatcheryRelationItem, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str(''))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    table_view_td:setItemList(l_dragon_list)
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_HatcheryRelationTab:getDragonList()
    local table_dragon = TableDragon()

    local function condition_func(t_table)
        if (not t_table['relation_point']) then
            return false
        end
        
        local relation_point = tonumber(t_table['relation_point'])
        if (not relation_point) then
            return false
        end

        if (relation_point <= 0) then
            return false
        end

        local did = t_table['did']
        local cur_rpoint = g_bookData:getRelationPoint(did)
        if (cur_rpoint <= 0) then
            return false
        end

        return true
    end

    local l_dragon_list = table_dragon:filterTable_condition(condition_func)

    local t_ret = {}
    for i,v in pairs(l_dragon_list) do
        local t_data = {}
        t_data['did'] = v['did']
        t_data['grade'] = v['birthgrade']
        t_ret[i] = StructDragonObject(t_data)
    end

    return t_ret
end

-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_HatcheryRelationTab:init_dragonSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
        --self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
            self.m_sortManagerDragon:setAllAscending(ascending)
            self:apply_dragonSort()
            --self:save_dragonSortInfo()

            vars['sortSelectOrderSprite']:stopAllActions()
            if ascending then
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 세이브데이터에 있는 정렬 값을 적용
    --self:apply_dragonSort_saveData()
    self:apply_dragonSort()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_HatcheryRelationTab:apply_dragonSort()
    local list = self.m_tableViewTD.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_tableViewTD:setDirtyItemList()
end

-------------------------------------
-- function click_dragonCard
-- @brief
-------------------------------------
function UI_HatcheryRelationTab:click_dragonCard(did)
    if self.m_selectedDid then
        local t_item = self.m_tableViewTD:getItem(self.m_selectedDid)
        if (t_item and t_item['ui']) then
            t_item['ui']:setSelected(false)
        end
    end

    self.m_selectedDid = did
    if self.m_selectedDid then
        local t_item = self.m_tableViewTD:getItem(self.m_selectedDid)
        if (t_item and t_item['ui']) then
            t_item['ui']:setSelected(true)
        end
    end

    self:refresh()
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_HatcheryRelationTab:refresh()
    local vars = self.vars

    if (not self.m_selectedDid) then
        vars['leftNode']:setVisible(false)
        vars['emptySprite']:setVisible(true)
        self.m_ownerUI:showNpc() -- NPC 등장
        return
    else
        vars['leftNode']:setVisible(true)
        vars['emptySprite']:setVisible(false)
        self.m_ownerUI:hideNpc() -- NPC 퇴장
    end

    local t_item = self.m_tableViewTD:getItem(self.m_selectedDid)
    if (not t_item) or (not t_item['data']) then
        return
    end

    local struct_dragon_object = t_item['data']

    -- 드래곤 실리소스
    if vars['dragonNode'] then
        vars['dragonNode']:removeAllChildren()
        local animator = ServerData_Dragons:makeDragonAnimator(struct_dragon_object)
        vars['dragonNode']:addChild(animator.m_node)
    end

    do -- 희귀도
        local rarity = struct_dragon_object:getRarity()
        vars['rarityNode']:removeAllChildren()
        local icon = IconHelper:getRarityIcon(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do -- 드래곤 속성
        local attr = struct_dragon_object:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = struct_dragon_object:getRole()
        vars['typeNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(role_type)
        vars['typeNode']:addChild(icon)

        vars['typeLabel']:setString(dragonRoleName(role_type))
    end

    -- 드래곤 이름
    if vars['dragonNameLabel'] then
        vars['dragonNameLabel']:setString(struct_dragon_object:getDragonNameWithEclv())
    end

    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_icon = IconHelper:getDragonGradeIcon(struct_dragon_object, 2)
        vars['starNode']:addChild(star_icon)
    end
	
	do -- 드래곤 소환 비용
		local birth = struct_dragon_object:getBirthGrade()
		local price = math_pow(2, birth - 2) * 100000
		vars['priceLabel']:setString(comma_value(price))
	end
end

-------------------------------------
-- function initButton
-- @brief
-------------------------------------
function UI_HatcheryRelationTab:initButton()
    local vars = self.vars
    vars['summonBtn']:registerScriptTapHandler(function() self:click_summonBtn() end)
end

-------------------------------------
-- function click_summonBtn
-- @brief
-------------------------------------
function UI_HatcheryRelationTab:click_summonBtn()
    local did = self.m_selectedDid

    if (not did) then
        UIManager:toastNotificationRed(Str('드래곤을 선택하세요.'))
        return
    end

    -- 인연포인트 값 얻어오기
    local req_rpoint = TableDragon():getRelationPoint(did)
    local cur_rpoint = g_bookData:getRelationPoint(did)
    if (cur_rpoint < req_rpoint) then
        UIManager:toastNotificationRed(Str('인연포인트가 부족합니다.'))
        return
    end

    -- 드래곤 최대치 보유가 넘었는지 체크
    local summon_cnt = 1
    if (not g_dragonsData:checkDragonSummonMaximum(summon_cnt)) then
        return
    end


    local function finish_cb(ret)
        local added_dragons = {}
        if (ret['dragon']) then
            added_dragons = {ret['dragon']}
        end

        if (table.count(added_dragons) > 0) then
            -- 드래곤 등장 연출
            UI_DragonAppear(StructDragonObject(added_dragons[1]))
        end

        -- 리스트 아이템 갱신
        local t_item = self.m_tableViewTD:getItem(self.m_selectedDid)
        local cur_rpoint = g_bookData:getRelationPoint(self.m_selectedDid)
        if (0 < cur_rpoint) then
            if t_item and t_item['ui'] then
                t_item['ui']:refresh()
            end
        else
            self.m_tableViewTD:delItem(self.m_selectedDid)
            self:click_dragonCard(nil)

            -- 첫 아이템 클릭
            local t_item = self.m_tableViewTD.m_itemList[1]
            if t_item and t_item['data'] and t_item['data']['did'] then
                local did = t_item['data']['did']
                self:click_dragonCard(did)
            end
        end

        -- 하일라이트 노티 갱신을 위해 호출
        self.m_ownerUI:refresh_highlight()
    end

    g_bookData:request_useRelationPoint(did, finish_cb)
end