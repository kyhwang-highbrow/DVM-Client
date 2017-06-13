local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Hatchery
-------------------------------------
UI_Hatchery = class(PARENT,{
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Hatchery:initUI()
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Hatchery:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Hatchery:refresh()
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
    local relation_tab = UI_IndivisualTab(self)
    vars['indivisualTabMenu']:addChild(summon_tab.root)
    vars['indivisualTabMenu']:addChild(incubate_tab.root)
    vars['indivisualTabMenu']:addChild(combine_tab.root)
    --vars['indivisualTabMenu']:addChild(relation_tab.root)

    self:addTabWidthTabUI('summon', vars['summonBtn'], summon_tab)       -- 소환
    self:addTabWidthTabUI('incubate', vars['incubateBtn'], incubate_tab) -- 부화
    self:addTabWidthTabUI('combine', vars['combineBtn'], combine_tab)    -- 조합
    self:addTabWidthTabUI('relation', vars['relationBtn'], relation_tab) -- 인연

    self:setTab('incubate')
end