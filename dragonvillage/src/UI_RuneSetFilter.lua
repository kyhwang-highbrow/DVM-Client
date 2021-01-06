local PARENT = UI

-------------------------------------
-- class UI_RuneSetFilter
-------------------------------------
UI_RuneSetFilter = class(PARENT,{
        m_selSetID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneSetFilter:init()
    local vars = self:load('dragon_rune_sort.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_RuneSetFilter')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneSetFilter:initUI()
    local vars = self.vars
    local table_rune_set = TableRuneSet()
    for i,v in ipairs(table_rune_set.m_orgTable) do
        local set_id = i
        local text = table_rune_set:makeRuneSetFullNameRichText(set_id)
        local label = vars['label'..set_id]
        if (label) then
            label:setString(text)
        end
    end

    -- 일반, 고대 필터
    vars['labelNormal']:setString(Str('일반 룬'))
    vars['labelAncient']:setString(Str('고대 룬'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneSetFilter:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_setFilter(set_id) end)

    -- 전체 정렬
    vars['allBtn']:registerScriptTapHandler(function() self:click_setFilter(0) end)

    local table_rune_set = TableRuneSet()
    for i,v in ipairs(table_rune_set.m_orgTable) do
        local set_id = i
        local text = table_rune_set:makeRuneSetFullNameRichText(set_id)
        local btn = vars['btn'..set_id]
        if (btn) then
            btn:registerScriptTapHandler(function() self:click_setFilter(set_id) end)
        end
    end

    -- 일반, 고대필터
    vars['btnNormal']:registerScriptTapHandler(function() self:click_setFilter('normal') end)
    vars['btnAncient']:registerScriptTapHandler(function() self:click_setFilter('ancient') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneSetFilter:refresh()
end

-------------------------------------
-- function click_setFilter
-------------------------------------
function UI_RuneSetFilter:click_setFilter(set_id)
    self.m_selSetID = set_id
    self:click_closeBtn()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_RuneSetFilter:click_closeBtn()
    local sel_set_id = self.m_selSetID 
    if (sel_set_id and self.m_closeCB) then
        self.m_closeCB(sel_set_id)
    end
    self.m_closeCB = nil
    self:close()
end

--@CHECK
UI:checkCompileError(UI_RuneSetFilter)
