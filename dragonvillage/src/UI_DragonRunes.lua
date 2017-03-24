local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonRunes
-------------------------------------
UI_DragonRunes = class(PARENT,{
        m_doid = 'doid',
        m_listFilterSetID = 'number', -- 0번은 전체 1~8은 해당 세트만
        m_tableViewTD = 'UIC_TableViewTD',

        m_equippedRuneObject = 'StructRuneObject',
        m_selectedRuneObject = 'StructRuneObject',

        m_mEquippedRuneObjects = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunes:init(doid, slot_idx)
    self.m_doid = doid
    self.m_listFilterSetID = 0
    self.m_mEquippedRuneObjects = {}

    local vars = self:load('dragon_rune_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunes')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 룬 Tab 설정
    self:initUI_runeTab(slot_idx)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunes:initUI()
    self:init_tableViewTD()

    self:setEquipedRuneObject(nil)
    self:setSelectedRuneObject(nil)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunes:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    -- 장착된 룬
    vars['useEnhanceBtn']:registerScriptTapHandler(function() self:click_useEnhanceBtn() end)
    vars['removeBtn']:registerScriptTapHandler(function() self:click_removeBtn() end)    

    -- 선택된 룬 판매
    vars['binBtn']:registerScriptTapHandler(function() self:click_binBtn() end)
    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
    vars['selectEnhance']:registerScriptTapHandler(function() self:click_selectEnhance() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunes:refresh()
end

-------------------------------------
-- function initUI_runeTab
-- @brief 룰 슬롯 버튼 처리
-------------------------------------
function UI_DragonRunes:initUI_runeTab(slot_idx)
    local vars = self.vars
    slot_idx = slot_idx or 1
    self:addTab(1, vars['runeSlotBtn1'], vars['runeSlotSelectSprite1']) --, vars[l_rune_slot_name[1] .. 'TableViewNode'])
    self:addTab(2, vars['runeSlotBtn2'], vars['runeSlotSelectSprite2']) --, vars[l_rune_slot_name[2] .. 'TableViewNode'])
    self:addTab(3, vars['runeSlotBtn3'], vars['runeSlotSelectSprite3']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(4, vars['runeSlotBtn4'], vars['runeSlotSelectSprite4']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(5, vars['runeSlotBtn5'], vars['runeSlotSelectSprite5']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(6, vars['runeSlotBtn6'], vars['runeSlotSelectSprite6']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:setTab(slot_idx)
end

-------------------------------------
-- function init_tableViewTD
-- @brief
-------------------------------------
function UI_DragonRunes:init_tableViewTD()
    local node = self.vars['runeTableViewNode']
    node:removeAllChildren()

    local l_item_list = {}

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)

        --ui.m_dragonCard.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data) end)
        local rune_obj = data
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectedRuneObject(rune_obj) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(101, 101)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('룬 인벤토리가 비어있습니다.\n다양한 전투를 통해 룬을 획득해보세요!'))

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function onChangeTab
-- @brief 룬 슬롯 탭이 변경되었을 때
-------------------------------------
function UI_DragonRunes:onChangeTab(tab, first)
    self:refreshTableViewList()

    -- 슬롯 타입이 변경되었을 때
    local slot_idx = tab
    local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_doid)
    local roid = dragon_obj['runes'][tostring(slot_idx)]
    if (roid == '') then
        roid = nil
    end
    if roid then
        local rune_obj = g_runesData:getRuneObject(roid)
        self:setEquipedRuneObject(rune_obj)
    else
        self:setEquipedRuneObject(nil)
    end
end

-------------------------------------
-- function setListFilterSetID
-- @brief
-------------------------------------
function UI_DragonRunes:setListFilterSetID(list_filter_set_id)
    if (self.m_listFilterSetID == list_filter_set_id) then
        return
    end

    self.m_listFilterSetID = list_filter_set_id
end


-------------------------------------
-- function refreshTableViewList
-- @brief
-------------------------------------
function UI_DragonRunes:refreshTableViewList()
    local unequipped = true
    local slot = self.m_currTab
    local set_id = self.m_listFilterSetID

    local l_item_list = g_runesData:getFilteredRuneList(unequipped, slot, set_id)

    local function refresh_func(item, new_data)
        local old_data = item['data']

        if (old_data['updated_at'] ~= new_data['updated_at']) then
            local roid = new_data['roid']
            self.m_tableViewTD:replaceItemUI(roid, new_data)
        end
    end

    self.m_tableViewTD:mergeItemList(l_item_list, refresh_func)

    -- 선택된 룬 refresh
    if (self.m_selectedRuneObject) then
        local roid = self.m_selectedRuneObject['roid']
        local rune_obj = l_item_list[roid]

        if (not rune_obj) then
            self:setSelectedRuneObject(nil)
        elseif (self.m_selectedRuneObject['updated_at'] ~= rune_obj['updated_at']) then
            self:setSelectedRuneObject(rune_obj)
        end
    end

    -- 드래곤이 장착 중인 6개의 룬 정보 갱신
    self:refreshEquippedRunes()
end

-------------------------------------
-- function refreshEquippedRunes
-- @brief
-------------------------------------
function UI_DragonRunes:refreshEquippedRunes()
    local vars = self.vars
    local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_doid)

    local slot_idx = self.m_currTab

    for i=1, 6 do
        local equipeed_roid = dragon_obj['runes'][tostring(i)]
        if (equipeed_roid == '') then
            equipeed_roid = nil
        end
        local rune_slot = vars['runeSlot' .. i]

        -- 장착이 되지 않았고 변경도 없을 경우
        if ((not self.m_mEquippedRuneObjects[i]) and (not equipeed_roid)) then

        -- 장착이 해제가 된 경우
        elseif (self.m_mEquippedRuneObjects[i] and (not equipeed_roid)) then
            rune_slot:removeAllChildren()

            if (slot_idx == i) then
                self:setEquipedRuneObject(nil)
            end

        -- 새롭게 장착이 된 경우
        elseif ((not self.m_mEquippedRuneObjects[i]) and equipeed_roid) then
            local rune_obj = g_runesData:getRuneObject(equipeed_roid)
            self.m_mEquippedRuneObjects[i] = rune_obj
            local icon = IconHelper:getItemIcon(rune_obj['item_id'], rune_obj)
            rune_slot:addChild(icon)

            if (slot_idx == i) then
                self:setEquipedRuneObject(rune_obj)
            end

        -- 둘 다 있을 경우
        else
            local before_rune_obj = self.m_mEquippedRuneObjects[i]
            local rune_obj = g_runesData:getRuneObject(equipeed_roid)
            if (before_rune_obj['updated_at'] ~= rune_obj['updated_at']) then
                self.m_mEquippedRuneObjects[i] = rune_obj
                rune_slot:removeAllChildren()
                local icon = IconHelper:getItemIcon(rune_obj['item_id'], rune_obj)
                rune_slot:addChild(icon)

                if (slot_idx == i) then
                    self:setEquipedRuneObject(rune_obj)
                end
            end
        end
        
    end
    
end

-------------------------------------
-- function setEquipedRuneObject
-- @brief
-------------------------------------
function UI_DragonRunes:setEquipedRuneObject(rune_obj)
    local vars = self.vars
    self.m_equippedRuneObject = rune_obj

    -- 룬 아이콘 삭제
    vars['useRuneNode']:removeAllChildren()
    vars['useRuneNameLabel']:setString('')
    vars['useMainOptionLabel']:setString('')
    vars['useSubOptionLabel']:setString('')
    vars['useRuneSetLabel']:setString('')
    vars['useLockBtn']:setVisible(false)

    if (not rune_obj) then
        return
    end

    -- 룬 명칭
    vars['useRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['useRuneNode']:addChild(rune_icon.root)

    -- 메인, 유니크 옵션
    vars['useMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 서브 옵션
    vars['useSubOptionLabel']:setString('')

    -- 세트 옵션
    vars['useRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())
end

-------------------------------------
-- function setSelectedRuneObject
-- @brief
-------------------------------------
function UI_DragonRunes:setSelectedRuneObject(rune_obj)
    local vars = self.vars
    self.m_selectedRuneObject = rune_obj

    -- 룬 아이콘 삭제
    vars['selectRuneNode']:removeAllChildren()
    vars['selectRuneNameLabel']:setString('')
    vars['selectMainOptionLabel']:setString('')
    vars['selectSubOptionLabel']:setString('')
    vars['selectRuneSetLabel']:setString('')
    vars['selectLockBtn']:setVisible(false)

    if (not rune_obj) then
        return
    end

    -- 룬 명칭
    vars['selectRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['selectRuneNode']:addChild(rune_icon.root)

    -- 메인, 유니크 옵션
    vars['selectMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 서브 옵션
    vars['selectSubOptionLabel']:setString('')

    -- 세트 옵션
    vars['selectRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())
end

-------------------------------------
-- function click_binBtn
-- @brief 룬 판매 버튼
-------------------------------------
function UI_DragonRunes:click_binBtn()
    if (not self.m_selectedRuneObject) then
        return
    end

    local rune_obj = self.m_selectedRuneObject
    local roid = rune_obj['roid']
    
    -- 판매 요청 (서버에)
    local function request_item_sell()
        local function finish_cb(ret)
            -- 판매된 룬을 리스트에서 제거하기 위해 refresh
            self:refreshTableViewList()
        end

        g_runesData:request_runeSell(roid, finish_cb)
    end

    -- 확인 팝업
    local item_name = rune_obj['name']
    local item_price = TableItem():getValue(rune_obj['rid'], 'sale_price')
    local msg = Str('[{1}]을(를) {2}골드에 판매하시겠습니까?', item_name, comma_value(item_price))
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end


-------------------------------------
-- function click_useEnhanceBtn
-- @brief 룬 강화 버튼
-------------------------------------
function UI_DragonRunes:click_useEnhanceBtn()
    if (not self.m_equippedRuneObject) then
        return
    end

    local ui = UI_DragonRunesEnhance(self.m_equippedRuneObject)

    local function close_cb()
        if (self.m_equippedRuneObject['updated_at'] ~= ui.m_runeObject['updated_at']) then
            self:refreshTableViewList()
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_removeBtn
-- @brief 룬 해제 버튼
-------------------------------------
function UI_DragonRunes:click_removeBtn()
    if (not self.m_equippedRuneObject) then
        return
    end

    local rune_obj = self.m_equippedRuneObject
    local slot = rune_obj['slot']
    local doid = self.m_doid

    local function finish_cb(ret)
        self:refreshTableViewList()
    end

    g_runesData:request_runesUnequip(doid, slot, finish_cb, fail_cb)
end



-------------------------------------
-- function click_selectEnhance
-- @brief 룬 강화 버튼
-------------------------------------
function UI_DragonRunes:click_selectEnhance()
    if (not self.m_selectedRuneObject) then
        return
    end

    local ui = UI_DragonRunesEnhance(self.m_selectedRuneObject)

    local function close_cb()
        if (self.m_selectedRuneObject['updated_at'] ~= ui.m_runeObject['updated_at']) then
            self:refreshTableViewList()
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_equipBtn
-- @brief 룬 장착 버튼
-------------------------------------
function UI_DragonRunes:click_equipBtn()
    if (not self.m_selectedRuneObject) then
        return
    end

    local rune_obj = self.m_selectedRuneObject
    local roid = rune_obj['roid']
    local doid = self.m_doid

    local function finish_cb(ret)
        self:refreshTableViewList()
    end

    g_runesData:request_runesEquip(doid, roid, finish_cb, fail_cb)
end
