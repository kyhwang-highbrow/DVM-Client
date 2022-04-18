local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventRouletteRewardItem
-- @brief
-------------------------------------
UI_EventRouletteRewardItem = class(PARENT, {
    m_key = 'number',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRouletteRewardItem:init(data)
    local vars = self:load('event_roulette_item.ui')

    if (data['val'] == nil) or (data['val'] == '') then
        vars['countLabel']:setString(Str(data['item_name']))
    else
        vars['countLabel']:setString(Str(string.format('%5d', data['val'])))
    end
    
    vars['probLabel']:setString(Str(data['real_weight']))
    
    -- vars['itemMenu']
    -- vars['itemNode']
    -- vars['countLabel']
    -- vars['probLabel']
end