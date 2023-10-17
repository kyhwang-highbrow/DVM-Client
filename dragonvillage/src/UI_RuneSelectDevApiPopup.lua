local PARENT = UI

-------------------------------------
-- class UI_RuneSelectDevApiPopup
-------------------------------------
UI_RuneSelectDevApiPopup = class(PARENT, {
        m_optionLabel = 'ui',

        m_mUiBtn = 'table',
        m_mUiUpBtn = 'table',
        m_mUiDownBtn = 'table',
        m_mUiMaxBtn = 'table',
        m_mUiDeleteBtn = 'table',
        m_mUiLabel = 'table',
        m_mUiEditBox = 'table',
        m_mUiComboBtn = 'ui',

        m_slot = 'number',
        m_set = 'number',
        m_grade = 'number',
        m_rarity = 'number',
        m_lv = 'number',
        m_mOpt = 'table',
        m_mVal = 'table',

        m_optionLabel = 'ui',
        m_openedComboBox = 'ui',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneSelectDevApiPopup:init()
    self.m_mUiBtn = {}
    self.m_mUiUpBtn = {}
    self.m_mUiDownBtn = {}
    self.m_mUiMaxBtn = {}
    self.m_mUiDeleteBtn = {}
    self.m_mUiLabel = {}
    self.m_mUiComboBtn= {}
    self.m_mUiEditBox = {}

    self.m_slot = 0
    self.m_set = 0
    self.m_grade = 0
    self.m_rarity = 0
    self.m_lv = 0
    self.m_mOpt = {}
    self.m_mOpt['mopt'] = '랜덤'
    self.m_mOpt['uopt'] = '랜덤'
    self.m_mOpt['sopt_1'] = '랜덤'
    self.m_mOpt['sopt_2'] = '랜덤'
    self.m_mOpt['sopt_3'] = '랜덤'
    self.m_mOpt['sopt_4'] = '랜덤'
    self.m_mVal = {}


    self.m_openedComboBox = nil

    local vars = self:load('rune_select_dev_api_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_RuneSelectDevApiPopup')
    
    self:initUI()
    self:initButton()
    self:initEditBox()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneSelectDevApiPopup:initUI()
    local vars = self.vars

    self.m_mUiBtn['set'] = vars['setBtn']
    self.m_mUiLabel['set'] = vars['setLabel']

    self.m_mUiBtn['grade'] = vars['gradeBtn']
    self.m_mUiLabel['grade'] = vars['gradeLabel']

    self.m_mUiBtn['rarity'] = vars['rarityBtn']
    self.m_mUiLabel['rarity'] = vars['rarityLabel']

    self.m_mUiBtn['slot'] = vars['slotBtn']
    self.m_mUiLabel['slot'] = vars['slotLabel']

    self.m_mUiBtn['mopt'] = vars['moptBtn']
    self.m_mUiLabel['mopt'] = vars['moptLabel']
    --self.m_mUiEditBox['mopt'] = vars['moptEditBox']

    self.m_mUiLabel['mopt'] = vars['moptLabel']

    self.m_mUiUpBtn['lv'] = vars['lvUpBtn']
    self.m_mUiDownBtn['lv'] = vars['lvDownBtn']
    self.m_mUiEditBox['lv'] = vars['lvEditBox']

    self.m_mUiBtn['uopt'] = vars['uoptBtn']
    self.m_mUiUpBtn['uopt'] = vars['uoptUpBtn']
    self.m_mUiDownBtn['uopt'] = vars['uoptDownBtn']
    self.m_mUiMaxBtn['uopt'] = vars['uoptMaxBtn']
    self.m_mUiDeleteBtn['uopt'] = vars['uoptDeleteBtn']
    self.m_mUiLabel['uopt'] = vars['uoptLabel']
    self.m_mUiEditBox['uopt'] = vars['uoptEditBox']

    

    for i = 1, 4 do
        self.m_mUiBtn['sopt_' .. i] = vars['soptBtn' .. i]
        self.m_mUiUpBtn['sopt_' .. i] = vars['soptUpBtn' .. i]
        self.m_mUiDownBtn['sopt_' .. i] = vars['soptDownBtn' .. i]
        self.m_mUiMaxBtn['sopt_' .. i] = vars['soptMaxBtn' .. i]
        self.m_mUiDeleteBtn['sopt_' .. i] = vars['soptDeleteBtn' .. i]
        self.m_mUiLabel['sopt_' .. i] = vars['soptLabel' .. i]
        self.m_mUiEditBox['sopt_' .. i] = vars['soptEditBox' .. i]
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneSelectDevApiPopup:initButton()
    local vars = self.vars

    self:makeComboBox2('set', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14})
    self:makeComboBox2('grade', {0, 1, 2, 3, 4, 5, 6, 7})
    self:makeComboBox2('rarity', {0, 1, 2, 3, 4})
    self:makeComboBox2('slot', {0, 1, 2, 3, 4, 5, 6})

    self:refreshOptionButton()

    
    vars['applyBtn']:registerScriptTapHandler(function() self:request(1) end)
    vars['applyBundleBtn']:registerScriptTapHandler(function() self:request(10) end)
    vars['applyBundle100Btn']:registerScriptTapHandler(function() self:request(100) end)

    vars['sellAllRunesBtn']:registerScriptTapHandler(function() self:sellAllRunes(100) end)
    
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refreshOptionButton
-------------------------------------
function UI_RuneSelectDevApiPopup:refreshOptionButton()
    local vars = self.vars
    local table_rune_opt = TABLE:get('table_rune_opt')

    local function initComboBox(opt)
        -- opt에 해당하는 slot_id를 만듬
        local slot_id

        if (opt == 'mopt') then
            slot_id = 'slot_' .. self.m_slot
        elseif (string.find(opt, 'uopt')) then
            slot_id = 'uopt'
        elseif (string.find(opt, 'sopt')) then
            slot_id = 'sopt'
        else
            return
        end
                
        -- 선택 가능한 옵션들로 콤보박스 생성
        local t_rune_opt = table_rune_opt[slot_id]
        local l_str = {'랜덤'}
        if (t_rune_opt) then
            local l_opt = pl.stringx.split(t_rune_opt['slot_opt'], ',')

            for i, v in ipairs(l_opt) do
                table.insert(l_str, v)
            end
        end

        self:makeComboBox(opt, l_str)
    end



    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        initComboBox(v)

        if (self.m_mUiUpBtn[v]) then
            self.m_mUiUpBtn[v]:registerScriptTapHandler(function()
                -- 옵션 + 1
                if (self.m_mVal[v]) then
                    local t_rune_opt_max = TABLE:get('table_rune_opt_status')
                    self.m_mVal[v] = self.m_mVal[v] + 1
                    if (self.m_grade <= 6) then
                        local max_value = t_rune_opt_max[self.m_mOpt[v] .. '_1']['status_max']
                        self.m_mVal[v] = math_min(max_value, self.m_mVal[v])
                    end

                    self:refresh()
                end
            end)
        end

        if (self.m_mUiDownBtn[v]) then
            self.m_mUiDownBtn[v]:registerScriptTapHandler(function()
                -- 옵션 - 1
                if (self.m_mVal[v]) then
                    self.m_mVal[v] = math_max(1, self.m_mVal[v] - 1)

                    self:refresh()
                end
            end)
        end

        if (self.m_mUiDeleteBtn[v]) then
            self.m_mUiDeleteBtn[v]:registerScriptTapHandler(function()
                -- 옵션 삭제
                self.m_mOpt[v] = '랜덤'
                self.m_mVal[v] = nil

                self:refresh()
            end)
        end
    end

    -- 강화 관련 버튼
    self.m_mUiUpBtn['lv']:registerScriptTapHandler(function()
        -- 강화 + 1
        self.m_lv = math_min(self.m_lv + 1, RUNE_LV_MAX)
        self:refresh()
    end)

    self.m_mUiDownBtn['lv']:registerScriptTapHandler(function()
        -- 강화 - 1
        self.m_lv = math_max(self.m_lv - 1, 0)
        self:refresh()
    end)
end
-------------------------------------
-- function initEditBox
-------------------------------------
function UI_RuneSelectDevApiPopup:initEditBox()
    local function isValidText(str)
        if (str ~= string.match(str, '[0-9]*')) then
            local msg = Str('숫자만 입력 가능합니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return false
        end

        return true
    end

    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        if (self.m_mUiEditBox[v]) then
            self.m_mUiEditBox[v]:registerScriptEditBoxHandler(function(strEventName, pSender)
                if (strEventName == "return") then
                    local editbox = pSender
                    local str = editbox:getText()

                    if ((isValidText(str)) and (self.m_mVal[v])) then
                        self.m_mVal[v] = tonumber(str)

                        if (self.m_grade <= 6) then
                            local t_rune_opt_max = TABLE:get('table_rune_opt_status')
                            local max_value = t_rune_opt_max[self.m_mOpt[v] .. '_1']['status_max']
                            self.m_mVal[v] = math_min(self.m_mVal[v], max_value)                    

                        end
                    end

                    self:refresh()
                end
            end)
        end
    end

    self.m_mUiEditBox['lv']:registerScriptEditBoxHandler(function(strEventName, pSender)
        if (strEventName == "return") then
            local editbox = pSender
            local str = editbox:getText()

            if isValidText(str) then
                local lv = tonumber(str)

                lv = math_max(0, lv)
                lv = math_min(lv, RUNE_LV_MAX)
                self:setLv(lv)
            end

            self:refresh()
        end
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneSelectDevApiPopup:refresh()
    local vars = self.vars

    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        self.m_mUiLabel[v]:setString(self.m_mOpt[v])

        if (self.m_mUiEditBox[v]) then
            self.m_mUiEditBox[v]:setText(self.m_mVal[v])
            self.m_mUiEditBox[v]:setEnabled(self.m_mOpt[v] ~= '')
        end
    end

    self.m_mUiEditBox['lv']:setText(self.m_lv)

    local set_str = self.set_str(self.m_set)
    vars['setLabel']:setString(set_str)

    local grade_str = self.grade_str(self.m_grade)
    vars['gradeLabel']:setString(grade_str)

    local rarity_str = self.rarity_str(self.m_rarity)
    vars['rarityLabel']:setString(rarity_str)

    local slot_str = self.slot_str(self.m_slot)
    vars['slotLabel']:setString(slot_str)

    -- 메인 옵션 값
    local mopt_value_str = self.m_mVal['mopt'] or ''
    vars['moptValueLabel']:setString(mopt_str)
    local mopt_label_str = self.opt_str(self.m_mOpt['mopt'])
    vars['moptLabel']:setString(mopt_label_str)

    -- 강화 
    self:setLv(self.m_lv)

    -- 서브 옵션 값
    local uopt_label_str = self.opt_str(self.m_mOpt['uopt'])
    vars['uoptLabel']:setString(uopt_label_str)

    for i = 1, 4 do
        local sopt_label_str = self.opt_str(self.m_mOpt['sopt_' .. i])
        vars['soptLabel' .. i]:setString(sopt_label_str)
    end

    self:setRuneObject()
end

-------------------------------------
-- function set_str
-------------------------------------
function UI_RuneSelectDevApiPopup.set_str(set)
    local set = set
    local str = '랜덤'
    if (set > 0) then
        str = TableRuneSet():getRuneSetName(set)
    end

    return str
end

-------------------------------------
-- function grade_str
-------------------------------------
function UI_RuneSelectDevApiPopup.grade_str(grade)
    local grade = grade
    local str = '랜덤'
    if (grade > 0) then
        str = grade .. '등급'
    end

    return str
end

-------------------------------------
-- function rarity_str
-------------------------------------
function UI_RuneSelectDevApiPopup.rarity_str(rarity)
    local rarity = rarity
    local str = '랜덤'
    if (rarity > 0) then
        str = getDragonRarityName(rarity)
    end

    return Str(str)
end

-------------------------------------
-- function slot_str
-------------------------------------
function UI_RuneSelectDevApiPopup.slot_str(slot)
    local slot = slot
    local str = '랜덤'
    if (slot > 0) then
        str = slot .. '번 슬롯'
    end

    return str
end

-------------------------------------
-- function opt_str
-------------------------------------
function UI_RuneSelectDevApiPopup.opt_str(type)
    if (type == '랜덤') then return '랜덤' end

    local t_opt_str = {
        ['atk'] = '공격력',
        ['aspd'] = '공격속도',
        ['cri_chance'] = '치명확률',
        ['cri_dmg'] = '치명피해',
        ['cri_avoid'] = '치명회피',
        ['def'] = '방어력',
        ['hp'] = '생명력',
        ['hit_rate'] = '적중',
        ['avoid'] = '회피',
        ['accuracy'] = '효과적중',
        ['resistance'] = '효과저항'
    }

    local table_option = TableOption()
    local opt, calc = table_option:parseOptionKey(type)
    local str = t_opt_str[opt]
    
    if (not isExistValue(type, 'atk_add', 'def_add', 'hp_add')) then
        str = str .. ' %'
    end

    return str
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_RuneSelectDevApiPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function setLv
-------------------------------------
function UI_RuneSelectDevApiPopup:setLv(lv)
    local lv = math_clamp(lv, 0, RUNE_LV_MAX)
    self.m_lv = lv

    -- 주옵션이 정해져있고, 등급도 정해져있다면 주옵션 표기
    if ((self.m_mOpt['mopt'] ~= '랜덤') and (self.m_grade > 0)) then
        local vid = self.m_mOpt['mopt'] .. '_' .. self.m_grade
        local value = TableRuneMoptStatus:getStatusValue(vid, lv)

        self.m_mVal['mopt'] = value
        self.vars['moptValueLabel']:setString(value)
    end
end


-------------------------------------
-- function sellAllRunes
-------------------------------------
function UI_RuneSelectDevApiPopup:sellAllRunes()
    local rune_list = g_runesData:getRuneList()
    local rune_sell_list = {}
    for _, struct_rune in pairs(rune_list) do
        if struct_rune:isEquippedRune() == false then
            table.insert(rune_sell_list, struct_rune)
        end
    end


    local selected_item_count = #rune_sell_list
    if (selected_item_count <= 0) then
        UIManager:toastNotificationRed(Str('조건에 해당하는 룬이 없습니다.'))
        return
    end

    local table_item = TableItem()
    local total_price = 0

    local rune_oids = nil
    for i,v in ipairs(rune_sell_list) do
        if v:isEquippedRune() == false then
            local roid = v['roid']
            local rid = v['rid']
            if (not rune_oids) then
                rune_oids = tostring(roid)
            else
                rune_oids = (rune_oids .. ',' .. tostring(roid))
            end

            local price = table_item:getValue(rid, 'sale_price')
            total_price = total_price + price
        end
    end

    local items = nil

    local function cb(ret)
        if self.m_sellCB then
            self.m_sellCB(ret)
        end

        self:refresh()
    end

    local function request_item_sell()
        g_inventoryData:request_itemSell(rune_oids, items, cb)
    end

    local msg = Str('{1}개의 룬을 {2}골드에 판매하시겠습니까?', selected_item_count, comma_value(total_price))
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end

-------------------------------------
-- function request
-------------------------------------
function UI_RuneSelectDevApiPopup:request(rune_count)
    local uid = g_userData:get('uid')
    local set = (self.m_set > 0) and self.m_set or nil
    local grade = (self.m_grade > 0) and self.m_grade or nil
    local slot = (self.m_slot > 0) and self.m_slot or nil
    local rarity = (self.m_rarity > 0) and self.m_rarity or nil
    local lv = (self.m_lv > 0) and self.m_lv or nil
    
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/add')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('count', rune_count)
    ui_network:setParam('rid', rid)
    ui_network:setParam('set', set)
    ui_network:setParam('grade', grade)
    ui_network:setParam('slot', slot)
    ui_network:setParam('rarity', rarity)
    ui_network:setParam('lv', lv)
    

    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        if (self.m_mOpt[v]) and (self.m_mVal[v]) then
            ui_network:setParam(v, self.m_mOpt[v])
            ui_network:setParam(v .. '_val', self.m_mVal[v])
        end
    end  

    if (self.m_mOpt['mopt'] ~= '랜덤') then
        ui_network:setParam('mopt', self.m_mOpt['mopt'])
    end 

    ui_network:setSuccessCB(function(ret)
        if ret and ret['runes'] then
            local t_rune_data = ret['runes'][1]
            local item_id = t_rune_data['rid']
            local count = 1
            local item_type = TableItem:getItemType(item_id)
            local t_item_data = StructRuneObject(t_rune_data)

            -- 아이템 정보창 띄움
            local ui = UI_ItemInfoPopup(item_id, count, t_item_data)
            ui:showItemInfoPopupOkBtn() -- "획득 장소"버튼은 끄고 "확인"버튼만 띄우도록 처리

            g_runesData:applyRuneData_list(ret['runes'])

            UIManager:toastNotificationRed(tostring(rune_count) .. '개의 룬을 획득했습니다.')
        end
    end)

    ui_network:request()
end

-------------------------------------
-- function getRid
-------------------------------------
function UI_RuneSelectDevApiPopup:getRid(grade, slot, set)
    local grade = grade or self.m_grade
    local slot = slot or self.m_slot
    local set = set or self.m_set

    if (slot == 0) then
        slot = math.random(1, 6)
    end

    if (set == 0) then
        set = math.random(1, 14)
        
        -- 등급값이 7등급인데 7등급 없는 세트이거나, 사용되고 있지 않는 세트의 경우
        while ((isExistValue(set, 3, 5)) or ((not isExistValue(set, 0, 1, 2, 4, 6, 7, 8)) and (grade == 7))) do
            set = math.random(1, 14)
        end
    end

    if (grade == 0) then
        if (isExistValue(set, 0, 1, 2, 4, 6, 7, 8)) then
            grade = math.random(1, 7)
        else
            grade = math.random(1, 6)
        end
    end

    local rid = 710000 + (set * 100) + (slot * 10) + (grade)

    return rid
end

-------------------------------------
-- function makeComboBox
-------------------------------------
function UI_RuneSelectDevApiPopup:makeComboBox(key, list)
    local button = self.m_mUiBtn[key]
    local label = self.m_mUiLabel[key]

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    if (self.m_mUiComboBtn[key] ~= nil) then
       self.m_mUiComboBtn[key]:removeFromParent()
    end

    self.m_mUiComboBtn[key] = UIC_SortList()
    self.m_mUiComboBtn[key].m_direction = UIC_SORT_LIST_TOP_TO_BOT
    self.m_mUiComboBtn[key].m_buttonHeight = 34
    self.m_mUiComboBtn[key]:setNormalSize(width, height)
    self.m_mUiComboBtn[key]:setPosition(x + 150, 330)
    self.m_mUiComboBtn[key]:setDockPoint(button:getDockPoint())
    self.m_mUiComboBtn[key]:setAnchorPoint(button:getAnchorPoint())
    self.m_mUiComboBtn[key]:init_container()
    parent:addChild(self.m_mUiComboBtn[key].m_node, 99)

    local uic = self.m_mUiComboBtn[key]

    --uic:setExtendButton(button)
    button:registerScriptTapHandler(function()
        uic:toggleVisibility()

        if (uic.m_bShow) then
            if ((self.m_openedComboBox) and (self.m_openedComboBox.m_bShow) and (self.m_openedComboBox ~= uic)) then
                self.m_openedComboBox:hide()
            end
            self.m_openedComboBox = uic
        end
    end)
    
    
    for i, type in ipairs(list) do
        local str = self.opt_str(type)
        uic:addSortType(type, str)
    end

    self.m_mOpt[key] = '랜덤'
    self.m_mVal[key] = nil

	uic:setSortChangeCB(function(type)
        self.m_mOpt[key] = type

        self.m_openedComboBox = nil

        -- 메인 옵션 타입이 변경된 경우면 강화 단계에 따른 현재 옵션값을 재계산해야함
        if (type == '랜덤') then
            self.m_mVal[key] = nil
        else
            if (key == 'mopt') then
                self:setLv(self.m_lv)
            else
                self.m_mVal[key] = 1
            end
        end
        

        self:refresh()
    end)

    return uic
end

-------------------------------------
-- function makeComboBox2
-- @brief 다른 옵션들에 영향을 끼치는 콤보박스들
-------------------------------------
function UI_RuneSelectDevApiPopup:makeComboBox2(key, list)
    local button = self.m_mUiBtn[key]
    local label = self.m_mUiLabel[key]

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    

    if (self.m_mUiComboBtn[key] == nil) then
        self.m_mUiComboBtn[key] = UIC_SortList()
        self.m_mUiComboBtn[key].m_direction = UIC_SORT_LIST_TOP_TO_BOT
        self.m_mUiComboBtn[key].m_buttonHeight = 34
        self.m_mUiComboBtn[key]:setNormalSize(width, height)
        self.m_mUiComboBtn[key]:setPosition(x + 150, 330)
        self.m_mUiComboBtn[key]:setDockPoint(button:getDockPoint())
        self.m_mUiComboBtn[key]:setAnchorPoint(button:getAnchorPoint())
        self.m_mUiComboBtn[key]:init_container()
    end

    local uic = self.m_mUiComboBtn[key]

    --uic:setExtendButton(button)
    button:registerScriptTapHandler(function()
        uic:toggleVisibility()

        if (uic.m_bShow) then
            if ((self.m_openedComboBox) and (self.m_openedComboBox.m_bShow) and (self.m_openedComboBox ~= uic)) then
                self.m_openedComboBox:hide()
            end
            self.m_openedComboBox = uic
        end

    end)
    
    parent:addChild(uic.m_node, 99)

    for i, type in ipairs(list) do
        local str = type
        if (self[key .. '_str']) then
            str = self[key .. '_str'](type)
        end
        uic:addSortType(type, str)
    end

	uic:setSortChangeCB(function(type)
        
        local key_name = 'm_' .. key        
        local old_type = self[key_name]
        self[key_name] = type
        self.m_openedComboBox = nil
        
        -- 각자 영향 미치는 것들 재배치
        if (key == 'slot') then
            -- 주옵션 변경
            local table_rune_opt = TABLE:get('table_rune_opt')
            local type = (type > 0) and type or nil

            local l_str = {'랜덤'}
            if (type ~= nil) then
                local t_rune_opt = table_rune_opt['slot_' .. type]
                if (t_rune_opt) then
                    local l_opt = pl.stringx.split(t_rune_opt['slot_opt'], ',')
                    for i, v in ipairs(l_opt) do
                        table.insert(l_str, v)
                    end
                end
            end
            self:makeComboBox('mopt', l_str)
        
        elseif (key == 'set') then
            if (not isExistValue(self.m_set, 0, 1, 2, 4, 6, 7, 8, 9, 10, 11, 13, 14)) then
                self.m_grade = math_min(self.m_grade, 6)
            end
        
        elseif (key == 'grade') then
            if (not isExistValue(self.m_set, 0, 1, 2, 4, 6, 7, 8, 9, 10, 11, 13, 14)) then
                self.m_grade = math_min(self.m_grade, 6)
            end

            if ((old_type == 7) and (type <= 6)) then
                -- 룬 옵션 세팅
                for i, v in ipairs(StructRuneObject.OPTION_LIST) do
                    local option = self.m_mOpt[v]       
                    local value = self.m_mVal[v]
        
                    if (value) then
                        local t_rune_opt_max = TABLE:get('table_rune_opt_status')
                        local max_value = t_rune_opt_max[option .. '_1']['status_max']
                        self.m_mVal[v] = math_min(self.m_mVal[v], max_value)
                    end
                    
                end
            end
        end

        self:refresh()
    end)

    return uic
end

-------------------------------------
-- function setRuneObject
-- @brief
-------------------------------------
function UI_RuneSelectDevApiPopup:setRuneObject()
    local vars = self.vars

    -- 룬 명칭
    if ((self.m_set > 0) and (self.m_slot > 0)) then
        local rid = self:getRid(1, nil, nil)
        local name = TableItem:getItemName(rid)
        
        if ((self.m_mVal['uopt'] ~= nil)) then
            local option = self.m_mOpt['uopt']
            local prefix = TableOption:getRunePrefix(option)

            if (prefix ~= '') then
                name = prefix .. ' ' .. name
            end
        end

        vars['useRuneNameLabel']:setString(name)
    else
        vars['useRuneNameLabel']:setString('샘플 룬')
    end
   
    -- 룬 아이콘
    if ((self.m_grade > 0) and (self.m_slot > 0) and (self.m_set > 0)) then
        local rid = self:getRid()
        local frame_res = StructRuneObject.getRarityFrameRes({['rarity'] = self.m_rarity})
        local star_res = string.format('card_star_yellow_01%02d.png', self.m_grade)
        local set_color = TableRuneSet:getRuneSetColor(self.m_set)
        local icon_res = string.format('res/ui/icons/rune/%.2d_%s_%.2d.png', self.m_slot, set_color, self.m_grade)

        -- 카드 생성
        local rune_ui = UI_Card()
        rune_ui.ui_res = 'card_rune.ui'
        rune_ui:getUIInfo()

        local btn = rune_ui.vars['clickBtn']

        if (not btn) then
            btn = cc.MenuItemImage:create()
            btn:setDockPoint(CENTER_POINT)
            btn:setAnchorPoint(CENTER_POINT)
            btn:setContentSize(150, 150)
    
            rune_ui.vars['clickBtn'] = UIC_Button(btn)
            rune_ui.root:addChild(btn, -1)

	        -- btn:registerScriptTapHandler(function()  end)
        end

        -- 프레임 생성
        rune_ui:makeSprite('frameNode', frame_res)
    
        -- 획득 가능한 범주의 등급 표시
        rune_ui:makeSprite('starNode', star_res) -- (lua_name, res, no_use_frames)
    
        -- 룬 이미지 표시
        rune_ui:makeSprite('runeNode', icon_res, true) -- (lua_name, res, no_use_frames)

        -- 룬 숫자 표시
        local slot = self.m_slot
        if (self.m_set < 9) then
	        local res = string.format('res/ui/icons/rune/rune_number_%.2d.png', self.m_slot)
            rune_ui:makeSprite('runeNumberNode', res, true) -- (lua_name, res, no_use_frames)
        end

        -- 강화 단계 표시
        local lv = self.m_lv
        if (lv > 0) then
            rune_ui:setNumberText(lv, true) -- (use_plus)
        end

        vars['useRuneNode']:addChild(rune_ui.root)
    
    else
        vars['useRuneNode']:removeAllChildren()
    end

    -- 세트 옵션
    local set_desc_rich_text
    if (self.m_set > 0) then
        set_desc_rich_text = TableRuneSet:makeRuneSetDescRichText(self.m_set)
    else
        set_desc_rich_text = '{@gray}랜덤 세트'
    end

    vars['useRuneSetLabel']:setString(set_desc_rich_text)


    do -- 레어도
        local color
        
        -- 희귀 (rare)
        if (self.m_rarity == 2) then
            color = cc.c3b(62, 139, 255)

        -- 영웅 (hero)
        elseif (self.m_rarity == 3) then
            color = cc.c3b(213, 57, 246)

        -- 전설 (legend)
        elseif (self.m_rarity == 4) then
            color = cc.c3b(255, 210, 0)
        else
            color = cc.c3b(174, 172, 162)
        end

        vars['useRuneNameLabel']:setColor(color)
        vars['useRarityNode']:setColor(color)

        local name = self.rarity_str(self.m_rarity)
        vars['useRarityLabel']:setString(name)
    end

    if (self.m_optionLabel == nil) then
        local option_label = UI()
        option_label:load('rune_info_board.ui')
        option_label.vars['runeInfo']:setVisible(true)
        option_label.vars['useMenu']:setVisible(false)
        vars['useRuneDscNode']:addChild(option_label.root)

        self.m_optionLabel = option_label
    end

    -- 룬 옵션 세팅
    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        local option_label = string.format("%s_useLabel", v)
        local option_label_node = string.format("%s_useNode", v)

        local option = self.m_mOpt[v]        
        local value = self.m_mVal[v]
        if (value) then        
            local desc_str = TableOption:getOptionDesc(option, value)
        
            local t_rune_opt_max = TABLE:get('table_rune_opt_status')
            local max_value = t_rune_opt_max[option .. '_1']['status_max']
            local is_max = ((value == max_value) and (self.m_grade <= 6))

            -- 추가옵션은 max, 연마 표시
            if (i > 2) and (is_max) then
                desc_str = desc_str .. '{@yellow} [MAX]'
            end

            self.m_optionLabel.vars[option_label_node]:setVisible(true)
            self.m_optionLabel.vars[option_label]:setString(desc_str)
        
        else
            self.m_optionLabel.vars[option_label_node]:setVisible(false)
        end
    end
end
