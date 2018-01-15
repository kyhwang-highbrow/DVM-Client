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