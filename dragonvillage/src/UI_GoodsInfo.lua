local PARENT = UI

-------------------------------------
-- class UI_GoodsInfo
-------------------------------------
UI_GoodsInfo = class(PARENT, {
        m_goodsType = 'string',
        m_numberLabel = 'NumberLabel',
        m_realNumber = 'number',
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

    -- 캐시 중인 숫자가 다를 경우만 호출 (임의로 탑바의 숫자를 변경하는 경우에 동작하는 것을 방지하기 위함)
    if (self.m_realNumber ~= value) then
        self.m_realNumber = value
        self.m_numberLabel:setNumber(value)
    end
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
        goods_name = 'staminas_event_illusion_01'
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

-------------------------------------
-- function setGoodsNumber
-- @brief 재화 숫자 설정
--        (유저 데이터가 아닌 임의로 사용하고자 할 때 사용)
-- @param num number
-------------------------------------
function UI_GoodsInfo:setGoodsNumber(num)
    if (self.m_numberLabel == nil) then
        return
    end

    self.m_numberLabel:setNumber(num)
end

-------------------------------------
-- function clearRealNumber
-- @brief 캐싱된 실제 (유저)데이터를 초기화 하여 UI가 갱신되도록 함
-------------------------------------
function UI_GoodsInfo:clearRealNumber()
    self.m_realNumber = nil
end
