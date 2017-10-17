local PARENT = UI

-------------------------------------
-- class UI_Forest_ExtensionBoard
-------------------------------------
UI_Forest_ExtensionBoard = class(PARENT,{
        m_cbForestLVChange = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_ExtensionBoard:init()
    local vars = self:load('dragon_forest_level.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_ExtensionBoard:initUI()
    local vars = self.vars
    vars['forestLvGauge']:setPercentage(0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_ExtensionBoard:initButton()
    local vars = self.vars
    vars['lvUpBtn']:registerScriptTapHandler(function() self:click_lvUpBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_ExtensionBoard:refresh()
    local lv = ServerData_Forest:getInstance():getExtensionLV()
    local max_lv = ServerData_Forest:getInstance():getExtensionMaxLV()
    

    local vars = self.vars

    -- 숲 레벨
    vars['forestLvLabel']:setString('Lv.' .. tostring(lv))

    local action = cc.ProgressTo:create(0.5, (lv/max_lv) * 100)
    vars['forestLvGauge']:runAction(action)

    -- 최대 레벨 확인
    if (max_lv <= lv) then
        vars['lvUpBtn']:setVisible(false)
        vars['maxSprite']:setVisible(true)
        vars['lockSprite']:setVisible(false)
        return
    end

    vars['lvUpBtn']:setVisible(true)
    vars['maxSprite']:setVisible(false)

    local extension = 'extension'
    local t_extension_info = TableForestStuffLevelInfo:getStuffTable(extension)
    local t_next = t_extension_info[lv + 1]

    local price_type = t_next['price_type']
    local price = t_next['price_value']

    -- 가격
    local icon = IconHelper:getPriceIcon(price_type)
    vars['priceNode']:removeAllChildren()
    vars['priceNode']:addChild(icon)
    vars['priceLabel']:setString(comma_value(price))

    -- 레벨 제한
    if (t_next['tamer_lv'] > g_userData:get('lv')) then
        vars['lockSprite']:setVisible(true)
        vars['lockLabel']:setString(Str('테이머 레벨 {1}', t_next['tamer_lv']))
    else
        vars['lockSprite']:setVisible(false)
    end
end

-------------------------------------
-- function click_lvUpBtn
-- @brief
-------------------------------------
function UI_Forest_ExtensionBoard:click_lvUpBtn()
    local btn = self.vars['lvUpBtn']
    if (not btn:isVisible()) or (not btn:isEnabled()) then
        return
    end

    local function cb_func(ret)
        self:refresh()
        self.vars['forestVisual']:changeAni('home_lvup')
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')
        if self.m_cbForestLVChange then
            self.m_cbForestLVChange(ret)
        end
	end

    ServerData_Forest:getInstance():extendMaxCount(cb_func)
end

-------------------------------------
-- function setForestLvChange
-- @brief
-------------------------------------
function UI_Forest_ExtensionBoard:setForestLvChange(cb_forest_lv_change)
    self.m_cbForestLVChange = cb_forest_lv_change
end