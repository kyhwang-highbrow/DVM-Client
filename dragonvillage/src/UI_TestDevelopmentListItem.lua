local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TestDevelopmentListItem
-------------------------------------
UI_TestDevelopmentListItem = class(PARENT, {
        m_data = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TestDevelopmentListItem:init(t_data)
    self.m_data = t_data
    local vars = self:load('empty.ui')

    --self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TestDevelopmentListItem:initUI()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo    

    vars['timeLabel']:setString(t_friend_info:getPastActiveTimeText())
    vars['nameLabel']:setString(t_friend_info:getNickText())
    vars['levelLabel']:setString(t_friend_info:getLvText())
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TestDevelopmentListItem:initButton()
    local vars = self.vars

    local node = cc.MenuItemImage:create('res/ui/buttons/64_base_btn_0101.png', 'res/ui/buttons/64_base_btn_0102.png', 1)
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))
    --node:setPositionX(-40)
    --node:setAnchorPoint(cc.p(0.5, 0.5))
    local uic_button = UIC_Button(node)
    uic_button:registerScriptTapHandler(function()
        --data['cb1'](self, data, 1)

        if self.m_data['cb'] then
            self.m_data['cb']()
        end
    end)
    self.root:addChild(node)  
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TestDevelopmentListItem:refresh()
end
