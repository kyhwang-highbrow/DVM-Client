local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Hatchery
-------------------------------------
UI_Hatchery = class(PARENT,{
        m_npcAnimator = 'Animator',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Hatchery:init(tab)
    local vars = self:load('hatchery.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Hatchery')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    if tab then
        self:setTab(tab)
    end
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_Hatchery:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Hatchery'
    self.m_titleStr = Str('부화소')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'fp' -- 우정포인트
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Hatchery:initUI()
    do -- NPC
        local res = 'res/character/npc/yuria/yuria.spine'
        local animator = MakeAnimator(res)
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)
        self.vars['npcNode']:addChild(animator.m_node)
        self.m_npcAnimator = animator
    end

    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Hatchery:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Hatchery:refresh()
    self:refresh_highlight()
    self:refresh_mileage()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Hatchery:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Hatchery:initTab()
    local vars = self.vars


    local summon_tab = UI_HatcherySummonTab(self)
    local incubate_tab = UI_HatcheryIncubateTab(self)
    local combine_tab = UI_HatcheryCombineTab(self)
    local relation_tab = UI_HatcheryRelationTab(self)
    vars['indivisualTabMenu']:addChild(summon_tab.root)
    vars['indivisualTabMenu']:addChild(incubate_tab.root)
    vars['indivisualTabMenu']:addChild(combine_tab.root)
    vars['indivisualTabMenu']:addChild(relation_tab.root)

    self:addTabWithTabUIAndLabel('summon', vars['summonTabBtn'], vars['summonTabLabel'], summon_tab)       -- 소환
    self:addTabWithTabUIAndLabel('incubate', vars['incubateTabBtn'], vars['incubateTabLabel'], incubate_tab) -- 부화
    self:addTabWithTabUIAndLabel('combine', vars['combineTabBtn'], vars['combineTabLabel'], combine_tab)    -- 조합
    self:addTabWithTabUIAndLabel('relation', vars['relationTabBtn'], vars['relationTabLabel'], relation_tab) -- 인연

    self:setTab('summon')
end


-- 이정보는 어디서 받아올지 찾아야함
local L_MILEAGE_INFO = {
    {
        ['mileage'] = 50,
        ['egg_id'] = 703004
    },
    {
        ['mileage'] = 170,
        ['egg_id'] = 703002
    },
    {
        ['mileage'] = 260,
        ['egg_id'] = 703019
    },
    {
        ['mileage'] = 700,
        ['egg_id'] = 703003
    },
    {
        ['mileage'] = 1500,
        ['egg_id'] = 703005
    },
}

-------------------------------------
-- function refresh_mileage
-------------------------------------
function UI_Hatchery:refresh_mileage()
    local vars = self.vars
    local mileage = g_userData:get('mileage')

    -- 마일리지 표시
    vars['mileageLabel']:setString(comma_value(mileage))
    vars['mileageGauge']:setPercentage(0)
    vars['mileageGauge']:runAction(cc.ProgressTo:create(0.5, mileage/1500*100))

    -- 마일리지 샵
    vars['mileageBtn']:registerScriptTapHandler(function()
        -- navigator에 붙여야겠다
        g_shopDataNew:openShopPopup('mileage')
    end)

    -- 마일리지 노드 생성
    for i, t_mileage in ipairs(L_MILEAGE_INFO) do
        local ui = UI()
        local ui_vars = ui:load('hatchery_mileage_item.ui')
        
        -- 마일리지
        local need_mileage = t_mileage['mileage']
        ui_vars['mileageLabel']:setString(need_mileage)
        
        -- 아이콘
        local item_id = t_mileage['egg_id']
        local item_card = UI_ItemCard(item_id, 1)
        item_card.vars['bgSprite']:setVisible(false)
        item_card.vars['commonSprite']:setVisible(false)
        item_card.vars['numberLabel']:setVisible(false)
        ui_vars['itemNode']:addChild(item_card.root)
        
        -- 잠금 표시
        if (need_mileage > mileage) then
            ui_vars['lockSprite']:setVisible(true)
        end

        vars['mileageNode' .. i]:removeAllChildren(true)
        vars['mileageNode' .. i]:addChild(ui.root)
    end
end

-------------------------------------
-- function refresh_highlight
-------------------------------------
function UI_Hatchery:refresh_highlight()
    local vars = self.vars

    local highlight, t_highlight = g_hatcheryData:checkHighlight()
    vars['summonNotiSprite']:setVisible(t_highlight['summon'])
    vars['incubateNotiSprite']:setVisible(t_highlight['incubate'])
    vars['relationNotiSprite']:setVisible(t_highlight['relation'])
    vars['combineNotiSprite']:setVisible(t_highlight['combine'])
end

-------------------------------------
-- function showNpc
-------------------------------------
function UI_Hatchery:showNpc()
    self.m_npcAnimator:setVisible(true)
end

-------------------------------------
-- function hideNpc
-------------------------------------
function UI_Hatchery:hideNpc()
    self.m_npcAnimator:setVisible(false)
end

-------------------------------------
-- function showMileage
-------------------------------------
function UI_Hatchery:showMileage()
    self.vars['mileageMenu']:setVisible(true)
end

-------------------------------------
-- function hideMileage
-------------------------------------
function UI_Hatchery:hideMileage()
    self.vars['mileageMenu']:setVisible(false)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Hatchery:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)
end