local PARENT = UI

-------------------------------------
-- class UI_EventAlphabetListItem
-------------------------------------
UI_EventAlphabetListItem = class(PARENT,{
        m_eventDataUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAlphabetListItem:init(ui_name)
    local ui_name = (ui_name or 'empty.ui')
    local vars = self:load(ui_name)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAlphabetListItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAlphabetListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAlphabetListItem:refresh(t_word_data)
    if (not t_word_data) then
        return
    end

    local vars = self.vars

    for i,item_id in ipairs(t_word_data['alphabet_list']) do

        local count = g_userData:get('alphabet', tostring(item_id)) or 0
        local item_card = UI_ItemCard(item_id, count)
        item_card.root:setSwallowTouch(false)
        --self.root:addChild(item_card.root)
        vars['alphabetNode' .. i]:addChild(item_card.root)

        local vars = item_card.vars
        vars['commonSprite']:setVisible(false)
        vars['bgSprite']:setVisible(false)
        --vars['numberLabel']:setString(100)
        
        if (count <= 0) then
            local shader = ShaderCache:getShader(SHADER_GRAY_PNG)
            vars['icon']:setGLProgram(shader)
        end
    end

    
end