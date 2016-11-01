local PARENT = UI

-------------------------------------
-- class UI_ItemCard
-------------------------------------
UI_ItemCard = class(PARENT, {
        m_itemID = 'number',
        m_itemCount = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemCard:init(item_id, count)
    self.m_itemID = item_id
    self.m_itemCount = count

    local vars = self:load('drop_item.ui')

    local icon = IconHelper:getItemIcon(item_id)
    vars['stoneNode']:addChild(icon)

    if (not count) or (count == 0) then
        vars['numberLabel']:setString('')
    else
        vars['numberLabel']:setString(Str('X{1}', comma_value(count)))
    end

    vars['disableSprite']:setVisible(false)

    -- 레어도 표시
    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    local rarity_str = evolutionStoneRarityNumToStr(t_item['rarity'])
    vars['rarityVisual']:setVisual('group', rarity_str)

    
    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function setRarityVisibled
-------------------------------------
function UI_ItemCard:setRarityVisibled(visible)
    self.vars['rarityVisual']:setVisible(visible)
end

-------------------------------------
-- function setHighlight
-------------------------------------
function UI_ItemCard:setHighlight(visible)
    self.vars['highlightSprite']:setVisible(visible)
    self.vars['numberLabel']:setString(Str('확률 증가'))
end

-------------------------------------
-- function setString
-------------------------------------
function UI_ItemCard:setString(str)
    self.vars['numberLabel']:setString(str)
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_ItemCard:click_clickBtn()

cclog('######## 클릭')
    local str = self:getToolTipDesc()
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_ItemCard:getToolTipDesc()
    local item_id = self.m_itemID

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    local desc = ''

    -- 열매 description은 아이템
    if (t_item['type'] == 'fruit') then
        if (t_item['t_desc'] == 'x') then
            local full_type = t_item['full_type']
            local table_fruit = TABLE:get('fruit')
            local t_fruit = table_fruit[full_type]
            desc = t_fruit['t_desc']
        end
    else
        desc = t_item['t_desc']
    end

    local str = '{@SKILL_NAME} ' .. t_item['t_name'] .. '\n {@SKILL_DESC}' .. desc
    return str
end