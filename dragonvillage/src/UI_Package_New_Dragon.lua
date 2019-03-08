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

    local struct_product1 = g_shopDataNew:getTargetProduct(tonumber(self.m_pids[1]))
    local struct_product2 = g_shopDataNew:getTargetProduct(tonumber(self.m_pids[2]))
    
    -- @jhakim 20190308 대표상품 하드코딩 -> mail_content 의 첫 번쨰 아이템으로 수정해야함
    local left_premier_item_id = 700603
    local right_premier_item_id = 771115

    local ui_product1 = openPackage_New_Dragon(struct_product1, left_premier_item_id)
    local ui_product2 = openPackage_New_Dragon(struct_product2, right_premier_item_id)

    vars['productNode1']:addChild(ui_product1.root)
    vars['productNode2']:addChild(ui_product2.root)
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
