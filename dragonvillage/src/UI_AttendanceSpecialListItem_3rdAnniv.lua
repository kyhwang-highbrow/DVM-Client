local PARENT = UI_AttendanceSpecialListItem_1st

-------------------------------------
-- class UI_AttendanceSpecialListItem_3rdAnniv
-- @brief 3주년 출석 이벤트
-------------------------------------
UI_AttendanceSpecialListItem_3rdAnniv = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceSpecialListItem_3rdAnniv:init(t_item_data, event_id)
    local vars = self:load('event_attendance_1st_anniversary.ui')
    cclog('UI_AttendanceSpecialListItem_3rdAnniv')
    self:initUI(event_id)
    self:initButton()
    self:refresh()

    -- 성공 콜백
    local function success_cb(ret)
        ccdump(ret)
        cclog(event_id)
        self.m_lMessage = {}
        self.m_messageIdx = 0
        self.m_messageTimer = 0 
        self.m_lMessagePosY = {}
        self.m_effectTimer = 0
        ----[[
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

--            self.m_lMessage = ret['messages'] or {}

        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end
    self:request_getCelebrateMsg(success_cb, event_id)
end