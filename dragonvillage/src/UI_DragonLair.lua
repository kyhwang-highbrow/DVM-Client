local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonLair
-------------------------------------
UI_DragonLair = class(PARENT,{
    m_lairTableView = '',
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
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLair:init(doid)
    local vars = self:load('dragon_lair.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, self.m_uiName)

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
    self:init_dragonTableView()
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
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLair:getDragonList()
    local result_dragon_map = {}
    if self.m_currTab == 'remove' then
        return g_lairData:getDragonsListRef()
    end

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
            local function open_simple_popup()
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

            cclog('did : ', data['did'])
            
            self:createDragonCardCB(ui, data)
            ui.root:setScale(0.66)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectDragonData(data['id']) end)
            ui.vars['clickBtn']:unregisterScriptPressHandler()
            ui.vars['clickBtn']:registerScriptPressHandler(function() open_simple_popup() end)

            -- 승급/진화/스킬강화 
            -- local is_noti_dragon = data:isNotiDragon()
            -- ui:setNotiSpriteVisible(is_noti_dragon)

            -- 새로 획득한 드래곤 뱃지
            local is_new_dragon = data:isNewDragon()
            ui:setNewSpriteVisible(is_new_dragon)
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
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonLair:setSelectDragonData(doid, b_force)
    if self.m_currTab == 'remove' then
        self:removeFromLair(doid)
    else
        self:addToLair(doid)
    end
end

-------------------------------------
-- function addToLair
-- @brief 드래곤 둥지 추가
-------------------------------------
function UI_DragonLair:addToLair(doid, b_force)
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

        -- 리더로 설정된 드래곤인지 체크
    local is_dragon_locked = g_dragonsData:isLeaderDragon(doid)
    local msg = Str('드래곤을 동굴에 등록하시겠습니까?')
    local submsg_1 = Str('동굴에 등록해도 자유롭게 해제가 가능합니다.')
    local submsg_2 = is_dragon_locked == false and Str('\n드래곤 잠금을 해제하고 등록하시겠습니까?') or ''
    local submsg = submsg_1 .. submsg_2

    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function removeFromLair
-- @brief 드래곤 둥지 제거
-------------------------------------
function UI_DragonLair:removeFromLair(doid, b_force)
    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
            self.m_tableViewExt:delItem(doid)
        end

        g_lairData:request_lairRemove(doid, sucess_cb)
    end

    local msg = Str('드래곤을 동굴에서 해제하시겠습니까?')
    local submsg = Str('해제해도 자유롭게 등록이 가능합니다.')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLair:refresh()
    local vars = self.vars
    
    for type = 1, 5 do
        local stat_id_list = {10001, 10004, 10006, 10007}
        local attr_str = TableLairStatus:getInstance():getLairOverlapStatStrByIds(stat_id_list)
        local label_str = string.format('typeLabel%d', type)

        if #stat_id_list == 0 then
            vars[label_str]:setString(Str('축복 효과 없음'))
        else
            vars[label_str]:setString(attr_str)
        end
    end
end

-------------------------------------
-- function click_blessBtn
-------------------------------------
function UI_DragonLair:click_blessBtn()
    UI_DragonLairBlessingPopup.open()
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

    local msg = Str('드래곤 동굴 새로고침')
    local submsg = Str('다이아 500개를 소모해서 새로고침 하시겠습니까?')
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_DragonLair:click_helpBtn()
    local ui = MakePopup('dragon_lair_info_popup.ui')
    -- @UI_ACTION
    ui:doActionReset()
    ui:doAction(nil, false)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonLair:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonLair)
