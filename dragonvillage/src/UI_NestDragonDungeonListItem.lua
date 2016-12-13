local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_NestDragonDungeonListItem
-------------------------------------
UI_NestDragonDungeonListItem = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_NestDragonDungeonListItem:init(t_data)
    local vars = self:load('nest_dungeon_list_02.ui')

    self:initUI(t_data)
    self:initButton()
    self:refresh()

    self.root:setDockPoint(cc.p(0, 0))
    self.root:setAnchorPoint(cc.p(0, 0))
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDragonDungeonListItem:initUI(t_data)
    --[[
    local vars = self.vars
    do -- lockSprite 지정
        vars['lockSprite']:setVisible(not t_data['open'])
        vars['lockSprite']:setLocalZOrder(1)
    end

    do -- titleLabel 지정
        local attr = t_data['attr']
        local str = ''
        if (attr == 'fire') then str = Str('불의 시련')
        elseif (attr == 'water') then str = Str('물의 시련')
        elseif (attr == 'earth') then str = Str('땅의 시련')
        elseif (attr == 'wind') then str = Str('바람의 시련')
        elseif (attr == 'light') then str = Str('빛의 시련')
        elseif (attr == 'dark') then str = Str('어둠의 시련')
        else error('attr : ' .. attr) end

        vars['titleLabel']:setString(str)
    end

    do -- openTimeLabel 지정
        vars['openTimeLabel']:setString(t_data['desc'])
    end

    do -- 아이콘 생성
        local icon = IconHelper:getAttributeIcon(t_data['attr'])
        icon:setPositionY(30)
        self.root:addChild(icon)
    end
    --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NestDragonDungeonListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDragonDungeonListItem:refresh()
end
