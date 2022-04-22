local PARENT = UI

-------------------------------------
-- class UI_Package_New_Dragon
-------------------------------------
UI_Package_New_Dragon = class(PARENT,{
        m_data = 'table',
        m_pids = 'table',
        m_ui_dragon_node = 'UI',
        m_package_name = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_New_Dragon:init(package_name, is_popup)
    self.m_package_name = package_name
    self.m_data = TablePackageBundle:getDataWithName(package_name) 
    self.m_pids = TablePackageBundle:getPidsWithName(package_name)

    local vars = self:load('package_new_dragon.ui')
    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_New_Dragon')
    end
	
	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- 상품이 없는 경우 예외처리
    if (#self.m_pids == 0) then
        return
    end
    
    -- 상품 정보가 없는 경우 예외처리
    if (not g_shopData:getTargetProduct(tonumber(self.m_pids[1]))) then
        return
    end

    self:initUI()
    self:setProduct()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_New_Dragon:initUI()
    local vars = self.vars

    -- 첫번째 상품을 드래곤 뽑기권이라고 보고, 드래곤 뽑기권의 드래곤들 출력
    local struct_product = g_shopData:getTargetProduct(tonumber(self.m_pids[1]))
    local item_id = self:getFirstProductItemId(struct_product)
    self:setDragonDisplay(item_id)
end

-------------------------------------
-- function setProduct
-------------------------------------
function UI_Package_New_Dragon:setProduct()
    local vars = self.vars
    local l_product = self.m_pids
    local product_cnt = #l_product

    for i, data in ipairs(l_product) do
        local struct_product = g_shopData:getTargetProduct(tonumber(l_product[i]))
        local item_id = self:getFirstProductItemId(struct_product)
        local ui_product = openPackage_New_Dragon(struct_product, item_id, product_cnt)
        if (item_id) and (ui_product) then
            local pos_ind = i
            if (product_cnt == 3) then
                pos_ind = pos_ind + 2
            end
            
            if (vars['productNode'..pos_ind]) then
                vars['productNode'..pos_ind]:addChild(ui_product.root)
            end
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_New_Dragon:refresh()
    local vars = self.vars   
    
    local struct_product = g_shopData:getTargetProduct(tonumber(self.m_pids[1])) -- 패키지들의 판매기간이 같다고 가정
    -- 판매종료시간 있는 경우 표시
    local time_label = vars['timeLabel']
    local end_date = struct_product:getEndDateStr()
    if (time_label) then
        if (end_date) then
            time_label:setString(end_date)
        else    
            time_label:setString('')
        end
    end
    
end

-------------------------------------
-- function getFirstProductItemId
-- @breif 패키지에서 UI로 보여줄 상품은 mail_content의 첫 번째 상품
-------------------------------------
function UI_Package_New_Dragon:getFirstProductItemId(struct_product)
 
    if (not struct_product) then
        return nil 
    end

    if (not struct_product['mail_content']) then
        return nil 
    end

    -- ex) 771115;1,700002;1000000,700001;3000,700009;9
    local l_mail_content = plSplit(struct_product['mail_content'], ',')
    -- ex) 771115;1
    local l_product = plSplit(l_mail_content[1], ';')
    return tonumber(l_product[1])
end

-------------------------------------
-- function setDragonDisplay
-------------------------------------
function UI_Package_New_Dragon:setDragonDisplay(item_id)
    local item_type = TableItem:getItemType(item_id)
    if (item_type == 'summon') then
        self:setDragonTicketDragons(item_id)
    end
end


-------------------------------------
-- function setDragonTicketDragons
-- @breif [드래곤 뽑기권]일 경우 세팅
-------------------------------------
function UI_Package_New_Dragon:setDragonTicketDragons(item_id)
    local vars = self.vars
    --[[
    -- 드래곤 뽑기권에서 나올 드래곤들 출력
    local dragon_list_str = TablePickDragon:getCustomList(item_id)
    local dragon_list = plSplit(dragon_list_str, ',')
    for i, dragon_id in ipairs(dragon_list) do
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(tonumber(dragon_id), 3)
        dragon_animator:setTalkEnable(false)
        dragon_animator:setIdle()

        if (self.vars['dragonNode'.. i]) then
            self.vars['dragonNode'.. i]:addChild(dragon_animator.m_node)
        end
    end
    --]]
end

-------------------------------------
-- function initUI_dragon
-- @breif [드래곤]일 경우 세팅
-------------------------------------
function UI_Package_New_Dragon:initUI_dragon()
    local vars = self.vars
    
    local did = TableItem:getDidByItemId(self.m_premier_item_id)
    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(tonumber(did), 3)
    dragon_animator:setTalkEnable(false)
    dragon_animator:setIdle()

    vars['dragonNode']:addChild(dragon_animator.m_node)
end


