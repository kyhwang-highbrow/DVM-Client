local PARENT = UI

-------------------------------------
-- class UI_EventFullPopup
-------------------------------------
UI_EventFullPopup = class(PARENT,{
        m_productID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventFullPopup:init(product_id)
    ccdump(product_id)
    local vars = self:load('event_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_productID = product_id

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventFullPopup')

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_TOP, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventFullPopup:initUI()
    local vars = self.vars
    local product_id = self.m_productID

    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product = l_item_list[product_id]

    if (struct_product) then
        local is_popup = false
        local ui = PackageManager:getTargetUI(struct_product, is_popup)

        local node = vars['eventNode']
        node:addChild(ui.root)
    else
        -- 이벤트 프로덕트 정보 없을 경우 비활성화라고 생각하고 닫아줌 (주말 패키지)
        self:closeWithAction()
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventFullPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventFullPopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventFullPopup:click_checkBtn()
    local vars = self.vars
    vars['checkSprite']:setVisible(true)

    -- 다시보지않기
    local product_id = self.m_productID
    local save_key = string.format('event_full_popup_%d', product_id)
    g_localData:applyLocalData(true, save_key)

    self:closeWithAction()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventFullPopup:click_closeBtn()
    self:closeWithAction()
end

--@CHECK
UI:checkCompileError(UI_EventFullPopup)
