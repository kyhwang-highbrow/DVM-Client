local PARENT = UI_AttendanceSpecialListItem_1st

-------------------------------------
-- class UI_AttendanceSpecialListItem_3rdAnniv
-- @brief 3�ֳ� �⼮ �̺�Ʈ
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

    -- ���� �ݹ�
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
        table.insert(self.m_lMessage, {msg='���Ҵ����ǪȪ�~~', nickname='����'})
        table.insert(self.m_lMessage, {msg='Well done guys on the great game', nickname='Isilwyn'})
        table.insert(self.m_lMessage, {msg='1�ֳ� �����ؿ� �ٸ� �̺�Ʈ �� �غ��ؼ� ������ ���� �þ��', nickname='������'})
        table.insert(self.m_lMessage, {msg='Congratz! Enjoying playing this game!', nickname='Agnus'})
        table.insert(self.m_lMessage, {msg='���� ���� �帰�̰� �ɰԿ�', nickname='����'})
        table.insert(self.m_lMessage, {msg='Great design and content. Keep it up devs!', nickname='Sazon'})
        table.insert(self.m_lMessage, {msg="Congratulations guys. You've earned it by giving such a good game. Keep it up.", nickname='Launna'})
        table.insert(self.m_lMessage, {msg='Felicidades que todo siga prosperando ', nickname='Soulflayer'})
        table.insert(self.m_lMessage, {msg='�������� �󸶾ȵ����� �±�!!��վ��', nickname='�ع̸�'})
        --]]

--            self.m_lMessage = ret['messages'] or {}

        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end
    self:request_getCelebrateMsg(success_cb, event_id)
end