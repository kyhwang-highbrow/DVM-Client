local PARENT = class(UI, ITableViewCell:getCloneTable())

local t_nest_dungeon_ani = {}
t_nest_dungeon_ani[21100] = 'nest_dungeon_dragon_earth' -- 거대용 던전
t_nest_dungeon_ani[21200] = 'nest_dungeon_dragon_water'
t_nest_dungeon_ani[21300] = 'nest_dungeon_dragon_fire'
t_nest_dungeon_ani[21400] = 'nest_dungeon_dragon_light'
t_nest_dungeon_ani[21500] = 'nest_dungeon_dragon_dark'
t_nest_dungeon_ani[22100] = 'nest_dungeon_nightmare'    -- 악몽
t_nest_dungeon_ani[22200] = 'nest_dungeon_nightmare'
t_nest_dungeon_ani[22300] = 'nest_dungeon_nightmare'
t_nest_dungeon_ani[22400] = 'nest_dungeon_nightmare'
t_nest_dungeon_ani[23000] = 'nest_dungeon_tree'         -- 거목

-------------------------------------
-- class UI_NestDragonDungeonListItem
-------------------------------------
UI_NestDragonDungeonListItem = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_NestDragonDungeonListItem:init(t_data)
    local vars = self:load('nest_dungeon_scene1_list.ui')

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

    local vars = self.vars

    local ani_name = t_nest_dungeon_ani[t_data['mode_id']]
    vars['dungeonListVisual']:changeAni(ani_name)

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
