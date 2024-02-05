local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_WorldRaidUserDeckInfoRuneListItem
-------------------------------------
UI_WorldRaidUserDeckInfoRuneListItem = class(PARENT, {
    m_dragonObj = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidUserDeckInfoRuneListItem:init(struct_dragon_object)
    self.m_dragonObj = struct_dragon_object
    self:load('world_raid_user_rune_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidUserDeckInfoRuneListItem:initUI()
    local vars = self.vars

    do -- 드래곤
        local card = UI_DragonCard(self.m_dragonObj)
        vars['dragonNode']:addChild(card.root)
    end


    local t_dragon_data = self.m_dragonObj
    -- local rune_set_obj = t_dragon_data:getStructRuneSetObject()
    -- local active_set_list = rune_set_obj:getActiveRuneSetList()


    -- -- 해당룬 세트 효과 활성화 되있다면 애니 재생
    -- local t_equip = {}
    -- local function show_set_effect(slot_id, set_id)
    --     for _, v in ipairs(active_set_list) do
    --         local visual = vars['runeVisual'..slot_id]
    --         if (v == set_id) then
    --             if (t_equip[set_id]) then
    --                 t_equip[set_id] = t_equip[set_id] + 1
    --             else
    --                 t_equip[set_id] = 1
    --             end

    --             local need_equip = get_need_equip(set_id)
    --             if (t_equip[set_id] <= need_equip) then
    --                 local ani_name = TableRuneSet:getRuneSetVisualName(slot_id, set_id)
    --                 visual:setVisible(true)
    --                 visual:changeAni(ani_name, true)
    --             end
    --             break
    --         end
    --     end
    -- end

    do -- 룬
        for slot=1, RUNE_SLOT_MAX do
            vars['runeVisual' .. slot]:setVisible(false)
            vars['runeSlot' .. slot]:removeAllChildren()
            local rune_obj = t_dragon_data:getRuneObjectBySlot(slot)
            if rune_obj then
				local card = UI_RuneCard(rune_obj)				
                vars['runeSlot' .. slot]:addChild(card.root)

                card.vars['clickBtn']:registerScriptPressHandler(function () end)
                card.vars['clickBtn']:registerScriptTapHandler(function() 
                    local item_id = rune_obj['rid']
                    local count = 1
                    --local param = {rune_obj:getObjectId()}
                    local ui = UI_ItemInfoPopup(item_id, count, rune_obj)
                    ui.vars['lockBtn']:setVisible(false)
                end)
            end
        end
    end

    -- do -- 룬 세트
    --     vars['runeSetNode']:removeAllChildren()

    --     local l_pos = getSortPosList(35, #active_set_list)
    --     for i,set_id in ipairs(active_set_list) do
    --         local ui = UI()
    --         ui:load('dragon_manage_rune_set.ui')

    --         -- 색상 지정
    --         local c3b = TableRuneSet:getRuneSetColorC3b(set_id)
    --         ui.vars['runeSetLabel']:setColor(c3b)

    --         -- 세트 이름
    --         local set_name = TableRuneSet:getRuneSetName(set_id)
    --         ui.vars['runeSetLabel']:setString(set_name)

    --         -- 툴팁 클릭
    --         ui.vars['tooltipBtn']:registerScriptTapHandler(function()
    --             local str = TableRuneSet:makeRuneSetFullNameRichText(set_id)
    --             local tool_tip = UI_Tooltip_Skill(0, 0, str)
    --             tool_tip:autoPositioning(ui.vars['tooltipBtn']) -- 자동 위치 지정
    --         end)

    --         -- AddCHild, 위치 지정
    --         vars['runeSetNode']:addChild(ui.root)
    --         ui.root:setPositionY(l_pos[i])
    --     end
    -- end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidUserDeckInfoRuneListItem:initButton()
    local vars = self.vars
    self.root:setSwallowTouch(false)
    -- for slot_idx = 1, 6 do
    --     local slot_node_str = 'runeSlotBtn' .. slot_idx
    --     vars[slot_node_str]:registerScriptTapHandler(function() self:click_runeCard(slot_idx) end)
    --     vars[slot_node_str]:registerScriptPressHandler(function() self:press_runeCard(slot_idx) end)
    -- end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidUserDeckInfoRuneListItem:refresh()
    --self:refreshRunes()
end

-- -------------------------------------
-- -- function refreshRunes
-- -------------------------------------
-- function UI_WorldRaidUserDeckInfoRuneListItem:refreshRunes()
--     local active_set_map = self.m_presetRune:getRunesSetMap()
--     for slot_idx = 1, 6 do
--         self:refreshRuneCard(slot_idx, active_set_map)
--     end
-- end

-- -------------------------------------
-- -- function refreshRuneCard
-- -- @brief 해당 함수는 룬 카드 변경이 필요할 때만 호출
-- -------------------------------------
-- function UI_WorldRaidUserDeckInfoRuneListItem:refreshRuneCard(slot_idx, active_set_map)
--     local vars = self.vars
--     vars['runeSlot' .. slot_idx]:removeAllChildren()

--     local visual = vars['runeVisual'..slot_idx]
--     visual:setVisible(false)

--     local runes_map = self.m_presetRune:getRunesMap()
--     self.m_runeUIMap[slot_idx] = nil

--     local roid = runes_map[slot_idx]
--     if (roid == nil) then
--         return
--     end

--     local rune_obj = g_runesData:getRuneObject(roid)
--     if rune_obj == nil then
--         return
--     end
    
--     local set_id = TableRune:getRuneSetId(rune_obj.rid)
--     local card = UI_RuneCard(rune_obj)
--     local t_set_info = active_set_map[set_id]

--     if t_set_info ~= nil and t_set_info['active'] == true then
--         t_set_info['count'] = t_set_info['count'] + 1
--         if t_set_info['need_equip'] >=  t_set_info['count'] and t_set_info['active_cnt'] > 0 then
--             local ani_name = TableRuneSet:getRuneSetVisualName(slot_idx, set_id)
--             visual:setVisible(true)
--             visual:changeAni(ani_name, true)

--             if t_set_info['need_equip'] ==  t_set_info['count'] then
--                 t_set_info['active_cnt'] = t_set_info['active_cnt'] - 1
--                 t_set_info['count'] = 0
--             end
--         end
--     end

--     --card:makeDragonAttrIcon()
--     --card:makeDragonIcon()
    
--     vars['runeSlot' .. slot_idx]:removeAllChildren()
--     vars['runeSlot' .. slot_idx]:addChild(card.root)

--     self.m_runeUIMap[slot_idx] = card
-- end

-------------------------------------
-- function click_runeCard
-------------------------------------
function UI_WorldRaidUserDeckInfoRuneListItem:click_runeCard(slot_idx)
end

-------------------------------------
-- function press_runeCard
-------------------------------------
function UI_WorldRaidUserDeckInfoRuneListItem:press_runeCard(slot_idx)
    -- local rune_ui = self.m_runeUIMap[slot_idx]
    -- if rune_ui ~= nil then
    --     rune_ui:press_clickBtn()
    -- end
end