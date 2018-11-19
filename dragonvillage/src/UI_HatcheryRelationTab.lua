local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_HatcheryRelationTab
-------------------------------------
UI_HatcheryRelationTab = class(PARENT,{
        m_uicSortList = 'UIC_SortList',
        m_tableViewTD = 'UIC_TableViewTD',
        m_selectedDid = '',
        m_selectedRarity = '',
    })

-- 탭 자동 등록을 위해 UI 네이밍과 맞춰줌  
UI_HatcheryRelationTab['LEGEND'] = 'legend'
UI_HatcheryRelationTab['HERO'] = 'hero'
UI_HatcheryRelationTab['RARE'] = 'rare'
UI_HatcheryRelationTab['COMMON'] = 'common'

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
        self:initTab()
        self:init_TableView()
        
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

    local table_dragon = TableDragon()

    -- 리스트 아이템 생성 콜백
    local function make_func(data)
        local did = data['did']
        local t_dragon = table_dragon:exists(did) and table_dragon:get(did) or nil
        -- 존재하지 않는 드래곤 빈 UI
        if (not t_dragon) then
            return UI_DragonReinforceItem('empty')
        end
        -- test 드래곤 빈 UI
        if (not g_dragonsData:isReleasedDragon(t_dragon['did'])) then
            return UI_DragonReinforceItem('empty')
        end
        return UI_HatcheryRelationItem(data)
    end

    local function create_func(ui, data)
        local did = data['did']
        if (not table_dragon:exists(did)) then
            return
        end

        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
        
        -- 선택되어있는 아이템일 경우
        if (self.m_selectedDid == data['did']) then
            ui:setSelected(true)
        end
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(105 + 8, 135 + 8)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(make_func, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str(''))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    table_view_td:setItemList(l_dragon_list)

    -- did와 속성으로 정렬 (더미 데이터가 있으므로 sortmanager 사용하지 않음)
    table.sort(table_view_td.m_itemList, function(a, b)
        local a_data = a['data']
        local b_data = b['data']

        local a_did = getDigit(a_data['did'], 10, 5)
        local b_did = getDigit(b_data['did'], 10, 5)

        -- 없는 드래곤까지 임시로 생성한 케이스라 한자리수로 비교
        local a_attr = a_data['did'] % 10
        local b_attr = b_data['did'] % 10

        -- 같을 경우 리턴 속성순으로
        if (a_did == b_did) then
            return a_attr < b_attr
        end

        return a_did > b_did
    end)
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_HatcheryRelationTab:getDragonList()
    local rarity = self.m_selectedRarity
    if (not rarity) then
        return
    end

    local table_dragon = TableDragon()

    -- 모든 속성이 테스트인 경우 리스트에서 제외
    local function check_all_test(did)
        local is_all_test = true
        local check_id = getDigit(did, 10, 5)
        for i = 1, 5 do
            local _did = check_id * 10 + i
            local t_dragon = table_dragon:exists(_did) and table_dragon:get(_did) or nil
            if (t_dragon and g_dragonsData:isReleasedDragon(t_dragon['did'])) then
                is_all_test = false
                break
            end
        end

        return is_all_test
    end

    local function condition_func(t_table)
        if (t_table['rarity'] ~= rarity) then
            return false
        end
        -- 인연 포인트 값 없을 경우 제외
        if (not t_table['relation_point']) then
            return false
        end
        -- 자코 제외
        local is_undering = (t_table['underling'] == 1)
        if (is_undering) then
            return false
        end

        local is_all_test = check_all_test(t_table['did'])
        if (is_all_test) then
            return false
        end
        
        return true
    end

    local l_dragon_list = table_dragon:filterTable_condition(condition_func)
    local l_dragon_list_for_ui = {}
    for i,v in pairs(l_dragon_list) do
        l_dragon_list_for_ui[i] = v
    end

    local t_check = {}
    for i,v in pairs(l_dragon_list) do
        local check_id = getDigit(v['did'], 10, 5)
        if (not t_check[check_id]) then
            t_check[check_id] = true
            -- 없는 속성도 테이블 뷰에 표시하기 위해 속성 검사후 임의로 데이터 넣어줌
            for _i = 1, 5 do
                local _did = check_id * 10 + _i
                if (not table_dragon:exists(_did)) then
                    l_dragon_list_for_ui[_did] = {did = _did, birthgrade = 1}
                end
            end
        end
    end
    
    local t_ret = {}
    for i,v in pairs(l_dragon_list_for_ui) do
        local t_data = {}
        t_data['did'] = v['did']
        t_data['grade'] = v['birthgrade']
        t_ret[i] = StructDragonObject(t_data)
    end

    return t_ret
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_HatcheryRelationTab:apply_dragonSort()
    local list = self.m_tableViewTD.m_itemList
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

        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
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
		local price = self:getPrice()
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
-- function initTab
-- @brief
-------------------------------------
function UI_HatcheryRelationTab:initTab()
    local vars = self.vars
    self:addTabAuto(UI_HatcheryRelationTab['LEGEND'], vars)
    self:addTabAuto(UI_HatcheryRelationTab['HERO'], vars)
    self:addTabAuto(UI_HatcheryRelationTab['RARE'], vars)
    self:addTabAuto(UI_HatcheryRelationTab['COMMON'], vars)
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)

    self:setTab(UI_HatcheryRelationTab['LEGEND'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_HatcheryRelationTab:onChangeTab(tab, first)
    self.m_selectedRarity = tab
    self:init_TableView()
end

-------------------------------------
-- function getPrice
-- @brief
-------------------------------------
function UI_HatcheryRelationTab:getPrice()
	local t_item = self.m_tableViewTD:getItem(self.m_selectedDid)
    if (not t_item) or (not t_item['data']) then
        return
    end

    local struct_dragon_object = t_item['data']

	local birth = struct_dragon_object:getBirthGrade()
	local price = math_pow(2, birth - 2) * 100000
	return price
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
        if t_item and t_item['ui'] then
            t_item['ui']:refresh()
        end

        -- 하일라이트 노티 갱신을 위해 호출
        self.m_ownerUI:refresh_highlight()
    end

	local function request_func()
		g_bookData:request_useRelationPoint(did, finish_cb)
	end
	local price = self:getPrice()
	MakeSimplePopup_Confirm('gold', price, Str('소환하시겠습니까?'), request_func)
end