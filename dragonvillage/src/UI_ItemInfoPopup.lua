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

    do -- 아이템 아이콘
        local type = TableItem:getItemType(self.m_itemID)
        if (type == 'dragon') and self.m_tSubData then
            local item_card = UI_DragonCard(self.m_tSubData)
            vars['itemNode']:addChild(item_card.root)
        else
            local item_card = UI_ItemCard(self.m_itemID, self.m_itemCount, self.m_tSubData)
        vars['itemNode']:addChild(item_card.root)
        end
    end

    -- 아이템 설명
    local desc = TableItem():getValue(self.m_itemID, 't_desc')
    vars['itemDscLabel']:setString(Str(desc))

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ItemInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['locationBtn']:registerScriptTapHandler(function() self:click_locationBtn() end)
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
    UI_AcquisitionRegionInformation(item_id)
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
