local PARENT = UI
-------------------------------------
-- class UI_DragonLairRegister
-------------------------------------
UI_DragonLairRegister = class(PARENT,{
    m_dragonTableView = 'TableVIew',
    m_sortManagerDragon = '',
    m_availableDragonList = 'Lit<>',
    m_dragonPriorityMap = 'Map<did, combat_power, create_at>',
    m_preAttr = 'string',
    m_attrRadioButton = 'UIC_RadioButton',
    m_isRegistered = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairRegister:init(owner_ui)
    self.m_uiName = 'UI_DragonLairRegister'    
    self.m_isRegistered = false
    self:load('dragon_lair_register.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairRegister')

    self:initTableView()
    self:initUI()
    self:initButton()
    self:refresh()

    self.m_attrRadioButton:setSelectedButton('all')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairRegister:initUI()
    local vars = self.vars

    local func_condition_value = function(struct_dragon_data)
        local val = 0
        local did = struct_dragon_data['did']
        local doid = struct_dragon_data['id']
        
        if self:isExistAvailableMap(did, doid) == true then
            val = val + 2
        elseif g_lairData:isRegisterLairDid(did, doid) == true then
            val = val + 1
        end

        return val
    end


    local sort_lair_register = function (a, b, ascending)
        local a_data = a['data'] and a['data'] or a
        local b_data = b['data'] and b['data'] or b

        local a_value = func_condition_value(a_data)
        local b_value = func_condition_value(b_data)
    
        -- 같을 경우 리턴
        if (a_value == b_value) then
            return nil
        end
    
        -- 오름차순 or 내림차순
        if ascending then return a_value < b_value
        else              return a_value > b_value
        end
    end

    local sort_mgr = SortManager_Dragon()
    sort_mgr:addPreSortType('sort_lair_register', false, sort_lair_register)
    sort_mgr:pushSortOrder('grade')
    self.m_sortManagerDragon = sort_mgr
    --self.m_sortManagerDragon:addPreSortType('sort_lair_register_available', false, sort_lair_register_available)

    do -- 속성(attribute)
        local radio_button = UIC_RadioButton()
        self.m_attrRadioButton = radio_button

        radio_button:addButtonAuto('all',vars)
        radio_button:addButtonAuto('fire', vars)
        radio_button:addButtonAuto('water', vars)
        radio_button:addButtonAuto('earth', vars)
        radio_button:addButtonAuto('dark', vars)
        radio_button:addButtonAuto('light', vars)        
        radio_button:setChangeCB(function() self:onChangeOption() end)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonLairRegister:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_registerBtn() end)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLairRegister:getDragonList()
    local attr_option = self.m_attrRadioButton.m_selectedButton
    local m_dragons  = {}
    if attr_option ~= 'all' then
        m_dragons = g_dragonsData:getDragonsListWithAttr(attr_option)
    else
        m_dragons = g_dragonsData:getDragonsListRef()
    end

    local result_map = {}
    for key, struct_dragon_object in pairs(m_dragons) do
        if struct_dragon_object:getBirthGrade() >= 5 then
            result_map[key] = struct_dragon_object
        end
    end

    return result_map
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_DragonLairRegister:onChangeOption()
    self:makeAvailableDragonList()
    local attr_option = self.m_attrRadioButton.m_selectedButton
    local l_item_list = self:getDragonList()

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_dragonTableView:setItemList(l_item_list)
    --self.m_dragonTableView:update(0)

    -- 정렬
    self:apply_dragonSort()
	self.m_preAttr = attr_option
    self.m_dragonTableView:relocateContainerDefault()
end

-------------------------------------
-- function makeAvailableDragonList
-------------------------------------
function UI_DragonLairRegister:makeAvailableDragonList()
    local m_dragons = g_dragonsData:getDragonsListRef()
    local did_map = {}

    self.m_dragonPriorityMap = {}
    for _, struct_dragon_data in pairs(m_dragons) do 
        if TableLairCondition:getInstance():isMeetCondition(struct_dragon_data) == true then
            local is_add_ticket_count = g_lairData:getAdditionalBlessingTicketExpectCount(struct_dragon_data) > 0
            local is_registered = g_lairData:isRegisterLairDid(struct_dragon_data['did'])
            if is_registered == false or is_add_ticket_count == true then
                local did = struct_dragon_data['did']

                local t_data = {}
                t_data['doid'] = struct_dragon_data['id']
                t_data['power'] = struct_dragon_data:getCombatPower()
                t_data['created_at'] = struct_dragon_data['created_at']

                if self.m_dragonPriorityMap[did] == nil then                    
                    self.m_dragonPriorityMap[did] = t_data
                    
                else
                    -- 전투력으 우선순위로 가져옴
                    local exist_data = self.m_dragonPriorityMap[did]
                    if exist_data['power'] < t_data['power'] then
                        self.m_dragonPriorityMap[did] = t_data

                    elseif exist_data['power'] == t_data['power'] then
                        -- 전투력 다음 획득이 오래된 것을 우선 순위로 가져옴
                        if exist_data['created_at'] > t_data['created_at'] then
                            self.m_dragonPriorityMap[did] = t_data
                        end
                    end
                end
            end
        end
    end


    for did, v in pairs(self.m_dragonPriorityMap) do
        did_map[did] = g_dragonsData:getDragonDataFromUidRef(v['doid'])
    end

    self.m_availableDragonList = did_map
end

-------------------------------------
-- function isExistAvailableMap
-------------------------------------
function UI_DragonLairRegister:isExistAvailableMap(did, doid)
    local info = self.m_dragonPriorityMap[did]
    if info == nil then
        return false
    end

    return info['doid'] == doid
end

-------------------------------------
-- function getAvailableDragonDoids
-------------------------------------
function UI_DragonLairRegister:getAvailableDragonDoids()
    local doid_list = {}
    for i,v in pairs(self.m_availableDragonList) do
        table.insert(doid_list, v['id'])
    end
    return table.concat(doid_list, ',')
end

-------------------------------------
-- function getAvailableTicketCount
-------------------------------------
function UI_DragonLairRegister:getAvailableTicketCount()
    local count = 0
    local basic_ticket = 3
    for _, v in pairs(self.m_availableDragonList) do
        if v:getBirthGrade() == 6 then
            if g_lairData:isRegisterLairDid(v['did']) == false then
                count = count + basic_ticket + v:getDragonSkillLevelUpNum()
            else
                count = count + g_lairData:getAdditionalBlessingTicketExpectCount(v)
            end
        else 
            count = count + basic_ticket
        end
    end
    return count
end

-------------------------------------
-- function initTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonLairRegister:initTableView()
    local list_table_node = self.vars['materialList']
    list_table_node:removeAllChildren()

    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
        ui.root:setScale(0.66)

        local is_registered = g_lairData:isRegisterLairDid(data['did'], data['id'])
        local is_register_available = self:isExistAvailableMap(data['did'], data['id'])

        ui.root:setColor((is_registered == true or is_register_available == true) and COLOR['white'] or COLOR['deep_gray'])
        ui:setHighlightSpriteVisible(is_register_available)

        return ui
    end

    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 9
    table_view_td:setCellUIClass(make_func, create_func)
    self.m_dragonTableView = table_view_td
    self.m_dragonTableView:setItemList({})
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonLairRegister:apply_dragonSort()
    if self.m_dragonTableView == nil then
        return
    end

    local list = self.m_dragonTableView.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_dragonTableView:setDirtyItemList()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLairRegister:refresh()
    local vars = self.vars
    
    do
        local reg_count = g_lairData:getLairSlotCompleteCount()
        local dragons_cnt = g_dragonsData:getDragonsCnt()
        vars['dragonCountLabel']:setString(Str('등록한 드래곤 {1}/{2}', reg_count, dragons_cnt))
    end

    do
        local count = table.count(self.m_availableDragonList)
        vars['lairNotiSprite']:setVisible(count > 0)
    end
end

-------------------------------------
-- function click_registerBtn
-------------------------------------
function UI_DragonLairRegister:click_registerBtn()
    local vars = self.vars
    local dragon_count = table.count(self.m_availableDragonList)
    local ticket_count = self:getAvailableTicketCount()
    
    if dragon_count == 0 then
        UIManager:toastNotificationRed(Str('등록 가능한 드래곤이 없습니다.'))
        return
    end

    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
            self.m_isRegistered = true
            local animator = MakeAnimator('res/effect/effect_blesssing_dragon/bless.json')
            animator:changeAni('bless')
            animator:addAniHandler(function ()
                animator:setVisible(false)
                local ui = UI_DragonLairRegisterResult.open(ticket_count, dragon_count)
                ui:setCloseCB(function()
                    self:close()
                end)
            end)

            vars['spineNode']:removeAllChildren()
            vars['spineNode']:addChild(animator.m_node)
        end

        local str_doids = self:getAvailableDragonDoids()
        g_lairData:request_lairAdd(str_doids, sucess_cb)
    end    

    local msg = Str('드래곤들을 등록하시겠습니까?')
    local submsg = Str('총 {1}마리의 드래곤이 등록됩니다.\n\n획득 축복 티켓 {2}개', 
                                    dragon_count, ticket_count)

    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_DragonLairRegister:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonLairRegister.open()
    return UI_DragonLairRegister()
end
