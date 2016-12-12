
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
-- class DragonSortManager
-- @breif 보유한 열매의 정렬을 돕는 클래스
-------------------------------------
DragonSortManager = class({
        vars = 'table',
        m_tableViewExt = 'TableViewExtension',
        m_currSortType = 'string',
        m_bAscendingSort = 'boolean', -- 오름차순인지 여부

        m_funcSettedDragon = 'function',

        -- 내부에서 별도로 사용하는 vars
        m_vars = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSortManager:init()
end

-------------------------------------
-- function init_commonSotrUI
-------------------------------------
function DragonSortManager:init_commonSotrUI(vars, table_view_ext, b_ascending_sort, sort_type)
    self.vars = vars
    self.m_tableViewExt = table_view_ext

    self:init_vars()
    self:init_button()

    self:click_sortOrderBtn(b_ascending_sort, true)
    self:click_sortTypeBtn(sort_type or 'lv', true)
end

-------------------------------------
-- function init_vars
-------------------------------------
function DragonSortManager:init_vars()
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
function DragonSortManager:getSortBtnName(type)
    return 'sort' .. type .. 'Btn', 'sort' .. type .. 'Btn'
end

-------------------------------------
-- function init_button
-------------------------------------
function DragonSortManager:init_button()
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
function DragonSortManager:click_sortBtn()
    local vars = self.m_vars
    vars['sortNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortOrderBtn
-- @brief 오름차순, 내림차순
-------------------------------------
function DragonSortManager:click_sortOrderBtn(b_ascending_sort, skip_change_sort)
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
function DragonSortManager:click_sortTypeBtn(type, skip_change_sort)
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
function DragonSortManager:getSortName(type)
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
-- function changeSort
-------------------------------------
function DragonSortManager:changeSort(immediately)
    local function default_sort_func(a, b)
        return self:sortFunc(a, b)
    end

    self.m_tableViewExt:insertSortInfo('sort', default_sort_func)

    if immediately then
        self.m_tableViewExt:sortImmediately('sort')
    else
        self.m_tableViewExt:sortTableView('sort', true)
    end
end


-------------------------------------
-- function sortFunc
-------------------------------------
function DragonSortManager:sortFunc(a, b)
    local a_data = a['data']
    local b_data = b['data']

    local a_sort_data = g_dragonsData:getDragonsSortData(a_data['id'])
    local b_sort_data = g_dragonsData:getDragonsSortData(b_data['id'])

    local a_deck_idx = self:isSettedDragon(a_data['id']) or 999
    local b_deck_idx = self:isSettedDragon(b_data['id']) or 999

    -- 덱에 설정된 데이터로 우선 정렬
    if (a_deck_idx ~= b_deck_idx) then
        return a_deck_idx < b_deck_idx
    end

    -- 정렬 타입
    local sort_type = self.m_currSortType
  
    -- 오름차순, 내림차순
    if (a_sort_data[sort_type] ~= b_sort_data[sort_type]) then
        if self.m_bAscendingSort then
            return a_sort_data[sort_type] < b_sort_data[sort_type]
        else
            return a_sort_data[sort_type] > b_sort_data[sort_type]
        end
    end

    -- 드래곤 ID
    if (a_sort_data['did'] ~= b_sort_data['did']) then
        return a_sort_data['did'] < b_sort_data['did']
    end

    -- 드래곤 진화도 높을 순
    if (a_sort_data['evolution'] ~= b_sort_data['evolution']) then
        return a_sort_data['evolution'] > b_sort_data['evolution']
    end

    -- 드래곤 등급 높을 순
    if (a_sort_data['grade'] ~= b_sort_data['grade']) then
        return a_sort_data['grade'] > b_sort_data['grade']
    end

    -- 레벨 높을 순
    if (a_sort_data['lv'] ~= b_sort_data['lv']) then
        return a_sort_data['lv'] > b_sort_data['lv']
    end
end

-------------------------------------
-- function isSettedDragon
-- @breif
-------------------------------------
function DragonSortManager:isSettedDragon(doid)
    if self.m_funcSettedDragon then
        return self.m_funcSettedDragon(doid) or 999
    end

    return g_deckData:isSettedDragon(doid) or 999
end

-------------------------------------
-- function setIsSettedDragonFunc
-- @breif
-------------------------------------
function DragonSortManager:setIsSettedDragonFunc(func)
    self.m_funcSettedDragon = func
end


-------------------------------------
-- class DragonSortManagerCommon
-- @breif 보유한 열매의 정렬을 돕는 클래스
-------------------------------------
DragonSortManagerCommon = class(DragonSortManager, {
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSortManagerCommon:init(vars, table_view_ext, b_ascending_sort, sort_type)
    self:init_commonSotrUI(vars, table_view_ext, b_ascending_sort, sort_type)
    self:changeSort(true)
end



-------------------------------------
-- class DragonSortManagerReady
-- @breif 보유한 열매의 정렬을 돕는 클래스
-------------------------------------
DragonSortManagerReady = class(DragonSortManager, {
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSortManagerReady:init(vars, table_view_ext, b_ascending_sort, sort_type)
    self:init_commonSotrUI(vars, table_view_ext, b_ascending_sort, sort_type)

    -- setIsSettedDragonFunc실행 후 하기 위해서 외부에서 호출함
    --self:changeSort()
end



-------------------------------------
-- class DragonSortManagerUpgradeMaterial
-- @breif 보유한 열매의 정렬을 돕는 클래스
-------------------------------------
DragonSortManagerUpgradeMaterial = class(DragonSortManager, {
        m_tableViewExt2 = 'TableViewExtension',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSortManagerUpgradeMaterial:init(vars, table_view_ext, table_view_ext2, b_ascending_sort, sort_type)
    self:init_commonSotrUI(vars, table_view_ext, b_ascending_sort, sort_type)
    self.m_tableViewExt2 = table_view_ext2
end

-------------------------------------
-- function init_vars
-------------------------------------
function DragonSortManagerUpgradeMaterial:init_vars()
    self.m_vars = {}
    self.m_vars['sortBtn'] = self.vars['sortSelectBtn'] 
    self.m_vars['sortOrderBtn'] = self.vars['sortSelectOrderBtn'] 
    self.m_vars['sortNode'] = self.vars['sortSelectNode']
    self.m_vars['sortOrderSprite'] = self.vars['sortSelectOrderSprite']
    self.m_vars['sortLabel'] = self.vars['sortSelectLabel']

    for i,v in ipairs(t_sort_type) do
        local luaname, luaname_org = self:getSortBtnName(firstLetterUpper(v))
        self.m_vars[luaname] = self.vars[luaname_org]
    end
end

-------------------------------------
-- function getSortBtnName
-------------------------------------
function DragonSortManagerUpgradeMaterial:getSortBtnName(type)
    return 'sort' .. type .. 'Btn', 'sortSelect' .. type .. 'Btn'
end

-------------------------------------
-- function changeSort
-------------------------------------
function DragonSortManagerUpgradeMaterial:changeSort()
    local function default_sort_func(a, b)
        return self:sortFunc(a, b)
    end

    self.m_tableViewExt:insertSortInfo('sort', default_sort_func)
    self.m_tableViewExt:sortTableView('sort', true)

    if self.m_tableViewExt2 then
        self.m_tableViewExt2:insertSortInfo('sort', default_sort_func)
        self.m_tableViewExt2:sortTableView('sort', true)
    end
end

-------------------------------------
-- function changeSort2
-------------------------------------
function DragonSortManagerUpgradeMaterial:changeSort2()
    local function default_sort_func(a, b)
        return self:sortFunc(a, b)
    end

    if self.m_tableViewExt2 then
        self.m_tableViewExt2:insertSortInfo('sort', default_sort_func)
        self.m_tableViewExt2:sortTableView('sort', true)
    end
end