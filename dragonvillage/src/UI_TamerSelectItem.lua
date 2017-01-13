local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TamerSelectItem
-------------------------------------
UI_TamerSelectItem = class(PARENT, {
        m_tamerID = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerSelectItem:init(tamer_id)
    local vars = self:load('tamer_select_popup_item.ui')

    self:initUI()
    self:initButton()
    self:refresh(tamer_id)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerSelectItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerSelectItem:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerSelectItem:refresh(tamer_id)
    local table_tamer = TableTamer()
    local t_tamer = table_tamer:get(tamer_id)

    local vars = self.vars
    local name = Str(t_tamer['t_name'])
    vars['tamerNameLabel']:setString(name)

    local res = 'res/ui/icon/cha/tamer_' .. t_tamer['type'] .. '.png'
    local icon = cc.Sprite:create(res)
    if icon then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['tamerNode']:addChild(icon)
    end

    if (tamer_id == 1) then
        vars['lockSprite']:setVisible(false)
        vars['lockBtnSprite']:setVisible(false)

        vars['selectLabel']:setColor(cc.c3b(255, 187, 0))
        vars['selectBtn']:setEnabled(true)
    else
        vars['lockSprite']:setVisible(true)
        vars['lockBtnSprite']:setVisible(true)
        
        vars['selectLabel']:setColor(cc.c3b(255, 255, 255))
        vars['selectLabel']:setString('')
        vars['selectBtn']:setEnabled(false)
    end 
end