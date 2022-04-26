local PARENT = UI

-------------------------------------
-- class UI_Package_AttrTowerPopup
-------------------------------------
UI_Package_AttrTowerPopup = class(PARENT,{
        m_isPopup = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AttrTowerPopup:init(is_popup)
    local vars = self:load('package_attr_tower.ui')
    self.m_isPopup = is_popup or false
	
	self.m_uiName = 'package_attr_tower.ui'

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_AttrTowerPopup')
    end

    self:initUI()
	self:initButton()
    self:refresh()

    -- 남은 시간 이미지 텍스트로 보여줌
    self:setLimit()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AttrTowerPopup:initUI()
    local vars = self.vars
    
    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function setLimit
-------------------------------------
function UI_Package_AttrTowerPopup:setLimit()
    local vars = self.vars
    -- 아무 속성이나 하나 골라서 계산 (모든 속성이 동일하게 끝날 것이라는 가정)
    local product_id_list = g_attrTowerPackageData:getProductIdList('earth')
    if (table.count(product_id_list) == 0) then 
        vars['limitMenu']:setVisible(false)
        vars['limitNode']:setVisible(false)    
        return 
    end
    local product_id = product_id_list[1]
    local struct_product = g_shopDataNew:getTargetProduct(product_id)

    if (vars['limitNode'] == nil) then
        return
    elseif (vars['limitMenu'] == nil) then
        return
    elseif (vars['timeNode'] == nil) then
        return
    end

    local is_limit = false
    local remain_time

    if (vars['limitNode']) then
        remain_time = struct_product:getTimeRemainingForEndOfSale() * 1000 -- milliseconds로 변경 
        local day = math.floor(remain_time / 86400000)
        -- 판매 기간이 조금 남은 경우
        if (day < 2) then
            is_limit = true
        end
    end

    if (is_limit) then
        -- 한정 표시
        vars['limitNode']:setVisible(true)
        vars['limitMenu']:setVisible(true)
        vars['limitNode']:runAction(cca.buttonShakeAction(3, 1)) 
        
        local desc_time = datetime.makeTimeDesc_timer_filledByZero(remain_time, false) -- param : milliseconds, from_day
        
        -- 남은 시간 이미지 텍스트로 보여줌
        local remain_time_label = cc.Label:createWithBMFont('res/font/tower_score.fnt', desc_time)
        remain_time_label:setAnchorPoint(cc.p(0.5, 0.5))
        remain_time_label:setDockPoint(cc.p(0.5, 0.5))
        remain_time_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        remain_time_label:setAdditionalKerning(0)
        vars['remainLabel'] = remain_time_label
        vars['timeNode']:addChild(remain_time_label)
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    else
        vars['limitMenu']:setVisible(false)
        vars['limitNode']:setVisible(false)    
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AttrTowerPopup:initButton()
    local vars = self.vars

    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn('fire') end)
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn('water') end)
    vars['buyBtn3']:registerScriptTapHandler(function() self:click_buyBtn('earth') end)
    vars['buyBtn4']:registerScriptTapHandler(function() self:click_buyBtn('light') end)
    vars['buyBtn5']:registerScriptTapHandler(function() self:click_buyBtn('dark') end)

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTowerPopup:refresh()
    local vars = self.vars

    self:refresh_packageNoti()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_AttrTowerPopup:click_buyBtn(attr)
    local huddle = g_attrTowerPackageData:getHuddleFloor(attr)
    local clear_floor = g_attrTowerData:getClearFloor()
    local product_id_list = g_attrTowerPackageData:getProductIdList(attr)

    -- 허들 이상 클리어한 경우
    local ui
    if ((table.count(product_id_list) > 1) and (clear_floor >= huddle)) then
        require('UI_Package_AttrTowerBundle')
        ui = UI_Package_AttrTowerBundle(attr)

    else 
        require('UI_Package_AttrTower')
        local first_product_id = product_id_list[1]
        ui = UI_Package_AttrTower(nil, first_product_id, true)
    end

    ui:setCloseCB(function() self:refresh_packageNoti() end)
end

-------------------------------------
-- function refresh_packageNoti
-------------------------------------
function UI_Package_AttrTowerPopup:refresh_packageNoti()
    local vars = self.vars

    local l_attr_list = {'fire', 'water', 'earth', 'light', 'dark'}

    -- noti
    --for i, attr in ipairs(l_attr_list) do
        --local product_id_list = g_attrTowerPackageData:getProductIdList(attr)
        --local sprite_name = ''
        --if (g_attrTowerPackageData:isVisible_attrTowerPackNoti(product_id_list)) then
            --vars[sprite_name]:setVisible(true)
        --else
            --vars[sprite_name]:setVisible(false)
        --end
    --end
end

-------------------------------------
-- function update
-------------------------------------
function UI_Package_AttrTowerPopup:update(dt)
    local vars = self.vars
    if (not vars['remainLabel']) then
        return
    end

    local product_id_list = g_attrTowerPackageData:getProductIdList('earth')
    if (table.count(product_id_list) == 0) then 
        vars['limitMenu']:setVisible(false)
        vars['limitNode']:setVisible(false)    
        return 
    end
    local product_id = product_id_list[1]
    local struct_product = g_shopDataNew:getTargetProduct(product_id)

    local remain_time = struct_product:getTimeRemainingForEndOfSale() * 1000 -- milliseconds로 변경
    local desc_time = datetime.makeTimeDesc_timer_filledByZero(remain_time, false) -- param : milliseconds, from_day

    vars['remainLabel']:setString(desc_time)
end
