local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonUpgradeCombineMaterialItem
-------------------------------------
UI_DragonUpgradeCombineMaterialItem = class(PARENT,{
        m_ownerUI = 'UI_DragonUpgradeCombineMaterial',
        ---------------------------------
        m_upgradeMaterialCombineData = 'StructUpgradeMaterialCombine',
        m_mDragonCardUI = 'map', -- 현재 생성되어있는 드래곤 카드 UI, map[index] = UI_DragonCard
        m_resultCard = 'UI_ItemCard',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgradeCombineMaterialItem:init(owner_ui, struct_upgrade_material_combine_data)
    local vars = self:load('dragon_upgrade_material_item.ui')
    
    self.m_ownerUI = owner_ui
    self.m_upgradeMaterialCombineData = struct_upgrade_material_combine_data
    self.m_mDragonCardUI = {}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonUpgradeCombineMaterialItem:initUI()
    local vars = self.vars
    
    -- 요구 재료 수에 맞게 재료 칸 정렬 및 visible 관리
    local require_count = self.m_upgradeMaterialCombineData:getRequireCount()
    for idx = require_count + 1, 5 do
        local node = vars['itemNode' .. idx]
        node:setVisible(false)
    end 
    
    --local l_align_ui_list = {}
    --local l_offset_list = {0, 245, 85, 32 , 5}
--
     --for idx = 1, 5 do
        --local node = vars['itemNode' .. idx]
        --if (idx <= require_count) then
            --table.insert(l_align_ui_list, node)
        --else
            --node:setVisible(false)
        --end
    --end 

    --AlignUIPos(l_align_ui_list, 'HORIZONTAL', 'CENTER', 5)

    self:makeResultSlimeCard()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonUpgradeCombineMaterialItem:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgradeCombineMaterialItem:refresh()
    local vars = self.vars

    local t_dragon_upgrade_material_combine_data = self.m_upgradeMaterialCombineData
    local combine_require_count = t_dragon_upgrade_material_combine_data:getRequireCount()
    
    -- 각 드래곤 재료 등록칸에 드래곤 카드 생성하기
    for idx = 1, combine_require_count do
        local is_dirty_index = t_dragon_upgrade_material_combine_data:isDirtyIndex(idx)
        
        if (is_dirty_index) then
            local t_dragon_data = t_dragon_upgrade_material_combine_data:getDragonDataFromIndex(idx)

            if (self.m_mDragonCardUI[idx] ~= nil) then
                self.m_mDragonCardUI[idx].root:removeFromParent()                
                self.m_mDragonCardUI[idx] = nil
            end 

            if (t_dragon_data ~= nil) then
                local dragon_card_ui = UI_DragonCard(t_dragon_data)
                dragon_card_ui.root:setSwallowTouch(false)
                dragon_card_ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(t_dragon_data) end)
                vars['itemNode' .. idx]:addChild(dragon_card_ui.root)
                
                cca.uiReactionSlow(dragon_card_ui.root, 1, 1, 1.3)
                self.m_mDragonCardUI[idx] = dragon_card_ui
            end

            t_dragon_upgrade_material_combine_data:setDirtyIndex(idx, false)
        end
    end

    -- 필요 경험치
    vars['dragonExpLabel']:setString(comma_value(t_dragon_upgrade_material_combine_data.m_needExp))

    -- 필요 골드
    vars['priceLabel']:setString(comma_value(t_dragon_upgrade_material_combine_data.m_needGold))


    -- 드래곤 재료 등록칸에 드래곤이 전부 등록된 경우
    if (t_dragon_upgrade_material_combine_data:isFull()) then
        vars['selectSprite']:setVisible(true)
        vars['deselectSprite']:setVisible(false)
    else
        vars['selectSprite']:setVisible(false)
        vars['deselectSprite']:setVisible(true)
    end
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_DragonUpgradeCombineMaterialItem:click_dragonCard(t_dragon_data)
    local vars = self.vars

    local owner_ui = self.m_ownerUI
    owner_ui:click_dragonCard(t_dragon_data)
end

-------------------------------------
-- function makeResultSlimeCard
-------------------------------------
function UI_DragonUpgradeCombineMaterialItem:makeResultSlimeCard()
    local vars = self.vars

    local t_dragon_upgrade_material_combine_data = self.m_upgradeMaterialCombineData
    local slime_grade = t_dragon_upgrade_material_combine_data:getRequireCount()

    -- 슈퍼 슬라임 카드 생성
    local slime_id = 779104 + 10 * slime_grade
    local slime_card = UI_ItemCard(slime_id)
    slime_card.root:setSwallowTouch(false)

    self.vars['resultNode']:addChild(slime_card.root)
    self.m_resultCard = slime_card
end