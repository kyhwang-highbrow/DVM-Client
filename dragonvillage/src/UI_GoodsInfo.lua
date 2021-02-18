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

    vars['chargeBtn']:registerScriptTapHandler(function() self:click_chargeBtn() end)
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

-------------------------------------
-- function click_chargeBtn
-------------------------------------
function UI_GoodsInfo:click_chargeBtn()
    local vars = self.vars

    local goods_type = self.m_goodsType

    if (goods_type == nil) then
        
    elseif (goods_type == 'gold') then
        UINavigatorDefinition:goTo('shop', 'gold')
    elseif (goods_type == 'cash') then
        UINavigatorDefinition:goTo('shop', 'cash')
    elseif (goods_type == 'honor') then
        UINavigatorDefinition:goTo('shop', 'honor')
    elseif (goods_type == 'valor') then
        UINavigatorDefinition:goTo('shop', 'valor')
    elseif (goods_type == 'capsule_coin') then
        local capsule_coin_package_popup = PackageManager:getTargetUI('package_capsule_coin', true)
    elseif (goods_type == 'st') then
        local b_use_cash_label = false
        local ui_charge_popup = UI_StaminaChargePopup(b_use_cash_label)
    else
        self:showToolTip()
    end
end

-------------------------------------
-- function showToolTip
-------------------------------------
function UI_GoodsInfo:showToolTip()
    local vars = self.vars
    
    local goods_type = self.m_goodsType

    local name
    local desc

    if (goods_type == 'fpvp') then
        name = Str('친선전 입장권')
        desc = Str('친구가 된 테이머와 강함을 겨룰 수 있는 친선전 입장권.')
    else
        local goods_id = TableItem():getItemIDFromItemType(goods_type)
        local t_item = TABLE:get('item')[goods_id]
        name = Str(t_item['t_name'])
        desc = Str(t_item['t_desc'])
    end

    local str = Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', name, desc)
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['chargeBtn'])
end
