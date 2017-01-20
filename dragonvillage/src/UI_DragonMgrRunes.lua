local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())

local l_rune_slot_name = {}
l_rune_slot_name[1] = 'bellaria'
l_rune_slot_name[2] = 'tutamen'
l_rune_slot_name[3] = 'cimelium'

local l_rune_slot_idx = {}
for i,v in pairs(l_rune_slot_name) do
    l_rune_slot_idx[v] = i
end

-------------------------------------
-- class UI_DragonMgrRunes
-------------------------------------
UI_DragonMgrRunes = class(PARENT,{
        m_bChangeDragonList = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMgrRunes:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMgrRunes'
    self.m_bVisible = true or false
    self.m_titleStr = Str('룬') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMgrRunes:init(doid)
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_rune.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMgrRunes')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMgrRunes:initUI()
    local vars = self.vars
    self:init_dragonTableView()

    -- 룬 Tab 설정
    self:initUI_runeTab()
end

-------------------------------------
-- function initUI_runeTab
-- @brief 룰 슬롯 버튼 처리
-------------------------------------
function UI_DragonMgrRunes:initUI_runeTab()
    local vars = self.vars
    self:addTab(l_rune_slot_name[1], vars['runeSlotBtn1'], vars['runeSlotSelectSprite1'])
    self:addTab(l_rune_slot_name[2], vars['runeSlotBtn2'], vars['runeSlotSelectSprite2'])
    self:addTab(l_rune_slot_name[3], vars['runeSlotBtn3'], vars['runeSlotSelectSprite3'])
    self:setTab(l_rune_slot_name[1])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonMgrRunes:onChangeTab(tab)
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local t_runes = t_dragon_data['runes']
    local roid = t_runes[tab]

    local vars = self.vars

    if roid then
        vars['useMenu']:setVisible(true)

        local t_rune_infomation = g_runesData:getRuneInfomation(roid)
        --ccdump(t_rune_infomation)
        vars['useRuneNameLabel']:setString(t_rune_infomation['full_name'])

    else
        vars['useMenu']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonMgrRunes:initButton()
    local vars = self.vars
    --vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMgrRunes:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars


    do -- 선택중인 드래곤 아이콘
        local node = vars['dragonNode']
        node:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        node:addChild(dragon_card.root)

        -- UI 반응 액션
        cca.uiReactionSlow(dragon_card.root)
    end
    
    do -- 룬 아이콘
        local t_runes = t_dragon_data['runes']

        
        for i,slot_name in ipairs(l_rune_slot_name) do
            local roid = t_runes[slot_name]

            vars['runeSlot' .. i]:removeAllChildren()

            if roid then
                local t_rune_infomation = g_runesData:getRuneInfomation(roid)
                --ccdump(t_rune_infomation)
                local item_card = UI_ItemCard(t_rune_infomation['rid'], 1, t_rune_infomation)
                vars['runeSlot' .. i]:addChild(item_card.root)
            end
        end
    end

    self:refreshCurrTab()
end

-------------------------------------
-- function refresh_currDragonInfo
-- @brief 왼쪽 정보(현재 진화 단계)
-------------------------------------
function UI_DragonMgrRunes:refresh_currDragonInfo(t_dragon_data, t_dragon)
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonMgrRunes:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonMgrRunes)
