local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_HatcheryCombinePopup
-------------------------------------
UI_HatcheryCombinePopup = class(PARENT,{
        m_bDirty = 'boolean',
        m_dragonID = 'number',
        m_tableViewTD = 'UIC_TableViewTD',
        m_selectedDragonCard = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_HatcheryCombinePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_HatcheryCombinePopup'
    self.m_bVisible = true or false
    self.m_titleStr = Str('조합') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryCombinePopup:init(did)
    self.m_bDirty = false
    self.m_dragonID = did

    local vars = self:load('hatchery_combine_02.ui')
    UIManager:open(self, UIManager.SCENE, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_HatcheryCombinePopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcheryCombinePopup:initUI()
    local vars = self.vars

    self:init_TableView()

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = MakeBirthDragonCard(self.m_dragonID)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 이름
        local name = TableDragon:getDragonName(self.m_dragonID)
        vars['dragonNameLabel']:setString(name)
    end

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[self.m_dragonID]

    do -- 드래곤 속성
        local attr = t_dragon['attr']
        local icon = IconHelper:getAttributeIconButton(attr)
        vars['attrNode']:addChild(icon)
        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할
        local role_type = t_dragon['role']
        local icon = IconHelper:getRoleIconButton(role_type)
        vars['typeNode']:addChild(icon)
        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
    end

    do -- 드래곤 희귀도
        local rarity = t_dragon['rarity']
        local icon = IconHelper:getRarityIconButton(rarity)
        vars['rarityNode']:addChild(icon)
        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do
        local table_dragon_combine = TableDragonCombine()
        local t_dragon_combine = table_dragon_combine:get(self.m_dragonID)

        local req_grade = t_dragon_combine['material_grade']
        local req_grade_max_lv = TableGradeInfo:getMaxLv(req_grade)
        local req_evolution = t_dragon_combine['material_evolution']

        -- 재료 조건 설명
        local msg = Str('{1}성 최대 레벨(Lv.{2}) 이상, {3} 이상', req_grade, req_grade_max_lv, evolutionName(req_evolution))
        vars['descLabel']:setString(msg)

        -- 가격 표시
        vars['priceLabel']:setString(comma_value(t_dragon_combine['req_gold']))

        -- 재표 보유 현황 정보
        local _, _, l_satisfy = g_hatcheryData:combineMaterialInfo(self.m_dragonID)

        self.m_selectedDragonCard = {}
        for i=1, 4 do
            local _did = t_dragon_combine['material_' .. i]
            local t_data = {}
            t_data['did'] = _did
            t_data['grade'] = req_grade
            t_data['lv'] = req_grade_max_lv
            t_data['evolution'] = req_evolution
            local dragon_card = MakeSimpleDragonCard(_did, t_data)
            vars['mtrlBG' .. i]:addChild(dragon_card.root)
            dragon_card.root:setScale(86/150)

            -- 재료가 조건을 충족하지 않을 경우 음영처리
            if (not l_satisfy[_did]) then
                dragon_card:setShadowSpriteVisible(true)
            end

            -- 재료 카드 클릭 시
            dragon_card.vars['clickBtn']:registerScriptTapHandler(function()
				UI_BookDetailPopup.open(_did, t_data['grade'], t_data['evolution'])
            end)

            self.m_selectedDragonCard[_did] = {['idx']=i}
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HatcheryCombinePopup:initButton()
    local vars = self.vars
    vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HatcheryCombinePopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_HatcheryCombinePopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_HatcheryCombinePopup:init_TableView()
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)

        -- 재료로 사용 불가능한 경우
        if (not self:checkMaterial(data)) then
            ui:setShadowSpriteVisible(true)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(ui, data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100 + 10, 100 + 10)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('조건에 해당하는 드래곤이 없습니다.'))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    table_view_td:setItemList(l_dragon_list)


    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        -- did로 정렬
        if (a_data['did'] ~= b_data['did']) then
            return a_data['did'] < b_data['did']
        end

        -- grade로 정렬
        if (a_data['grade'] ~= b_data['grade']) then
            return a_data['grade'] > b_data['grade']
        end

        -- lv로 정렬
        if (a_data['lv'] ~= b_data['lv']) then
            return a_data['lv'] > b_data['lv']
        end

        -- evolution으로 정렬
        --if (a_data['evolution'] ~= b_data['evolution']) then
            return a_data['evolution'] > b_data['evolution']
        --end
    end
    table.sort(table_view_td.m_itemList, sort_func)
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_HatcheryCombinePopup:getDragonList()
    local did = self.m_dragonID
    local t_ret = g_hatcheryData:combineMaterialList(did)

    return t_ret
end

-------------------------------------
-- function checkMaterial
-------------------------------------
function UI_HatcheryCombinePopup:checkMaterial(struct_dragon_obj)

    local table_dragon_combine = TableDragonCombine()
    local t_dragon_combine = table_dragon_combine:get(self.m_dragonID)

    local req_grade = t_dragon_combine['material_grade']
    local req_grade_max_lv = TableGradeInfo:getMaxLv(req_grade)
    local req_evolution = t_dragon_combine['material_evolution']

    local v = struct_dragon_obj
    local satisfy = false
    local doid = v['id']
    local msg = nil

    -- 재료 드래곤으로 사용 가능한지 여부 : 리더나 잠금 상태를 제외한다
    local _possible, _msg = g_dragonsData:possibleMaterialDragon(doid)

    if (_possible == false) then
        msg = _msg
    elseif (v:getGrade() < req_grade) then
        -- 등급이 낮아서 불충족
    elseif (v:getGrade() == req_grade) and (v:getLv() < req_grade_max_lv) then
        -- 최대 레벨이 낮아서 불충족 (필요 등급의 max레벨이거나 등급 자체가 더 높아야함)
    elseif (v:getEvolution() < req_evolution) then
        -- 진화도가 낮아서 불충족
    else
        satisfy = true
    end

    return satisfy, msg
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_HatcheryCombinePopup:click_dragonCard(ui, data)

    local table_dragon_combine = TableDragonCombine()
    local t_dragon_combine = table_dragon_combine:get(self.m_dragonID)

    local req_grade = t_dragon_combine['material_grade']
    local req_grade_max_lv = TableGradeInfo:getMaxLv(req_grade)
    local req_evolution = t_dragon_combine['material_evolution']

    local v = data
    local satisfy, msg = self:checkMaterial(data)

    if (not satisfy) then
        local msg = msg or Str('재료는 {1}성 최대 레벨(Lv.{2}) 이상, {3} 이상이어야 합니다.', req_grade, req_grade_max_lv, evolutionName(req_evolution))
        UIManager:toastNotificationRed(msg)
        return
    end

    local did = data['did']
    local t_data = self.m_selectedDragonCard[did]
    -- 선택된 드래곤이 해제되는 경우
    if t_data and t_data['dragon_obj'] and t_data['dragon_obj']['id'] == data['id'] then
        self:setlectMtrlCard(ui, data)
    -- 선택된 드래곤이 선택 되는 경우 재료 드래곤 경고 확인
    else
        local function next_func()
            self:setlectMtrlCard(ui, data)
        end
        local oid = data['id']
        local t_warning = {}
        t_warning['grade'] = (req_grade + 1)
        t_warning['lv'] = (req_grade_max_lv + 1)
        t_warning['evolution'] = (req_evolution + 1)
		t_warning['pass_comb'] = true
        g_dragonsData:dragonMaterialWarning(oid, next_func, t_warning)
    end
end

-------------------------------------
-- function setlectMtrlCard
-------------------------------------
function UI_HatcheryCombinePopup:setlectMtrlCard(ui, data)

    local did = data['did']
    local t_data = self.m_selectedDragonCard[did]

    if t_data['selected_card'] then
        t_data['selected_card'].root:removeFromParent()
        t_data['selected_card'] = nil
    end

    if t_data['ui'] then
        t_data['ui']:setCheckSpriteVisible(false)
    end

    t_data['dragon_obj'] = nil

    if (t_data['ui'] == ui) then
        t_data['ui'] = nil
        self.vars['mtrlBG' .. t_data['idx']]:setVisible(true)
        return
    end

    t_data['dragon_obj'] = data

    t_data['ui'] = ui 
    t_data['ui']:setCheckSpriteVisible(true)

    local dragon_card = UI_DragonCard(data)
    dragon_card.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(ui, data) end)
    dragon_card:setCheckSpriteVisible(true)
    local scale = 86/150
    dragon_card.root:setScale(scale)
    t_data['selected_card'] = dragon_card
    self.vars['mtrlNode' .. t_data['idx']]:removeAllChildren()
    self.vars['mtrlNode' .. t_data['idx']]:addChild(dragon_card.root)
    self.vars['mtrlBG' .. t_data['idx']]:setVisible(false)

    cca.uiReactionSlow(dragon_card.root, scale, scale)
end

-------------------------------------
-- function click_combineBtn
-------------------------------------
function UI_HatcheryCombinePopup:click_combineBtn()
    local cnt = 0
    local doids = ''
    for i,v in pairs(self.m_selectedDragonCard) do
        local dragon_obj = v['dragon_obj']
        if dragon_obj then
            cnt = (cnt + 1)
            if (doids == '') then
                doids = dragon_obj['id']
            else
                doids = doids .. ',' .. dragon_obj['id']
            end
        end
    end

    if (cnt < 4) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요!'))
        return
    end

    local function ok_btn_cb()
        local function finish_cb(ret)
            self.m_bDirty = true

            -- 재료로 사용된 드래곤 삭제
            if ret['deleted_dragons_oid'] then
                for _,doid in pairs(ret['deleted_dragons_oid']) do
                    self.m_tableViewTD:delItem(doid)
                end
            end

            -- 선택된 재료들 정리
            for i,v in pairs(self.m_selectedDragonCard) do
                v['dragon_obj'] = nil
                v['ui'] = nil
                if v['selected_card'] then
                    v['selected_card'].root:removeFromParent()
                    v['selected_card'] = nil
                end
                self.vars['mtrlBG' .. v['idx']]:setVisible(true)
            end

            -- 드래곤 소환 연출
            local l_dragon_list = ret['added_dragons']
            local ui = UI_DragonAppear(StructDragonObject(l_dragon_list[1]))
        end

        local did = self.m_dragonID
        g_hatcheryData:request_dragonCombine(did, doids, finish_cb)
    end

    -- 조합 진행 여부 묻기 (재화 사용)
    local table_dragon_combine = TableDragonCombine()
    local t_dragon_combine = table_dragon_combine:get(self.m_dragonID)
    local name = TableDragon:getDragonName(self.m_dragonID)
    local msg = Str('{1} 조합을 진행하시겠습니까?', name)
    MakeSimplePopup_Confirm('gold', t_dragon_combine['req_gold'], msg, ok_btn_cb)
end

-------------------------------------
-- function isDirty
-------------------------------------
function UI_HatcheryCombinePopup:isDirty()
	return self.m_bDirty
end

--@CHECK
UI:checkCompileError(UI_HatcheryCombinePopup)
