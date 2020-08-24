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

    self:initUI(event_id)
    self:initButton()
    self:refresh()

    -- ���� �ݹ�
    local function success_cb(ret)
        self.m_lMessage = {}
        self.m_messageIdx = 0
        self.m_messageTimer = 0 
        self.m_lMessagePosY = {}
        self.m_effectTimer = 0
        
        --[[
        table.insert(self.m_lMessage, {table = {msg='Congrats guys and gals!', nickname='69mort69'}})
        table.insert(self.m_lMessage, {table = {msg='���Ҵ����ǪȪ�~~', nickname='����'}})
        table.insert(self.m_lMessage, {table = {msg='Well done guys on the great game', nickname='Isilwyn'}})
        table.insert(self.m_lMessage, {table = {msg='1�ֳ� �����ؿ� �ٸ� �̺�Ʈ �� �غ��ؼ� ������ ���� �þ��', nickname='������'}})
        table.insert(self.m_lMessage, {table = {msg='Congratz! Enjoying playing this game!', nickname='Agnus'}})
        table.insert(self.m_lMessage, {table = {msg='���� ���� �帰�̰� �ɰԿ�', nickname='����'}})
        table.insert(self.m_lMessage, {table = {msg='Great design and content. Keep it up devs!', nickname='Sazon'}})
        table.insert(self.m_lMessage, {table = {msg="Congratulations guys. You've earned it by giving such a good game. Keep it up.", nickname='Launna'}})
        table.insert(self.m_lMessage, {table = {msg='Felicidades que todo siga prosperando ', nickname='Soulflayer'}})
        table.insert(self.m_lMessage, {table = {msg='�������� �󸶾ȵ����� �±�!!��վ��', nickname='�ع̸�'}})
        --]]

        self.m_lMessage = ret['messages'] or {}

        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end

    -- @mskim 2020.08.24
    -- attendance_event�� �����ڷ� ���� number id�� ����ϴµ� ���ϸ޼��� ������ ����Ű�� ����� �� ����.
    -- Ŭ������ �и������� �ϵ��ڵ��ص� ������ ������ ����
    self:request_getCelebrateMsg(success_cb, '3rd_anniversary')
end