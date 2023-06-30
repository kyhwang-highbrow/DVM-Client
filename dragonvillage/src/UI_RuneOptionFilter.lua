local PARENT = UI

-------------------------------------
-- class UI_RuneOptionFilter
-------------------------------------
UI_RuneOptionFilter = class(PARENT,{
        m_lOptDataList = 'list', -- 옵션 정보(옵션 키, 옵션 텍스트) 가지고 있는 리스트
        m_mMoptStatus = 'map', -- 해당 옵션이 선택되어 있는지 map[opt_type] = true/false
        m_mSoptStatus = 'map', -- 해당 옵션이 선택되어 있는지 map[opt_type] = true/false

        m_bDirty = 'boolean', -- 세팅 정보가 바뀌었는지
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneOptionFilter:init(l_mopt_list, l_sopt_list, b_include_equipped)
    local vars = self:load('dragon_rune_sort_opt.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_RuneOptionFilter')

    self:doActionReset()
    self:doAction(nil, false)

    local l_option_data_list = {}
    table.insert(l_option_data_list, {'all', Str('전체')})
	table.insert(l_option_data_list, {'aspd_add', Str('공격 속도') .. ' %'})
    table.insert(l_option_data_list, {'atk_multi', Str('공격력') .. ' %'})
    table.insert(l_option_data_list, {'atk_add', Str('공격력') .. ' +'})
    table.insert(l_option_data_list, {'def_multi', Str('방어력') .. ' %'})
    table.insert(l_option_data_list, {'def_add', Str('방어력') .. ' +'})
    table.insert(l_option_data_list, {'hp_multi', Str('생명력') .. ' %'})
    table.insert(l_option_data_list, {'hp_add', Str('생명력') .. ' +'})
    table.insert(l_option_data_list, {'cri_chance_add', Str('치명 확률') .. ' %'})
    table.insert(l_option_data_list, {'cri_dmg_add', Str('치명 피해') .. ' %'})
    table.insert(l_option_data_list, {'hit_rate_add', Str('적중') .. ' %'})
    table.insert(l_option_data_list, {'avoid_add', Str('회피') .. ' %'})
    table.insert(l_option_data_list, {'accuracy_add', Str('효과 적중') .. ' %'})
    table.insert(l_option_data_list, {'resistance_add', Str('효과 저항') .. ' %'})
    self.m_lOptDataList= l_option_data_list
    
    self.m_mMoptStatus = {}
    self.m_mSoptStatus = {}

    for idx, opt_data in ipairs(self.m_lOptDataList) do
        local opt_type = opt_data[1]
        self.m_mMoptStatus[opt_type] = false
        self.m_mSoptStatus[opt_type] = false
    end
    
    if (l_mopt_list ~= nil) then
        for idx, opt_type in ipairs(l_mopt_list) do
            self.m_mMoptStatus[opt_type] = true
        end
    else
        self.m_mMoptStatus['all'] = true
    end
    
    if (l_sopt_list ~= nil) then
        for idx, opt_type in ipairs(l_sopt_list) do
            self.m_mSoptStatus[opt_type] = true
        end

    else
        self.m_mSoptStatus['all'] = true
    end
    
    self.m_bDirty = false

    if (b_include_equipped ~= nil) then
        -- 매개변수 바로 활용하기 위해 여기서 체크박스 초기화함
        vars['equipBtn'] = UIC_CheckBox(vars['equipBtn'].m_node, vars['equipSprite'], b_include_equipped)
        vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
    
    else
        vars['equipBtn']:setVisible(false)
    end

    do -- 룬점수 보기
        local look_rune_filter_point = g_settingData:get('option_rune_filter', 'look_rune_filter_point')
        vars['pointBtn'] = UIC_CheckBox(vars['pointBtn'].m_node, vars['pointSprite'], look_rune_filter_point)
        vars['pointBtn']:registerScriptTapHandler(function() self:click_pointBtn() end)
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneOptionFilter:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneOptionFilter:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)

    for _, opt_category in ipairs({'mopt', 'sopt'}) do
        for idx, opt_data in ipairs(self.m_lOptDataList) do
            local opt_type = opt_data[1]
            local opt_str = opt_data[2]

            vars[opt_category .. tostring(idx) .. 'Btn']:registerScriptTapHandler(function() self:click_optionBtn(opt_category, opt_type) end)
            vars[opt_category .. tostring(idx) .. 'ActiveBtn']:registerScriptTapHandler(function() self:click_optionBtn(opt_category, opt_type) end)
            
            vars[opt_category .. tostring(idx) .. 'Label']:setString(opt_str)
            vars[opt_category .. tostring(idx) .. 'ActiveLabel']:setString(opt_str)
        end
    end


end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneOptionFilter:refresh()
    local vars = self.vars

    local select_label_color = cc.c4b(0, 0, 0, 255)
    local not_select_label_color = cc.c4b(240, 215, 159, 255)

    -- 선택되어 있는 옵션의 경우 표시
    for idx, opt_data in ipairs(self.m_lOptDataList) do
        local opt_type = opt_data[1]
        
        -- 라벨 색 변화   
        vars['mopt' .. tostring(idx) .. 'ActiveBtn']:setVisible((self.m_mMoptStatus[opt_type] == true))
        vars['sopt' .. tostring(idx) .. 'ActiveBtn']:setVisible((self.m_mSoptStatus[opt_type] == true))
    end
end

-------------------------------------
-- function click_optionBtn
-- @param opt_category : [mopt, sopt], 주옵션인지 보조옵션인지
-- @param opt_type : atk_multi, atk_add, ... 옵션 종류
-------------------------------------
function UI_RuneOptionFilter:click_optionBtn(opt_category, opt_type)
    local vars = self.vars
    local m_option_status = (opt_category == 'mopt') and self.m_mMoptStatus or self.m_mSoptStatus

    -- '전체' 옵션을 선택한 경우
    if (opt_type == 'all') then
        if (m_option_status['all'] == true) then
            return
        end
        
        -- 다른 개별 옵션들을 전부 끈다. 
        for idx, option_data in ipairs(self.m_lOptDataList) do
            local option = option_data[1]
            local b_is_active = m_option_status[option]

            if (option ~= 'all') and (b_is_active == true) then
                m_option_status[option] = false
            end
        end
        
        m_option_status['all'] = true

    -- 개별 옵션을 선택한 경우
    else
        -- '전체' 옵션이 켜져있던 경우 끈다.
        if (m_option_status['all'] == true) then
            m_option_status['all'] = false
        end

        m_option_status[opt_type] = not m_option_status[opt_type]
        
        -- 단일 옵션 체크인 경우 해당 옵션을 키게 될 때 다른 옵션 꺼준다
        if ((m_option_status[opt_type] == true) and (opt_category == 'mopt')) then
            for idx, option_data in ipairs(self.m_lOptDataList) do
                local option = option_data[1]
                local b_is_active = m_option_status[option]

                if (option ~= opt_type) and (b_is_active == true) then
                    m_option_status[option] = false
                end
            end
        end
        
        -- 모든 옵션이 꺼진 경우 '전체' 옵션을 켜준다.
        local b_is_all_inactive = true
        for idx, option_data in ipairs(self.m_lOptDataList) do
            local option = option_data[1]
            local b_is_active = m_option_status[option]
            
            if (b_is_active == true) then
                b_is_all_inactive = false
                break
            end
        end

        if (b_is_all_inactive == true) then
            m_option_status['all'] = true
        end
    end

    self.m_bDirty = true
    self:refresh()
end

-------------------------------------
-- function click_equipBtn
-------------------------------------
function UI_RuneOptionFilter:click_equipBtn()
    local vars = self.vars

    self.m_bDirty = true
end

-------------------------------------
-- function click_pointBtn
-------------------------------------
function UI_RuneOptionFilter:click_pointBtn()
    local vars = self.vars

    self.m_bDirty = true
end

-------------------------------------
-- function click_refreshBtn
-------------------------------------
function UI_RuneOptionFilter:click_refreshBtn()
    local vars = self.vars

    for idx, opt_data in ipairs(self.m_lOptDataList) do
        local opt_type = opt_data[1]
        self.m_mMoptStatus[opt_type] = false
        self.m_mSoptStatus[opt_type] = false
    end
    self.m_mMoptStatus['all'] = true
    self.m_mSoptStatus['all'] = true

    if (vars['equipBtn']:isVisible()) then
        b_include_equipped = vars['equipBtn']:setChecked(false)
    end

    self.m_bDirty = true
    self:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_RuneOptionFilter:click_closeBtn()
    if (self.m_closeCB) and (self.m_bDirty == true) then
        local vars = self.vars
        local l_mopt_list = self:getOptionList('mopt')
        local l_sopt_list = self:getOptionList('sopt')
        local b_include_equipped = nil
        b_include_equipped = not vars['equipBtn']:isChecked()

        g_settingData:lockSaveData()
        g_settingData:applySettingData(b_include_equipped, 'option_rune_filter', 'not_include_equipped')
        g_settingData:applySettingData(vars['pointBtn']:isChecked(), 'option_rune_filter', 'look_rune_filter_point')
        g_settingData:unlockSaveData()
        
        self.m_closeCB(l_mopt_list, l_sopt_list, b_include_equipped)
    end

    self.m_closeCB = nil
    self:close()
end

-------------------------------------
-- function getOptionList
-- @return nil 반환하면 전체 옵션, list 반환하면 해당 옵션만
-------------------------------------
function UI_RuneOptionFilter:getOptionList(opt_category)
    local l_option_list = {}
    local m_option_status = (opt_category == 'mopt') and self.m_mMoptStatus or self.m_mSoptStatus

    if (m_option_status['all'] == false) then
        for option, b_is_active in pairs(m_option_status) do
            if (b_is_active == true) then
                table.insert(l_option_list, option)
            end
        end
    else
        l_option_list = nil
    end

    return l_option_list
end


--@CHECK
UI:checkCompileError(UI_RuneOptionFilter)
