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
-- class UI_NestDungeonListItem
-------------------------------------
UI_NestDungeonListItem = class(PARENT, {
        m_tData = 'nestDungeonInfo',
        m_remainTimeText = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonListItem:init(t_data)
    self.m_tData = t_data

    local vars = self:load('nest_dungeon_list_item.ui')

    self:initUI(t_data)
    self:initButton()
    self:refresh()

    self.root:setDockPoint(cc.p(0, 0))
    self.root:setAnchorPoint(cc.p(0, 0))

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDungeonListItem:initUI(t_data)

    local vars = self.vars

    local dungeon_id = t_data['mode_id']
    local ani_name = t_nest_dungeon_ani[dungeon_id]
    vars['dungeonListVisual']:changeAni(ani_name)

    -- 남은 시간 얻어오기
    g_nestDungeonData:getNestDungeonRemainTimeText(dungeon_id)

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
function UI_NestDungeonListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDungeonListItem:refresh()
    local vars = self.vars
    vars['dayLabel']:setString('')

    -- 요일 정보 출력
    self:refresh_dayLabel(self.m_tData['days'], self.m_tData['mode'])
end

-------------------------------------
-- function refresh_dayLabel
-------------------------------------
function UI_NestDungeonListItem:refresh_dayLabel(days, mode)
    local vars = self.vars

    local l_days = seperate(days, ',')

    -- 거대용 던전이 아닌 경우
    --if (#l_days >= 7) then
    if (mode ~= 1) then
        vars['dayLabel']:setString('')
        return
    end

    local t_days = {}
    t_days['mon'] = {day='mon', name='월', idx=1}
    t_days['tue'] = {day='tue', name='화', idx=2}
    t_days['wed'] = {day='wed', name='수', idx=3}
    t_days['thu'] = {day='thu', name='목', idx=4}
    t_days['fri'] = {day='fri', name='금', idx=5}
    t_days['sat'] = {day='sat', name='토', idx=6}
    t_days['sun'] = {day='sun', name='일', idx=7}

    local l_days_sort = {}
    for i, v in ipairs(l_days) do
        local t_day = t_days[v]
        table.insert(l_days_sort, t_day)
    end

    local function sort_func(a, b)
        return a['idx'] < b['idx']
    end

    table.sort(l_days_sort, sort_func)

    local str = ''

    for i, v in ipairs(l_days_sort) do
        if (i ~= 1) then
            str = str .. ', '
        end
        str = str .. v['name']
    end

    vars['dayLabel']:setString(str)
end

-------------------------------------
-- function update
-------------------------------------
function UI_NestDungeonListItem:update(dt)
    local dungeon_id = self.m_tData['mode_id']
    local text = g_nestDungeonData:getNestDungeonRemainTimeText(dungeon_id)

    -- 텍스트가 변경되었을 때에만 문자열 변경
    if (self.m_remainTimeText ~= text) then
        self.m_remainTimeText = text
        self.vars['timeLabel']:setString(text)

        do -- 텍스트 변경됨을 알리는 액션
            self.vars['timeLabel']:stopAllActions()
            local start_action = cc.MoveTo:create(0.05, cc.p(-20, -223))
            local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, -223)), 0.2)
            self.vars['timeLabel']:runAction(cc.Sequence:create(start_action, end_action))
        end
    end
end