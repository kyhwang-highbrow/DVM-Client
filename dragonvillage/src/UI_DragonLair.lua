local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonLair
-------------------------------------
UI_DragonLair = class(PARENT,{
    m_cardList = 'List<UI_DragonCard>',
    
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
    self:initTab()
    self:initButton()
    self:refresh()
    self:checkCompleteAllSlots()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLair:initUI()
    local vars = self.vars
end


-------------------------------------
-- function checkCompleteAllSlots
-------------------------------------
function UI_DragonLair:checkCompleteAllSlots()
    local vars = self.vars
    
    -- ok 콜백
    local ok_btn_cb = function ()
        local sucess_cb = function (ret)
            self:refresh()
            self:apply_dragonSort()
        end

        g_lairData:request_lairComplete(sucess_cb)
    end

    -- 동굴 슬롯 완성했는지
    if g_lairData:isLairSlotComplete() == true then
        local msg = Str('말판을 완성하였습니다.')
        local submsg = Str('말판이 새로고침됩니다.')
        local ui = MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, ok_btn_cb)
    end
end



-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLair:initTab()
    local vars = self.vars

    local add_tab = UI_DragonLairRegisterTab(self)
    local remove_tab = UI_DragonLairUnregisterTab(self)

    vars['indivisualTabMenu']:addChild(add_tab.root)
    vars['indivisualTabMenu']:addChild(remove_tab.root)

    self:addTabWithTabUIAndLabel('add', vars['addTabBtn'], vars['addTabLabel'], add_tab)       -- 정보
    self:addTabWithTabUIAndLabel('remove', vars['removeTabBtn'], vars['removeTabLabel'], remove_tab) -- 관리

    self:setTab('add')
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
-- function apply_dragonSort
-------------------------------------
function UI_DragonLair:apply_dragonSort()
    for _, v in pairs(self.m_mTabData) do
        if v['ui'] ~= nil then
            v['ui']:apply_dragonSort()
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLair:refresh()
    local vars = self.vars
    
    for type = 1, 5 do
        local stat_id_list, stat_count = g_lairData:getLairStatIdList(type)
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

    require('UI_DragonCard_Flip')
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

        local card_ui = UI_DragonCard_Flip(StructDragonObject(t_dragon_data))
        self.m_cardList[i] = card_ui
        card_ui:openCard()
     --[[        card_ui:openCard()

            cclog('여기 안들어놔??')
        end) ]]
        
        --card_ui:setHighlightSpriteVisible(is_register_dragon)

        vars[node_str]:removeAllChildren()
        vars[node_str]:addChild(card_ui.root)
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
            self:apply_dragonSort()
            self:refresh()

            
            SoundMgr:playEffect('UI', 'ui_card_flip')
        end
    
        g_lairData:request_lairReload(success_cb)
    end

    local msg = Str('말판 새로고침')
    local submsg = Str('다이아 500개를 소모해서 새로고침 하시겠습니까?')
    local ui = MakeSimplePricePopup(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
    ui:setPrice('cash', 500)
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
