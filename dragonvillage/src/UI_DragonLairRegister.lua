local PARENT = UI
-------------------------------------
-- class UI_DragonLairRegister
-------------------------------------
UI_DragonLairRegister = class(PARENT,{
    m_dragonTableView = 'TableVIew',
    m_dragonCount = '',
    m_sortManagerDragon = '',
    m_availableDragonMap = 'Map<>',
    m_allDragonsMap = 'Map<>',
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
    self.m_dragonCount = 0
    self.m_isRegistered = false
    self.m_allDragonsMap = nil
    self:load('dragon_lair_register.ui')
    UIManager:open(self, UIManager.POPUP, true)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairRegister')

    self:makeAvailableDragonList()
    self:initTableView()
    self:initUI()
    self:initButton()

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
        
        if self:isExistAvailableMap(did) == true then
            val = val + 100
        elseif g_lairData:isRegisterLairDid(did) == true then
            val = val + 10
        elseif doid ~= nil then
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
    sort_mgr:pushSortOrder('rarity')
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

    if self.m_allDragonsMap == nil then
        self.m_allDragonsMap = self:getBookDragonList()
    end

    local result_map = {}
    for k, v in pairs(self.m_allDragonsMap) do
        if (attr_option ~= 'all') and (attr_option ~= v:getAttr()) then
        else
            result_map[k] = v
        end
    end

    return result_map
end

-------------------------------------
-- function getBestDragonObjectByDid
-- @breif 같은 did를 가진 개체 중에 최고의 드래곤 얻어오기
-------------------------------------
function UI_DragonLairRegister:getBestDragonObjectByDid(did)
    local m_dragons = g_dragonsData:getDragonsByDid(did)
    local result_dragon = nil
    local exist_combat_power = nil

    for k, struct_dragon_data in pairs(m_dragons) do
        -- 등록 가능한 드래곤이라면 최우선 노출 순위가 됨
        if self.m_availableDragonMap[did] ~= nil then
            return self.m_availableDragonMap[did]
        end

        return struct_dragon_data
    end

    return result_dragon
end

-------------------------------------
-- function getBookDragonList
-- @breif 도감 기준으로 모든 드래곤 리스트 얻어옴
-------------------------------------
function UI_DragonLairRegister:getBookDragonList()
    local role_type = 'all'
    local l_ret = {}

    self.m_dragonCount = 0
    local table_dragon = TableDragon()
    for i, v in pairs(table_dragon.m_orgTable) do
        -- 개발 중인 드래곤은 도감에 나타내지 않는다.
        if (not g_dragonsData:isReleasedDragon(v['did'])) then
--[[         -- 속성 걸러내기		
        elseif (attr_type ~= 'all') and (attr_type ~= v['attr']) then
        -- 위 조건들에 해당하지 않은 경우만 추가 ]]
        else
            local did = v['did']
			local key = did
			-- 자코는 진화하지 않으므로 evolution 1 만 담는다.
			if (table_dragon:isUnderling(did)) then
            elseif (v['birthgrade'] < 5) then
			else -- 진화도를 만들어준다.
                local exist_dragon = self:getBestDragonObjectByDid(key)
                if exist_dragon ~= nil then
                    l_ret[key] = exist_dragon
                else
                    local t_dragon = {}                
                    t_dragon['did'] = did
                    t_dragon['evolution'] = 3
                    t_dragon['grade'] = 6
                    t_dragon['lv'] = 0
                    t_dragon['created_at'] = 0
                    l_ret[key] = StructDragonObject(t_dragon)
                end

                self.m_dragonCount = self.m_dragonCount + 1
			end
        end
    end

    return l_ret
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_DragonLairRegister:onChangeOption()
    
    local attr_option = self.m_attrRadioButton.m_selectedButton
    local l_item_list = self:getDragonList()

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_dragonTableView:setItemList(l_item_list)
    --self.m_dragonTableView:update(0)

    self:refresh()

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
            local did = struct_dragon_data['did']
            local is_add_ticket_count = g_lairData:getAdditionalBlessingTicketExpectCount(struct_dragon_data) > 0
            local is_registered = g_lairData:isRegisterLairDid(did)

            if is_registered == false then
                if did_map[did] == nil then
                    did_map[did] = struct_dragon_data
                else
                    local exist_dragon = did_map[did]
                    local exist_combat_power = exist_dragon:getCombatPower()
                    local exist_created_at = exist_dragon['created_at']

                    local combat_power = struct_dragon_data:getCombatPower()
                    local created_at = struct_dragon_data['created_at']

                    if combat_power > exist_combat_power then
                        did_map[did] = struct_dragon_data
                    elseif combat_power == exist_combat_power then
                        if exist_created_at > created_at then
                            did_map[did] = struct_dragon_data
                        end
                    end
                end
            elseif is_add_ticket_count == true then
                did_map[did] = struct_dragon_data
            end
        end
    end

    self.m_availableDragonMap = did_map
end

-------------------------------------
-- function isExistAvailableMap
-------------------------------------
function UI_DragonLairRegister:isExistAvailableMap(did)
    local info = self.m_availableDragonMap[did]
    if info == nil then
        return false
    end

    return true
end

-------------------------------------
-- function getAvailableDragonDoids
-------------------------------------
function UI_DragonLairRegister:getAvailableDragonDoids()
    local doid_list = {}
    for i,v in pairs(self.m_availableDragonMap) do
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
    for _, v in pairs(self.m_availableDragonMap) do
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

        local is_registered = g_lairData:isRegisterLairDid(data['did'])
        local is_register_available = self:isExistAvailableMap(data['did'])
        local is_not_exist = (data['id'] == nil)

        if is_registered == true or is_register_available == true then
            ui.root:setColor(COLOR['white'])
        elseif is_not_exist == true then
            ui.root:setColor(cc.c3b(40, 40, 40))
        else
            ui.root:setColor(COLOR['deep_gray'])
        end
           
        local function tap_func()
            if is_not_exist == true then
                UI_BookDetailPopup.openWithFrame(data['did'], data['grade'], data['evolution'], 1, true)
            else
                local doid = data['id']
                if doid and (doid ~= '') then
                    UI_SimpleDragonInfoPopup(data)
                end
            end
        end

        ui.vars['clickBtn']:registerScriptTapHandler(tap_func)
        ui.vars['clickBtn']:registerScriptPressHandler(function() end)
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
        --local dragons_cnt = g_dragonsData:getDragonsCnt()
        vars['dragonCountLabel']:setString(Str('등록한 드래곤 {1}/{2}', reg_count, self.m_dragonCount))
    end

    do
        vars['lairNotiSprite']:setVisible(g_lairData:isAvailableRegisterDragons())
    end
end

-------------------------------------
-- function sceneFadeOutAction
-- @brief Scene 전환 페이드인 효과
-------------------------------------
function UI_DragonLairRegister:sceneFadeOutAction(finish_func)
    finish_func = (finish_func or function() end)
    local layerColor = cc.LayerColor:create( cc.c4b(0,0,0,0) )
    layerColor:setDockPoint(cc.p(0.5, 0.5))
    layerColor:setAnchorPoint(cc.p(0.5, 0.5))
    layerColor:setRelativeSizeAndType(cc.size(MAX_RESOLUTION_X, MAX_RESOLUTION_Y), 1, false)
    layerColor:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.CallFunc:create(finish_func)))
    self.root:addChild(layerColor, 100)
end

-------------------------------------
-- function click_registerBtn
-------------------------------------
function UI_DragonLairRegister:click_registerBtn()
    local vars = self.vars
    local dragon_count = table.count(self.m_availableDragonMap)
    local ticket_count = self:getAvailableTicketCount()
    
    if dragon_count == 0 then
        UIManager:toastNotificationRed(Str('등록 가능한 드래곤이 없습니다.'))
        return
    end

    local sucess_cb = function (ret)
        self.m_isRegistered = true
        SoundMgr:playEffect('UI', 'ui_rune_success')

        local func = function()            
            self:close()
            UI_DragonLairRegisterResult.open(ticket_count, dragon_count)
        end
        self:sceneFadeOutAction(func)
    end

    local ok_btn_cb = function ()
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
