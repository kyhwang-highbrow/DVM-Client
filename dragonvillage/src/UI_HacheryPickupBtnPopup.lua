UI_HacheryPickupBtnPopup = class(UI, {
    m_parent = 'UI_HatcherySummonTab',
})
 
----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_HacheryPickupBtnPopup:init(parent, t_egg_data, item_value, msg, ok_btn_cb, cancel_btn_cb)
	self.m_uiName = 'UI_HacheryPickupBtnPopup'

    local title = t_egg_data['name']
    local vars = self:load('hatchery_summon_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HacheryPickupBtnPopup')

    
    vars['okBtn']:registerScriptTapHandler(function() 
        ok_btn_cb()
        self:close()
    end)

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)

    self.m_parent = parent

    vars['titleLabel']:setString(title)
    vars['selectLabel']:setString(msg)
    vars['priceLabel']:setString(comma_value(item_value))

    local has_empty_slot = g_hatcheryData:isPickupEmpty() == true
    vars['unselectMenu']:setVisible(has_empty_slot)
    vars['selectMenu']:setVisible(not has_empty_slot)

    local type = t_egg_data['price_type']

    local price_icon = IconHelper:getPriceIcon(type)
	if (price_icon) then
		vars['iconNode']:addChild(price_icon)
	end

    if (not has_empty_slot) then self:setChanceUpDragons() end
    
end


-------------------------------------
-- function setChanceUpDragons
-- @brief 확률업 드래곤 
-------------------------------------
function UI_HacheryPickupBtnPopup:setChanceUpDragons()
    local vars = self.vars

    local idx = 0
    local desc_idx = 0 -- dragonName1 :드래곤 1마리 일 때, dragonName2, dragonName3 : 드래곤 2마리 일 때

    -- normal_did 물불땅 / unique_did 빛어둠
    -- 바로 알아볼 수 있게 같은 로직 두번 돌림
    local normal_did, unique_did = g_hatcheryData:getSelectedPickup()
    local l_dragon = {}

    if (normal_did) then table.insert(l_dragon, {did = normal_did}) end
    if (unique_did) then table.insert(l_dragon, {did = unique_did}) end

    local pickup_dragon_map = self.m_parent:makeDragonInfoMap(l_dragon)

    for _, t_data in pairs(pickup_dragon_map) do
        local did = t_data['did']
        local attr = TableDragon:getDragonAttr(did)

        -- 빛어둠 3 / 땅물불 2
        idx = isExistValue(attr, 'light', 'dark') and 2 or 1
        desc_idx = idx

        -- 드래곤 이름
        local name = TableDragon:getChanceUpDragonName2(did)
        local is_definite_pickup = g_hatcheryData.m_isDefinitePickup == true

        vars['dragonNameLabel'..desc_idx]:setString(name)
        vars['selectVisual'..desc_idx]:setVisible(is_definite_pickup)
        
        -- 드래곤 카드
        do
            local t_dragon_data = {}
            t_dragon_data['did'] = did
            t_dragon_data['evolution'] = 1
            t_dragon_data['grade'] = 5
            t_dragon_data['skill_0'] = 1
            t_dragon_data['skill_1'] = 1
            t_dragon_data['skill_2'] = 0
            t_dragon_data['skill_3'] = 0

            -- 드래곤 클릭 시, 도감 팝업
            local func_tap = function()
                UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true)    -- param : did, grade, evolution scale, ispopup
            end

            local dragon_card = UI_DragonCard(StructDragonObject(t_dragon_data))
            dragon_card.root:setScale(0.66)
            dragon_card.vars['clickBtn']:registerScriptTapHandler(function() func_tap() end)
            vars['dragonCard'..desc_idx]:addChild(dragon_card.root)
        end
    end
end
