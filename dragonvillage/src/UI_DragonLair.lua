local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonLair
-------------------------------------
UI_DragonLair = class(PARENT,{
    m_lairTableView = '',

    m_lairTargetDragonMap = 'Map<number, StructDragonObject>',
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLair:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLair'
    self.m_subCurrency = 'blessing_ticket'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true or false
    self.m_titleStr = nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bShowInvenBtn = true
    self.m_lairTargetDragonMap = nil
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLair:init(doid)
    local vars = self:load('dragon_lair.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonLair')

    self:sceneFadeInAction()
    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DragonLair:init_after()
    PARENT.init_after(self)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLair:initUI()
    local vars = self.vars
    self:init_lairSlot()
    --self:init_dragonTableView()
    --self:init_lairTableView()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLair:initTab()
    local vars = self.vars

    local func_cb = function (tab, first)
        self:onEnterTab(tab, first)
    end

    self:setChangeTabCB(func_cb)

    self:addTabAuto('add', vars) -- 추가 
    self:addTabAuto('remove', vars) -- 삭제

    self:setTab('add')
end

--------------------------------------------------------------------------
-- @function onEnterTab
--------------------------------------------------------------------------
function UI_DragonLair:onEnterTab(tab, first)
    local vars = self.vars
    self:init_dragonTableView()

    self.m_tableViewExt:update(0)
    self.m_tableViewExt:relocateContainerDefault()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLair:initButton()
    local vars = self.vars

    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
    vars['blessBtn']:registerScriptTapHandler(function() self:click_blessBtn() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    

    if IS_TEST_MODE() == true then
        vars['resetBtn']:setVisible(true)        
        vars['resetBtn']:registerScriptTapHandler(function() self:click_resethBtn() end)

        vars['autoReloadtBtn']:setVisible(true)        
        vars['autoReloadtBtn']:registerScriptTapHandler(function() self:click_autoReloadBtn() end)
    end
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLair:getDragonList()
    
    if self.m_currTab == 'remove' then
        if self.m_lairTargetDragonMap == nil then
            self.m_lairTargetDragonMap = g_lairData:getLairTargetDragonMap()
        end

        return self.m_lairTargetDragonMap
    end

    local result_dragon_map = {}
    local m_dragons = g_dragonsData:getDragonsListRef()
    for doid, struct_dragon_data in pairs(m_dragons) do
        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            result_dragon_map[doid] = struct_dragon_data
        end
    end

    return result_dragon_map
end

-------------------------------------
-- function init_lairSlot
-------------------------------------
function UI_DragonLair:init_lairSlot(is_not_show_popup)
    local vars = self.vars

    local l_dids = g_lairData:getLairSlotDidList()
    for i, did in ipairs(l_dids) do
        local node_str = string.format('dragonNode%d', i)
        local birth_grade = TableDragon:getBirthGrade(did)
        local is_register_dragon = g_lairData:isRegisterLairDid(did)

        local t_dragon_data = {}
        t_dragon_data['did'] = did
        t_dragon_data['evolution'] = 3
        t_dragon_data['grade'] = TableLairCondition:getInstance():getLairConditionGrade(birth_grade)
        t_dragon_data['lv'] = TableLairCondition:getInstance():getLairConditionLevel(birth_grade)

        local card_ui = MakeSimpleDragonCard(did, t_dragon_data)
        card_ui:setHighlightSpriteVisible(is_register_dragon)

        vars[node_str]:removeAllChildren()
        vars[node_str]:addChild(card_ui.root)
    end

    -- 팝업일 경우 띄우지 않음
    if is_not_show_popup == true then
        return
    end

    -- ok 콜백
    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
            self:init_lairSlot(true)
        end

        g_lairData:request_lairComplete(sucess_cb)
    end

    -- 동굴 슬롯 완성했는지
    if g_lairData:isLairSlotComplete() == true then
        local msg = Str('축하드립니다.')
        local submsg = Str('말판을 완성하였습니다.')
        local ui = MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, ok_btn_cb)
    end
end

-------------------------------------
-- function init_dragonTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonLair:init_dragonTableView()
    if (not self.m_tableViewExt) then
        local list_table_node = self.vars['materialTableViewNode']

        local function make_func(object)
            return UI_DragonCard(object)
        end

        local function create_func(ui, data)
            if self.m_currTab == 'remove' then
                local is_registered = g_lairData:isRegisterLairDid(data['did'])
                local is_exist_doid = g_lairData:isRegisterLairDragonExist(data['did'])


                ui.root:setColor((is_registered and is_exist_doid) and COLOR['white'] or COLOR['deep_gray'])
                ui:setTeamBonusCheckSpriteVisible(is_registered)
                ui.vars['clickBtn']:registerScriptTapHandler(function() self:removeFromLair(data['did'], ui) end)
            else
                -- 이미 한번 등록된 드래곤이냐?
                local is_register_doid = g_lairData:isRegisterLairByDoid(data['did'], data['id'])
                ui:setTeamBonusCheckSpriteVisible(is_register_doid)
                ui.vars['clickBtn']:registerScriptTapHandler(function() self:addToLair(data['id']) end)
            end

            ui.root:setScale(0.66)
            return ui

--[[             local function open_simple_popup()
                if self.m_currTab == 'remove' then
                    return
                end

                local doid = data['id']
                if doid and (doid ~= '') then
                    local popup = UI_SimpleDragonInfoPopup(data)
                    popup:setManagePossible(true)
                    --popup:setRefreshFunc(function() popup_close_cb() end)
                end
            end

            --cclog('did : ', data['did'])            
            self:createDragonCardCB(ui, data)
            ui.root:setScale(0.66)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectDragonData(data['id']) end)
            ui.vars['clickBtn']:unregisterScriptPressHandler()
            ui.vars['clickBtn']:registerScriptPressHandler(function() open_simple_popup() end) ]]
        end


        local table_view_td = UIC_TableViewTD(list_table_node)
        table_view_td.m_cellSize = cc.size(100, 100)
        table_view_td.m_nItemPerCell = 5
        table_view_td:setCellUIClass(make_func, create_func)
        self.m_tableViewExt = table_view_td
    end

    local l_item_list = self:getDragonList()
    self.m_tableViewExt:setItemList(l_item_list)

end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-- @override
-------------------------------------
function UI_DragonLair:checkDragonSelect(doid)
	-- 재료용 검증 함수이지만 판매와 동일하기 때문에 사용
    local possible, msg = g_dragonsData:possibleLairMaterialDragon(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function addToLair
-- @brief 드래곤 둥지 추가
-------------------------------------
function UI_DragonLair:addToLair(doid, b_force)
    local ok_cb_1
    local ok_cb_2

    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
            self.m_tableViewExt:delItem(doid)
            self:init_lairSlot()
        end

        g_lairData:request_lairAdd(doid, sucess_cb)
    end

    -- 등록 가능 여부 체크
    if self:checkDragonSelect(doid) == false then
        return
    end

    local is_dragon_locked = g_dragonsData:isLockDragon(doid)

    ok_cb_1 = function()
        local ok_cb = function ()
            if is_dragon_locked == true then
                ok_cb_2()
            else
                ok_btn_cb()
            end
        end

        local msg = Str('드래곤을 동굴에 등록하시겠습니까?')
        local submsg = Str('동굴에 등록해도 자유롭게 해제가 가능합니다.')
        local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_cb)

        -- 잠금 설정된 드래곤인지 체크
        local check_cb = function()
            g_settingData:setSkipAddToLairConfimPopup()
        end
        
        ui:setCheckBoxCallback(check_cb)
    end

    ok_cb_2 = function()
        local msg = Str('드래곤이 잠금된 상태입니다.')
        local submsg = Str('드래곤 잠금을 무시하고 등록하시겠습니까?')
        local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
    end

    if g_settingData:isSkipAddToLairConfimPopup() == true then
        ok_btn_cb()
    else
        ok_cb_1()
    end
end

-------------------------------------
-- function removeFromLair
-- @brief 드래곤 둥지 제거
-------------------------------------
function UI_DragonLair:removeFromLair(did, ui_cell)
    local info = g_lairData:getRegisterLairInfo(did)
    if info == nil then
        return
    end

    local doid = info['doid']
    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
--[[             local is_registered = g_lairData:isRegisterLairDid(did)
            local is_exist_doid = g_lairData:isRegisterLairDragonExist(data['did']) ]]
            ui_cell.root:setColor(COLOR['deep_gray'])
        end

        g_lairData:request_lairRemove(doid, sucess_cb)
    end


    local msg = Str('드래곤을 동굴에서 해제하시겠습니까?')
    local submsg = Str('해제 시 동굴에 다시 등록 불가합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLair:refresh()
    local vars = self.vars
    
    for type = 1, 5 do
        local stat_id_list, stat_count = g_lairData:getLairStatIdList(self.m_currTab)
        local label_str = string.format('typeLabel%d', type)

        if stat_count == 0 then
            vars[label_str]:setString(Str('축복 효과 없음'))
        else
            local attr_str = TableLairStatus:getInstance():getLairOverlapStatStrByIds(stat_id_list)
            local bonus_str = TableLairStatus:getInstance():getLairBonusStatStrByIds(stat_id_list)

            if bonus_str == '' then
                vars[label_str]:setString(attr_str)
            else
            end
        end
    end
end

-------------------------------------
-- function click_blessBtn
-------------------------------------
function UI_DragonLair:click_blessBtn()
    local ui = UI_DragonLairBlessingPopup.open()

    ui:setCloseCB(function () 
        self:refresh()
    end)
end

-------------------------------------
-- function click_refreshBtn
-------------------------------------
function UI_DragonLair:click_refreshBtn()
    local ok_btn_cb = function ()
        local success_cb = function (ret)
            self:init_lairSlot()
            self:refresh()
        end
    
        g_lairData:request_lairReload(success_cb)
    end

    local msg = Str('말판 새로고침')
    local submsg = Str('다이아 500개를 소모해서 새로고침 하시겠습니까?')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function click_resethBtn
-------------------------------------
function UI_DragonLair:click_resethBtn()
    local ok_btn_cb = function ()
        local success_cb = function (ret)
            local success_cb_1 = function()
                self:close()
                local ui = UI_DragonLair()
            end

            g_dragonsData:request_dragonsInfo(success_cb_1)
        end
    
        g_lairData:request_lairSeasonResetManage(success_cb)
    end

    local msg = '시즌 초기화를 진행하겠습니까?(테스트 기능)'
    local submsg = '해당 버튼은 라이브환경에서는 노출되지 않습니다.'
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function click_autoReloadBtn
-------------------------------------
function UI_DragonLair:click_autoReloadBtn()
    local result_list = {}
    local m_dragons = g_dragonsData:getDragonsListRef()
    for doid, struct_dragon_data in pairs(m_dragons) do
        local did = struct_dragon_data['did']
        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            local result, msg = g_dragonsData:possibleLairMaterialDragon(doid, true)
            if result == true then            
                if #result_list < 5 then
                    table.insert(result_list, did)
                end
            end

        end
    end

    local ok_btn_cb = function ()
        local success_cb = function (ret)
            self:init_lairSlot()
            self:refresh()
        end

        g_lairData:request_lairAutoReloadManage(table.concat(result_list,','), success_cb)
    end

    local msg = '보유한 드래곤으로 슬롯을 리로드하시겠습니까?(테스트 기능)'
    local submsg = '해당 버튼은 라이브환경에서는 노출되지 않습니다.'
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_DragonLair:click_helpBtn()
    UI_Help('lair')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonLair:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonLair)
