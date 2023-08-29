local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonLair
-------------------------------------
UI_DragonLair = class(PARENT,{
    m_cardList = 'List<UI_DragonCard>',
    m_preAttr = 'string',
    m_attrRadioButton = 'UIC_RadioButton',
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
    self.m_cardList = {}
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonLair')

    self:sceneFadeInAction()
    self:initUI()

    self:initButton()
    self:refresh()

    self:update()
    self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLair:initUI()
    local vars = self.vars

    do -- 이름
        local season_name = g_lairData:getLairSeasonName()
        local season_desc = g_lairData:getLairSeasonDesc()
        vars['seasonNameLabel']:setString(string.format('%s {@R}(%s){@}', season_name, season_desc))
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLair:initButton()
    local vars = self.vars

    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
    vars['blessBtn']:registerScriptTapHandler(function() self:click_blessBtn() end)
    vars['registerBtn']:registerScriptTapHandler(function() self:click_registerBtn() end)

    --vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)

    if IS_TEST_MODE() == true then
        vars['resetBtn']:setVisible(true)        
        vars['resetBtn']:registerScriptTapHandler(function() self:click_resethBtn() end)
        --vars['autoReloadtBtn']:setVisible(true)        
        --vars['autoReloadtBtn']:registerScriptTapHandler(function() self:click_autoReloadBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLair:refresh()
    local vars = self.vars
    local table_option = TableOption()
    
    for type = 1, 5 do
        local option_key_list = g_lairData:getLairRepresentOptionKeyListByType(type)

        for idx, option_key in ipairs(option_key_list) do
            
            local option_value_sum, option_bonus_sum = g_lairData:getLairStatOptionValueSum(type ,option_key)
            local option_value_total = option_value_sum + option_bonus_sum
            local desc = table_option:getOptionDesc(option_key, option_value_total)

            local label_str = string.format('%dTypeLabel%d', type, idx)
            vars[label_str]:setVisible(false)

            local progress_label_str =  string.format('%dTypeProgressLabel%d', type, idx)
            if option_value_sum == 0 then
                vars[progress_label_str]:setString(desc)
            else
                vars[progress_label_str]:setString(string.format('{@ORANGE}%s(%d + {@green}%d{@}{@ORANGE}){@}',desc, option_value_sum, option_bonus_sum))
            end
        end

        --local progress_bar_str =  string.format('%dTypeProgress', type)
        --vars[progress_bar_str]:setPercentage(0)
    end

    do -- 레드닷
        vars['lairNotiSprite']:setVisible(g_lairData:isAvailableRegisterDragons())
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_DragonLair:update()
    local vars =  self.vars
    local text = Str('시즌 종료까지 {1}', g_lairData:getLairSeasonEndRemainTimeText())
    vars['remainTimeLabel']:setString(text)
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
-- function click_registerBtn
-------------------------------------
function UI_DragonLair:click_registerBtn()
    local ui = UI_DragonLairRegister.open()
    ui:setCloseCB(function ()
        self:refresh()
    end)
end

-------------------------------------
-- function click_resethBtn
-------------------------------------
function UI_DragonLair:click_resethBtn()
    local ok_btn_cb = function ()
        local success_cb = function (ret)
            self:close()
            UINavigator:goTo('lair')
        end
        g_lairData:request_lairSeasonResetManage(success_cb)
    end

    local msg = '시즌 초기화를 진행하겠습니까?(테스트 기능)'
    local submsg = '해당 버튼은 라이브환경에서는 노출되지 않습니다.'
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

--[[ 
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
            self:apply_dragonSort()
            self:refresh()

            SoundMgr:playEffect('UI', 'ui_card_flip')
        end

        g_lairData:request_lairAutoReloadManage(table.concat(result_list,','), success_cb)
    end

    local msg = '보유한 드래곤으로 슬롯을 리로드하시겠습니까?(테스트 기능)'
    local submsg = '해당 버튼은 라이브환경에서는 노출되지 않습니다.'
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end
 ]]


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
