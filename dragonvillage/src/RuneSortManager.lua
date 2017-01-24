
local t_sort_type = {}
table.insert(t_sort_type, 'hp')
table.insert(t_sort_type, 'def')
table.insert(t_sort_type, 'atk')
table.insert(t_sort_type, 'attr')
table.insert(t_sort_type, 'lv')
table.insert(t_sort_type, 'grade')
table.insert(t_sort_type, 'rarity')
table.insert(t_sort_type, 'friendship')

-------------------------------------
-- class RuneSortManager
-- @breif 보유하
-------------------------------------
RuneSortManager = class({
        vars = 'table',
        m_lTableView = 'list[UIC_TableView]',
        m_currSortType = 'string',
        m_bAscendingSort = 'boolean', -- 오름차순인지 여부

        -- 내부에서 별도로 사용하는 vars
        m_vars = 'table',

        m_bUseGlobalSetting = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function RuneSortManager:init()
    self.m_bUseGlobalSetting = false
    self.m_bAscendingSort = false
    self.m_lTableView = {}
end

-------------------------------------
-- function init_vars
-------------------------------------
function RuneSortManager:init_vars()
    self.m_vars = {}
    self.m_vars['sortBtn'] = self.vars['sortBtn'] 
    self.m_vars['sortOrderBtn'] = self.vars['sortOrderBtn'] 
    self.m_vars['sortNode'] = self.vars['sortNode']
    self.m_vars['sortOrderSprite'] = self.vars['sortOrderSprite']
    self.m_vars['sortLabel'] = self.vars['sortLabel']

    for i,v in ipairs(t_sort_type) do
        local luaname, luaname_org = self:getSortBtnName(firstLetterUpper(v))
        self.m_vars[luaname] = self.vars[luaname_org]
    end
end

-------------------------------------
-- function getSortBtnName
-------------------------------------
function RuneSortManager:getSortBtnName(type)
    return 'sort' .. type .. 'Btn', 'sort' .. type .. 'Btn'
end

-------------------------------------
-- function init_button
-------------------------------------
function RuneSortManager:init_button()
    local vars = self.m_vars

    -- 정렬 카테고리 on/off
    vars['sortBtn']:registerScriptTapHandler(function() self:click_sortBtn() end)

    -- 오름차순/내림차순
    vars['sortOrderBtn']:registerScriptTapHandler(function() self:click_sortOrderBtn() end)

    for i,v in ipairs(t_sort_type) do
        local luaname = self:getSortBtnName(firstLetterUpper(v))
        vars[luaname]:registerScriptTapHandler(function() self:click_sortTypeBtn(v) end)
    end
end

-------------------------------------
-- function click_sortBtn
-- @brief 정렬 카테고리 on/off
-------------------------------------
function RuneSortManager:click_sortBtn()
    local vars = self.m_vars
    vars['sortNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortOrderBtn
-- @brief 오름차순, 내림차순
-------------------------------------
function RuneSortManager:click_sortOrderBtn(b_ascending_sort, skip_change_sort)
    if (b_ascending_sort ~= nil) then
        self.m_bAscendingSort = b_ascending_sort
    else
        self.m_bAscendingSort = (not self.m_bAscendingSort)
    end
    local vars = self.m_vars

    if self.m_bAscendingSort then
        vars['sortOrderSprite']:setScaleY(-1)
    else
        vars['sortOrderSprite']:setScaleY(1)
    end

    if (not skip_change_sort) then
        self:changeSort()
    end
end

-------------------------------------
-- function click_sortTypeBtn
-- @brief
-------------------------------------
function RuneSortManager:click_sortTypeBtn(type, skip_change_sort)
    local vars = self.m_vars
    local str = self:getSortName(type)
    vars['sortLabel']:setString(str)

    self.m_currSortType = type

    if (not skip_change_sort) then
        self:changeSort()
    end
end


-------------------------------------
-- function getSortName
-- @brief
-------------------------------------
function RuneSortManager:getSortName(type)
    local str = ''
    if (type == 'hp') then
        str = Str('체력')

    elseif (type == 'def') then
        str = Str('방어력')

    elseif (type == 'atk') then
        str = Str('공격력')

    elseif (type == 'attr') then
        str = Str('속성')

    elseif (type == 'lv') then
        str = Str('레벨')

    elseif (type == 'grade') then
        str = Str('등급')

    elseif (type == 'rarity') then
        str = Str('희귀도')

    elseif (type == 'friendship') then
        str = Str('친밀도')

    else
        error('type : ' .. type)
    end

    return str
end


-------------------------------------
-- function clearTableView
-------------------------------------
function RuneSortManager:clearTableView(table_view)
    self.m_lTableView = {}

    if table_view then
        self:addTableView(table_view)
    end
end

-------------------------------------
-- function addTableView
-------------------------------------
function RuneSortManager:addTableView(table_view)
    table.insert(self.m_lTableView, table_view)
end

-------------------------------------
-- function changeSort
-------------------------------------
function RuneSortManager:changeSort(immediately)
    local function default_sort_func(a, b)
        return self:sortFunc(a, b)
    end

    for i,v in ipairs(self.m_lTableView) do
        local table_view = v
        table_view:insertSortInfo('sort', default_sort_func)
        if immediately then
            table_view:sortImmediately('sort')
        else
            table_view:sortTableView('sort', true)
        end    
    end

    -- 글로벌 설정을 사용할 경우
    if self.m_bUseGlobalSetting then
        g_serverData:applyServerData(self.m_bAscendingSort, 'local', 'dragon_sort_ascending')
        g_serverData:applyServerData(self.m_currSortType, 'local', 'dragon_sort_type')
    end
end


-------------------------------------
-- function sortFunc
-------------------------------------
function RuneSortManager:sortFunc(a, b)
    local a_data = a['data']
    local b_data = b['data']

    local ascending = self.m_bAscendingSort

    -- 등급순
    if (a_data['grade'] ~= b_data['grade']) then
        if ascending then
            return a_data['grade'] < b_data['grade']
        else
            return a_data['grade'] > b_data['grade']
        end
    end

    -- 레벨순
    if (a_data['lv'] ~= b_data['lv']) then
        if ascending then
            return a_data['lv'] < b_data['lv']
        else
            return a_data['lv'] > b_data['lv']
        end
    end
    
    -- rune_object_id 순
    return a_data['id'] < b_data['id']
end