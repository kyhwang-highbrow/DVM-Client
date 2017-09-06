local PARENT = UI

-------------------------------------
-- class UI_EventFullPopup
-------------------------------------
UI_EventFullPopup = class(PARENT,{
        m_productID = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventFullPopup:init(product_id)
    self.m_productID = product_id
end

-------------------------------------
-- function openEventFullPopup
-------------------------------------
function UI_EventFullPopup:openEventFullPopup()
    local vars = self:load('event_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventFullPopup')

    self:initUI()
    self:initButton()
    self:refresh()

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventFullPopup:initUI()
    local vars = self.vars
    local product_id = self.m_productID

    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product

    -- 묶음 UI 별도 처리
    if (product_id == 'slime_package') then
        struct_product = {product_id = 'slime_package'}
    else
        struct_product = l_item_list[tonumber(product_id)]
    end

    if (struct_product) then
        local is_popup = false
        local ui = PackageManager:getTargetUI(struct_product, is_popup)

        local node = vars['eventNode']
        node:addChild(ui.root)
    else
        -- 이벤트 프로덕트 정보 없을 경우 비활성화라고 생각하고 닫아줌 (주말 패키지)
        self:close()
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
-- function click_checkBtn
-------------------------------------
function UI_EventFullPopup:click_checkBtn()
    local vars = self.vars
    vars['checkSprite']:setVisible(true)

    -- 다시보지않기
    local product_id = self.m_productID
    local save_key = tostring(product_id)
    g_localData:applyLocalData(true, 'event_full_popup', save_key)

    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventFullPopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_EventFullPopup)
