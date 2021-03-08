local PARENT = class(UI, ITableViewCell:getCloneTable())

UI_BattlePassTabButton = class(PARENT, {

    m_structProduct = 'StructProduct',

    -- Nodes in ui file
    m_listBtn = '',
    m_selectSprite = '',
    m_badgeNode = '',
    m_listLabel = '',
    m_iconNode = '',
    
})


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// pure virtual functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassTabButton:init(struct_product)

    local vars = self:load('shop_battle_pass_list.ui')

    self:initMember(struct_product)
    self:initUI()
    self:initButton()
    self:refresh()
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassTabButton:initUI()
    local vars = self.vars

    -- 버튼 이름 (패키지 번들 참조)

    local pid = self.m_structProduct['product_id']
    local l_item_list = g_shopDataNew:getProductList('pass')
    local name = l_item_list[pid]['t_name']

    if (name) then
        self.m_listLabel:setString(name)
    end
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassTabButton:initButton()
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassTabButton:refresh()
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Init Helper Functions (local)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassTabButton:initMember(struct_product)
    local vars = self.vars

    self.m_structProduct = struct_product

    self.m_listBtn = vars['listBtn']
    self.m_selectSprite = vars['selectSprite']
    self.m_badgeNode = vars['badgeNode']
    self.m_listLabel = vars['listLabel']
    self.m_iconNode = vars['iconNode']
    
end