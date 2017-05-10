-------------------------------------
-- class ChatContent
-- @brief
-------------------------------------
ChatContent = class({
        m_uuid = 'string',
        m_timestamp = 'Timastamp',
        
        m_contentCategory = 'string',
        -- 'general' �Ϲ� ä��
        -- 'guild' ��� ä��
        -- 'whisper' �ӼӸ� ä��

        m_contentType = 'string',
        -- 'my_msg' �� �޼���
        -- 'msg' �Ϲ� �޼��� (�ٸ� ����� �޼���)

        nickname = '',
        guild = '',
        uid = '',
        message = '',
        did = '',

        m_dragonID = '',
        m_dragonEvolution = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ChatContent:init(data)

    -- �ܺο��� ���޹��� data ���̺�� �ʱ�ȭ
    if data then
        self:applyTableData(data)
    end

    -- uuid ����
    if (not self.m_uuid) then
        self.m_uuid = self:uuid()
    end

    -- timestamp ����
    if (not self.m_timestamp) then
        self.m_timestamp = socket.gettime()
    end

    if self.did then
        local l_str = pl.stringx.split(self.did, ';')
        self.m_dragonID = tonumber(l_str[1]) or 120011
        self.m_dragonEvolution = tonumber(l_str[2]) or 1
    end
end

ChatContent.replacement = {
        --['uid'] = 'm_uid',
        --['did'] = 'm_did',
        --['message'] = 'm_message',
        --['nickname'] = 'm_nickname',
    }

-------------------------------------
-- function applyTableData
-- @breif �ܼ� ������ table���� struct�� �ɹ� ������ �����ϴ� �Լ�
-------------------------------------
function ChatContent:applyTableData(data)
    --ccdump(data)
    -- �������� key���� �ٿ��� �� ��찡 �־ ��ȯ���ش�
    local replacement = ChatContent.replacement

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function uuid
-- @breif
-------------------------------------
function ChatContent:uuid()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

-------------------------------------
-- function setContentCategory
-- @breif
-------------------------------------
function ChatContent:setContentCategory(category)
    self.m_contentCategory = category
end

-------------------------------------
-- function getContentCategory
-- @breif
-------------------------------------
function ChatContent:getContentCategory()
    return self.m_contentCategory
end

-------------------------------------
-- function setContentType
-- @breif
-------------------------------------
function ChatContent:setContentType(type)
    self.m_contentType = type
end

-------------------------------------
-- function getContentType
-- @breif
-------------------------------------
function ChatContent:getContentType(type)
    return self.m_contentType
end


-------------------------------------
-- function getUserInfoStr
-- @breif ���, ����, �г���
-------------------------------------
function ChatContent:getUserInfoStr()
    return self['nickname'] or ''
end

-------------------------------------
-- function getMessage
-- @breif
-------------------------------------
function ChatContent:getMessage()
    return self['message'] or ''
end

-------------------------------------
-- function makeTimeDesc
-- @breif
-------------------------------------
function ChatContent:makeTimeDesc()
    local curr_time = socket.gettime()

    local sec = curr_time - self.m_timestamp

    local showSeconds = false
    local firstOnly = true
    local desc = datetime.makeTimeDesc(sec, showSeconds, firstOnly)
    return desc
end