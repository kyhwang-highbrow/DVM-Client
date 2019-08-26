local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AttendanceSpecialListItem_1st
-------------------------------------
UI_AttendanceSpecialListItem_1st = class(PARENT, {
        m_tItemData = 'table',
        m_lMessage = '',
        m_messageIdx = '',
        m_messageTimer = '',
        m_lMessagePosY = '',
        m_effectTimer = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem_1st:init(t_item_data, event_id)
    self.m_tItemData = t_item_data

    local vars = self:load('event_attendance_1st_anniversary.ui')

    self:initUI()
    self:initButton()
    self:refresh()

    if (event_id == '1st_event') then
        -- 성공 콜백
        local function success_cb(ret)
            self.m_lMessage = {}
            self.m_messageIdx = 0
            self.m_messageTimer = 0 
            self.m_lMessagePosY = {}
            self.m_effectTimer = 0
            --[[
            table.insert(self.m_lMessage, {msg='Congrats guys and gals!', nickname='69mort69'})
            table.insert(self.m_lMessage, {msg='一周年おめでとう~~', nickname='汪太'})
            table.insert(self.m_lMessage, {msg='Well done guys on the great game', nickname='Isilwyn'})
            table.insert(self.m_lMessage, {msg='1주년 축하해요 다른 이벤트 잘 준비해서 유저들 많이 늘어나길', nickname='레오플'})
            table.insert(self.m_lMessage, {msg='Congratz! Enjoying playing this game!', nickname='Agnus'})
            table.insert(self.m_lMessage, {msg='이제 착한 드린이가 될게요', nickname='남작'})
            table.insert(self.m_lMessage, {msg='Great design and content. Keep it up devs!', nickname='Sazon'})
            table.insert(self.m_lMessage, {msg="Congratulations guys. You've earned it by giving such a good game. Keep it up.", nickname='Launna'})
            table.insert(self.m_lMessage, {msg='Felicidades que todo siga prosperando ', nickname='Soulflayer'})
            table.insert(self.m_lMessage, {msg='시작한지 얼마안됫지만 굿굿!!재밌어요', nickname='해미메'})
            --]]

            self.m_lMessage = ret['messages'] or {}

            self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
        end
        self:request_getCelebrateMsg(success_cb)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecialListItem_1st:initUI()
    local vars = self.vars
    local data = self.m_tItemData

    for i = 1,7 do
        if (vars['rewardNode' .. i]) then
            local ui = UI_AttendanceSpecialListItem_1stItem(data['step_list'][i])
            local cur_step = i
            ui:setTodayStep(data['today_step'], cur_step)
            vars['rewardNode' .. i]:addChild(ui.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceSpecialListItem_1st:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceSpecialListItem_1st:refresh()
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_AttendanceSpecialListItem_1st:update(dt)
    self.m_messageTimer = (self.m_messageTimer - dt)
    local cooltime = 0.3
    if (self.m_messageTimer <= 0) then
        self.m_messageTimer = (self.m_messageTimer + cooltime)
        self:rolling()
    end


    self.m_effectTimer = (self.m_effectTimer - dt)
    if (self.m_effectTimer <= 0) then
        local cooltime_effect = math_random(8, 20) / 10
        self.m_effectTimer = (self.m_effectTimer + cooltime_effect)

        -- 이펙트 생성
        local vars = self.vars
        local res = 'res/effect/effect_billbord_light/effect_billbord_light.spine'
        local animator = MakeAnimator(res)
        animator:changeAni('light_1', true) -- light_2
        local i = math_random(1, 10)
        vars['light' .. string.format('%.2d', i)]:addChild(animator.m_node)
        animator:addAniHandler(function() animator:runAction(cc.RemoveSelf:create()) end)
    end
end

-------------------------------------
-- function rolling
-- @brief
-------------------------------------
function UI_AttendanceSpecialListItem_1st:rolling()

    if (6 <= table.count(self.m_lMessagePosY)) then
        return
    end

    self.m_messageIdx = (self.m_messageIdx + 1)
    local msg_cnt = table.count(self.m_lMessage)
    if (msg_cnt < self.m_messageIdx) then
        self.m_messageIdx = 1
    end

    local parent_width = 836
    local parent_height = 218

    local t_data = self.m_lMessage[self.m_messageIdx]

    local font_name = Translate:getFontPath()
    local font_size = math_random(18, 35)
    local stroke_tickness = 1
    local dimension = cc.size(2000, 100)

    local text = t_data['msg'] .. ' -' .. t_data['nickname'] .. '-'

    local l_color = {}
    table.insert(l_color, cc.c4b(255,0,240, 255))
    table.insert(l_color, cc.c4b(255,138,0, 255))
    table.insert(l_color, cc.c4b(0,252,255, 255))
    table.insert(l_color, cc.c4b(216,255,0, 255))
    table.insert(l_color, cc.c4b(0,108,255, 255))
    table.insert(l_color, cc.c4b(255,234,0, 255))
    table.insert(l_color, cc.c4b(255,0,168, 255))
    table.insert(l_color, cc.c4b(255,0,108, 255))
    table.insert(l_color, cc.c4b(216,0,255, 255))
    table.insert(l_color, cc.c4b(0,150,255, 255))
    table.insert(l_color, cc.c4b(0,255,204, 255))
    table.insert(l_color, cc.c4b(0,255,138, 255))
    table.insert(l_color, cc.c4b(0,255,54, 255))
    table.insert(l_color, cc.c4b(255,252,0, 255))
    table.insert(l_color, cc.c4b(255,78,0, 255))
    table.insert(l_color, cc.c4b(255,24,0, 255))
    local color = l_color[math_random(1, table.count(l_color))]

    local label = cc.Label:createWithTTF(text, font_name, font_size, stroke_tickness, dimension, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    --label:setTextColor(cc.c4b(240, 215, 159, 255))
    label:setTextColor(color)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))

    local string_width = label:getStringWidth()

    local start_x = (parent_width/2) + (string_width/2)
    if (math_random(1, 2) == 1) then
        start_x = -start_x
    end
    
    local y_idx = nil
    for i=1, 6 do
        if (not self.m_lMessagePosY[i]) then
            y_idx = i
            self.m_lMessagePosY[y_idx] = true
            break
        end
    end
    
    local l_pos = getSortPosList((parent_height / 6), 6)
    local pos_y = l_pos[y_idx]
    label:setPositionY(pos_y)
    label:setPositionX(start_x)

    local time = math_random(6, 12)    
    local move_action = cc.MoveTo:create(time, cc.p(-start_x, pos_y))
    local call_func = cc.CallFunc:create(function() self.m_lMessagePosY[y_idx] = nil end)
    local sequence = cc.Sequence:create(move_action, call_func, cc.RemoveSelf:create())
    label:runAction(sequence)

    local vars = self.vars
    vars['neonClippingNode']:addChild(label)
end

-------------------------------------
-- function request_getCelebrateMsg
-------------------------------------
function UI_AttendanceSpecialListItem_1st:request_getCelebrateMsg(success_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_celebrate_msg')
    ui_network:setParam('uid', uid)
    ui_network:setParam('size', 50)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end


















local PARENT = UI

-------------------------------------
-- class UI_AttendanceSpecialListItem_1stItem
-------------------------------------
UI_AttendanceSpecialListItem_1stItem = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem_1stItem:init(t_item_data)
    self.m_tItemData = t_item_data

    local vars = self:load('event_attendance_1st_anniversary_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceSpecialListItem_1stItem:initUI()
    local vars = self.vars
    local t_item_data = self.m_tItemData

    local item_id = t_item_data['item_id']
    local item_cnt = t_item_data['value']
    
    -- 아이콘
    local item_icon = IconHelper:getItemIcon(item_id, nil)
    vars['itemNode']:addChild(item_icon)
    
    -- 이름
    local item_name = TableItem():getValue(item_id, 't_name')
    local name = UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
    vars['quantityLabel']:setString(name)
    
    -- 아이템 설명
    if vars['dscLabel'] then
    	local desc = TableItem:getItemDesc(item_id)
    	vars['dscLabel']:setString(desc)
    end

    vars['dayLabel']:setString(Str('{1}일 차', t_item_data['step']))
end

-------------------------------------
-- function setTodayStep
-------------------------------------
function UI_AttendanceSpecialListItem_1stItem:setTodayStep(today_step, cur_step)
    local vars = self.vars

    if (not today_step) then
        return
    end

    if (today_step == '') then
        return
    end

    -- 수령 표시
    if (cur_step <= tonumber(today_step)) then
        vars['checkSprite']:setVisible(true)
    end
end