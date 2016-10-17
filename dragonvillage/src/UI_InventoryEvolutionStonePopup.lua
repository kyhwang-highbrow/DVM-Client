local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_InventoryEvolutionStonePopup
-------------------------------------
UI_InventoryEvolutionStonePopup = class(PARENT, {
        m_selectedEvolutionStoneRarity = 'number',  -- 선택된 진화석의 레어도
        m_selectedEvolutionStoneAttr = 'string',    -- 선택된 진화석의 속성
        m_upgradeCount = 'number', -- 한 번에 진화석 업그레이드시킬 갯수
        m_lUpgradeCountBtn = 'list[button]',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryEvolutionStonePopup:init()
    local vars = self:load('inventory_evolution_stone_popup.ui')
    UIManager:open(self, UIManager.POPUP)


    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_InventoryEvolutionStonePopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_InventoryEvolutionStonePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_InventoryEvolutionStonePopup'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_InventoryEvolutionStonePopup:click_exitBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:close()
end

-------------------------------------
-- function initUI
-- @brief UI 초기화
-------------------------------------
function UI_InventoryEvolutionStonePopup:initUI()
    local vars = self.vars
    
    -- 업그레이드 버튼 초기화
    vars['priceLabel']:setString('0')
    vars['upgradeBtn']:setEnabled(false)

    vars['gradeLabel1']:setString('')
    vars['evolutionLabel1']:setString('')
    vars['numberLabel1']:setString('')

    vars['gradeLabel2']:setString('')
    vars['evolutionLabel2']:setString('')
    vars['numberLabel2']:setString('')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_InventoryEvolutionStonePopup:initButton()
    local vars = self.vars

    -- 진화석 교환 갯수 (1, 5, 25, 50) 버튼
    vars['oneBtn']:registerScriptTapHandler(function() self:click_countBtn(1) end)
    vars['fiveBtn']:registerScriptTapHandler(function() self:click_countBtn(5) end)
    vars['twentyFiveBtn']:registerScriptTapHandler(function() self:click_countBtn(25) end)
    vars['fiftyBtn']:registerScriptTapHandler(function() self:click_countBtn(50) end)

    self.m_lUpgradeCountBtn = {}
    self.m_lUpgradeCountBtn[1] = vars['oneBtn']
    self.m_lUpgradeCountBtn[5] = vars['fiveBtn']
    self.m_lUpgradeCountBtn[25] = vars['twentyFiveBtn']
    self.m_lUpgradeCountBtn[50] = vars['fiftyBtn']

    do -- 진화석 개별 버튼
        local t_data = g_evolutionStoneData.m_tData

        for rarity,t in pairs(t_data) do
            local rarity = tonumber(rarity)
            local rarity_str = ''
            if (rarity==1) then      rarity_str = 'Common'
            elseif (rarity==2) then  rarity_str = 'Rare'
            elseif (rarity==3) then  rarity_str = 'Hero'
            elseif (rarity==4) then  rarity_str = 'Legend'
            end

            for attr,v in pairs(t) do
                local ui_key = attr .. rarity_str .. 'Btn'
                vars[ui_key]:registerScriptTapHandler(function() self:click_evolutionStoneItem(rarity, attr) end)
            end
        end
    end

    -- 업그레이드 버튼
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_InventoryEvolutionStonePopup:refresh()
    -- 진화석 갯수 갱신
    self:refresh_evolutionStoneCount()

    -- 선택된 진화석 정보 갱신
    self:refresh_selectEvolutionStone()
    self:refresh_selectEvolutionStoneNext()
end

-------------------------------------
-- function refresh_selectEvolutionStone
-- @brief 선택된 진화석 정보 갱신
-------------------------------------
function UI_InventoryEvolutionStonePopup:refresh_selectEvolutionStone()
    local vars = self.vars
    local rarity = self.m_selectedEvolutionStoneRarity
    local attr = self.m_selectedEvolutionStoneAttr

    -- 진화석 아이콘 삭제
    vars['itemNode1']:removeAllChildren()

    if (not rarity) or (not attr) then
        return
    end
    
    do -- 아이콘 아이콘 생성
        vars['itemNode1']:removeAllChildren()
        local full_type = g_evolutionStoneData:makeEvolutionStoneFullType(rarity, attr)
        local icon = IconHelper:getItemIcon(full_type)
        vars['itemNode1']:addChild(icon)
    end

    do -- 진화석 등급
        local str = g_evolutionStoneData:evolutionStoneRarityNumToStr(rarity)
        vars['gradeLabel1']:setString(str)
    end

    do -- 진화석 이름
        local str = g_evolutionStoneData:getEvolutionStoneName(rarity, attr)
        vars['evolutionLabel1']:setString(str)
    end

    do -- 진화석 갯수
        local count = g_evolutionStoneData:getEvolutionStoneCount(rarity, attr)
        local need_count, need_gold = g_evolutionStoneData:getUpgradeInfo(rarity, attr)
        vars['numberLabel1']:setString(Str('{1}/{2}', count, need_count))
    end
end

-------------------------------------
-- function refresh_selectEvolutionStoneNext
-- @brief 선택된 진화석 정보 갱신
-------------------------------------
function UI_InventoryEvolutionStonePopup:refresh_selectEvolutionStoneNext()
    local vars = self.vars
    local rarity = self.m_selectedEvolutionStoneRarity
    local attr = self.m_selectedEvolutionStoneAttr

    -- 진화석 아이콘 삭제
    vars['itemNode2']:removeAllChildren()

    if (not rarity) or (not attr) then
        return
    end

    -- 다음 단계 진화석
    rarity = rarity + 1

    if (rarity <= 4) then
        do -- 아이콘 아이콘 생성
            vars['itemNode2']:removeAllChildren()
            local full_type = g_evolutionStoneData:makeEvolutionStoneFullType(rarity, attr)
            local icon = IconHelper:getItemIcon(full_type)
            vars['itemNode2']:addChild(icon)
        end

        do -- 진화석 등급
            local str = g_evolutionStoneData:evolutionStoneRarityNumToStr(rarity)
            vars['gradeLabel2']:setString(str)
        end

        do -- 진화석 이름
            local str = g_evolutionStoneData:getEvolutionStoneName(rarity, attr)
            vars['evolutionLabel2']:setString(str)
        end

        do -- 진화석 갯수
            local count = g_evolutionStoneData:getEvolutionStoneCount(rarity, attr)
            local need_count, need_gold = g_evolutionStoneData:getUpgradeInfo(rarity, attr)

            if need_count then
                vars['numberLabel2']:setString(Str('{1}/{2}', count, need_count))
            else
                vars['numberLabel2']:setString(tostring(count))
            end
        end    
    else
        vars['gradeLabel2']:setString('')
        vars['evolutionLabel2']:setString('')
        vars['numberLabel2']:setString('')
    end
    
    
end

-------------------------------------
-- function refresh_evolutionStoneCount
-- @brief 진화석 갯수 갱신
-------------------------------------
function UI_InventoryEvolutionStonePopup:refresh_evolutionStoneCount()
    local vars = self.vars
    local t_data = g_evolutionStoneData.m_tData

    for i,t in pairs(t_data) do
        local i = tonumber(i)
        local rarity_str = ''
        if (i==1) then
            rarity_str = 'Common'
        elseif (i==2) then
            rarity_str = 'Rare'
        elseif (i==3) then
            rarity_str = 'Hero'
        elseif (i==4) then
            rarity_str = 'Legend'
        end

        for key,v in pairs(t) do
            local ui_key = key .. rarity_str .. 'Label'
            vars[ui_key]:setString(comma_value(v))
        end
    end
end

-------------------------------------
-- function click_evolutionStoneItem
-- @breif 진화석 개별 버튼 클릭
-------------------------------------
function UI_InventoryEvolutionStonePopup:click_evolutionStoneItem(rarity, attr)
    SoundMgr:playEffect('EFFECT', 'ui_button')
    if (self.m_selectedEvolutionStoneRarity == rarity) and (self.m_selectedEvolutionStoneAttr == attr) then
        return
    end

    self.m_selectedEvolutionStoneRarity = rarity
    self.m_selectedEvolutionStoneAttr = attr

    self.m_upgradeCount = 0

    self:refresh()
    self:setUpgradeCount(1)
end

-------------------------------------
-- function click_countBtn
-- @breif 진화석 교환 갯수 버튼
-------------------------------------
function UI_InventoryEvolutionStonePopup:click_countBtn(count)
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:setUpgradeCount(count)
end

-------------------------------------
-- function setUpgradeCount
-- @breif
-------------------------------------
function UI_InventoryEvolutionStonePopup:setUpgradeCount(count)
    if (not self.m_selectedEvolutionStoneRarity) or (not self.m_selectedEvolutionStoneAttr) then
        return false
    end

    if (count <= 0) then
        return false
    end

    -- 갯수 지정
    self.m_upgradeCount = count

    -- 변수들 정리
    local vars = self.vars
    local max_rarity = 4
    local rarity = self.m_selectedEvolutionStoneRarity
    local attr = self.m_selectedEvolutionStoneAttr
    local is_max_rarity = (max_rarity <= rarity)

    -- 최고 레어도 진화석일 경우
    if is_max_rarity then
        vars['priceLabel']:setString('0')
        vars['upgradeBtn']:setEnabled(false)
        return
    end

    -- 진화석업그레이드 정보 얻어옴
    local need_count, need_gold = g_evolutionStoneData:getUpgradeInfo(rarity, attr)
    vars['priceLabel']:setString(comma_value(need_gold * count))
    vars['upgradeBtn']:setEnabled(true)

    do -- 버튼 상태 변경
        for _,button in pairs(self.m_lUpgradeCountBtn) do
            button:setEnabled(true)
        end
        self.m_lUpgradeCountBtn[count]:setEnabled(false)
    end

    return true
end

-------------------------------------
-- function click_upgradeBtn
-- @breif 진화석 교환 업그레이드(교환)
-------------------------------------
function UI_InventoryEvolutionStonePopup:click_upgradeBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    
    local rarity = self.m_selectedEvolutionStoneRarity
    local attr = self.m_selectedEvolutionStoneAttr
    local count = self.m_upgradeCount

    if (not rarity) or (not attr) then
        return
    end

    local success, l_invalid_data = g_evolutionStoneData:upgradeEvolutionStone(rarity, attr, count)

    if (success == true) then
        self:refresh()
    else
        if l_invalid_data then
            for _,t_invalid_data in ipairs(l_invalid_data) do
                UIManager:toastNotificationRed(t_invalid_data['msg'])
            end
        end
    end
end
