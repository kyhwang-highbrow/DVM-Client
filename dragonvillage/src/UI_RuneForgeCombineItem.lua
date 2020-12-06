local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RuneForgeCombineItem
-------------------------------------
UI_RuneForgeCombineItem = class(PARENT,{
        m_ownerUI = 'UI_RuneForgeCombineTab',
        m_grade = 'number',
        m_idx = 'number',
        ---------------------------------
        m_mSelectRuneMap = 'map', -- 현재 선택되어있는 룬 저장하는 map
        m_lRuneCardList = 'list', -- 현재 선택되어있는 룬 카드 UI의 list
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeCombineItem:init(owner_ui, struct_combine_rune)
    local vars = self:load('rune_forge_combine_item.ui')
    
    --self.m_grade = grade
    --self.m_idx = idx
    --
    --local first_roid = t_first_rune_data['roid']
    --self.m_mSelectRuneMap[first_roid] = t_first_rune_data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeCombineItem:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeCombineItem:initButton()
    local vars = self.vars
        
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeCombineItem:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_rune
-- @brief 룬 선택
-------------------------------------
function UI_RuneForgeCombineItem:click_rune(ui, data)
    local rune_card = ui
    local t_rune_data = data

    local roid = t_rune_data['roid']
    local grade = t_rune_data['grade']
    local select_roid_map = self.m_mSelectRoidMap[grade]
    local select_roid_list = self.m_mSelectRoidList[grade]

    if (select_roid_map[roid] == nil) then
        select_roid_map[roid] = data
        table.insert(select_roid_list, data)

        if (table.count(select_roid_list) % UI_RuneForgeCombineTab.RUNE_COMBINE_REQUIRE == 1) then
            local idx = math_floor(table.count(select_roid_list) / UI_RuneForgeCombineTab.RUNE_COMBINE_REQUIRE)
            self:add_combineItem(grade, idx)
        end
    else 
        select_roid_map[roid] = nil
        for idx, data in ipairs(select_roid_list) do
            if (data['roid'] == roid) then
                table.remove(select_roid_list, idx)
                break
            end
        end
    end

    self:refresh()
end