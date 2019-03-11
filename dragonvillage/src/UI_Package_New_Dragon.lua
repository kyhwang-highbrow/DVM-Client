local PARENT = UI

-------------------------------------
-- class UI_Package_New_Dragon
-------------------------------------
UI_Package_New_Dragon = class(PARENT,{
        m_data = 'table',
        m_pids = 'table',

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

    self:initUI()
	self:initButton(is_popup)
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_New_Dragon:initUI()
    local vars = self.vars

    local struct_product_left = g_shopDataNew:getTargetProduct(tonumber(self.m_pids[1]))
    local struct_product_right = g_shopDataNew:getTargetProduct(tonumber(self.m_pids[2]))
    

    local product_id_left = self:getFirstProductId(struct_product_left)
    local product_id_right = self:getFirstProductId(struct_product_right)

    -- 왼쪽 상품 UI 세팅
    do
        if (not product_id_left) then
            return
        end

        local ui_product_left = openPackage_New_Dragon(struct_product_left, product_id_left)   
        if (ui_product_left) then
            vars['productNode1']:addChild(ui_product_left.root)
        end
    end
    
    -- 오른쪽 상품 UI 세팅
    do
        if (not product_id_right) then
            return
        end
        
        local ui_product_right = openPackage_New_Dragon(struct_product_right, product_id_right)
        if (ui_product_right) then
            vars['productNode2']:addChild(ui_product_right.root)
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_New_Dragon:refresh()
    local vars = self.vars   
    
    local struct_product = g_shopDataNew:getTargetProduct(tonumber(self.m_pids[1])) -- 패키지 2개의 판매기간이 같다고 가정
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
-- function getFirstProductId
-- @breif 패키지에서 UI로 보여줄 상품은 mail_content의 첫 번째 상품
-------------------------------------
function UI_Package_New_Dragon:getFirstProductId(struct_product)
 
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
