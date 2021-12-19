local PARENT = UI

-------------------------------------
-- class UI_CustomEnhanceFruit
-------------------------------------
UI_CustomEnhanceFruit = class(PARENT, {
        m_data = 'table',

        m_upCount = 'number',

        m_usingCnt = 'number',

        m_parent = 'UI_DragonReinforcement',

        m_itemLabel = 'label',

        m_fid = 'number',
     })


-------------------------------------
-- function init
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:init(parent)
    self.m_uiName = 'UI_CustomEnhanceFruit'
    local vars = self:load('dragon_enhance_tooltip.ui')

    self.m_parent = parent
    self.m_usingCnt = 0
    self.m_upCount = 0
    self:initButton()
    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initButton
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:initButton()
    local vars = self.vars

    if (vars['applyBtn']) then vars['applyBtn']:registerScriptTapHandler(function() self:click_applyBtn() end) end
    
    vars['enhanceLabel']:setString('')
    
    if (vars['plusBtn']) then vars['plusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(1) end) end
    if (vars['minusBtn']) then vars['minusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(-1) end) end
    if (vars['maxBtn']) then vars['maxBtn']:registerScriptTapHandler(function() self:click_max() end) end


    
    -- 1번 마이너스 2번 플러스
    --[[
    vars['quantityBtn2']:registerScriptTapHandler(function() self:click_quantityBtn(1) end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_quantityBtn(-1) end)

    vars['quantityBtn2']:registerScriptPressHandler(function() self:click_quantityBtn(1, true) end)
    vars['quantityBtn1']:registerScriptPressHandler(function() self:click_quantityBtn(-1, true) end)]]
end

-------------------------------------
-- function initUI
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:initUI()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:refresh()
    local vars = self.vars

    local text = tostring(self.m_upCount).. ' ' .. Str('강화')

    vars['enhanceLabel']:setString(text)
    self.m_usingCnt = self:getRequiredExpByLevel()

    local can_use = self.m_usingCnt > 0
    local color = can_use and COLOR['black'] or COLOR['DESC']

    vars['applyBtn']:setEnabled(can_use)
    vars['applyLabel']:setColor(color)

    if (self.m_itemLabel) then
	    string_format = '%s / %s'
	    self.m_itemLabel:setString(string.format(string_format, comma_value(self.m_usingCnt), comma_value(self.m_data['relation'])))
    end
end


function UI_CustomEnhanceFruit:click_applyBtn()
    self.m_parent:request_upgrade(self.m_usingCnt, self.m_fid)

    self.root:setVisible(false)
end



function UI_CustomEnhanceFruit:setActive(is_visible, data, label, fid)
    if (self.m_itemLabel) then
	    string_format = '%s / %s'
	    self.m_itemLabel:setString(comma_value(self.m_data['relation']))
    end

    self.m_data = data
    self.m_itemLabel = label.m_label
    self.m_fid = fid

    if (is_visible) then
        self.m_upCount = 0
        self:refresh()
    else

    end

    self:setVisible(is_visible)
end


-------------------------------------
-- function click_quantityBtn
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:click_quantityBtn(number, is_pressed)
    local vars = self.vars

    local function adjust_func()
        self:refresh()
    end

    local max_available_lv = self:getMaxAvailableLevel()

    local adjust_cnt = number < 0 and math.max(self.m_upCount + number, 0) or math.min(self.m_upCount + number, max_available_lv)

    if (not is_pressed) then
        self.m_upCount = adjust_cnt
        adjust_func()
    else
        local button    

        -- 버튼 2번이 플러스
        if (number >= 0) then
            button = vars['quantityBtn2']
        else
            button = vars['quantityBtn1']
        end

        local function update_level(dt)
            adjust_cnt = number < 0 and math.max(self.m_upCount + number, 0) or math.min(self.m_upCount + number, max_available_lv)

            if (not button:isSelected()) or (not button:isEnabled()) then
                self.root:unscheduleUpdate()
            else
                self.m_upCount = adjust_cnt
                adjust_func()
            end
        end

        self.root:scheduleUpdateWithPriorityLua(function(dt) return update_level(dt) end, 0)
    end
end

-------------------------------------
-- function click_apply
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:click_apply()
    -- self.m_usingCnt

    self:setVisible(false)
end

-------------------------------------
-- function click_max
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:click_max()
    self.m_upCount = self:getMaxAvailableLevel()

    self:refresh()
end




-------------------------------------
-- function getMaxAvailableLevel
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:getMaxAvailableLevel()
    local index = 0
    local exp = tonumber(self.m_data['exp'])
    local relation = tonumber(self.m_data['relation']) * tonumber(self.m_data['one_exp']) + exp
    local level_table = self.m_data['exp_list']

    for idx, exp in ipairs(level_table) do
        if (tonumber(exp) > relation) then break end
        relation = relation - tonumber(exp)
        index = idx
    end

    return index
end


-------------------------------------
-- function getRequiredExpByLevel
-- @brief 
-------------------------------------
function UI_CustomEnhanceFruit:getRequiredExpByLevel()
    if (not self.m_data) then return 0 end

    local cur_exp = tonumber(self.m_data['exp'])
    local relation = tonumber(self.m_data['relation']) * tonumber(self.m_data['one_exp'])
    local level_table = self.m_data['exp_list']
    local point = 0

    -- self.m_upCount
    -- 다음경험치 - 현재경험치 = 바로 다음단계 경험치
    for idx, exp in ipairs(level_table) do
        -- 단계수 도달
        if (self.m_upCount  + 1 <= idx) then 
        
            break
        end

        local combine_exp = exp

        if (idx == 1) then 
            combine_exp = combine_exp - cur_exp 
        
        end

        if (tonumber(combine_exp) > relation) then
            point = point + relation
            break
            
        else
            relation = relation - tonumber(combine_exp)
            point = point + tonumber(combine_exp)

        end
    end

    cclog(point)

    return math_floor(point / tonumber(self.m_data['one_exp']))
end

