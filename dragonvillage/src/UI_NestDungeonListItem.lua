local PARENT = class(UI, ITableViewCell:getCloneTable())

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

    local vars = self:load('dungeon_item.ui')

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

    -- 리스트 아이템 이미지 지정
    local res = t_data['res']
    local ani = t_data['ani']
    local animator = MakeAnimator(res)
    animator:changeAni(ani, true)
    vars['dungeonImgNode']:addChild(animator.m_node)

    -- 남은 시간 얻어오기
    local dungeon_id = t_data['mode_id']
    g_nestDungeonData:getNestDungeonRemainTimeText(dungeon_id)
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

    vars['titleLabel']:setString(Str(self.m_tData['t_name']))
    vars['infoLabel']:setString(Str(self.m_tData['t_info']))

    -- 요일 정보 출력
    self:refresh_dayLabel(self.m_tData['major_day'], self.m_tData['days'], self.m_tData['mode'])

    -- 보너스 정보 출력
    self:refresh_bonusInfo()
end

-------------------------------------
-- function refresh_dayLabel
-------------------------------------
function UI_NestDungeonListItem:refresh_dayLabel(major_day, days, mode)
    local vars = self.vars

    -- 거대용, 거목던전은 요일던전 형태로 동작
    if (mode ~= NEST_DUNGEON_DRAGON) and (mode ~= NEST_DUNGEON_TREE) then
        vars['dayLabel']:setString('')
        
        if vars['timeNode'] then
            vars['timeNode']:setVisible(false)
        end
        vars['timeLabel']:setVisible(false)
        return
    end
    
    -- major_day가 없을 경우 가장 빠른 요일로 처리
    if (not major_day) then
        local t_days = {}
        t_days['mon'] = 1
        t_days['tue'] = 2
        t_days['wed'] = 3
        t_days['thu'] = 4
        t_days['fri'] = 5
        t_days['sat'] = 6
        t_days['sun'] = 7
    

        local l_days = seperate(days, ',')
        table.sort(l_days, function(a, b)
            return t_days[a] < t_days[b]
        end)

        major_day = l_days[1]
    end

    --[[
    -- 모든 요일 표시 코드
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
    --]]

    local str = ''
    if     (major_day == 'mon') then str = Str('월요일')
    elseif (major_day == 'tue') then str = Str('화요일')
    elseif (major_day == 'wed') then str = Str('수요일')
    elseif (major_day == 'thu') then str = Str('목요일')
    elseif (major_day == 'fri') then str = Str('금요일')
    elseif (major_day == 'sat') then str = Str('토요일')
    elseif (major_day == 'sun') then str = Str('일요일')
    end

    vars['dayLabel']:setString(str)
end

-------------------------------------
-- function refresh_bonusInfo
-- @brief "거목 던전"에서 해당하는 요일에 추가 보상을 준다는 것을 알려줌
-------------------------------------
function UI_NestDungeonListItem:refresh_bonusInfo()
    local vars = self.vars

    -- 보너스가 없을 경우 리턴 
    local bonus_rate = self.m_tData['bonus_rate'] or 0
    if (bonus_rate <= 0) then
        return
    end

    -- 등록된 보너스 아이템이 없을 경우 리턴
    local l_bonus_value = seperate(self.m_tData['bonus_value'], ',')
    if (#l_bonus_value <= 0) then
        return
    end

    vars['bonusSprite']:setVisible(true)

    -- 첫 번째 아이템의 속성을 얻어옴
    local table_item = TABLE:get('item')
    local first_bonus_item = tonumber(l_bonus_value[1])
    local t_item = table_item[first_bonus_item]
    local attr = t_item['attr']

    -- 속성에 따라 문구 결정
    local attr_str = dragonAttributeName(attr)
    local str = Str('{1}의 열매 추가 제공 중!', attr_str)
    vars['bonusLabel']:setString(str)
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
            local start_action = cc.MoveTo:create(0.05, cc.p(-20, 0))
            local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, 0)), 0.2)
            self.vars['timeLabel']:runAction(cc.Sequence:create(start_action, end_action))
        end
    end
end