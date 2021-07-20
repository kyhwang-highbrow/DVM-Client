local PARENT = UI

-------------------------------------
-- class UI_StaminaInfo
-------------------------------------
UI_StaminaInfo = class(PARENT, {
        m_staminaType = 'string',
        m_numberLabel = 'NumberLabel',
     })

local THIS = UI_StaminaInfo

-------------------------------------
-- function init
-------------------------------------
function UI_StaminaInfo:init()
    local vars = self:load('top_user_info_goods.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function create
-------------------------------------
function UI_StaminaInfo:create(stamina_type)
    local ui = UI_StaminaInfo()

    if stamina_type then
        ui:setStaminaType(stamina_type)
    end

    return ui 
end

-------------------------------------
-- function setStaminaType
-------------------------------------
function UI_StaminaInfo:setStaminaType(stamina_type)
    local vars = self.vars

    self.m_staminaType = stamina_type

    local icon = IconHelper:getStaminaInboxIcon(stamina_type)
    vars['iconNode']:removeAllChildren()
    vars['iconNode']:addChild(icon)

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StaminaInfo:initUI()
    local vars = self.vars

    self.m_numberLabel = NumberLabel(vars['label'], 0, 0.3) -- param : label, number, actionDuration
    self.m_numberLabel:setNumber(0, false) -- param : number, immediately
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StaminaInfo:initButton()
    local vars = self.vars

    vars['chargeBtn']:registerScriptTapHandler(function() self:click_chargeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StaminaInfo:refresh()
    local vars = self.vars

    if (not self.m_staminaType) then
        vars['label']:setString('')
        return
    end

    -- 스태미너
    local stamina_type = self.m_staminaType
    local st_ad = g_staminasData:getStaminaCount(stamina_type)
    local max_cnt = g_staminasData:getStaminaMaxCnt(stamina_type)

    local str = Str('{1}/{2}', comma_value(st_ad), comma_value(max_cnt))

    -- 황금던전 이벤트 스태미너는 MAX 존재하지 않음
    if (stamina_type == 'event_st') then
        str = Str('{1}', comma_value(st_ad))
    end

    vars['label']:setString(str)

    local charging_time = TableStaminaInfo:getChargingTime(stamina_type)
    if (charging_time ~= '' and st_ad < max_cnt) then
        vars['timeNode']:setVisible(true)
        local time_str = g_staminasData:getChargeRemainText(self.m_staminaType)
        vars['timeLabel']:setString(time_str)
    else
        vars['timeNode']:setVisible(false)
    end

end

-------------------------------------
-- function click_chargeBtn
-------------------------------------
function UI_StaminaInfo:click_chargeBtn()
    local vars = self.vars

    local stamina_type = self.m_staminaType

    if (stamina_type == nil) then
        
    elseif (stamina_type == 'gold') then
        UINavigatorDefinition:goTo('shop', 'gold')
    elseif (stamina_type == 'cash') then
        UINavigatorDefinition:goTo('package_shop', 'diamond_shop')
    elseif (goods_type == 'capsule_coin') then
        local capsule_coin_package_popup = PackageManager:getTargetUI('package_capsule_coin', true)
    elseif (stamina_type == 'st') then
        local b_use_cash_label = false
        local ui_charge_popup = UI_StaminaChargePopup(b_use_cash_label)
    elseif (stamina_type == 'arena_new') then
        local ui_charge_popup = UI_ArenaNewStaminaChargePopup()
    else
        self:showToolTip()
    end
end

-------------------------------------
-- function showToolTip
-------------------------------------
function UI_StaminaInfo:showToolTip()
    local vars = self.vars
    
    local stamina_type = self.m_staminaType

    local name
    local desc

    if (stamina_type == 'fpvp') then
        name = Str('친선전 입장권')
        desc = Str('친구가 된 테이머와 강함을 겨룰 수 있는 친선전 입장권.')
    else
        local stamina_id = TableItem():getItemIDFromItemType(stamina_type)
        local t_item = TABLE:get('item')[stamina_id]
        cclog(stamina_type)

        name = Str(t_item['t_name'])
        desc = Str(t_item['t_desc'])
    end

    local str = Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', name, desc)
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['chargeBtn'])
end
