local PARENT = UI

-------------------------------------
-- class UI_RuneDevApiPopup
-------------------------------------
UI_RuneDevApiPopup = class(PARENT, {
        m_runeObjectID = 'string',
        m_optionLabel = 'ui',

        m_mUiBtn = 'table',
        m_mUiUpBtn = 'table',
        m_mUiDownBtn = 'table',
        m_mUiMaxBtn = 'table',
        m_mUiDeleteBtn = 'table',
        m_mUiLabel = 'table',
        m_mUiEditBox = 'table',

        m_lv = 'number',
        m_mOpt = 'table',
        m_mVal = 'table',

        m_openedComboBox = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneDevApiPopup:init(rune_object_id)
    self.m_runeObjectID = rune_object_id

    local t_rune_data = g_runesData:getRuneObject(self.m_runeObjectID)

    self.m_mUiBtn = {}
    self.m_mUiUpBtn = {}
    self.m_mUiDownBtn = {}
    self.m_mUiMaxBtn = {}
    self.m_mUiDeleteBtn = {}
    self.m_mUiLabel = {}
    self.m_mUiEditBox = {}

    self.m_lv = t_rune_data['lv'] or 0
    self.m_mOpt = {}
    self.m_mVal = {}

    self.m_openedComboBox = nil

    -- 현재 룬 옵션 임시 저장
    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        self.m_mOpt[v], self.m_mVal[v] = t_rune_data:parseRuneOptionStr(t_rune_data[v])
    end

    local vars = self:load('rune_dev_api_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_RuneDevApiPopup')
    
    self:initUI()
    self:initButton()
    self:initEditBox()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneDevApiPopup:initUI()
    local vars = self.vars
    local t_rune_data = g_runesData:getRuneObject(self.m_runeObjectID)

    self.m_mUiBtn['mopt'] = vars['moptBtn']
    self.m_mUiLabel['mopt'] = vars['moptLabel']
    --self.m_mUiEditBox['mopt'] = vars['moptEditBox']

    self.m_mUiLabel['mopt'] = vars['moptLabel']

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

    -- 룬 이름 지정
    -- vars['nameLabel']:setString(Str(t_rune_data['name']))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneDevApiPopup:initButton()
    local vars = self.vars
    local t_rune_data = g_runesData:getRuneObject(self.m_runeObjectID)
    local table_rune_opt = TABLE:get('table_rune_opt')

    local function initComboBox(opt)
        -- opt에 해당하는 slot_id를 만듬
        local slot_id

        if (opt == 'mopt') then
            slot_id = 'slot_' .. t_rune_data['slot']
        elseif (string.find(opt, 'uopt')) then
            slot_id = 'uopt'
        elseif (string.find(opt, 'sopt')) then
            slot_id = 'sopt'
        else
            return
        end
                
        -- 선택 가능한 옵션들로 콤보박스 생성
        local t_rune_opt = table_rune_opt[slot_id]
        if (t_rune_opt) then
            local l_str = pl.stringx.split(t_rune_opt['slot_opt'], ',')
            self:makeComboBox(opt, l_str)
        end
    end

    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        initComboBox(v)

        if (self.m_mUiUpBtn[v]) then
            self.m_mUiUpBtn[v]:registerScriptTapHandler(function()
                -- 옵션 + 1
                if (self.m_mVal[v]) then
                    local t_rune_opt_max = TABLE:get('table_rune_opt_status')
                    local max_value = t_rune_opt_max[self.m_mOpt[v]]['status_max']
                    self.m_mVal[v] = math_min(max_value, self.m_mVal[v] + 1)

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

         if (self.m_mUiMaxBtn[v]) then
            self.m_mUiMaxBtn[v]:registerScriptTapHandler(function()
                -- 옵션 최대값
                if (self.m_mVal[v]) then
                    local t_rune_opt_max = TABLE:get('table_rune_opt_status')
                    local max_value = t_rune_opt_max[self.m_mOpt[v]]['status_max']
                    self.m_mVal[v] = max_value

                    self:refresh()
                end
            end)
        end

         if (self.m_mUiDeleteBtn[v]) then
            self.m_mUiDeleteBtn[v]:registerScriptTapHandler(function()
                -- 옵션 삭제
                self.m_mOpt[v] = nil
                self.m_mVal[v] = nil

                self:refresh()
            end)
        end
    end

    do -- 강화 관련 버튼
        
        -- 최대 강화
        vars['maxEhchantBtn']:registerScriptTapHandler(function()
            self:setLv(RUNE_LV_MAX)
            self:refresh()
        end)

        -- 강화 제거
        vars['enchantDeleteBtn']:registerScriptTapHandler(function()
            self:setLv(0)
            self:refresh()
        end)

        -- 강화 단계 낮춤
        vars['enchantDownBtn']:registerScriptTapHandler(function()
            self:setLv(self.m_lv - 1)
            self:refresh()
        end)

        -- 강화 단계 높임
        vars['enchantUpBtn']:registerScriptTapHandler(function()
            self:setLv(self.m_lv + 1)
            self:refresh()
        end)
    end

    vars['applyBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    
    vars['closeBtn']:registerScriptTapHandler(function() self:setCloseCB(nil) self:close() end)
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_RuneDevApiPopup:initEditBox()
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

                    if ((isValidText(str)) and (self.m_mOpt[v])) then
                        local t_rune_opt_max = TABLE:get('table_rune_opt_status')
                        local max_value = t_rune_opt_max[self.m_mOpt[v]]['status_max']
                        max_value = math_min(tonumber(str), max_value)           
                        self.m_mVal[v] = math_max(1, max_value)            
                    end

                    self:refresh()
                end
            end)
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneDevApiPopup:refresh()
    local vars = self.vars

    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        if (self.m_mOpt[v]) then
            local str = self.opt_str(self.m_mOpt[v])
            self.m_mUiLabel[v]:setString(str)
        else
            self.m_mUiLabel[v]:setString('')
        end

        if (self.m_mUiEditBox[v]) then
            self.m_mUiEditBox[v]:setText(self.m_mVal[v])
            self.m_mUiEditBox[v]:setEnabled(self.m_mOpt[v] ~= '')
        end
    end

    -- 메인 옵션 값
    vars['moptValueLabel']:setString(self.m_mVal['mopt'])

    -- 강화 단계
    vars['enchantLabel']:setString(string.format('+%d', self.m_lv))

    self:setRuneObject()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_RuneDevApiPopup:click_closeBtn()
    self:setCloseCB(nil)
    self:close()
    --local t_rune_data = g_runesData:getRuneObject(self.m_runeObjectID)
--
    --local m_update = {}
    --local m_delete = {}
--
    --for _, v in ipairs(StructRuneObject.OPTION_LIST) do
        ---- 원본 룬 정보와 비교하여 변경되거나 삭제된 옵션들을 골라냄
        --local opt, opt_val = t_rune_data:parseRuneOptionStr(t_rune_data[v])
--
        ---- 메인 옵션 타입이 변경된 경우는 삭제도 되어야 한다(서버 저장 방식의 이슈로 인함)
        --if (v == 'mopt' and opt ~= self.m_mOpt[v]) then
            --m_delete[v] = true
        --end
--
        --if (opt ~= self.m_mOpt[v] or opt_val ~= self.m_mVal[v]) then
            --if (self.m_mOpt[v] == nil or self.m_mOpt[v] == '' or self.m_mVal[v] == nil or self.m_mVal[v] == 0) then
                --m_delete[v] = true
            --else
                --m_update[v] = true
            --end
        --end
    --end
--
    --if ((table.count(m_update) == 0) and (table.count(m_delete) == 0)) then
        --self:setCloseCB(nil)
    --end
--
    --self:request('delete', m_delete, function()
        --self:request('update', m_update, function()
            --self:close()
        --end)
    --end)
end


-------------------------------------
-- function setLv
-------------------------------------
function UI_RuneDevApiPopup:setLv(lv)
    local lv = math_clamp(lv, 0, RUNE_LV_MAX)
    local t_rune_data = g_runesData:getRuneObject(self.m_runeObjectID)
    local vid = self.m_mOpt['mopt'] .. '_' .. t_rune_data['grade']
    local value = TableRuneMoptStatus:getStatusValue(vid, lv)

    self.m_lv = lv
    self.m_mVal['mopt'] = value
end

-------------------------------------
-- function opt_str
-------------------------------------
function UI_RuneDevApiPopup.opt_str(type)
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
-- function request
-------------------------------------
function UI_RuneDevApiPopup:request(act, map, next_cb)
    if (table.count(map) == 0) then
        next_cb()
        return
    end

    local uid = g_userData:get('uid')
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/update')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', act)
    ui_network:setParam('roid', self.m_runeObjectID)

    if (act ~= 'delete') then
        ui_network:setParam('lv', self.m_lv)
    end

    if (act == 'update') then
        -- 옵션 변경
        if (map['mopt']) then
            ui_network:setParam('mopt', string.format('%s,%d', self.m_mOpt['mopt'], self.m_mVal['mopt']))
        end
        if (map['uopt']) then
            ui_network:setParam('uopt', string.format('%s,%d', self.m_mOpt['uopt'], self.m_mVal['uopt']))
        end

        for i = 1, 4 do
            if (map['sopt_' .. i]) then
                ui_network:setParam('sopt', string.format('%d,%s', i, self.m_mOpt['sopt_' .. i]))
                ui_network:setParam('sopt_val', string.format('%d,%d', i, self.m_mVal['sopt_' .. i]))
            end
        end

    elseif (act == 'delete') then
        -- 옵션 삭제
        local t_rune_data = g_runesData:getRuneObject(self.m_runeObjectID)

        for k, _ in pairs(map) do
            local opt, opt_val = t_rune_data:parseRuneOptionStr(t_rune_data[k])

            if (k == 'mopt') then
                ui_network:setParam(k, string.format('%s,%d', opt, opt_val))

            elseif (k == 'uopt') then
                ui_network:setParam(k, string.format('%s,%d', opt, opt_val))

            elseif (string.find(k, 'sopt_')) then
                local idx = string.gsub(k, 'sopt_', '')

                ui_network:setParam('sopt', string.format('%d,%s', idx, opt))
                ui_network:setParam('sopt_val', string.format('%d,%d', idx, opt_val))
            end
        end
    end

    ui_network:setSuccessCB(function(ret)
        if ret and ret['rune'] then
            g_runesData:applyRuneData(ret['rune'])
        end

        next_cb()
    end)
    ui_network:request()
end


-------------------------------------
-- function makeComboBox
-------------------------------------
function UI_RuneDevApiPopup:makeComboBox(key, list)
    local button = self.m_mUiBtn[key]
    local label = self.m_mUiLabel[key]

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()
    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic.m_buttonHeight = 34
    uic:setNormalSize(width, height)
    --uic:setPosition(x, y)
    uic:setPosition(x + 300, 330)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

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
    
    parent:addChild(uic.m_node)

    for i, type in ipairs(list) do
        local str = self.opt_str(type)
        uic:addSortType(type, str)
    end

	uic:setSortChangeCB(function(type)
        self.m_mOpt[key] = type

        self.m_openedComboBox = nil

        -- 메인 옵션 타입이 변경된 경우면 강화 단계에 따른 현재 옵션값을 재계산해야함
        if (key == 'mopt') then
            self:setLv(self.m_lv)
        else
            self.m_mVal[key] = 1
        end

        self:refresh()
    end)

    return uic
end


-------------------------------------
-- function setRuneObject
-- @brief
-------------------------------------
function UI_RuneDevApiPopup:setRuneObject()
    local vars = self.vars

    local rune_obj = g_runesData:getRuneObject(self.m_runeObjectID)

    -- 현재 룬 옵션 임시 저장
    rune_obj['lv'] = self.m_lv
    for i, v in ipairs(StructRuneObject.OPTION_LIST) do
        if ((self.m_mOpt[v] ~= nil) and (self.m_mVal[v] ~= nil)) then
            rune_obj[v] = string.format('%s;%s', self.m_mOpt[v], self.m_mVal[v])
        else
            rune_obj[v] = ''
        end
    end

    -- 룬 명칭
    local name = rune_obj['name']
    if ((self.m_mVal['uopt'] ~= nil)) then
        local option = self.m_mOpt['uopt']
        local prefix = TableOption:getRunePrefix(option)

        if (prefix ~= '') then
            name = prefix .. ' ' .. name
        end
    end
    vars['useRuneNameLabel']:setString(name)

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['useRuneNode']:addChild(rune_icon.root)

    -- 세트 옵션
    vars['useRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())

    do -- 레어도
        local color = rune_obj:getRarityColor()
        vars['useRuneNameLabel']:setColor(color)
        vars['useRarityNode']:setColor(color)

        local name = rune_obj:getRarityName()
        vars['useRarityLabel']:setString(name)
    end

    if (self.m_optionLabel == nil) then
        self.m_optionLabel = rune_obj:getOptionLabel()
        self.vars['useRuneDscNode']:addChild(self.m_optionLabel.root)
    end
    
    rune_obj:setOptionLabel(self.m_optionLabel, 'use') -- param : ui, label_format, show_change
end
