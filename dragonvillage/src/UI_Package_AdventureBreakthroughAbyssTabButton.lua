local PARENT = class(UI_Package, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Package_AdventureBreakthroughAbyssTabButton
-------------------------------------
UI_Package_AdventureBreakthroughAbyssTabButton = class(PARENT, {
        m_productId = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssTabButton:init(stage_id)
    self.m_productId = stage_id
    self:load('package_adventure_clear_abyss_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssTabButton:initUI()
    local vars = self.vars   
    local reward_list = g_adventureBreakthroughAbyssPackageData:getRewardListFromProductId(self.m_productId)

    if #reward_list > 0 then
        local t_data = reward_list[1]
        -- 스테이지
        local stage_id = t_data['stage']        
        local str = g_adventureData:getStageCategoryStr(stage_id)
        vars['listLabel']:setString(str)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssTabButton:initButton()
    local vars = self.vars
    --vars['listBtn']:registerScriptTapHandler(function() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AdventureBreakthroughAbyssTabButton:refresh()
    local vars = self.vars

    local struct_product = g_shopDataNew:getProduct('abyss_pass', self.m_productId)
    if (not struct_product) then
        return
    end

    self.m_productList = {struct_product}

    local is_noti_visible = false
    self:initEachProduct(index, struct_product)

    is_noti_visible = (struct_product:getPrice() == 0) and (struct_product:isItBuyable())

    if vars['notiSprite'] then 
        vars['notiSprite']:setVisible(is_noti_visible)
    end
end
