local PARENT = UI

-------------------------------------
-- class UI_FruitListItem
-------------------------------------
UI_FruitListItem = class(PARENT, {
        m_fruitRarity = 'number',
        m_fruitType = 'string',
        m_fruitFullType = 'string',
        m_clickCB = 'function',

        m_baseScale = 'number',
        m_useToolTip = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FruitListItem:init(rarity, type, click_cb)
    local vars = self:load('fruit_item.ui')

    self.m_fruitRarity = rarity
    self.m_fruitType = type
    self.m_fruitFullType = DataFruit:makeFruitFullType(rarity, type)
    self.m_clickCB = click_cb
    self.m_baseScale = 1
    self.m_useToolTip = false

    --[[
    selectSprite
    numberLabel
    fruitNode
    selectBtn
    --]]

    self.root:setSwallowTouch(false)

    local item_icon = IconHelper:getItemIcon(self.m_fruitFullType)
    vars['fruitNode']:addChild(item_icon)

    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)

    self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FruitListItem:refresh()
    local rarity = self.m_fruitRarity
    local detailed_stats_type = self.m_fruitType
    local fruit_count = g_fruitData:getFruitCount(rarity, detailed_stats_type)

    local dp_max_count = 9999
    if (fruit_count > dp_max_count) then
        self.vars['numberLabel']:setString('+' .. comma_value(9999))
    else
        self.vars['numberLabel']:setString(comma_value(fruit_count))
    end
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_FruitListItem:click_selectBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')

    self.root:stopAllActions()

    -- 버튼 클릭 리액션
    local scale = self.m_baseScale
    self.root:setScale(0.9 * scale)
    self.root:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.2 * scale), cc.ScaleTo:create(0.1, 1 * scale)))

    if self.m_clickCB then
        local fruit_full_type = self.m_fruitFullType
        self.m_clickCB(fruit_full_type)
    end

    if self.m_useToolTip then
        self:showToolTip()
    end
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_FruitListItem:setSelected(selected)
    self.vars['selectSprite']:setVisible(selected)
end

-------------------------------------
-- function setBaseScale
-------------------------------------
function UI_FruitListItem:setBaseScale(base_scale)
    self.m_baseScale = base_scale
    self.root:stopAllActions()
    self.root:setScale(base_scale)
end

-------------------------------------
-- function showToolTip
-------------------------------------
function UI_FruitListItem:showToolTip()
    local str = self:getFruitDescStr()
    local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['selectBtn'])
end

-------------------------------------
-- function getFruitDescStr
-------------------------------------
function UI_FruitListItem:getFruitDescStr()
    local table_fruit = TABLE:get('fruit')
    local t_fruit = table_fruit[self.m_fruitFullType]

    local str = '{@SKILL_NAME} ' .. t_fruit['t_name'] .. '\n {@SKILL_DESC}' .. t_fruit['t_desc']
    return str
end