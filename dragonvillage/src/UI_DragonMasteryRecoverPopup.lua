
-------------------------------------
-- class UI_DragonMasteryRecoverPopup
-------------------------------------
UI_DragonMasteryRecoverPopup = class(PARENT, {
    m_targetDragonObject = 'DragonObject',
    m_cost = 'number',
    m_costType = 'string',
})


-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasteryRecoverPopup:init(dragon_obj)
    local vars = self:load('dragon_mastery_recover_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_DragonMasteryRecoverPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMasteryRecoverPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self.m_targetDragonObject = dragon_obj
    self.m_costType = 'cash'

    local dragon_attr = dragon_obj:getAttr()

    if (dragon_attr == 'dark') or (dragon_attr == 'light') then
        self.m_cost = 30000
    else
        self.m_cost = 5000
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasteryRecoverPopup:initUI()
    local vars = self.vars

    local current_dragon_object = self.m_targetDragonObject

    -- 소모되는 재화 종류
    --vars['price_node']

    -- 소모되는 재화 수량
    vars['priceLabel']:setString(comma_value(self.m_cost))


    local dragon_obj = self.m_targetDragonObject

    -- 속성별 특성 재료
    local material_type = 'mastery_material_' .. dragon_obj:getRarity() .. '_' .. dragon_obj:getAttr()
    local material_id = TableItem:getItemIDFromItemType(material_type)
    local material_name = TableItem:getItemName(material_id)
    
    -- 특성 레벨 2를 회수하여 {1} 1개를 획득합니다.
    local info_origin_str = vars['infoLabel']:getString()
    
    -- 드래곤 속성
    local dragon_attr = dragon_obj:getAttr()
    -- 특성 재료 아이템을 속성별로 색을 표현
    local item_name = string.format('{@%s}%s{@default}', dragon_attr, Str(material_name))

    vars['infoLabel']:setString(Str(info_origin_str, item_name))

    -- 획득 아이템 카드
    local item_card = UI_ItemCard(material_id, 1)
    vars['masteryNode']:addChild(item_card.root)    
end

-------------------------------------
-- function initBtn
-------------------------------------
function UI_DragonMasteryRecoverPopup:initButton()
    local vars = self.vars

    vars['recoverBtn']:registerScriptTapHandler(function() self:click_recoverBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryRecoverPopup:refresh()
    self:refresh_dragonCard()
end


-------------------------------------
-- function refresh_dragonCard
-------------------------------------
function UI_DragonMasteryRecoverPopup:refresh_dragonCard()
    local vars = self.vars

    local current_dragon_object = self.m_targetDragonObject
    do -- 드래곤 현재 정보 카드
        local dragon_card = UI_DragonCard(current_dragon_object)
        vars['dragonPreNode']:addChild(dragon_card.root)
    end

    local expected_dragon_object = clone(current_dragon_object)
    expected_dragon_object['mastery_lv'] = expected_dragon_object['mastery_lv'] - 2



    do -- 드래곤 회수될 정보 카드
        local dragon_card = UI_DragonCard(expected_dragon_object)
        vars['dragonAfterNode']:addChild(dragon_card.root)
    end
end

-------------------------------------
-- function click_recoverBtn
-------------------------------------
function UI_DragonMasteryRecoverPopup:click_recoverBtn()
    local function ok_cb()

        local function success_cb(ret)
            
            local added_items = ret['added_items'] 
            local items_list = added_items['items_list']

            local ui = UI_ObtainPopup(items_list)

            -- 수정된 드래곤 정보
            local edited_dragon_info = ret['dragon_info']

            -- 회수 최소 조건이 되지 않을 경우 팝업을 닫는다
            if (edited_dragon_info['mastery_lv'] < 2) then
                ui:setCloseCB(function() self:close() end)
            -- 현재 팝업 정보 갱신
            else
                ui:setCloseCB(function() 
                    self.m_targetDragonObject = g_dragonsData:getDragonDataFromUid(edited_dragon_info['id'])
                    
                    self:refresh()
                end)
            end
        end
    
    
        local doid = self.m_targetDragonObject['id']

        g_dragonsData:request_mastery_lvdown(doid, success_cb)
    end

    local item_id = TableItem:getItemIDFromItemType(self.m_costType)
    local item_name = TableItem:getItemName(item_id)

    local cost = comma_value(self.m_cost)

    local dragon_obj = self.m_targetDragonObject

    -- 속성별 특성 재료
    local material_type = 'mastery_material_' .. dragon_obj:getRarity() .. '_' .. dragon_obj:getAttr()
    local material_id = TableItem:getItemIDFromItemType(material_type)
    local matertial_name = TableItem:getItemName(material_id)

    local msg = Str('{1} {2}개를 사용하여{@yellow} {3} {4}개{@default}를 회수하시겠습니까?', item_name, cost, matertial_name, 1)


    UI_ConfirmPopup(self.m_costType, self.m_cost, msg, ok_cb)
end
-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_DragonMasteryRecoverPopup:click_cancelBtn()
    self:close()
end