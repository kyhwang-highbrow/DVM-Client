local PARENT = UI

-------------------------------------
-- class UI_DragonTrainSlot_ListItem
-------------------------------------
UI_DragonTrainSlot_ListItem = class(PARENT, {
        m_doid = 'string',
        m_grade = 'number',


        m_cellSize = 'cc.size',
        m_bExpanded = 'boolean',

        m_bOrgVisible = 'boolean',
        m_visibleRefCnt = 'number',
     })

-------------------------------------
-- function init
-- @param t_data {doid=dragon_object_id, grade=1~6}
-------------------------------------
function UI_DragonTrainSlot_ListItem:init(t_data)
    self.m_doid = t_data['doid']
    self.m_grade = t_data['grade']

    local vars = self:load('dragon_train_list2.ui')

    self.m_cellSize = self.root:getContentSize()    

    self:refresh()

    self.m_bExpanded = true
    self.m_bOrgVisible = true
    self.m_visibleRefCnt = 0
end

-------------------------------------
-- function refresh
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:refresh()
    local vars = self.vars

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_doid)
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(t_dragon_data['did'])

    do -- 수련 슬롯 등급
        vars['starNode']:removeAllChildren()
        local icon = cc.Sprite:create('res/ui/star020' .. self.m_grade .. '.png')
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setDockPoint(cc.p(0.5, 0.5))
        vars['starNode']:addChild(icon)
    end

    -- 가격 표시
    local table_dragon_train_info = TableDragonTrainInfo()
    local req_lactea = table_dragon_train_info:getReqLactea(self.m_grade, t_dragon['rarity'])

    -- a슬롯
    self:refresh_slotVars(self.m_grade, 'a', t_dragon['role'], req_lactea)

    -- b슬롯
    self:refresh_slotVars(self.m_grade, 'b', t_dragon['role'], req_lactea)
end

-------------------------------------
-- function parseTrainSlotData
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:parseTrainSlotData(slot_name)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_doid)

    local level = t_dragon_data['train_slot'][slot_name] or 0
    local is_max_level = (level >= 10)
    local reward_receive = t_dragon_data['train_max_reward'][slot_name] or false

    return level, is_max_level, reward_receive
end

-------------------------------------
-- function refresh_slotVars
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:refresh_slotVars(grade, slot_type, role, req_lactea)
    local vars = self.vars

    local slot_name = string.format('%.2d_%s', grade, slot_type)
    local level, is_max_level, reward_receive = self:parseTrainSlotData(slot_name)

    local table_dragon_train_statue = TableDragonTrainStatus()

    -- luaname을 위해 대문자로 변경
    local suffix = string.upper(slot_type)

    -- 가격 표시
    if (is_max_level == true) and (reward_receive == true) then
        vars['priceLabel' .. suffix]:setString(Str('MAX'))
    elseif (is_max_level == true) and (reward_receive == false) then
        vars['priceLabel' .. suffix]:setString(Str('보상'))
    else
        vars['priceLabel' .. suffix]:setString(comma_value(req_lactea))
    end

    -- 레벨 표시 (1~10레벨이므로 10을 곱함)
    vars['trainGaugeLabel' .. suffix]:setString(Str('{1}/10', level))
    vars['trainGauge' .. suffix]:setPercentage(level * 10)

    -- 수련 1회에 해당하는 설명
    local desc = table_dragon_train_statue:getDesc(slot_name, role)
    vars['dscLabel' .. suffix]:setString(desc)

    -- 현재 상승된 능력치
    local str = table_dragon_train_statue:getTrainSlotDescStr(slot_name, role, level)
    vars['titleLabel' .. suffix]:setString(str)
end

-------------------------------------
-- function setExpand
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:setExpand(expand, duration)
    if (self.m_bExpanded == expand) then
        return
    end

    self.m_bExpanded = expand

    local target_width = 400
    local duration = duration or 0.15

    if (expand) then
        target_width = 400
    else
        target_width = 180
    end

    local node = self.root

    local width, height = node:getNormalSize()
    local func = function(value)
        node:setNormalSize(value, height)
    end
    local tween = cc.ActionTweenForLua:create(duration, width, target_width, func)
    node:stopAllActions()
    node:runAction(tween)

    self.m_cellSize['width'] = target_width

end













-------------------------------------
-- function getCellSize
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:getCellSize()
    return self.m_cellSize
end


-------------------------------------
-- function increaseVisibleCnt
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:increaseVisibleCnt()
    self.m_visibleRefCnt = (self.m_visibleRefCnt + 1)
end

-------------------------------------
-- function decreaseVisibleCnt
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:decreaseVisibleCnt()
    self.m_visibleRefCnt = (self.m_visibleRefCnt - 1)

    if (self.m_visibleRefCnt <= 0) then
        self.root:setVisible(self.m_bOrgVisible)
    end
end

-------------------------------------
-- function setVisible
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:setVisible(visible)
    self.m_bOrgVisible = visible

    if (self.m_visibleRefCnt <= 0) then
        self.root:setVisible(visible)
    else
        self.root:setVisible(true)
    end
end