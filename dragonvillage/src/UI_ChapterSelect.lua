local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChapterSelect
-------------------------------------
UI_ChapterSelect = class(PARENT,{
        m_difficulty = 'number',
        m_target = 'number',
        m_refreshFunc = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChapterSelect:init(target_difficulty, refresh_func)
    self.m_target = target_difficulty
    self.m_refreshFunc = refresh_func

    local vars = self:load('adventure_chapter_select.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChapterSelect')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChapterSelect:initUI()
    local vars = self.vars
    
    self:addTabWithLabel(1, vars['normalBtn'], vars['normalLabel'])
    self:addTabWithLabel(2, vars['hardBtn'], vars['hardLabel'])
    self:addTabWithLabel(3, vars['hellBtn'], vars['hellLabel'])
    self:addTabWithLabel(4, vars['hellFireBtn'], vars['hellFireLabel'])
    self:addTabWithLabel(5, vars['abyss_0Btn'], vars['abyss_0Label'])
    self:setTab(self.m_target)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChapterSelect:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ChapterSelect:onChangeTab(tab, first)
    self.m_difficulty = tonumber(tab)
    self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChapterSelect:refresh()
    local vars = self.vars
    local difficulty = self.m_difficulty
    local stage_id = 1 -- 1 스테이지 오픈되었는지로 검사
    
    for chapter = 1, MAX_ADVENTURE_CHAPTER do
        local node = vars['chapterNode'..chapter]
        node:removeAllChildren()

        local target_id = makeAdventureID(difficulty, chapter, stage_id)
        local ui = UI_ChapterSelectListItem(self, target_id)
        node:addChild(ui.root)
    end
end

-------------------------------------
-- function setRefreshClose
-------------------------------------
function UI_ChapterSelect:setRefreshClose(stage_id)
    if (not stage_id) then
        return 
    end

    if (self.m_refreshFunc) then
        self.m_refreshFunc(stage_id)
    end

    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ChapterSelect:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ChapterSelect)
