local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

local MAX_RUNE_ENCHANT_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_RuneEnchantPopup
-------------------------------------
UI_RuneEnchantPopup = class(PARENT, {
        m_tRuneData = 'table',
        m_tableViewMaterials = 'UIC_TableViewTD',
        m_tableViewSelectedMaterials = 'UIC_TableView',

        -- 정렬
        m_sortManagerRune = 'SortManagerRune', -- 룬 정렬 도우미
        m_bAscending = 'boolean', -- 오름차순 여부

        m_runeEnchantHelper = 'RuneEnchantHelper',

        m_bDirtyRuneData = 'boolean', -- 강화를 시도하여 정보가 변경되었는지 여ㅂ
        m_lDeletedRuneRoid = 'list', -- 재료로 사용되어 삭제된 룬 리스트
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneEnchantPopup:init(t_rune_data)
    local roid = t_rune_data['id']
    local with_set_data = true
    self.m_tRuneData = g_runesData:getRuneData(roid, with_set_data)

    self.m_runeEnchantHelper = RuneEnchantHelper(self.m_tRuneData)
    self.m_bDirtyRuneData = false
    self.m_lDeletedRuneRoid = {}

    local vars = self:load('dragon_rune_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneEnchantPopup')

    self:sceneFadeInAction()

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RuneEnchantPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneEnchantPopup'
    self.m_bVisible = true
    self.m_titleStr = Str('룬 강화')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RuneEnchantPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneEnchantPopup:initUI()
    self:init_runeEnchantMaterials()
    self:init_runeEnchantSelectedMaterials()

    -- 정렬
    self.m_bAscending = true
    local sort_manager = SortManager_Rune()
    sort_manager:pushSortOrder('set_color')
    sort_manager:pushSortOrder('lv')
    sort_manager:pushSortOrder('grade')
    self.m_sortManagerRune = sort_manager
    self:tableViewSortAndRefresh()

    local vars = self.vars
    vars['enhanceGauge']:setVisible(true)
    vars['enhanceGauge']:setPercentage(0)
end

-------------------------------------
-- function init_runeEnchantMaterials
-------------------------------------
function UI_RuneEnchantPopup:init_runeEnchantMaterials()
    local roid = self.m_tRuneData['id']
    local node = self.vars['selectListNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)
        
        local function click_func()
            local t_rune_data = data
            self:click_enchantMaterial(t_rune_data)
        end
        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    local skip_update = true -- 정렬 후 업데이트하기 위해
    table_view_td:setItemList(g_runesData:getRuneEnchantMaterials(roid), skip_update)

    self.m_tableViewMaterials = table_view_td
end

-------------------------------------
-- function init_runeEnchantSelectedMaterials
-------------------------------------
function UI_RuneEnchantPopup:init_runeEnchantSelectedMaterials()
    local node = self.vars['materialNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.6)
        
        local function click_func()
            local t_rune_data = data
            self:click_enchantMaterial(t_rune_data)
        end
        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블뷰 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(90, 90)
    table_view:setCellUIClass(UI_RuneCard, create_func)
    table_view:setItemList({})

    self.m_tableViewSelectedMaterials = table_view
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneEnchantPopup:initButton()
    local vars = self.vars
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
    vars['sortSelectBtn']:setVisible(false)
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function() self:setAscending(not self.m_bAscending) end)
end

-------------------------------------
-- function setAscending
-------------------------------------
function UI_RuneEnchantPopup:setAscending(ascending)
    self.m_bAscending = ascending

    local vars = self.vars

    if ascending then
        vars['sortSelectOrderSprite']:setScaleY(-1)
    else
        vars['sortSelectOrderSprite']:setScaleY(1)
    end
   
    -- 내부 슬롯별 탭 정렬
    self:tableViewSortAndRefresh()
end

-------------------------------------
-- function refresh
-- @brief dragon_id로 드래곤의 상세 정보를 출력
-------------------------------------
function UI_RuneEnchantPopup:refresh()
    local vars = self.vars

    t_rune_data = self.m_tRuneData

    local t_rune_information = t_rune_data['information']

    do -- 룬 아이콘 표시
        vars['runeNode']:removeAllChildren()
        local rid = t_rune_data['rid']
        local count = 1
        local icon = UI_ItemCard(rid, count, t_rune_information)
        vars['runeNode']:addChild(icon.root)
    end

    -- 룬 이름
    vars['runeNameLabel']:setString(t_rune_information['full_name'])

    local str

    -- 메인 옵션
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'], 'category')
    vars['mainOptionLabel']:setString(str)
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'], 'value')
    vars['mainOptionStatusLabel']:setString(str)

    -- 다음 레벨의 메인 옵션
    if t_rune_information['is_max_lv'] then
        vars['mainOptionStatusUpLabel']:setString('')
    else 
        local next_lv_t_rune_data = clone(t_rune_data)
        next_lv_t_rune_data['lv'] = (next_lv_t_rune_data['lv'] + 1)
        local l_next_lv_rune_status = ServerData_Runes:makeRuneStatus(next_lv_t_rune_data)
        str = TableRuneStatus:makeRuneOptionStr(l_next_lv_rune_status['mopt'], 'next_value')
        vars['mainOptionStatusUpLabel']:setString(str)
    end

    -- 서브 옵션
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'], 'category')
    vars['subOptionLabel']:setString(str)
    str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'], 'value')
    vars['subOptionStatusLabel']:setString(str)

    -- 세트 효과
    local t_rune_set = t_rune_data['rune_set']
    if t_rune_set then
        vars['runeSetLabel']:setVisible(true)
        local str = TableRuneStatus:makeRuneSetOptionStr(t_rune_set)
        vars['runeSetLabel']:setString(str)
    else
        vars['runeSetLabel']:setVisible(false)
    end

    self:refresh_selectedMaterials()
end

-------------------------------------
-- function refresh_selectedMaterials
-- @brief
-------------------------------------
function UI_RuneEnchantPopup:refresh_selectedMaterials()
    local vars = self.vars
    local material_count = self.m_tableViewSelectedMaterials:getItemCount()
    vars['selectLabel']:setVisible(true)
    vars['selectLabel']:setString(Str('선택재료 {1} / {2}', material_count, MAX_RUNE_ENCHANT_MATERIAL_MAX))

    -- 재료 분석
    local l_rune_material = {}
    for i,v in ipairs(self.m_tableViewSelectedMaterials.m_itemList) do
        local t_rune_data = v['data']
        table.insert(l_rune_material, t_rune_data)
    end

    -- 갯수에 따라 설명 출력
    if (material_count <= 0) then
        vars['infoLabel1']:setVisible(true)
        vars['infoLabel2']:setVisible(true)
    else
        vars['infoLabel1']:setVisible(false)
        vars['infoLabel2']:setVisible(false)
    end

    do -- 강화 비용 출력
        local req_gold = comma_value(self.m_runeEnchantHelper.m_enchantReqGold)
        vars['enhancePriceLabel']:setString(req_gold)
    end

    do -- 경험치
        local grade = t_rune_data['grade']
        local lv = t_rune_data['lv']
        local max_exp = TableRuneExp:getReqExp(grade, lv)

        local exp = t_rune_data['exp'] + self.m_runeEnchantHelper.m_exp
        local percentage = math_floor((exp / max_exp) * 100)
        percentage = math_clamp(percentage, 0, 100)

        vars['enhanceExpLabel']:setString(Str('강화 경험치 {1}%', percentage))
        vars['enhanceGauge']:stopAllActions()
        vars['enhanceGauge']:runAction(cc.ProgressTo:create(0.3, percentage)) 
    end
end

-------------------------------------
-- function click_enchantMaterial
-- @brief 룬 강화 재료 클릭
-------------------------------------
function UI_RuneEnchantPopup:click_enchantMaterial(t_rune_data)
    local roid = t_rune_data['id']

    local material_item = self.m_tableViewMaterials:getItem(roid)
    local item = self.m_tableViewSelectedMaterials:getItem(roid)

    -- 해제
    if item then
        material_item['ui'].vars['disableSprite']:setVisible(false)
        self.m_tableViewSelectedMaterials:delItem(roid)

        -- 해제
        self.m_runeEnchantHelper:removeRuneEnchantMaterial(roid)

    -- 추가
    else
        -- 선택된 재료 갯수
        local material_count = self.m_tableViewSelectedMaterials:getItemCount()

        -- 최대 재료 갯수 체크
        if (material_count >= MAX_RUNE_ENCHANT_MATERIAL_MAX) then
            UIManager:toastNotificationRed(Str('한 번에 최대 {1}개까지 가능합니다.', MAX_RUNE_ENCHANT_MATERIAL_MAX))
            return
        end

        -- 추가
        self.m_runeEnchantHelper:addRuneEnchantMaterial(t_rune_data)

        material_item['ui'].vars['disableSprite']:setVisible(true)
        self.m_tableViewSelectedMaterials:addItem(roid, t_rune_data)
        self.m_tableViewSelectedMaterials:expandTemp(0.5)
    end

    self:tableViewSortAndRefresh()
    self:refresh_selectedMaterials()
end

-------------------------------------
-- function click_enhanceBtn
-- @brief
-------------------------------------
function UI_RuneEnchantPopup:click_enhanceBtn()
    if (self.m_runeEnchantHelper.m_materialCnt <= 0) then
        UIManager:toastNotificationRed(Str('재료 룬을 선택해주세요!'))
        return
    end

    local function cb_func(ret)
        -- 강화를 시도하여 정보가 갱신되었음
        self.m_bDirtyRuneData = true

        -- 재료 리스트에서 사용된 아이템 삭제
        for i,v in ipairs(ret['deleted_rune_oid']) do
            local roid = v
            self.m_tableViewMaterials:delItem(roid)

            -- 삭제된 roid를 저장
            table.insert(self.m_lDeletedRuneRoid, roid)
        end

        self.m_tableViewSelectedMaterials:clearItemList()
        self:tableViewSortAndRefresh()

        local before_lv = self.m_tRuneData['lv']

        local roid = ret['rune']['id']
        self.m_tRuneData = g_runesData:getRuneData(roid, true)
        self.m_runeEnchantHelper = RuneEnchantHelper(self.m_tRuneData)

        local next_lv = self.m_tRuneData['lv']

        local t_rune_data = self.m_tRuneData
        if t_rune_data['information']['is_max_lv'] then
            self:close()

            local full_name = t_rune_data['information']['full_name']
            local msg = Str('축하합니다.\n[{1}]의 최대 강화 단계를 달성하였습니다.', full_name)
            MakeSimplePopup(POPUP_TYPE.OK, msg)
        elseif (before_lv < next_lv) then
            local full_name = t_rune_data['information']['full_name']
            local msg = Str('축하합니다.\n[{1}]이\n{2}단계로 강화되었습니다.', full_name, next_lv)
            MakeSimplePopup(POPUP_TYPE.OK, msg)

            local vars = self.vars
            vars['enhanceGauge']:stopAllActions()
            vars['enhanceGauge']:setPercentage(0)
        end

        self:refresh()
    end

    local roid, src_roids = self.m_runeEnchantHelper:getRuneEnchantRequestParams()
    g_runesData:requestRuneEnchant(roid, src_roids, cb_func)
end

-------------------------------------
-- function tableViewSortAndRefresh
-- @brief 테이블 뷰 정렬, 갱신
-------------------------------------
function UI_RuneEnchantPopup:tableViewSortAndRefresh()
    local sort_manager = self.m_sortManagerRune
    sort_manager:setAllAscending(self.m_bAscending)
    sort_manager:sortExecution(self.m_tableViewMaterials.m_itemList)
    sort_manager:sortExecution(self.m_tableViewSelectedMaterials.m_itemList)

    self.m_tableViewMaterials:expandTemp(0.5)
    self.m_tableViewSelectedMaterials:expandTemp(0.5)

    local animated = true
    self.m_tableViewMaterials:relocateContainer(animated)
    self.m_tableViewSelectedMaterials:relocateContainer(animated)
end

--@CHECK
UI:checkCompileError(UI_RuneEnchantPopup)
