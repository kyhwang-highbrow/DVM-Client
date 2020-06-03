local PARENT = UI

-------------------------------------
-- class UI_SupplyProductInfoPopup
-------------------------------------
UI_SupplyProductInfoPopup = class(PARENT,{
        m_tSupplyData = 'number',
        --{
        --    ['supply_id']=1004;
        --    ['period']=14;
        --    ['daily_content']='gold;1000000';
        --    ['t_name']='14일 골드 보급';
        --    ['product_content']='cash;1590';
        --    ['t_desc']='';
        --    ['type']='daily_gold';
        --    ['product_id']=120104;
        --    ['ui_priority']=40;
        --    ['period_option']=1;
        --}
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyProductInfoPopup:init(t_data)
    self.m_tSupplyData = t_data

    local vars = self:load('supply_product_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)


    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyProductInfoPopup')

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
function UI_SupplyProductInfoPopup:initUI()
    local vars = self.vars
    
    local t_data = self.m_tSupplyData

    do -- 이름
        vars['titleLabel']:setString(Str(t_data['t_name']))
    end

    do -- 설명
        vars['descLabel']:setString(Str('지금 바로 구매하고 획득'))
    end

    do -- 다이아 즉시 획득량
        local package_item_str = t_data['product_content']
        local count = ServerData_Item:getItemCountFromPackageItemString(package_item_str, ITEM_ID_CASH)
        vars['obtainLabel']:setString(comma_value(count))
    end

    do -- n일간 매일 수령
        local period = t_data['period']
        local str = Str('{1}일간 매일 수령', period)
        vars['periodLabel']:setString(str)
    end

    do -- 일간 보상 아이콘
        local package_item_str = t_data['daily_content']
        local l_item_list_mail = ServerData_Item:parsePackageItemStr(package_item_str)
        if l_item_list_mail[1] then
            local t_item_data = l_item_list_mail[1]
            local item_id = t_item_data['item_id']
            local item_cnt = t_item_data['count']
            local card = UI_ItemCard(item_id, item_cnt)
            card.root:setSwallowTouch(false)
            vars['itemNode']:addChild(card.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyProductInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyProductInfoPopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SupplyProductInfoPopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_SupplyProductInfoPopup)
