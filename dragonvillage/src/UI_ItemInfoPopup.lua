local PARENT = UI

-------------------------------------
-- class UI_ItemInfoPopup
-------------------------------------
UI_ItemInfoPopup = class(PARENT,{
        m_itemID = 'number',
        m_itemCount = 'number',
        m_tSubData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemInfoPopup:init(item_id, count, t_sub_data)
    self.m_itemID = item_id
    self.m_itemCount = count
    self.m_tSubData = t_sub_data

    local vars = self:load('item_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ItemInfoPopup')

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
function UI_ItemInfoPopup:initUI()
    local vars = self.vars

    local type = TableItem:getItemType(self.m_itemID)

    
    -- 아이템명 출력
    if (type == 'rune') and self.m_tSubData then
        vars['titleLabel']:setString(self.m_tSubData['name'])
    else
        
        local item_name = TableItem:getItemName(self.m_itemID)
        vars['titleLabel']:setString(item_name)
    end
    

    do -- 아이템 아이콘    
        if (type == 'dragon') and self.m_tSubData then
            local item_card = UI_DragonCard(self.m_tSubData)
            vars['itemNode']:addChild(item_card.root)
        else
            local item_card = UI_ItemCard(self.m_itemID, self.m_itemCount, self.m_tSubData)
            vars['itemNode']:addChild(item_card.root)
            item_card:unregisterScriptPressHandler()
        end
    end

    -- 아이템 설명
    local desc = ''
    if (type == 'rune') and self.m_tSubData then
        local t_rune_data = self.m_tSubData
        desc = t_rune_data:makeRuneDescRichText()
    else
        desc = TableItem():getValue(self.m_itemID, 't_desc')
    end
    vars['itemDscLabel']:setString(Str(desc))

    -- 하위 UI가 모두 opacity값을 적용되도록
    self:setOpacityChildren(true)

    -- 획득 장소가 없다면 버튼을 꺼버린다.
    local l_region = UI_AcquisitionRegionInformation:makeRegionList(self.m_itemID)
    if (table.count(l_region) == 0) then
        vars['locationBtn']:setVisible(false)
        vars['okBtn']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ItemInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['locationBtn']:registerScriptTapHandler(function() self:click_locationBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ItemInfoPopup:refresh()
end

-------------------------------------
-- function click_locationBtn
-------------------------------------
function UI_ItemInfoPopup:click_locationBtn()
    local item_id = self.m_itemID
    UI_AcquisitionRegionInformation:create(item_id)
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ItemInfoPopup:click_okBtn()
    self:close()
end







function MakeSimpleRewarPopup(title_str, item_id, count, t_sub_data)
    local ui = UI_ItemInfoPopup(item_id, count, t_sub_data)
    ui.vars['titleLabel']:setString(title_str)
    ui.vars['locationBtn']:setVisible(false)
    ui.vars['closeBtn']:setPositionX(0)
    return ui
end

--@CHECK
UI:checkCompileError(UI_ItemInfoPopup)
