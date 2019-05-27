local PARENT = UI

-------------------------------------
-- class UI_GoodsInfo
-------------------------------------
UI_GoodsInfo = class(PARENT, {
        m_goodsType = 'string',
        m_numberLabel = 'NumberLabel',
     })

local THIS = UI_GoodsInfo

-------------------------------------
-- function init
-------------------------------------
function UI_GoodsInfo:init(goods_type)
    self.m_goodsType = goods_type

    local vars = self:load('top_user_info_goods.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GoodsInfo:initUI()
    local vars = self.vars

    local icon = self:makeGoodsIcon(goods_name)
    vars['iconNode']:addChild(icon)

    self.m_numberLabel = NumberLabel(vars['label'], 0, 0.3) -- param : label, number, actionDuration
    self.m_numberLabel:setNumber(0, false) -- param : number, immediately
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GoodsInfo:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GoodsInfo:refresh()
    local vars = self.vars

    -- 재화 수량 갱신
    local goods_type = self.m_goodsType
    local value = g_userData:get(goods_type)
    self.m_numberLabel:setNumber(value)
end

-------------------------------------
-- function makeGoodsIcon
-------------------------------------
function UI_GoodsInfo:makeGoodsIcon(goods_name)
    local goods_name = (goods_name or self.m_goodsType)

    if (goods_name == 'runeGrindStone') then
        goods_name = 'grindstone'
    end
    
    if (goods_name == 'event_illusion') then
        goods_name = 'staminas_illusion_token_01'
    end
    
    local res_icon = string.format('res/ui/icons/inbox/inbox_%s.png', goods_name)
    local icon = cc.Sprite:create(res_icon)

    if (not icon) then
        icon = cc.Sprite:create('res/ui/icons/cha/developing.png')
    end

    if (icon) then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        --ui.vars['iconNode']:addChild(icon)
    end

    return icon
end