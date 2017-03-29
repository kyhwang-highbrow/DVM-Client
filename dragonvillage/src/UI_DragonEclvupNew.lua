local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonEclvupNew
-- @brief 초월 UI
-------------------------------------
UI_DragonEclvupNew = class(PARENT,{
        m_bChangeDragonList = 'boolean',

        m_mtrlTableViewTD = '',
        m_mtrlDragonSortManager = 'SortManager_Dragon',

        m_selectedMaterial = '',
        m_selectedMaterialUI = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonEclvupNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonEclvupNew'
    self.m_bVisible = true or false
    self.m_titleStr = Str('초월')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEclvupNew:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_transcend.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonEclvupNew')

    -- 정렬 매니저
    self.m_mtrlDragonSortManager = SortManager_Dragon()

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr(b_ascending_sort, sort_type)

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonEclvupNew:initUI()
    local vars = self.vars

    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonEclvupNew:initButton()
    local vars = self.vars
    vars['transcendBtn']:registerScriptTapHandler(function() self:click_transcendBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonEclvupNew:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    do -- 선택된 재료 삭제
        if self.m_selectedMaterialUI then
            self.m_selectedMaterialUI.root:removeFromParent()
            self.m_selectedMaterialUI = nil
        end

        if (self.m_selectedMaterial) then
            self.m_selectedMaterial = nil
        end
    end

    local vars = self.vars

    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(t_dragon_data['did'])
    local doid = t_dragon_data['id']

    do -- 드래곤 아이콘
        vars['dragonIconNode']:removeAllChildren()
        local ui = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(ui.root)
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(Str(t_dragon['t_name']))
    end
    
    do -- 현재 레벨의 능력치 계산기
        local status_calc = MakeOwnDragonStatusCalculator(doid)

        local atk = status_calc:getFinalStatDisplay('atk')
        local def = status_calc:getFinalStatDisplay('def')
        local hp = status_calc:getFinalStatDisplay('hp')

        vars['statusLabel1']:setString(atk .. '\n' .. def .. '\n' .. hp)
    end

    do -- 변경된 레벨의 능력치 계산기
        local chaged_dragon_data = {}
        chaged_dragon_data['eclv'] = t_dragon_data['eclv'] + 1
        local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

        local atk = changed_status_calc:getFinalStatDisplay('atk')
        local def = changed_status_calc:getFinalStatDisplay('def')
        local hp = changed_status_calc:getFinalStatDisplay('hp')

        vars['statusLabel2']:setString(atk .. '\n' .. def .. '\n' .. hp)
    end

    do
        local eclv = t_dragon_data['eclv']
        local req_gold = TableGradeInfo:getEclvUpgradeReqGold(eclv)
        vars['priceLabel']:setString(comma_value(req_gold))
    end

    -- 재료 테이블 뷰 갱신
    self:refresh_materialTableView()
end

-------------------------------------
-- function UI_DragonEclvupNew
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonEclvupNew:getDragonList()
    local l_item_list = g_dragonsData:getDragonsList()

    for i,v in pairs(l_item_list) do
        local doid = v['id']
        local upgradeable, msg = g_dragonsData:checkEclvUpgradeable(doid)
        if (not upgradeable) then
            l_item_list[i] = nil
        end
    end

    return l_item_list
end

-------------------------------------
-- function refresh_materialTableView
-- @brief 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonEclvupNew:refresh_materialTableView()
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_material(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:makeDefaultEmptyDescLabel(Str('초월에는 동일한 드래곤이 필요합니다.'))
    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)
end

-------------------------------------
-- function getMaterialList
-- @brief 드래곤 재료(다른 드래곤) 리스트
-------------------------------------
function UI_DragonEclvupNew:getMaterialList(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용
    local table_dragon = TableDragon()

    -- 자기 자신 드래곤 제외
    l_dragon_list[doid] = nil

    for doid,v in pairs(l_dragon_list) do
        -- 원종이 다른 항목 제거
        if (t_dragon_data['did'] ~= v['did']) then
            l_dragon_list[doid] = nil
        elseif (not g_dragonsData:possibleMaterialDragon(doid)) then
            l_dragon_list[doid] = nil
        end
    end

    return l_dragon_list
end

-------------------------------------
-- function click_material
-------------------------------------
function UI_DragonEclvupNew:click_material(data)
    local vars = self.vars
    local doid = data['id']

    -- 선택되어있는 재료가 있으면 해제
    if self.m_selectedMaterial then
        local item = self.m_mtrlTableViewTD:getItem(self.m_selectedMaterial)
        local ui = item['ui']
        if ui then
            ui:setShadowSpriteVisible(false)
        end
        
        if self.m_selectedMaterialUI then
            self.m_selectedMaterialUI.root:removeFromParent()
            self.m_selectedMaterialUI = nil
        end

        if (self.m_selectedMaterial == doid) then
            self.m_selectedMaterial = nil
            return
        end
    end

    -- 선택된 재료 UI 생성
    local ui = UI_DragonCard(data)
    cca.uiReactionSlow(ui.root)
    self.m_selectedMaterialUI = ui
    ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_material(data) end)
    vars['materialNode']:addChild(ui.root)
    local item = self.m_mtrlTableViewTD:getItem(doid)
    local ui = item['ui']
    ui:setShadowSpriteVisible(true)
    self.m_selectedMaterial = doid
end

-------------------------------------
-- function click_transcendBtn
-------------------------------------
function UI_DragonEclvupNew:click_transcendBtn()
    if (not self.m_selectedMaterial) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요.'))
        return
    end


    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = self.m_selectedMaterial

    local function success_cb(ret)
        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)

                -- 드래곤 리스트 갱신
                self.m_tableViewExt:delItem(doid)
            end
        end

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['modified_dragon'])

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        self.m_bChangeDragonList = true

        -- 최대 초월 단계일 경우
        if g_dragonsData:isMaxEclv(doid) then
            UIManager:toastNotificationRed(Str('최고 초월 단계를 달성하셨습니다.'))
            self:close()
        else
            self:refresh_dragonIndivisual(doid)
            self:refresh()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/exceed')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

--@CHECK
UI:checkCompileError(UI_DragonEclvupNew)
