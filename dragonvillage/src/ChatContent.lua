-------------------------------------
-- class ChatContent
-- @brief
-------------------------------------
ChatContent = class({
        m_uuid = 'string',
        m_timestamp = 'Timastamp',
        
        m_contentCategory = 'string',
        -- 'general' 일반 채팅
        -- 'guild' 길드 채팅
        -- 'whisper' 귓속말 채팅

        m_contentType = 'string',
        -- 'my_msg' 내 메세지
        -- 'msg' 일반 메세지 (다른 사람들 메세지)

        channelName = 'string',
        nickname = '',
        level = 'number',
        guild = '',
        uid = '',
        message = '',
        did = '',
        transform = '',
        json = 'string',
        profile_frame = 'number',
        profile_frame_expired_at = 'number',

        -- 귓속말에서 사용
        to = '',
        to_did = '',
        to_level = 'number',

        -- 공통
        status = '',

        m_dragonID = '',
        m_dragonEvolution = '',

        m_dragonSkinID = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ChatContent:init(data)
    -- 외부에서 전달받은 data 테이블로 초기화
    if data then
        self:applyTableData(data)
    end

    -- uuid 지정
    if (not self.m_uuid) then
        self.m_uuid = self:uuid()
    end

    -- timestamp 저장
    if (not self.m_timestamp) then
        self.m_timestamp = socket.gettime()
    end

    if self.did then
        local l_str = pl.stringx.split(self.did, ';')
        self.m_dragonID = tonumber(l_str[1]) or 120011
        self.m_dragonEvolution = tonumber(l_str[2]) or 1
        self.m_dragonSkinID = tonumber(l_str[4]) or 0
    end
end

ChatContent.replacement = {
        ['content_category'] = 'm_contentCategory',
        --['did'] = 'm_did',
        --['message'] = 'm_message',
        --['nickname'] = 'm_nickname',
    }

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function ChatContent:applyTableData(data)
    --ccdump(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
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
function ChatContent:getContentType()
    return self.m_contentType
end

-------------------------------------
-- function setChannelName
-- @breif
-------------------------------------
function ChatContent:setChannelName(channel_name)
    self['channelName'] = channel_name
end

-------------------------------------
-- function getChannelName
-- @breif
-------------------------------------
function ChatContent:getChannelName()
    return self['channelName']
end

-------------------------------------
--- @function getProfileFrame
--- @breif 프로필 프레임
-------------------------------------
function ChatContent:getProfileFrame()
    if self:isProfileFrameExpired() == true then
        return 0
    end

    return self['profile_frame'] or 0
end

-------------------------------------
--- @function isProfileFrameExpired
--- @breif 프로필 프레임 만료기간 체크
-------------------------------------
function ChatContent:isProfileFrameExpired()
    local expired_at = self['profile_frame_expired_at'] or 0
    if expired_at == 0 then
        return false
    end

    local curr_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    return curr_time > expired_at
end

-------------------------------------
--- @function makeProfileFrameAnimator
--- @brief 프로필 프레임 에니메이터 생성
--- @return table
-------------------------------------
function ChatContent:makeProfileFrameAnimator()
    local profile_frame_id = 900002 --self:getProfileFrame()
    return IconHelper:getProfileFrameAnimator(profile_frame_id)
end

-------------------------------------
-- function getUserInfoStr
-- @breif 길드, 레벨, 닉네임
-------------------------------------
function ChatContent:getUserInfoStr()
    if (self:getContentCategory() == 'whisper') and (self:getContentType() == 'my_msg') then
        local nickname = self['to']
        local level = self['to_level']
        local info_str = Str('Lv.{1} {2} {@C}◀', level, nickname)
        return info_str
    end

    
    local nickname = self['nickname']
    local level = self['level']
    local channelName = self['channelName']

    local info_str
    if (self:getContentCategory() == 'whisper') then
        info_str = Str('Lv.{1} {2}', level, nickname)
    elseif (self:getContentCategory() == 'clan') then
        info_str = Str('Lv.{1} {2}', level, nickname)
    else
        info_str = Str('Lv.{1} {2} {@C}(채널 {3})', level, nickname, channelName)
    end
    return info_str
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
    local desc = ServerTime:getInstance():makeTimeDescToSec(sec,showSeconds, firstOnly)
    return desc
end


-------------------------------------
-- function openUserInfoMini
-- @breif
-------------------------------------
function ChatContent:openUserInfoMini()
    local t_data = {}
    t_data['uid'] = self['uid']
    t_data['nickname'] = self['nickname']
    t_data['lv'] = self['level']
    t_data['leader_dragon_object'] = StructDragonObject({
        ['did']=self.m_dragonID, 
        ['evolution']=self.m_dragonEvolution, 
        ['dragon_skin']=self.m_dragonSkinID
    })

    local struct_user_info = StructUserInfo(t_data)

    UI_UserInfoMini:open(struct_user_info)
end