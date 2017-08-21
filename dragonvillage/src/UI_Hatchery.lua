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
function UI_Hatchery:init()
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
-- function onChangeTab
-------------------------------------
function UI_Hatchery:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)
end