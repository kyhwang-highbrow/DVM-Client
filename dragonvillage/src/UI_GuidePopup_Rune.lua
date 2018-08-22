local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_GuidePopup_Rune
-------------------------------------
UI_GuidePopup_Rune = class(PARENT,{
    })

UI_GuidePopup_Rune.SUMMARY = 'summary' -- 론 개요
UI_GuidePopup_Rune.NUMBER = 'number' -- 룬 번호
UI_GuidePopup_Rune.TYPE = 'type' -- 룬 종류
UI_GuidePopup_Rune.ENHANCE = 'enhance' -- 룬 강화
UI_GuidePopup_Rune.NIGHTMARE = 'nightmare' -- 악몽 던전
UI_GuidePopup_Rune.ANCIENT_RUIN = 'ancient_ruin' -- 고대 유적 던전

-------------------------------------
-- function init
-------------------------------------
function UI_GuidePopup_Rune:init()
    local vars = self:load('rune_guide_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_GuidePopup_Rune')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GuidePopup_Rune:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GuidePopup_Rune:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GuidePopup_Rune:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_GuidePopup_Rune:initTab()
    local vars = self.vars

    self:addTabAuto(UI_GuidePopup_Rune.SUMMARY, vars, vars['summaryMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.NUMBER, vars, vars['numberMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.TYPE, vars, vars['typeMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.ENHANCE, vars, vars['enhanceMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.NIGHTMARE, vars, vars['nightmareMenu'])
    self:addTabAuto(UI_GuidePopup_Rune.ANCIENT_RUIN, vars, vars['ancient_ruinMenu'])

    self:setTab(UI_GuidePopup_Rune.SUMMARY)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_GuidePopup_Rune:onChangeTab(tab, first)
    -- 탭할때마다 액션 
    self:doActionReset()
    self:doAction(nil, false)  
end

--@CHECK
UI:checkCompileError(UI_GuidePopup_Rune)
